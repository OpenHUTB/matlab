classdef ( Sealed, Hidden )Assertion < simscape.battery.internal.sscinterface.StringItem




properties ( Constant )
Type = "Assertion";
end 

properties ( Access = private )
Condition;
ErrorMessage;
Action;
end 

methods 
function obj = Assertion( condition, diagnostic )


R36
condition string{ mustBeTextScalar, mustBeNonzeroLengthText }
diagnostic.ErrorMessage string{ mustBeTextScalar } = ""
diagnostic.Action string{ mustBeTextScalar, mustBeMember( diagnostic.Action, [ "error", "warn", "none", "" ] ) } = ""
end 

obj.Condition = condition;
obj.ErrorMessage = diagnostic.ErrorMessage;
obj.Action = diagnostic.Action;
end 
end 

methods ( Access = protected )

function children = getChildren( ~ )

children = [  ];
end 

function str = getOpenerString( obj )



assertionString = "assert(" + obj.Condition;


if obj.ErrorMessage ~= ""
assertionString = assertionString.append( "," );
newlineExpected = obj.IdealCharsPerLine <= assertionString.strlength;
assertionString( newlineExpected ) = assertionString( newlineExpected ).append( "...", newline );
assertionString = assertionString.append( "'", obj.ErrorMessage, "'" );
end 


if obj.Action ~= ""
assertionString = assertionString.append( ",Action = simscape.enum.assert.action.", obj.Action );
end 


assertionString = assertionString.append( ")" );
str = assertionString;
end 

function str = getTerminalString( ~ )

str = ";" + newline;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp4AdnuP.p.
% Please follow local copyright laws when handling this file.

