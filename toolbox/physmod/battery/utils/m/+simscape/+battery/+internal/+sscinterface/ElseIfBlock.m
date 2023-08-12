classdef ( Sealed, Hidden )ElseIfBlock < simscape.battery.internal.sscinterface.ConditionalBlock




properties ( Constant )
Type = "ElseIfBlock";
end 

properties ( Constant, Access = protected )
Operator = "elseif";
end 

properties ( Access = protected )
Condition
end 

methods 
function obj = ElseIfBlock( condition )


R36
condition string{ mustBeTextScalar, mustBeNonzeroLengthText }
end 

obj.Condition = condition;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpzEiOdm.p.
% Please follow local copyright laws when handling this file.

