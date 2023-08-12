classdef ( Sealed, Hidden )NodesSection < simscape.battery.internal.sscinterface.Section




properties ( Constant )
Type = "NodesSection";
end 

properties ( Constant, Access = protected )
SectionIdentifier = "nodes"
end 

methods 
function obj = NodesSection( attributeArguments )

R36
attributeArguments.Access string{ mustBeTextScalar, mustBeMember( attributeArguments.Access, [ "public", "private", "protected", "" ] ) } = ""
attributeArguments.ExternalAccess string{ mustBeTextScalar, mustBeMember( attributeArguments.ExternalAccess, [ "modify", "observe", "none", "" ] ) } = ""
end 
obj = obj.setAttribute( "Access", attributeArguments.Access );
obj = obj.setAttribute( "ExternalAccess", attributeArguments.ExternalAccess );
end 

function obj = addNode( obj, name, value, visualization )

R36
obj
name string{ mustBeTextScalar, mustBeNonzeroLengthText }
value string{ mustBeTextScalar, mustBeNonzeroLengthText }
visualization.Label string{ mustBeTextScalar } = ""
visualization.Location string{ mustBeTextScalar, mustBeMember( visualization.Location, [ "", "left", "right", "top", "bottom" ] ) } = ""
end 


if visualization.Location == ""
portAppearance = visualization.Label;
else 
portAppearance = visualization.Label.append( ":", visualization.Location );
end 


obj.SectionContent( end  + 1 ) = simscape.battery.internal.sscinterface.EqualityStatement( name, value, "Comment", portAppearance );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp9Y0ZqU.p.
% Please follow local copyright laws when handling this file.

