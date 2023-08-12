classdef ProductConstraint < cpopt.internal.constraints.GroupConstraintStrategy




properties 
Inputs
Out
Supported
end 

methods 
function obj = ProductConstraint( inputGroupInfos, pathItemGroupInfos, varargin )
blkObj = varargin{ 1 };
obj.Supported = false;
inputSpec = blkObj.Inputs;
if inputSpec == "2"
obj.Supported = true;
end 
stars = strfind( inputSpec, '*' );
if ~contains( inputSpec, '/' ) && length( stars ) == 2
obj.Supported = true;
end 

obj.Inputs = inputGroupInfos;
obj.Out = pathItemGroupInfos( '1' );
end 

function apply( obj, cpModel )
if obj.Supported
cpModel.addConstraint( cpopt.internal.ConstraintType.Product, { obj.Inputs{ 1 }.ID, obj.Inputs{ 2 }.ID }, { obj.Out.ID } );
else 
if obj.Out.isProposable(  )
cpModel.setVariable( obj.Out.ID, 1, 0 );
end 
for i = 1:length( obj.Inputs )
in = obj.Inputs{ i };
if in.isProposable(  )
cpModel.setVariable( in.ID, 1, 0 );
end 
end 
end 
end 

function redundant = isRedundant( obj )
redundant = obj.Out.isKnown(  );
for i = 1:length( obj.Inputs )
redundant = redundant && obj.Inputs{ i }.isKnown(  );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp8eBpeS.p.
% Please follow local copyright laws when handling this file.

