classdef ForLoop < simscape.battery.internal.sscinterface.StringItem





properties ( Constant )
Type = "ForLoop";
end 

properties ( Access = private )
SectionsContainer = simscape.battery.internal.sscinterface.SectionsContainer;
Index
Values
end 

methods 
function obj = ForLoop( index, values )

R36
index string{ mustBeTextScalar, mustBeNonzeroLengthText }
values string{ mustBeTextScalar, mustBeNonzeroLengthText }
end 
obj.Index = index;
obj.Values = values;
end 

function obj = addSection( obj, section )

obj.SectionsContainer = obj.SectionsContainer.addSection( section );
end 
end 

methods ( Access = protected )

function children = getChildren( obj )

children = obj.SectionsContainer.getContent;
end 

function str = getOpenerString( obj )

str = newline + "for " + obj.Index + " = " + obj.Values;
end 

function str = getTerminalString( ~ )

str = "end" + newline;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpY09bIJ.p.
% Please follow local copyright laws when handling this file.

