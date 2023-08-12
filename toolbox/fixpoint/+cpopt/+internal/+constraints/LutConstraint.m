classdef LutConstraint < cpopt.internal.constraints.GroupConstraintStrategy




properties 
Inputs
Breakpoints
Table
Output
Supported
end 

methods 
function obj = LutConstraint( inputGroupInfos, pathItemGroupInfos, varargin )
obj.Supported = true;



if pathItemGroupInfos.isKey( 'Table' )
obj.Table = pathItemGroupInfos( 'Table' );
else 
obj.Supported = false;
end 
obj.Output = pathItemGroupInfos( 'Output' );
obj.Inputs = inputGroupInfos;
end 

function apply( obj, cpModel )
if obj.Supported
cpModel.addConstraint( cpopt.internal.ConstraintType.Same, { obj.Table.ID }, { obj.Output.ID } );
else 


if ~obj.Output.isKnown(  )
cpModel.setVariable( obj.Output.ID, 1, 0 );
end 
end 
end 

function redundant = isRedundant( obj )
if ~obj.Supported
redundant = false;
else 
redundant = obj.Table.isKnown(  ) && obj.Output.isKnown(  );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp5ObMXG.p.
% Please follow local copyright laws when handling this file.

