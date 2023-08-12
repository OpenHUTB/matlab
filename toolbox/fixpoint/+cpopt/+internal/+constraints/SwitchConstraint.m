classdef SwitchConstraint < cpopt.internal.constraints.GroupConstraintStrategy



properties 
In1
In2
Out
end 

methods 
function obj = SwitchConstraint( inputGroupInfos, pathItemGroupInfos, varargin )
obj.Out = pathItemGroupInfos( '1' );
obj.In1 = inputGroupInfos{ 1 };
obj.In2 = inputGroupInfos{ 3 };
end 

function apply( obj, cpModel )
cpModel.addConstraint( cpopt.internal.ConstraintType.Same, { obj.In1.ID }, { obj.Out.ID } );
cpModel.addConstraint( cpopt.internal.ConstraintType.Same, { obj.In2.ID }, { obj.Out.ID } );
end 

function redundant = isRedundant( obj )
redundant = obj.In1.isKnown(  ) && obj.In2.isKnown(  ) && obj.Out.isKnown(  );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpwEoB_y.p.
% Please follow local copyright laws when handling this file.

