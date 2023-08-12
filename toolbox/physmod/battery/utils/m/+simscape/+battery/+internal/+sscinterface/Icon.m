classdef ( Sealed, Hidden )Icon < simscape.battery.internal.sscinterface.StringItem




properties ( Constant )
Type = "Icon";
end 

properties ( Access = private )
IconPath
end 

methods 
function obj = Icon( iconPath )


R36
iconPath string{ mustBeTextScalar, mustBeNonzeroLengthText }
end 

obj.IconPath = iconPath;
end 
end 

methods ( Access = protected )
function children = getChildren( ~ )

children = [  ];
end 

function str = getOpenerString( obj )



str = "Icon = '" + obj.IconPath + "'";
end 

function str = getTerminalString( ~ )

str = ";" + newline;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpkKNbKL.p.
% Please follow local copyright laws when handling this file.

