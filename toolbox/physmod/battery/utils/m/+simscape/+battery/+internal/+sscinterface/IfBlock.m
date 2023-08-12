classdef ( Sealed, Hidden )IfBlock < simscape.battery.internal.sscinterface.ConditionalBlock





properties ( Constant )
Type = "IfBlock";
end 

properties ( Constant, Access = protected )
Operator = "if";
end 

properties ( Access = protected )
Condition
end 

methods 
function obj = IfBlock( condition )

R36
condition string{ mustBeTextScalar, mustBeNonzeroLengthText }
end 

obj.Condition = condition;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpsBLf1G.p.
% Please follow local copyright laws when handling this file.

