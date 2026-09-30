// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


interface IERC20 { function transfer(address,uint256) external returns(bool); function transferFrom(address,address,uint256) external returns(bool); }


contract AgentTreasury {
 enum Status { None, Assigned, Submitted, Approved, Revision, Cancelled }
 struct Project { address creator; uint128 balance; uint64 deadline; bool closed; bytes32 metadataHash; }
 struct Department { address worker; uint128 budget; uint128 cost; Status status; bytes32 deliverableHash; }
 IERC20 public immutable usdc; uint256 public nextProjectId=1; uint256 private lockState=1;
 mapping(uint256=>Project) public projects; mapping(uint256=>mapping(bytes32=>Department)) public departments; mapping(uint256=>uint32) public pendingSubmissions;
 event ProjectCreated(uint256 indexed id,address indexed creator,bytes32 metadataHash,uint64 deadline);
 event ProjectFunded(uint256 indexed id,address indexed funder,uint256 amount);
 event DepartmentAssigned(uint256 indexed id,bytes32 indexed department,address indexed worker,uint256 budget);
 event WorkSubmitted(uint256 indexed id,bytes32 indexed department,bytes32 deliverableHash,uint256 cost);
 event RevisionRequested(uint256 indexed id,bytes32 indexed department);
 event WorkApproved(uint256 indexed id,bytes32 indexed department,address indexed worker,uint256 paid);
 event ProjectClosed(uint256 indexed id,uint256 refunded);
 error Unauthorized(); error InvalidInput(); error InvalidState(); error InsufficientBalance(); error TransferFailed();
 modifier creator(uint256 id){if(projects[id].creator!=msg.sender)revert Unauthorized();_;}
 modifier nonReentrant(){if(lockState!=1)revert InvalidState();lockState=2;_;lockState=1;}
 constructor(address token){if(token==address(0))revert InvalidInput();usdc=IERC20(token);}
 function createProject(bytes32 metadataHash,uint64 deadline) external returns(uint256 id){if(metadataHash==0||deadline<=block.timestamp)revert InvalidInput();id=nextProjectId++;projects[id]=Project(msg.sender,0,deadline,false,metadataHash);emit ProjectCreated(id,msg.sender,metadataHash,deadline);}
 function fundProject(uint256 id,uint128 amount) external nonReentrant {Project storage p=projects[id];if(p.creator==address(0)||p.closed||amount==0)revert InvalidState();p.balance+=amount;_pull(msg.sender,amount);emit ProjectFunded(id,msg.sender,amount);}
 function assignDepartment(uint256 id,bytes32 dept,address worker,uint128 budget) external creator(id){Project storage p=projects[id];Department storage d=departments[id][dept];if(p.closed||dept==0||worker==address(0)||budget==0)revert InvalidInput();if(d.status==Status.Submitted||d.status==Status.Approved)revert InvalidState();departments[id][dept]=Department(worker,budget,0,Status.Assigned,0);emit DepartmentAssigned(id,dept,worker,budget);}
 function submitWork(uint256 id,bytes32 dept,bytes32 hash,uint128 cost) external {Project storage p=projects[id];Department storage d=departments[id][dept];if(msg.sender!=d.worker)revert Unauthorized();if(p.closed||hash==0||cost==0||cost>d.budget)revert InvalidInput();if(d.status!=Status.Assigned&&d.status!=Status.Revision)revert InvalidState();d.deliverableHash=hash;d.cost=cost;d.status=Status.Submitted;pendingSubmissions[id]+=1;emit WorkSubmitted(id,dept,hash,cost);}
 function requestRevision(uint256 id,bytes32 dept) external creator(id){Department storage d=departments[id][dept];if(d.status!=Status.Submitted)revert InvalidState();d.status=Status.Revision;pendingSubmissions[id]-=1;emit RevisionRequested(id,dept);}
 function approveAndPay(uint256 id,bytes32 dept) external creator(id) nonReentrant {Project storage p=projects[id];Department storage d=departments[id][dept];if(p.closed||d.status!=Status.Submitted)revert InvalidState();if(p.balance<d.cost)revert InsufficientBalance();p.balance-=d.cost;d.status=Status.Approved;pendingSubmissions[id]-=1;_push(d.worker,d.cost);emit WorkApproved(id,dept,d.worker,d.cost);}
 function cancelDepartment(uint256 id,bytes32 dept) external creator(id){Department storage d=departments[id][dept];if(d.status!=Status.Assigned&&d.status!=Status.Revision)revert InvalidState();d.status=Status.Cancelled;}
 function closeProject(uint256 id) external creator(id) nonReentrant {Project storage p=projects[id];if(p.closed||pendingSubmissions[id]!=0)revert InvalidState();p.closed=true;uint128 refund=p.balance;p.balance=0;if(refund>0)_push(p.creator,refund);emit ProjectClosed(id,refund);}
 function _push(address to,uint256 amount) private {(bool ok,bytes memory data)=address(usdc).call(abi.encodeCall(IERC20.transfer,(to,amount)));if(!ok||(data.length>0&&!abi.decode(data,(bool))))revert TransferFailed();}
 function _pull(address from,uint256 amount) private {(bool ok,bytes memory data)=address(usdc).call(abi.encodeCall(IERC20.transferFrom,(from,address(this),amount)));if(!ok||(data.length>0&&!abi.decode(data,(bool))))revert TransferFailed();}
}

