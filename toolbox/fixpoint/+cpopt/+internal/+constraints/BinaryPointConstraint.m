classdef BinaryPointConstraint < cpopt.internal.constraints.GroupConstraintStrategy




properties 
GroupInfos
end 

methods 
function obj = BinaryPointConstraint( inputGroupInfos, pathItemGroupInfos, varargin )
obj.GroupInfos = [ inputGroupInfos, pathItemGroupInfos.values ];
end 

function apply( obj, cpModel )
for i = 1:length( obj.GroupInfos )
groupInfo = obj.GroupInfos{ i };
if groupInfo.isProposable(  )
cpModel.setVariable( groupInfo.ID, 1, 0 );
end 
end 
end 

function redundant = isRedundant( obj )
redundant = true;
for i = 1:length( obj.GroupInfos )
groupInfo = obj.GroupInfos{ i };
redundant = redundant && groupInfo.isKnown(  );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpUdnpgC.p.
% Please follow local copyright laws when handling this file.

