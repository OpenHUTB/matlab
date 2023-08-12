classdef ( Abstract, Hidden, AllowedSubclasses = { ?simscape.battery.internal.sscinterface.AnnotationsSection, ?simscape.battery.internal.sscinterface.BranchesSection, ?simscape.battery.internal.sscinterface.ComponentsSection ...
, ?simscape.battery.internal.sscinterface.ConnectionsSection, ?simscape.battery.internal.sscinterface.EquationsSection, ?simscape.battery.internal.sscinterface.IntermediatesSection,  ...
?simscape.battery.internal.sscinterface.InputsSection, ?simscape.battery.internal.sscinterface.NodesSection, ?simscape.battery.internal.sscinterface.OutputsSection,  ...
?simscape.battery.internal.sscinterface.ParametersSection, ?simscape.battery.internal.sscinterface.VariablesSection } ) ...
Section < simscape.battery.internal.sscinterface.StringItem




properties ( Abstract, Constant, Access = protected )
SectionIdentifier string{ mustBeTextScalar, mustBeNonzeroLengthText };
end 

properties ( Access = private )
Attributes( :, 2 )string{ mustBeText } = string.empty( 0, 2 );
end 

properties ( Access = protected )
SectionContent = simscape.battery.internal.sscinterface.StringItem.empty;
AccessAttribute string{ mustBeTextScalar } = "";
ExternalAccessAttribute string{ mustBeTextScalar } = "";
end 

methods ( Sealed )
function obj = addComment( obj, commentString )

obj.SectionContent( end  + 1 ) = simscape.battery.internal.sscinterface.Comment( commentString );
end 

function isEqual = eq( obj1, obj2 )

R36
obj1{ mustBeNonempty, mustBeScalarOrEmpty }
obj2{ mustBeVector, mustBeA( obj2, "simscape.battery.internal.sscinterface.Section" ) }
end 
isEqual = obj1.Type == [ obj2.Type ] &  ...
cellfun( @( attributes )isequal( attributes, obj1.Attributes ), { obj2.Attributes } );
isEqual = reshape( isEqual, size( obj2 ) );
end 

function sortedObj = sort( obj )

sectionTypes = reshape( [ obj.Type ], size( obj ) );
sectionOrder = [ "ParametersSection", "InputsSection", "OutputsSection", "NodesSection", "VariablesSection" ...
, "IntermediatesSection", "BranchesSection", "EquationsSection", "ComponentsSection", "ConnectionsSection", "AnnotationsSection" ];
[ ~, sectionTypeIndex ] = ismember( string( sectionTypes ), sectionOrder );
[ ~, sectionSortingOrder ] = sort( sectionTypeIndex );

sortedObj = obj( sectionSortingOrder );
end 
end 

methods 
function mergedSection = merge( sections )

R36
sections{ mustBeNonempty, mustBeVector }
end 
assert( all( sections( 1 ) == sections ), message( "physmod:battery:sscinterface:IncompatibleSectionsMerge" ) );
mergedSection = sections( 1 );
mergedSection.SectionContent = [ sections.SectionContent ];
end 
end 

methods ( Access = protected )
function children = getChildren( obj )

children = [ obj.SectionContent ];
end 

function str = getOpenerString( obj )



if ~isempty( obj.Attributes )
attributeEquations = join( obj.Attributes, "=" );
attributeDeclaration = "(" + join( attributeEquations, "," ) + ")";
else 
attributeDeclaration = "";
end 

str = newline + obj.SectionIdentifier + attributeDeclaration + newline;
end 

function str = getTerminalString( ~ )

str = "end" + newline;
end 

function obj = setAttribute( obj, attributeName, attributeValue )

R36
obj
attributeName string{ mustBeTextScalar, mustBeNonzeroLengthText }
attributeValue string{ mustBeTextScalar }
end 
if attributeValue ~= ""
isAttribute = obj.Attributes( :, 1 ) == attributeName;
if any( isAttribute )

obj.Attributes( isAttribute, 2 ) = attributeValue;
else 

obj.Attributes = [ obj.Attributes;attributeName, attributeValue ];
end 
else 

end 
end 

function obj = parseAttributeArguments( obj, attributeArguments )


R36
obj
attributeArguments.Access string{ mustBeTextScalar, mustBeMember( attributeArguments.Access, [ "public", "private", "protected", "" ] ) } = ""
attributeArguments.ExternalAccess string{ mustBeTextScalar, mustBeMember( attributeArguments.ExternalAccess, [ "modify", "observe", "none", "" ] ) } = ""
end 


obj.ExternalAccessAttribute = attributeArguments.ExternalAccess;
obj.AccessAttribute = attributeArguments.Access;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp7WzcNf.p.
% Please follow local copyright laws when handling this file.

