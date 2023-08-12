classdef ( Sealed, Hidden )Connection < simscape.battery.internal.sscinterface.StringItem




properties ( Constant )
Type = "Connection";
end 

properties ( Access = private )
SourcePort
DestinationPorts
end 

methods 
function obj = Connection( sourcePort, destinationPorts )


R36
sourcePort string{ mustBeTextScalar, mustBeNonzeroLengthText }
destinationPorts( 1, : )string{ mustBeText, mustBeNonzeroLengthText }
end 

obj.SourcePort = sourcePort;
obj.DestinationPorts = destinationPorts;
end 
end 

methods ( Access = protected )

function children = getChildren( ~ )

children = [  ];
end 

function str = getOpenerString( obj )

destinationString = join( obj.DestinationPorts, "," );
str = "connect(" + obj.SourcePort + "," + destinationString;
end 

function str = getTerminalString( ~ )

str = ");" + newline;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpLXxZmz.p.
% Please follow local copyright laws when handling this file.

