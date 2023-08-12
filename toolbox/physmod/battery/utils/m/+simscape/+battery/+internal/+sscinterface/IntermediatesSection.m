classdef ( Sealed, Hidden )IntermediatesSection < simscape.battery.internal.sscinterface.Section




properties ( Constant )
Type = "IntermediatesSection";
end 

properties ( Constant, Access = protected )
SectionIdentifier = "intermediates"
end 

methods 
function obj = IntermediatesSection( attributeArguments )

R36
attributeArguments.Access string{ mustBeTextScalar, mustBeMember( attributeArguments.Access, [ "public", "private", "protected", "" ] ) } = ""
attributeArguments.ExternalAccess string{ mustBeTextScalar, mustBeMember( attributeArguments.ExternalAccess, [ "modify", "observe", "none", "" ] ) } = ""
end 
obj = obj.setAttribute( "Access", attributeArguments.Access );
obj = obj.setAttribute( "ExternalAccess", attributeArguments.ExternalAccess );
end 

function obj = addEquation( obj, name, value, appearance )

R36
obj
name{ mustBeTextScalar, mustBeNonzeroLengthText }
value{ mustBeTextScalar, mustBeNonzeroLengthText }
appearance.DescriptiveName char{ mustBeTextScalar } = ""
end 

obj.SectionContent( end  + 1 ) = simscape.battery.internal.sscinterface.EqualityStatement( name, value, "Comment", appearance.DescriptiveName );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpuues6g.p.
% Please follow local copyright laws when handling this file.

