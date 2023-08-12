classdef CastConstraint < cpopt.internal.constraints.GroupConstraintStrategy




properties 
In
Out
end 

methods 
function obj = CastConstraint( inputGroupInfos, pathItemGroupInfos, varargin )
obj.In = inputGroupInfos{ 1 };
obj.Out = pathItemGroupInfos( '1' );
end 

function apply( obj, cpModel )
cpModel.addConstraint( cpopt.internal.ConstraintType.Same, { obj.In.ID }, { obj.Out.ID } );
end 

function redundant = isRedundant( obj )

redundant = obj.In.isKnown(  ) &&  ...
obj.Out.isKnown(  );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp1KM_bU.p.
% Please follow local copyright laws when handling this file.

