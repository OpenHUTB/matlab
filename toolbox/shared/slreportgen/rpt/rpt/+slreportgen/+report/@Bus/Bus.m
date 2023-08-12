classdef Bus < slreportgen.report.Reporter





































































































properties 





Object




































Title{ mlreportgen.report.validators.mustBeInstanceOfMultiClass( [ "function_handle", "string", "char", "mlreportgen.dom.Element" ], Title ) } = [  ];


































ReportedBlockType = "auto"

















IncludeNestedBuses{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = false;














ShowSignalHierarchy{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = false;









ShowSignalTable{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = true;













ShowBusObject{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = true;















ShowConnectedBlocks{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = true;











IncludeBusLinks{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = true;











IncludeBlockLinks{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = false;








IncludeSignalLinks{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = false;
















SelectorSignalProperties{ mustBeVector, mustBeText } = [ "Outport", "Name", "DataType", "Destination" ];

















CreatorSignalProperties{ mustBeVector, mustBeText } = [ "Inport", "Name", "DataType", "Source" ];







ShowEmptyColumns{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = false;




































SignalFilterFcn{ mlreportgen.report.validators.mustBeInstanceOfMultiClass( [ "function_handle", "string", "char" ], SignalFilterFcn ) } = [  ];













TableReporter









ListFormatter










ParagraphFormatter
end 

properties ( Constant, Hidden )

SupportedBlockTypes = [ "BusCreator", "BusSelector", "BusAssignment", "Inport", "Outport" ];

LabelTextStyle = "BusLabel";

MultiDestListStyle = "BusDestinationList";

TitleStyle = "BusTitle";
end 

properties ( SetAccess = private, Hidden )

ToSearch;

BlockTypes;

PortBlockTypes;

HashLinkIds;
end 

methods 
function this = Bus( varargin )
if nargin == 1

varargin = { "Object", varargin{ 1 } };
end 

this = this@slreportgen.report.Reporter( varargin{ : } );


p = inputParser;




p.KeepUnmatched = true;




addParameter( p, "TemplateName", "Bus" );

baseTable = mlreportgen.report.BaseTable;
baseTable.TableStyleName = "BusTable";
addParameter( p, "TableReporter", baseTable );

list = mlreportgen.dom.UnorderedList;
list.StyleName = "BusList";
addParameter( p, "ListFormatter", list );

para = mlreportgen.dom.Paragraph;
para.StyleName = "BusParagraph";
para.WhiteSpace = "preserve";
addParameter( p, "ParagraphFormatter", para );


parse( p, varargin{ : } );


results = p.Results;
this.TemplateName = results.TemplateName;
this.TableReporter = results.TableReporter;
this.ListFormatter = results.ListFormatter;
this.ParagraphFormatter = results.ParagraphFormatter;
end 

end 

methods 

function set.ReportedBlockType( this, value )


mustBeNonempty( value );


mustBeVector( value );
mustBeText( value );

str = string( value );


if ~isscalar( str ) || ~ismember( lower( str ), [ "all", "auto" ] )
if ~all( ismember( str, this.SupportedBlockTypes ) )
supportedBlkTypes = strjoin( this.SupportedBlockTypes, ", " );
error( message( "slreportgen:report:error:invalidBusBlockType", supportedBlkTypes ) );
end 
end 

this.ReportedBlockType = value;
end 

function set.TableReporter( this, value )


mustBeNonempty( value );

mustBeA( value, "mlreportgen.report.BaseTable" );

this.TableReporter = value;
end 

function set.ParagraphFormatter( this, value )


mustBeNonempty( value );

mustBeA( value, "mlreportgen.dom.Paragraph" );

this.ParagraphFormatter = value;
end 

function set.ListFormatter( this, value )


mustBeNonempty( value );

mustBeA( value, [ "mlreportgen.dom.UnorderedList", "mlreportgen.dom.OrderedList" ] );


if ~isempty( value.Children )
error( message( "slreportgen:report:error:nonemptyListFormatter" ) );
end 

this.ListFormatter = value;
end 

function impl = getImpl( this, rpt )
R36
this( 1, 1 )
rpt( 1, 1 ){ validateReport( this, rpt ) }
end 

if isempty( this.Object )

error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );
end 


if ~isempty( this.ListFormatter.Children )
error( message( "slreportgen:report:error:nonemptyListFormatter" ) );
end 

object = this.Object;
if isa( object, "mlreportgen.finder.Result" )
object = object.Object;
end 



type = mlreportgen.utils.safeGet( object, "Type", 'get_param' );
switch type{ 1 }
case { "block", "block_diagram" }
this.ToSearch = slreportgen.utils.getSlSfHandle( object );
case "port"


line = get_param( object, "Line" );
if line ==  - 1


connPorts = object;
else 
connPorts = [ get_param( line, "SrcPortHandle" ); ...
get_param( line, "DstPortHandle" ) ];
end 
parents = get_param( connPorts, "Parent" );



this.ToSearch = replaceSubsWithPortBlks( getSimulinkBlockHandle( parents ), connPorts );
otherwise 
error( message( "slreportgen:report:error:invalidBusReporterObject" ) );
end 

this.HashLinkIds = ~rpt.Debug;


modelH = slreportgen.utils.getModelHandle( bdroot( object ) );
compileModel( rpt, modelH );



impl = getImpl@slreportgen.report.Reporter( this, rpt );
end 

end 

methods ( Hidden )
function templatePath = getDefaultTemplatePath( ~, rpt )
path = slreportgen.report.Bus.getClassFolder(  );
templatePath =  ...
mlreportgen.report.ReportForm.getFormTemplatePath(  ...
path, rpt.Type );
end 

end 

methods ( Access = { ?mlreportgen.report.ReportForm, ?slreportgen.report.Bus } )

function content = getContent( this, rpt )


if isa( this.TemplateSrc, "slreportgen.report.internal.DocumentPart" )
baseDp = this.TemplateSrc;
else 
baseDp = slreportgen.report.internal.DocumentPart( rpt.Type, this.TemplateSrc, "BusDetails" );
end 


reportedBlks = findReportedBlocks( this, this.ToSearch );

nBlocks = numel( reportedBlks );
content = slreportgen.report.internal.DocumentPart.empty( 0, nBlocks );
for idx = 1:nBlocks
dp = slreportgen.report.internal.DocumentPart( baseDp, "BusDetails" );
openImpl( this, dp );

blkInfo = reportedBlks( idx );

if blkInfo.IsTopLevelPort



linkTargetObj = blkInfo.Blocks( 1 );
elseif blkInfo.IsPort

linkTargetObj = blkInfo.BusPortHandle;
else 
linkTargetObj = blkInfo.Blocks;
end 
linkTarget = mlreportgen.dom.LinkTarget( getBusDetailsLinkTargetID( this, linkTargetObj ) );
append( dp, linkTarget );


currHole = moveToNextHole( dp );
while ~strcmp( currHole, "#end#" )
switch currHole
case "Title"
holeContent = getTitle( this, blkInfo );
case "SignalHierarchy"
holeContent = getSignalHierarchy( this, blkInfo );
case "BusObject"
holeContent = getBusObject( this, blkInfo );
case "ConnectedBlocks"
holeContent = getConnectedBlocks( this, blkInfo );
case "SignalTable"
holeContent = getSignalTable( this, rpt, blkInfo );
end 
if iscell( holeContent )



for contentIdx = 1:numel( holeContent )
append( dp, holeContent{ contentIdx } );
end 
elseif isa( holeContent, "mlreportgen.report.Reporter" )
append( dp, getImpl( holeContent, rpt ) );
elseif ~isempty( holeContent )
append( dp, holeContent );
end 
currHole = moveToNextHole( dp );
end 

content( idx ) = dp;
end 
end 

function content = getTitle( this, blkInfo )



title = this.Title;
if isa( title, "function_handle" )
blk = blkInfo.Blocks;


if ~blkInfo.IsPort
blkStruct.BlockName = mlreportgen.utils.normalizeString( string( get_param( blk, "Name" ) ) );
blkStruct.BlockPath = mlreportgen.utils.normalizeString( string( getfullname( blk ) ) );
blkStruct.BusPortString = [  ];
else 
blkStruct.BlockPath = mlreportgen.utils.normalizeString( string( getfullname( get_param( blk( 1 ), "Parent" ) ) ) );
blkStruct.BlockName = mlreportgen.utils.normalizeString( string( get_param( blkStruct.BlockPath, 'Name' ) ) );
type = get_param( blk( 1 ), "blocktype" );
blkStruct.BusPortString = strcat( type, " ", get_param( blk( 1 ), "port" ) );
end 
blkStruct.PortHandle = blkInfo.BusPortHandle;


try 
title = title( blkStruct );
catch me
title = [  ];
warning( message( "slreportgen:report:warning:titleFcnError", me.message ) )
end 
end 

if ischar( title ) || isstring( title )
p = mlreportgen.dom.Paragraph( title, this.TitleStyle );
content = p;
else 
content = title;
end 


end 

function content = getSignalHierarchy( this, blkInfo )


content = [  ];
if this.ShowSignalHierarchy && blkInfo.BusPortHandle ~=  - 1
label = clone( this.ParagraphFormatter );
labelTxt = mlreportgen.dom.Text(  ...
getString( message( "slreportgen:report:Bus:busSignalHierarchy" ) ),  ...
this.LabelTextStyle );
labelTxt.WhiteSpace = "preserve";
append( label, labelTxt );
port = blkInfo.BusPortHandle;


sh = get_param( port, "SignalHierarchy" );
content = { label, getSignalHierarchyList( sh.Children, this.ListFormatter ) };
end 
end 

function content = getSignalTable( this, rpt, blkInfo )


content = {  };
if this.ShowSignalTable
blk = blkInfo.Blocks;


ph = get_param( blk, "PortHandles" );
if blkInfo.IsPort
if iscell( ph )
ph = [ ph{ : } ];
end 
if blkInfo.IsSelector
props = this.SelectorSignalProperties;
sigs = [ ph.Outport ];
type = "Inport";
else 
props = this.CreatorSignalProperties;
sigs = [ ph.Inport ];
type = "Outport";
end 


sigNames = string( get_param( blk, "Element" ) );

blkPath = get_param( blk( 1 ), "Parent" );


portNum = get_param( blk( 1 ), "port" );
portStr = strcat( ": ", type, " ", portNum );
else 


blkPath = blk;

portStr = "";
if blkInfo.IsSelector
props = this.SelectorSignalProperties;
sigs = ph.Outport;
sigNames = string( get_param( blk, "OutputSignals" ) );
sigNames = strsplit( sigNames, "," );
else 
props = this.CreatorSignalProperties;
sigs = ph.Inport;
type = get_param( blk( 1 ), "blocktype" );
if strcmp( type, "BusAssignment" )

sigNames = string( get_param( blk, "AssignedSignals" ) );
sigNames = strsplit( sigNames, "," );

sigNames = [ "(" + getString( message( "slreportgen:report:Bus:inputBus" ) ) + ")"; ...
sigNames' ];
else 


sh = get_param( ph.Outport, "SignalHierarchy" );
sigNames = string( { sh.Children.SignalName } );
end 
end 

end 


data = getSignalTableData( this, props, sigs, sigNames );

if ~isempty( data )
if ~this.ShowEmptyColumns

empty = cellfun( @isempty, data );
emptyCols = all( empty, 1 );
data( :, emptyCols ) = [  ];
props( emptyCols ) = [  ];
end 


tbl = copy( this.TableReporter );
ft = mlreportgen.dom.FormalTable( props, data );

blkName = mlreportgen.utils.normalizeString( get_param( blkPath, "Name" ) );
if this.IncludeBlockLinks
blkLink = mlreportgen.dom.InternalLink(  ...
slreportgen.utils.getObjectID( blkPath ), blkName );
appendTitle( tbl, blkLink );
signalsTxt = mlreportgen.dom.Text( strcat( portStr,  ...
" ", getString( message( "slreportgen:report:Bus:signals" ) ) ) );
signalsTxt.WhiteSpace = "preserve";
appendTitle( tbl, signalsTxt );
else 
appendTitle( tbl, strcat( blkName, portStr,  ...
" ", getString( message( "slreportgen:report:Bus:signals" ) ) ) );
end 
tbl.Content = ft;


titleReporter = getTitleReporter( tbl );
titleReporter.TemplateSrc = this;
if isChapterNumberHierarchical( this, rpt )
titleReporter.TemplateName = "BusHierNumberedTitle";
else 
titleReporter.TemplateName = "BusNumberedTitle";
end 
tbl.Title = titleReporter;

content = tbl;
end 
end 
end 

function content = getConnectedBlocks( this, blkInfo )



content = {  };
if this.ShowConnectedBlocks && blkInfo.BusPortHandle ~=  - 1
port = blkInfo.BusPortHandle;

line = get_param( port, "line" );
if line > 0
if blkInfo.IsSelector
connPorts = get_param( line, "SrcPortHandle" );
t = mlreportgen.dom.Text(  ...
getString( message( "slreportgen:report:Bus:sourceBlock" ) ) + ": ",  ...
this.LabelTextStyle );
t.WhiteSpace = "preserve";
else 
connPorts = get_param( line, "DstPortHandle" );
t = mlreportgen.dom.Text(  ...
getString( message( "slreportgen:report:Bus:destBlocks" ) ) + ": ",  ...
this.LabelTextStyle );
t.WhiteSpace = "preserve";
end 

content = createSourceDestDOM( this, connPorts, t );
end 

end 
end 

function content = getBusObject( this, blkInfo )


content = {  };
if this.ShowBusObject && blkInfo.BusPortHandle ~=  - 1


sh = get_param( blkInfo.BusPortHandle, "SignalHierarchy" );
if ~isempty( sh.BusObject )
labelTxt = mlreportgen.dom.Text(  ...
getString( message( "slreportgen:report:Bus:busObject" ) ) + ": ",  ...
this.LabelTextStyle );
labelTxt.WhiteSpace = "preserve";

busObjLink = mlreportgen.dom.InternalLink(  ...
mlreportgen.utils.normalizeLinkID( "bus-" + sh.BusObject ),  ...
sh.BusObject );

content = clone( this.ParagraphFormatter );
append( content, labelTxt );
append( content, busObjLink );
end 
end 
end 

end 

methods ( Access = private )
function blks = findReportedBlocks( this, toSearch )















blks = [  ];
blkTypes = string( this.ReportedBlockType );

if isscalar( blkTypes ) && strcmpi( blkTypes, "auto" )



if isscalar( toSearch ) &&  ...
strcmp( get_param( toSearch, "Type" ), "block" ) &&  ...
~ismember( get_param( toSearch, 'blocktype' ), [ "BusSelector", "Inport" ] )
this.BlockTypes = [ "BusCreator", "BusAssignment" ];
this.PortBlockTypes = "Outport";
else 
this.BlockTypes = "BusSelector";
this.PortBlockTypes = "Inport";
end 
elseif isscalar( blkTypes ) && strcmpi( blkTypes, "all" )

this.BlockTypes = [ "BusCreator", "BusSelector", "BusAssignment" ];
this.PortBlockTypes = [ "Inport", "Outport" ];
else 



inportIdx = strcmpi( blkTypes, "Inport" );
outportIdx = strcmpi( blkTypes, "Outport" );
this.PortBlockTypes = blkTypes( inportIdx | outportIdx );
blkTypes( inportIdx | outportIdx ) = [  ];
this.BlockTypes = blkTypes;
end 


if ~isempty( toSearch )
blks = searchBusBlocks( this, toSearch, [  ] );
end 
end 

function [ blkList, allReportedBlks ] = searchBusBlocks( this, toSearch, allReportedBlks )





blkList = [  ];

portBlkTypes = join( this.PortBlockTypes, "|" );
foundPortBlks = find_system( toSearch, "Regexp", 'on', "FindAll", 'on',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
"Type", "Block", "blocktype", portBlkTypes,  ...
"IsBusElementPort", 'on' );

blkTypes = join( this.BlockTypes, "|" );
foundOtherBlks = find_system( toSearch, "Regexp", 'on', "FindAll", 'on',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
"Type", "Block", "blocktype", blkTypes );

blks = [ foundPortBlks;foundOtherBlks ];


nBlks = numel( blks );
for idx = 1:nBlks
blk = blks( idx );

if ~ismember( blk, allReportedBlks )
type = get_param( blk, "blocktype" );
if endsWith( type, "port" )


portStr = get_param( blk, "Port" );
parent = get_param( blk, "Parent" );
relatedPorts = find_system( parent, "FindAll", 'on',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
"Type", "block", "blocktype", type, "IsBusElementPort", "on", "Port", portStr );

allReportedBlks = union( allReportedBlks, relatedPorts );


blkStruct.Blocks = relatedPorts;
blkStruct.IsPort = true;
blkStruct.IsTopLevelPort = slreportgen.utils.isModel( parent );

if ~blkStruct.IsTopLevelPort
portNum = str2double( portStr );
ph = get_param( parent, "PortHandles" );
end 
else 

allReportedBlks( end  + 1 ) = blk;%#ok<AGROW>

blkStruct.Blocks = blk;
blkStruct.IsPort = false;
blkStruct.IsTopLevelPort = false;

ph = get_param( blk, "PortHandles" );
portNum = 1;
end 


blkStruct.IsSelector = ismember( type, [ "BusSelector", "Inport" ] );
if blkStruct.IsTopLevelPort
blkStruct.BusPortHandle =  - 1;
else 
if blkStruct.IsSelector
blkStruct.BusPortHandle = ph.Inport( portNum );
else 
blkStruct.BusPortHandle = ph.Outport( portNum );
end 
end 


blkList = [ blkList;blkStruct ];%#ok<AGROW>

if this.IncludeNestedBuses



newToSearch = traceBlockPorts( blk, ~blkStruct.IsSelector );
[ newBlks, allReportedBlks ] = searchBusBlocks( this, newToSearch, allReportedBlks );
blkList = [ blkList;newBlks ];%#ok<AGROW>
end 
end 
end 

end 

function data = getSignalTableData( this, props, sigs, sigNames )


nSigs = numel( sigs );
nProps = numel( props );
data = cell( nSigs, nProps );
emptyRows = [  ];

for idx = 1:nSigs
sig = sigs( idx );
line = get_param( sig, "line" );

if isempty( this.SignalFilterFcn ) || ~isFilteredSignal( this.SignalFilterFcn, sig, line )

for propIdx = 1:nProps
prop = props( propIdx );
switch prop
case { "Inport", "Outport" }
val = string( idx );
if this.IncludeSignalLinks

sigID = slreportgen.report.Signal.getLinkTargetID( sig );
val = mlreportgen.dom.InternalLink( sigID, val );
end 
case "Name"
val = sigNames( idx );
case "Destination"

if line < 0
val = [  ];
else 
dsts = get_param( line, "DstPortHandle" );
val = createSourceDestDOM( this, dsts, [  ] );
end 

case "Source"

if line < 0
val = [  ];
else 
srcs = get_param( line, "SrcPortHandle" );
val = createSourceDestDOM( this, srcs, [  ] );
end 
otherwise 
val = slreportgen.utils.internal.getSignalProperty( sig, prop );
end 
data{ idx, propIdx } = val;
end 
else 
emptyRows( end  + 1 ) = idx;%#ok<AGROW>
end 
end 

data( emptyRows, : ) = [  ];
end 

function content = createSourceDestDOM( this, ports, prefix )




n = numel( ports );
blocks = get_param( ports, "Parent" );

if n == 0
content = {  };
elseif n == 1

if ~isempty( prefix )



content = clone( this.ParagraphFormatter );
append( content, prefix );
else 



content = mlreportgen.dom.Paragraph;
end 

name = mlreportgen.utils.normalizeString( get_param( blocks, "Name" ) );
blkLink = mlreportgen.dom.InternalLink(  ...
slreportgen.utils.getObjectID( blocks ),  ...
name );
append( content, blkLink );

if this.IncludeBusLinks && isReportedBlockType( this, blocks, ports )
appendBusDetailsLink( this, content, blocks, ports );
end 
else 

content = mlreportgen.dom.UnorderedList;
content.StyleName = this.MultiDestListStyle;
for idx = 1:n
blk = blocks{ idx };
para = mlreportgen.dom.Paragraph;
para.WhiteSpace = "preserve";

name = mlreportgen.utils.normalizeString( get_param( blk, "Name" ) );
blkLink = mlreportgen.dom.InternalLink(  ...
slreportgen.utils.getObjectID( blk ),  ...
name );
append( para, blkLink );

if this.IncludeBusLinks && isReportedBlockType( this, blk, ports( idx ) )
appendBusDetailsLink( this, para, blk, ports( idx ) );
end 

append( content, para );
end 
if ~isempty( prefix )


prefixDOM = clone( this.ParagraphFormatter );
append( prefixDOM, prefix );
content = { prefixDOM;content };
end 
end 
end 

function id = getBusDetailsLinkTargetID( this, targetObj )

blkType = mlreportgen.utils.safeGet( targetObj, 'BlockType', 'get_param' );
if endsWith( blkType{ 1 }, "port" )


parentId = slreportgen.utils.getObjectID( get_param( targetObj, "Parent" ) );
id = "bus-details-" + parentId + blkType{ 1 } + get_param( targetObj, "Port" );
else 
blkID = slreportgen.utils.getObjectID( targetObj, "Hash", false );
id = "bus-details-" + blkID;
end 

if this.HashLinkIds
id = mlreportgen.utils.normalizeLinkID( id );
end 
end 

function appendBusDetailsLink( this, domObj, blk, port )



type = get_param( blk, "BlockType" );

if strcmp( type, "Inport" )
parent = get_param( blk, "Parent" );
if slreportgen.utils.isModel( parent )


targetObj = blk;
else 


ph = get_param( parent, "PortHandles" );
portNum = str2double( get_param( blk, "Port" ) );
targetObj = ph.Inport( portNum );
end 
isSelector = true;
elseif strcmp( type, "Outport" )
parent = get_param( blk, "Parent" );
if slreportgen.utils.isModel( parent )


targetObj = blk;
else 


ph = get_param( parent, "PortHandles" );
portNum = str2double( get_param( blk, "Port" ) );
targetObj = ph.Outport( portNum );
end 
isSelector = false;
elseif strcmp( type, "SubSystem" )
targetObj = port;
isSelector = strcmp( get_param( port, "PortType" ), "inport" );
else 
targetObj = blk;
isSelector = strcmp( get_param( blk, "BlockType" ), "BusSelector" );
end 


if isSelector
linkText = getString( message( "slreportgen:report:Bus:signalsSelected" ) );
else 
linkText = getString( message( "slreportgen:report:Bus:busCreated" ) );
end 


link = mlreportgen.dom.InternalLink(  ...
getBusDetailsLinkTargetID( this, targetObj ),  ...
linkText );

append( domObj, " [" );
append( domObj, link );
append( domObj, "]" );
end 

function tf = isReportedBlockType( this, blk, port )




tf = false;
type = get_param( blk, "BlockType" );
if ismember( type, this.BlockTypes )


tf = true;
elseif ismember( type, this.PortBlockTypes )


tf = strcmp( "on", get_param( blk, "IsBusElementPort" ) );
elseif strcmp( type, "SubSystem" )


portType = mlreportgen.utils.capitalizeFirstChar( get_param( port, "porttype" ) );
if ismember( portType, this.PortBlockTypes )
portNum = num2str( get_param( port, "PortNumber" ) );
busElemBlks = find_system( blk, "SearchDepth", 1, "type", "block",  ...
"blocktype", portType, "Port", portNum, "IsBusElementPort", "on" );
tf = ~isempty( busElemBlks );
end 
end 
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








path = slreportgen.report.Bus.getClassFolder(  );
template = mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

function classFile = customizeReporter( toClasspath )









classFile = mlreportgen.report.ReportForm.customizeClass(  ...
toClasspath, "slreportgen.report.Bus" );
end 
end 
end 

function list = getSignalHierarchyList( sh, listFormatter )


list = clone( listFormatter );
nSignals = numel( sh );
for idx = 1:nSignals
sig = sh( idx );
li = mlreportgen.dom.ListItem( sig.SignalName );
if ~isempty( sig.Children )
subList = getSignalHierarchyList( sig.Children, listFormatter );
append( li, subList );
end 
append( list, li );
end 
end 

function blks = traceBlockPorts( blk, traceInports )


if traceInports
portType = "Inport";
else 
portType = "Outport";
end 
ports = slreportgen.utils.internal.traceBlockPorts( blk, portType );
blks = get_param( ports, "Parent" );


blks = replaceSubsWithPortBlks( getSimulinkBlockHandle( blks ), ports );

end 

function newBlks = replaceSubsWithPortBlks( blks, ports )



newBlks = blks;
blkTypes = get_param( blks, "blocktype" );
subIdx = find( strcmp( blkTypes, "SubSystem" ) );
nSubs = numel( subIdx );
for k = 1:nSubs
idx = subIdx( k );
portNum = num2str( get_param( ports( idx ), "portnumber" ) );
portType = mlreportgen.utils.capitalizeFirstChar( get_param( ports( idx ), "porttype" ) );
portBlks = find_system( blks( idx ),  ...
'MatchFilter', @Simulink.match.allVariants, "SearchDepth", 1,  ...
"FindAll", 'on', "Type", "block", "blocktype", portType, "Port", portNum );
newBlks( idx ) = portBlks( 1 );
end 
end 

function isFiltered = isFilteredSignal( signalFilterFcn, portHandle, line )



isFiltered = false;

parentPath = string( get_param( portHandle, "Parent" ) );
if line > 0
sourcePath = string( getfullname( get_param( line, "SrcBlockHandle" ) ) );
destinationPath = string( getfullname( get_param( line, "DstBlockHandle" ) ) );
else 
sourcePath = "";
destinationPath = "";
end 
try 
if isa( signalFilterFcn, 'function_handle' )
isFiltered = signalFilterFcn( portHandle, parentPath, sourcePath, destinationPath );
else 




eval( signalFilterFcn );
end 

catch me
warning( message( "mlreportgen:report:warning:filterFcnError", "SignalFilterFcn", me.message ) );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYrQlKn.p.
% Please follow local copyright laws when handling this file.

