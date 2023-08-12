classdef ( Sealed, Hidden = true )AnnotationsSection < simscape.battery.internal.sscinterface.Section




properties ( Constant )
Type = "AnnotationsSection";
end 

properties ( Constant, Access = protected )
SectionIdentifier = "annotations"
end 

methods 
function obj = AnnotationsSection(  )

end 

function obj = addExternalAccess( obj, externalAccess, componentMembers )




obj.SectionContent( end  + 1 ) = simscape.battery.internal.sscinterface.ExternalAccess( externalAccess, componentMembers );
end 

function obj = addUiLayout( obj, uiLayout )

R36
obj
uiLayout{ mustBeA( uiLayout, "simscape.battery.internal.sscinterface.UiLayout" ) }
end 


obj.SectionContent( end  + 1 ) = uiLayout;
end 

function obj = addPortLocation( obj, portNames, sideSpecification )



obj.SectionContent( end  + 1 ) = simscape.battery.internal.sscinterface.PortLocation( portNames, sideSpecification );
end 

function obj = setIcon( obj, iconPath )

iconIndex = string( [ obj.SectionContent.Type ] ) == simscape.battery.internal.sscinterface.Icon.Type;
if ~any( iconIndex )

obj.SectionContent( end  + 1 ) = simscape.battery.internal.sscinterface.Icon( iconPath );
else 

obj.SectionContent( iconIndex ) = simscape.battery.internal.sscinterface.Icon( iconPath );
end 
end 

function mergedSection = merge( sections )


R36
sections{ mustBeNonempty, mustBeVector }
end 

assert( all( sections( 1 ) == sections ), message( "physmod:battery:sscinterface:IncompatibleSectionsMerge" ) );


content = [ sections.SectionContent ];
contentType = [ content.Type ];
assert( nnz( contentType == simscape.battery.internal.sscinterface.Icon.Type ) < 2, message( "physmod:battery:sscinterface:MultipleIconsSpecified" ) );



isUiLayout = contentType == "UiLayout";
mergedContent = content( ~isUiLayout );
if ( any( isUiLayout ) )

uiLayout = content( isUiLayout ).merge;
mergedContent( end  + 1 ) = uiLayout;
else 

end 


mergedSection = sections( 1 );
mergedSection.SectionContent = mergedContent;
end 
end 

methods ( Access = protected )
function children = getChildren( obj )


sectionTypes = string( [ obj.SectionContent.Type ] );
children = [ obj.SectionContent( sectionTypes == "Comment" ),  ...
obj.SectionContent( sectionTypes == "PortLocation" ),  ...
obj.SectionContent( sectionTypes == "ExternalAccess" ),  ...
obj.SectionContent( sectionTypes == "UiLayout" ),  ...
obj.SectionContent( sectionTypes == "Icon" ) ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFaUPhG.p.
% Please follow local copyright laws when handling this file.

