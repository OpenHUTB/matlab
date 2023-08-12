classdef UnaryMinusConstraint < cpopt.internal.constraints.GroupConstraintStrategy




properties 
In
Out
end 

methods 
function obj = UnaryMinusConstraint( inputGroupInfos, pathItemGroupInfos, varargin )
obj.In = inputGroupInfos{ 1 };
obj.Out = pathItemGroupInfos( '1' );
end 

function apply( obj, cpModel )







if obj.In.isProposable(  )
cpModel.setVariableBias( obj.In.ID, 0.0 );
cpModel.setVariableBias( obj.Out.ID, 0.0 );
end 
end 

function redundant = isRedundant( obj )
redundant = obj.In.isKnown(  ) && obj.Out.isKnown(  );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpQAMifT.p.
% Please follow local copyright laws when handling this file.

