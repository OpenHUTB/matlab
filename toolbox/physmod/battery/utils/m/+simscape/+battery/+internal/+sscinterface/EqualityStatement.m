classdef ( Sealed, Hidden )EqualityStatement < simscape.battery.internal.sscinterface.StringItem




properties ( Constant )
Type = "EqualityStatement";
end 

properties ( Access = private )
Name
Value
Comment = "";
end 

methods 
function obj = EqualityStatement( name, value, statementDetails )


R36
name string{ mustBeTextScalar, mustBeNonzeroLengthText }
value string{ mustBeTextScalar, mustBeNonzeroLengthText }
statementDetails.Comment string{ mustBeTextScalar } = ""
end 

obj.Name = name;
obj.Value = value;
obj.Comment = statementDetails.Comment;
end 
end 

methods ( Access = protected )

function children = getChildren( ~ )

children = [  ];
end 

function str = getOpenerString( obj )

str = obj.Name.append( " = ", obj.Value );
end 

function str = getTerminalString( obj )



if obj.Comment ~= ""
str = "; % " + obj.Comment + newline;
else 
str = ";" + newline;
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpC41gZ5.p.
% Please follow local copyright laws when handling this file.

