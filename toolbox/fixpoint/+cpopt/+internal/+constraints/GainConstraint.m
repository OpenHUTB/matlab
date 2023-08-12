classdef GainConstraint < cpopt.internal.constraints.GroupConstraintStrategy




properties 
In
Gain
Out
end 

methods 
function obj = GainConstraint( inputGroupInfos, pathItemGroupInfos, varargin )
obj.In = inputGroupInfos{ 1 };
obj.Gain = pathItemGroupInfos( 'Gain' );
obj.Out = pathItemGroupInfos( '1' );
end 

function apply( obj, cpModel )
cpModel.addConstraint( cpopt.internal.ConstraintType.Product, { obj.In.ID, obj.Gain.ID }, { obj.Out.ID } );
end 

function redundant = isRedundant( obj )
redundant = obj.In.isKnown(  ) && obj.Gain.isKnown(  ) && obj.Out.isKnown(  );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp6VVz18.p.
% Please follow local copyright laws when handling this file.

