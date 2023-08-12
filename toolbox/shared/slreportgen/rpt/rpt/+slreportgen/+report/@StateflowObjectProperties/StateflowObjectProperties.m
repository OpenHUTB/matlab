classdef StateflowObjectProperties < slreportgen.report.ObjectPropertiesBase

































































properties 
























Object{ slreportgen.report.validators.mustBeStateflowObject( Object ) } = [  ];
end 

properties ( Access = protected )


HierNumberedTitleTemplateName = "StateflowObjPropHierNumberTitle";
NumberedTitleTemplateName = "StateflowObjPropNumberTitle";
ParaStyleName = "StateflowObjectPropertiesScript";
end 

methods 

function stateflowObjectProperties = StateflowObjectProperties( varargin )
if nargin == 1
varargin = [ { "Object" }, varargin ];
end 

stateflowObjectProperties =  ...
stateflowObjectProperties@slreportgen.report.ObjectPropertiesBase( varargin{ : } );

if ~mlreportgen.report.ReporterBase.isPropertySet( "PropertyTable", varargin )
defaultTable = mlreportgen.report.BaseTable;
defaultTable.TableStyleName = "StateflowObjectPropertiesContent";
defaultTable.TableWidth = '100%';
stateflowObjectProperties.PropertyTable = defaultTable;
end 

if ( isempty( stateflowObjectProperties.TemplateName ) )
stateflowObjectProperties.TemplateName = 'StateflowObjectProperties';
end 

end 

function impl = getImpl( stateflowObjectProperties, rpt )
R36
stateflowObjectProperties( 1, 1 )
rpt( 1, 1 ){ validateReport( stateflowObjectProperties, rpt ) }
end 

if isempty( stateflowObjectProperties.Object )
error( message( "slreportgen:report:error:noStateflowObjectSourceSpecified" ) );
else 

if isempty( stateflowObjectProperties.LinkTarget ) &&  ...
~isempty( stateflowObjectProperties.Object ) &&  ...
isValidTarget( stateflowObjectProperties )
stateflowObjectProperties.LinkTarget = slreportgen.utils.getObjectID( stateflowObjectProperties.Object );
end 

impl = getImpl@slreportgen.report.ObjectPropertiesBase( stateflowObjectProperties, rpt );
end 
end 
end 

methods ( Access = protected )

function content = getTableContent( stateflowObjectProperties, rpt )
handle = stateflowObjectProperties.Object;

compileModel( rpt, handle );
try 

objType = slreportgen.utils.getObjectType( handle );
dialogParam = getReportedProperties( stateflowObjectProperties, handle, objType );
catch 
content = [  ];
return ;
end 


nParams = numel( dialogParam );
content = cell( nParams, 2 );
emptyVals = false( nParams, 1 );
for i = 1:nParams
propName = dialogParam{ i };
returnRawValue = false;
[ propVal, emptyVals( i ) ] = getObjectProperty( stateflowObjectProperties, handle,  ...
objType, propName, returnRawValue );

content{ i, 1 } = propName;
content{ i, 2 } = propVal;
end 


if ~stateflowObjectProperties.ShowEmptyValues && nParams > 0
content = content( ~emptyVals, : );
end 

end 

function titleContent = getTableTitleString( stateflowObjectProperties )
objH = slreportgen.utils.getSlSfHandle( stateflowObjectProperties.Object );
obj = slreportgen.utils.getSlSfObject( objH );
objPath = strrep( obj.Path, newline, ' ' );
switch class( obj )
case 'Stateflow.Transition'
titleContent = string( objPath ) + "/" + strrep( obj.LabelString, newline, '' ) + " Properties";
case 'Stateflow.Junction'
titleContent = string( objPath ) + "/Junction" + num2str( obj.SSIdNumber );
case 'Stateflow.Annotation'
titleContent = string( objPath ) + "/" + mlreportgen.utils.getFirstLine( obj.Text ) + " Properties";
case 'Stateflow.Port'
titleContent = string( objPath ) + "/" + obj.PortType + ":" + strrep( obj.LabelString, newline, '' ) + " Properties";
otherwise 
objName = strrep( obj.Name, newline, ' ' );
titleContent = string( objPath ) + "/" + string( objName ) + " Properties";
end 
end 
end 

methods ( Access = { ?slreportgen.report.StateflowObjectProperties, ?slreportgen.finder.DiagramElementResult } )
function props = getReportedProperties( stateflowObjectProperties, handle, objType )
if isempty( stateflowObjectProperties.Properties )

dialogParams = slreportgen.utils.getStateflowObjectParameters( handle, objType );
props = [ "Type", string( dialogParams( : ) )' ];
else 

props = stateflowObjectProperties.Properties;
end 
end 

function [ val, isEmptyVal ] = getObjectProperty( stateflowObjectProperties, handle, objType, propName, returnRawVal )
if strcmpi( propName, "type" )
if strcmp( objType, 'State' )
val = strcat( handle.Type, " ", objType );
else 
val = objType;
end 
val = mlreportgen.dom.Paragraph( val );
isEmptyVal = false;
else 

normPropName = strrep( propName, " ", "" );
[ val, ~, isScript ] = slreportgen.utils.getStateflowObjectValue( handle, normPropName );


if iscell( val ) && ~isempty( val )
SLSFValue = fetchSLSFValue( stateflowObjectProperties, val );
if ~isempty( SLSFValue )
val = SLSFValue;
end 
end 

isEmptyVal = isEmptyPropValue( stateflowObjectProperties, val );


if ~returnRawVal && ( ~isEmptyVal || stateflowObjectProperties.ShowEmptyValues )
if isScript
val = mlreportgen.dom.Paragraph( val );
val.StyleName = simulinkObjectProperties.ParaStyleName;
val.WhiteSpace = "preserve";
else 
val = stateflowObjectProperties.fetchCellArrayValue( val );
end 
end 
end 
end 
end 

methods ( Access = protected, Hidden )


result = openImpl( reporter, impl, varargin )



function isTarget = isValidTarget( stateflowObjectProperties )
isTarget = true;
objType = slreportgen.utils.getObjectType( stateflowObjectProperties.Object );
if strcmp( objType, 'Chart' ) ||  ...
strcmp( objType, 'SLFunction' ) ||  ...
strcmp( objType, 'ActionState' ) ||  ...
strcmp( objType, 'SimulinkBasedState' ) ||  ...
strcmp( objType, 'Stateflow.AtomicSubchart' ) ||  ...
( strcmp( objType, 'State' ) && stateflowObjectProperties.Object.IsSubchart ) ||  ...
( strcmp( objType, 'Function' ) && stateflowObjectProperties.Object.IsSubchart ) ||  ...
( strcmp( objType, 'Box' ) && stateflowObjectProperties.Object.IsSubchart )
isTarget = false;
end 
end 

end 

methods ( Access = private, Hidden )

function stateFlowObjectValue = fetchSLSFValue( ~, blockDialogValue )
stateFlowObjectValue = {  };
for outerInd = 1:length( blockDialogValue )
if isa( blockDialogValue{ outerInd }, 'Stateflow.Object' ) || isa( blockDialogValue{ outerInd }, 'Simulink.Object' )
if isa( blockDialogValue{ outerInd }, 'Stateflow.Junction' )
for innerInd = 1:length( blockDialogValue{ outerInd } )
stateFlowObjectValue{ end  + 1 } = [ 'Junction', num2str( blockDialogValue{ outerInd }( innerInd ).SSIdNumber ) ];%#ok<AGROW>
end 
elseif isa( blockDialogValue{ outerInd }, 'Stateflow.Transition' )
for innerInd = 1:length( blockDialogValue{ outerInd } )
stateFlowObjectValue{ end  + 1 } = blockDialogValue{ outerInd }( innerInd ).LabelString;%#ok<AGROW>
end 
elseif isa( blockDialogValue{ outerInd }, 'Stateflow.Port' )
for innerInd = 1:length( blockDialogValue{ outerInd } )
stateFlowObjectValue{ end  + 1 } = blockDialogValue{ outerInd }( innerInd ).LabelString;%#ok<AGROW>
end 
else 
for innerInd = 1:length( blockDialogValue{ outerInd } )
stateFlowObjectValue{ end  + 1 } = blockDialogValue{ outerInd }( innerInd ).Name;%#ok<AGROW>
end 
end 
end 
end 
end 

function para = fetchCellArrayValue( ~, blockDialogValue )

if ( iscell( blockDialogValue ) )
value = char( mlreportgen.utils.toString( blockDialogValue ) );



if startsWith( value, '{' ) && endsWith( value, '}' )
value( 1 ) = '';
value( end  ) = '';
value = strtrim( value );
end 
para = mlreportgen.dom.Paragraph( string( value ) );
para.WhiteSpace = "preserve";
else 
para = string( blockDialogValue );
end 
end 


end 


methods ( Static )
function path = getClassFolder(  )

[ path ] = fileparts( mfilename( 'fullpath' ) );
end 

function template = createTemplate( templatePath, type )







path = slreportgen.report.StateflowObjectProperties.getClassFolder(  );
template = mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

function classfile = customizeReporter( toClasspath )












classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
"slreportgen.report.StateflowObjectProperties" );
end 

end 



end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpaoFOn0.p.
% Please follow local copyright laws when handling this file.

