classdef ( Sealed, Hidden )ExternalAccess < simscape.battery.internal.sscinterface.StringItem




properties ( Constant )
Type = "ExternalAccess";
end 

properties ( Access = private )
ExternalAccessIdentifier
ComponentMembers
end 

methods 
function obj = ExternalAccess( externalAccessIdentifier, componentMembers )


R36
externalAccessIdentifier string{ mustBeTextScalar, mustBeMember( externalAccessIdentifier, [ "modify", "observe", "none" ] ) }
componentMembers( 1, : )string{ mustBeNonzeroLengthText }
end 

obj.ExternalAccessIdentifier = externalAccessIdentifier;
obj.ComponentMembers = componentMembers;
end 
end 

methods ( Access = protected )

function children = getChildren( ~ )

children = [  ];
end 

function str = getOpenerString( obj )

memberSection = join( obj.ComponentMembers, "," );
if length( obj.ComponentMembers ) > 1

memberArray = "[" + memberSection + "]";
else 

memberArray = memberSection;
end 


str = memberArray.append( " : ExternalAccess=", obj.ExternalAccessIdentifier );
end 

function str = getTerminalString( ~ )

str = ";" + newline;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpG7zhta.p.
% Please follow local copyright laws when handling this file.

