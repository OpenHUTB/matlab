classdef ( Sealed, Hidden )Equation < simscape.battery.internal.sscinterface.StringItem




properties ( Constant )
Type = "Equation";
end 

properties ( Access = private )
Name
Value
end 

methods 
function obj = Equation( name, value )


R36
name string{ mustBeTextScalar, mustBeNonzeroLengthText }
value string{ mustBeTextScalar, mustBeNonzeroLengthText }
end 

obj.Name = name;
obj.Value = value;
end 
end 

methods ( Access = protected )

function children = getChildren( ~ )

children = [  ];
end 

function str = getOpenerString( obj )

statement = obj.Name.append( " == " );
newlineExpected = obj.IdealCharsPerLine <= statement.strlength;
statement( newlineExpected ) = statement( newlineExpected ).append( "...", newline );
str = statement.append( obj.Value );
end 

function str = getTerminalString( ~ )

str = ";" + newline;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpD1tbJl.p.
% Please follow local copyright laws when handling this file.

