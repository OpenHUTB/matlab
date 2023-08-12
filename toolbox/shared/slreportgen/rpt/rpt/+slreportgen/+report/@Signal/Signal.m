classdef Signal < slreportgen.report.ObjectPropertiesBase





















































































properties 





Object{ mustBeValidOutport( Object ) } = [  ];













ShowSimulinkSignalObject( 1, 1 )logical = true;





























MATLABVariableReporter{ mlreportgen.report.validators.mustBeInstanceOf(  ...
"mlreportgen.report.MATLABVariable", MATLABVariableReporter ) }
end 

properties ( Access = protected )



HierNumberedTitleTemplateName = "SignalHierNumberedTitle";
NumberedTitleTemplateName = "SignalNumberedTitle"
ParaStyleName = "";

DestinationListStyle = "SignalList";

HashLinkIds;
end 

methods 
function this = Signal( varargin )
if nargin == 1
varargin = [ { "Object" }, varargin ];
end 

this = this@slreportgen.report.ObjectPropertiesBase( varargin{ : } );




if isempty( this.Properties )
this.Properties = [ "Name", "Description", "Source", "NonvirtualDestination", "DataType" ];
end 


p = inputParser;




p.KeepUnmatched = true;




addParameter( p, "TemplateName", "Signal" );

defaultTable = mlreportgen.report.BaseTable;
defaultTable.TableStyleName = "SignalTable";
addParameter( p, "PropertyTable", defaultTable );

mlVar = mlreportgen.report.MATLABVariable(  );

mlVar.DepthLimit = 0;
addParameter( p, "MATLABVariableReporter", mlVar );


parse( p, varargin{ : } );


results = p.Results;
this.TemplateName = results.TemplateName;
this.PropertyTable = results.PropertyTable;
this.MATLABVariableReporter = results.MATLABVariableReporter;
end 

function impl = getImpl( this, rpt )
R36
this( 1, 1 )
rpt( 1, 1 ){ validateReport( this, rpt ) }
end 

if isempty( this.Object )
error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );
else 
this.HashLinkIds = ~rpt.Debug;


compileModel( rpt, this.Object );


if isempty( this.LinkTarget )
this.LinkTarget = slreportgen.report.Signal.getLinkTargetID( this.Object );
end 

impl = getImpl@slreportgen.report.ObjectPropertiesBase( this, rpt );
end 
end 
end 

methods ( Access = { ?mlreportgen.report.ReportForm, ?slreportgen.report.Signal } )

function content = getSignalObject( this, ~ )





content = [  ];
if this.ShowSimulinkSignalObject
object = this.Object;




if strcmp( get_param( object, "MustResolveToSignalObject" ), "on" )


objName = get_param( object, "Name" );
finder = slreportgen.finder.ModelVariableFinder( bdroot( object ) );
finder.Name = objName;
result = find( finder );

sigObj = getVariableValue( result );


linkID = getSignalObjectLinkID( this );
else 

sigObj = get_param( object, "SignalObject" );
linkID = [  ];
end 



if ~isempty( sigObj )
content = copy( this.MATLABVariableReporter );
content.Variable = "Signal Object";
setVariableValue( content, sigObj );
content.LinkTarget = linkID;
end 
end 
end 

end 

methods ( Access = protected )
function tableContent = getTableContent( this, ~ )





object = this.Object;
props = string( this.Properties );
line = get_param( object, "Line" );


nProps = numel( props );
tableContent = cell( nProps, 2 );
emptyRows = [  ];
for i = 1:nProps
prop = props( i );
switch lower( prop )
case "name"
name = get_param( object, "Name" );




if strcmp( get_param( object, "MustResolveToSignalObject" ), "on" )
if this.ShowSimulinkSignalObject
linkID = getSignalObjectLinkID( this );
else 

f = slreportgen.finder.ModelVariableFinder( bdroot( object ) );
f.Name = name;
r = find( f );
linkID = getVariableID( r );
end 

val = mlreportgen.dom.InternalLink(  ...
linkID, name );
else 
val = mlreportgen.utils.normalizeString( string( name ) );
end 
case { "destination", "nonvirtualdestination" }
val = createDestinationDOM( this, prop, line );
case { "source", "parent" }

val = createSrcOrDstPara( this, object );
otherwise 
val = slreportgen.utils.internal.getSignalProperty( object, prop );
if ~isempty( val ) && ~isa( val, "mlreportgen.dom.Element" )

val = mlreportgen.utils.toString( val );
end 
end 


if this.ShowEmptyValues || ~isEmptyPropValue( this, val )
tableContent{ i, 1 } = prop;
tableContent{ i, 2 } = val;
else 
emptyRows( end  + 1 ) = i;%#ok<AGROW>
end 
end 


tableContent( emptyRows, : ) = [  ];
end 

function titleContent = getTableTitleString( this, ~ )



object = this.Object;
portType = get_param( object, "PortType" );
portNum = get_param( object, "PortNumber" );
objParent = mlreportgen.utils.normalizeString( get_param( object, "Parent" ) );
titleContent = string( objParent ) + " " + mlreportgen.utils.capitalizeFirstChar( portType ) + ":" + portNum + " Properties";
end 
end 


methods ( Access = { ?slreportgen.report.Signal, ?slreportgen.finder.SignalResult } )
function para = createSrcOrDstPara( ~, port )



para = mlreportgen.dom.Paragraph;
para.WhiteSpace = "preserve";

blk = get_param( port, "Parent" );


blkName = mlreportgen.utils.normalizeString( getfullname( blk ) );


link = mlreportgen.dom.InternalLink( slreportgen.utils.getObjectID( blk ), blkName );
append( para, link );

portType = get_param( port, "PortType" );
str = " " + mlreportgen.utils.capitalizeFirstChar( portType );
if ismember( portType, [ "inport", "outport" ] )
portNum = get_param( port, "PortNumber" );
str = str + ": " + num2str( portNum );
else 

str = str + " Port";
end 
append( para, str );
end 

function destDOM = createDestinationDOM( this, prop, line )

if strcmpi( prop, "destination" )
dst = mlreportgen.utils.safeGet( line, "DstPortHandle", "get_param" );
else 
dst = mlreportgen.utils.safeGet( line, "NonVirtualDstPorts", "get_param" );
end 
dst = dst{ 1 };


if isscalar( dst )

destDOM = createSrcOrDstPara( this, dst );
else 

nDst = numel( dst );
destDOM = mlreportgen.dom.UnorderedList(  );
destDOM.StyleName = this.DestinationListStyle;
for k = 1:nDst
dstPara = createSrcOrDstPara( this, dst( k ) );
append( destDOM, dstPara );
end 
end 
end 
end 

methods ( Access = private )
function linkID = getSignalObjectLinkID( this )
sigID = slreportgen.utils.getObjectID( this.Object, "Hash", false );
linkID = sigID + "-signal-object";
if this.HashLinkIds
linkID = mlreportgen.utils.normalizeLinkID( linkID );
end 
end 
end 

methods ( Static, Hidden )
function id = getLinkTargetID( portHandle )





if ~strcmp( get_param( portHandle, 'porttype' ), 'outport' )
[ ~, portHandle, ~ ] = slreportgen.utils.traceSignal( portHandle, "NonVirtual", false );
end 
id = slreportgen.utils.getObjectID( portHandle );
end 
end 

methods ( Access = protected, Hidden )

result = openImpl( reporter, impl, varargin )
end 


methods ( Static )
function path = getClassFolder(  )


[ path ] = fileparts( mfilename( 'fullpath' ) );
end 

function template = createTemplate( templatePath, type )







path = slreportgen.report.Signal.getClassFolder(  );
template = mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

function classfile = customizeReporter( toClasspath )













classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
"slreportgen.report.Signal" );
end 

end 

end 



function mustBeValidOutport( value )


mustBeScalarOrEmpty( value );
if ~isempty( value ) &&  ...
( ~isValidSlObject( slroot, value ) ||  ...
~strcmp( get_param( value, "Type" ), "port" ) ||  ...
~strcmp( get_param( value, "porttype" ), "outport" ) )
error( message( "slreportgen:report:error:mustBeValidOutport" ) )
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpvZyLGm.p.
% Please follow local copyright laws when handling this file.

