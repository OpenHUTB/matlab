classdef PreLookup < slreportgen.report.Reporter





































































properties 



Object{ mustBePreLookupObject( Object ) } = [  ];






















DataReporter{ mustBeBaseTable( DataReporter ) } = [  ];










IncludeTable{ mustBeLogical } = true;





IncludePlot{ mustBeLogical } = true;






PlotType{ mustBeMember( PlotType, [ "Surface Plot", "Mesh Plot" ] ) } = "Surface Plot";


















PlotReporter{ mustBeFigure( PlotReporter ) } = [  ];
















MaxTableColumns{ mustBeValidMaxSize( MaxTableColumns ) } = Inf;

end 

properties ( Hidden, Access = public )
Content = [  ];
end 

properties ( Access = private )
src = [  ];
xLabel = [  ];
yLabel = [  ];
compilationError = false;


ShouldNumberTableHierarchically = [  ];


ReportOutputType;
end 

properties ( Constant, Access = private )
KnownErrorIdentifiers = [ "slreportgen:LUTDimensionMismatch", "slreportgen:UnResolvableExpression" ];
end 

methods 

function this = PreLookup( varargin )
if ( nargin == 1 )
args = [ { 'Object' }, varargin ];
else 
args = varargin;
end 

this = this@slreportgen.report.Reporter( args{ : } );





p = inputParser;




p.KeepUnmatched = true;

addParameter( p, "TemplateName", "PreLookup" );
addParameter( p, "DataReporter", mlreportgen.report.BaseTable );
addParameter( p, "PlotReporter", mlreportgen.report.Figure );
addParameter( p, "PlotType", "Surface Plot" );
addParameter( p, "MaxTableColumns", Inf );

parse( p, args{ : } );

this.TemplateName = p.Results.TemplateName;
this.DataReporter = p.Results.DataReporter;
this.PlotReporter = p.Results.PlotReporter;
this.MaxTableColumns = p.Results.MaxTableColumns;

end 

function set.Object( this, obj )
this.Object = obj;
createPreLookupSource( this );
end 


function impl = getImpl( h, rpt )
R36
h( 1, 1 )
rpt( 1, 1 ){ validateReport( h, rpt ) }
end 

impl = [  ];%#ok<NASGU>

setOutputType( h, rpt.Type );


if isempty( h.Object )
error( message( "slreportgen:report:error:noSourceObjectSpecified", class( h ) ) );
else 


if isempty( h.LinkTarget )



objH = slreportgen.utils.getSlSfHandle( h.Object );
parent = get_param( objH, "Parent" );
hs = slreportgen.utils.HierarchyService;
dhid = hs.getDiagramHID( parent );
parentPath = hs.getPath( dhid );

if ~isempty( parentPath )
parentPath = strrep( parentPath, newline, ' ' );
parentDiagram = getContext( rpt, parentPath );
if ~isempty( parentDiagram ) && ( parentDiagram.HyperLinkDiagram )
h.LinkTarget = slreportgen.utils.getObjectID( h.Object );
end 
end 
end 


modelH = slreportgen.utils.getModelHandle( h.Object );
compileModel( rpt, modelH );

h.ShouldNumberTableHierarchically = isChapterNumberHierarchical( h, rpt );
impl = getImpl@slreportgen.report.Reporter( h, rpt );
end 
end 
end 


methods ( Access = { ?mlreportgen.report.ReportForm } )

function preLookupTypesReporter = getPreLookupDataTypes( h, ~ )




preLookupTypesReporter = [  ];
if ( ~h.compilationError )
try 

dtProps = getLookupTableDataTypeProperties( h.src );

if ~isempty( dtProps )
tableHeader = { h.src.PropTableHeader,  ...
getString( message( "lutdesigner:PreLookupReporter:Value" ) ) };

table = mlreportgen.dom.FormalTable( tableHeader, dtProps );

titleStr = getPropertiesTableTitle( h.src );
dataTypeBaseTable = mlreportgen.report.BaseTable(  ...
"Title", titleStr,  ...
"Content", table );
dataTypeBaseTable.TableStyleName = "PreLookupDataTypeStyle";

if mlreportgen.report.Reporter.isInlineContent( dataTypeBaseTable.Title )
titleReporter = getTitleReporter( dataTypeBaseTable );
titleReporter.TemplateSrc = h;

if h.ShouldNumberTableHierarchically
titleReporter.TemplateName = 'PreLookupHierNumberedTitle';
else 
titleReporter.TemplateName = 'PreLookupNumberedTitle';
end 
dataTypeBaseTable.Title = titleReporter;
end 
preLookupTypesReporter = dataTypeBaseTable;
end 
catch 
warning( ME.identifier, "%s", ME.message );
end 
end 
end 

function content = getContent( h, rpt )
content = [  ];
if isInputSimulated( h.src )
simulatedContentStr = getBlockInputStr( h.src );
if ~strcmp( simulatedContentStr, "" )
simulatedContentHeading = mlreportgen.dom.Paragraph(  );
simulatedContentHeading.StyleName = "PreLookupSimulatedContentHeadingStyle";
simulatedHeadingStr = getDisplayLabel( h.src );
append( simulatedContentHeading, simulatedHeadingStr );

simulatedContent = mlreportgen.dom.Paragraph(  );
append( simulatedContent, simulatedContentStr );
simulatedContent.StyleName = "PreLookupSimulatedContentStyle";

content = { simulatedContentHeading, simulatedContent };
end 
else 
try 
breakPoints = getBreakPoints( h.src );
tableData = getTableData( h.src );
assertValidBreakPoints( h.src, breakPoints, tableData );

if ~isempty( tableData ) || ~isempty( breakPoints )



tableTitle = getTableTitle( h.src );
slicedData = makeMultiTable( h, breakPoints, tableData, tableTitle, [  ], 0, {  } );



slicedDataLength = numel( slicedData );
content = cell( 1, slicedDataLength );
for i = 1:slicedDataLength
documentPartObj = createDocPartObj( h, rpt, slicedData{ i } );
content{ i } = { documentPartObj };
end 
end 
catch ME
content = getCompilationErrorMessage( h, ME );
end 
end 
h.Content = content;

end 

function content = getFootNoteContent( h, rpt )%#ok<INUSD>

content = {  };
if ( ~h.compilationError )
try 
if ( h.IncludeTable ) || ( h.IncludePlot )
items = [  ...
getTableDataExpressionContent( h ) ...
, getBreakpointExpressionContent( h ) ...
, getLookupTableObjExpressionContent( h ) ...
, getBreakpointObjExpressionContent( h ) ...
, getEvenSpacingInfoContent( h ) ...
 ];

nItems = numel( items );
if ( nItems > 0 )
footNoteHeading = mlreportgen.dom.Paragraph(  );
append( footNoteHeading, getString( message( "lutdesigner:PreLookupReporter:Note" ) ) );
footNoteHeading.StyleName = "PreLookupFootNoteTitleStyle";

footNoteList = mlreportgen.dom.UnorderedList(  );
footNoteList.StyleName = "PreLookupFootNoteContentStyle";
for i = 1:nItems
append( footNoteList, items{ i } );
end 
content = { footNoteHeading, footNoteList };
end 
end 
catch ME
warning( ME.identifier, "%s", ME.message );
end 
end 
end 
end 
methods ( Access = private )

function compilationErrorContent = getCompilationErrorMessage( h, ME )
h.compilationError = true;
compilationErrorContent = {  };

compilationErrorContent{ 1 } = mlreportgen.dom.Paragraph(  );
compilationErrorContent{ 1 }.StyleName = "PreLookupCompiledErrorContentHeadingStyle";
compilationContentHeadingStr = getDisplayLabel( h.src );
append( compilationErrorContent{ 1 }, compilationContentHeadingStr );

compilationErrorContent{ 2 } = mlreportgen.dom.Paragraph(  );
blkName = mlreportgen.utils.normalizeString( get_param( h.Object, 'Name' ) );


index = find( ismember( h.KnownErrorIdentifiers, ME.identifier ), 1 );


if isempty( index )
str = getString( message( "slreportgen:report:error:UnknownCompileError", get_param( h.Object, "Name" ) ) );
append( compilationErrorContent{ 2 }, str );
else 
warning( ME.identifier, "%s", ME.message );
compilationErrorContentStr = getString( message( "slreportgen:report:error:CompileError", blkName ) );
append( compilationErrorContent{ 2 }, compilationErrorContentStr );
compilationErrorContent{ 3 } = mlreportgen.dom.UnorderedList(  );
compilationErrorContent{ 3 }.StyleName = "PreLookupCompilationErrorListStyle";
append( compilationErrorContent{ 3 }, mlreportgen.dom.Text( ME.message ) );

end 
end 

function content = getBreakpointExpressionContent( h )
bpExpr = getBreakpointExpression( h.src );
n = numel( bpExpr );
content = cell( 1, n );
for i = 1:n
str = getString( message( "lutdesigner:PreLookupReporter:BreakpointAsExpression", bpExpr{ i }{ 1 },  ...
bpExpr{ i }{ 2 } ) );
content{ i } = mlreportgen.dom.Text( str );
end 
end 

function content = getTableDataExpressionContent( h )
tableDataExpr = getTableDataExpression( h.src );
if ~isempty( tableDataExpr )
str = getString( message( "slreportgen:report:TableDataAsExpression", tableDataExpr ) );
content = { mlreportgen.dom.Text( str ) };
else 
content = {  };
end 
end 

function content = getLookupTableObjExpressionContent( h )
preLookupExpr = getLookupTableObjExpression( h.src );
if ~isempty( preLookupExpr )
str = getString( message( "lutdesigner:PreLookupReporter:PreLookupObject", preLookupExpr ) );
content = { mlreportgen.dom.Text( str ) };
else 
content = {  };
end 
end 

function content = getBreakpointObjExpressionContent( h )
bpObjExpr = getBreakpointObjExpression( h.src );
if ~isempty( bpObjExpr )
str = getString( message( "lutdesigner:PreLookupReporter:BreakpointObject", bpObjExpr ) );
content{ 1 } = mlreportgen.dom.Text( str );
else 
content = {  };
end 
end 

function content = getEvenSpacingInfoContent( h )
bpEvenSpacingInfo = getEvenSpacingInfo( h.src );
n = numel( bpEvenSpacingInfo );
content = cell( 1, n );
for i = 1:n
str = getString( message( "lutdesigner:PreLookupReporter:EvenSpacedBreakpoints", bpEvenSpacingInfo{ i }{ 1 },  ...
bpEvenSpacingInfo{ i }{ 2 }, bpEvenSpacingInfo{ i }{ 3 } ) );
content{ i } = mlreportgen.dom.Text( str );
end 
end 

function createPreLookupSource( h )

source = [  ];
objH = slreportgen.utils.getSlSfHandle( h.Object );
switch get_param( objH, 'BlockType' )
case "PreLookup"
source = lutdesigner.report.utils.PreLookup( objH );
end 
if isempty( source )
error( message( "slreportgen:report:error:unsupportedLookupTableBlock" ) );
end 
h.src = source;
end 

function [ xLabel, yLabel ] = generateXYLabel( h, slicedData )

if isempty( h.xLabel ) && isempty( h.yLabel )

if isa( slicedData.breakPoints1, "embedded.fi" )
slicedBP1 = getFixedPointValues( slicedData.breakPoints1 );
else 
slicedBP1 = slicedData.breakPoints1;
end 
if isfield( slicedData, 'breakPoints2' )
if isa( slicedData.breakPoints2, "embedded.fi" )
slicedBP2 = getFixedPointValues( slicedData.breakPoints2 );
else 
slicedBP2 = slicedData.breakPoints2;
end 
end 

[ sz, nDims ] = getTableDimensions( slicedData.dataSlice );

yDim = sz( 1 );
xDim = sz( 2 );
if nDims == 1



xLabel = cell( 0, 2 );
yDim = max( sz );
else 
xLabel = getBreakPointsLabel( slicedBP2, xDim, slicedData.zeroBasedIndices );
xLabel = [ { '' }, xLabel( : )' ];
end 

yLabel = getBreakPointsLabel( slicedBP1, yDim, slicedData.zeroBasedIndices );

h.xLabel = xLabel;
h.yLabel = yLabel;
else 
xLabel = h.xLabel;
yLabel = h.yLabel;

end 
end 


function documentPartObj = createDocPartObj( h, rpt, slicedData )
figReporter = [  ];
titleRptrForPreLookup = [  ];
slicedTableContent = [  ];



[ xLabelVal, yLabelVal ] = generateXYLabel( h, slicedData );

if isa( slicedData.dataSlice, "embedded.fi" )
slicedTableData = getFixedPointValues( slicedData.dataSlice );
else 
slicedTableData = slicedData.dataSlice;
end 

if ( h.IncludeTable )
[ sz, nDims ] = getTableDimensions( slicedTableData );


if ( nDims == 1 ) ||  ...
( nDims == 2 && sz( 2 ) < h.MaxTableColumns )
[ titleRptrForPreLookup, slicedTableContent ] = generateTable( h, slicedTableData, slicedData.tableTitle,  ...
xLabelVal, yLabelVal );
end 
end 

if ( h.IncludePlot )
if ( lutdesigner.report.PreLookup.isOneDimensionalSliceData( slicedData ) )
figReporter = generatePlot( h, rpt, slicedData.dataSlice, slicedData.tableTitle,  ...
slicedData.breakPoints1 );
else 

figReporter = generatePlot( h, rpt, slicedData.dataSlice, slicedData.tableTitle,  ...
slicedData.breakPoints1, slicedData.breakPoints2 );
end 
end 
if isa( h.TemplateSrc, "slreportgen.report.internal.DocumentPart" )
documentPartObj = slreportgen.report.internal.DocumentPart( h.TemplateSrc, "PreLookupContent" );
else 
documentPartObj = slreportgen.report.internal.DocumentPart( rpt.Type, h.TemplateSrc, "PreLookupContent" );
end 

fillDocPartHoles( h, rpt, documentPartObj, titleRptrForPreLookup, slicedTableContent, figReporter );
end 

function fillDocPartHoles( h, rpt, documentPartObj, titleRptrForPreLookup, slicedTableContent, figReporter )

open( documentPartObj );

while ~strcmp( documentPartObj.CurrentHoleId, "#end#" )
switch documentPartObj.CurrentHoleId
case "TableContent"
if ~isempty( titleRptrForPreLookup )
titleRptrForPreLookup.TemplateSrc = h;

if h.ShouldNumberTableHierarchically
titleRptrForPreLookup.TemplateName = 'PreLookupHierNumberedTitle';
else 
titleRptrForPreLookup.TemplateName = 'PreLookupNumberedTitle';
end 

append( documentPartObj, titleRptrForPreLookup.getImpl( rpt ) );









for i = 1:length( slicedTableContent )
append( documentPartObj, slicedTableContent{ i } );
end 
end 
case "FigureContent"
if ~isempty( figReporter )






figReporter.Snapshot.Image = getSnapshotImage( figReporter, rpt );
if mlreportgen.report.Reporter.isInlineContent( figReporter.Snapshot.Image )
imageReporter = getImageReporter( figReporter.Snapshot, rpt );
imageReporter.TemplateSrc = h;
imageReporter.TemplateName = 'PreLookupImage';
figReporter.Snapshot.Image = imageReporter;
end 

if ~isempty( figReporter.Snapshot.Caption ) &&  ...
mlreportgen.report.Reporter.isInlineContent( figReporter.Snapshot.Caption )
captionReporter = getCaptionReporter( figReporter.Snapshot );
captionReporter.TemplateSrc = h;

if h.ShouldNumberTableHierarchically
captionReporter.TemplateName = 'PreLookupHierNumberedCaption';
else 
captionReporter.TemplateName = 'PreLookupNumberedCaption';
end 
figReporter.Snapshot.Caption = captionReporter;
end 

figureImpl = figReporter.getImpl( rpt );
append( documentPartObj, figureImpl );
end 
end 
moveToNextHole( documentPartObj );
end 
close( documentPartObj );
end 

function content = generatePlot( this, rpt, tableData, tableTitle, breakPoints1 )
R36
this
rpt
tableData
tableTitle string
breakPoints1
end 
[ sz, nDims ] = getTableDimensions( tableData );%#ok<ASGLU>
if nDims == 1

figH = makeFigureOneD( breakPoints1,  ...
this.src.BreakpointsHeader,  ...
tableData,  ...
getString( message( "lutdesigner:PreLookupReporter:Outputs" ) ) );
else 
figH = [  ];
end 
if ~isempty( figH )
captionStr = getDisplayLabel( this.src );
slicingCaption = strjoin( tableTitle );
captionStr = strjoin( [ captionStr, strtrim( slicingCaption ) ] );
fig = copy( this.PlotReporter );
if isempty( fig.Snapshot.Caption )
fig.Snapshot.Caption = captionStr;
else 


appendCaption( fig.Snapshot, captionStr );
end 
fig.Source = figH;
content = fig;
figureHandles = getContext( rpt, 'figureHandles' );
figureHandles{ end  + 1 } = figH;
setContext( rpt, 'figureHandles', figureHandles );
else 
content = [  ];
end 
end 





function slicedData = makeMultiTable( ~, breakPoints, tableData, tableTitle, history, zeroBasedIndices, slicedData )

[ ~, nDims ] = getTableDimensions( tableData );

tableTitle = [ tableTitle, ' ',  ...
getnDTitle( history, breakPoints, nDims, zeroBasedIndices ) ];
history = num2cell( history );
dataSlice = tableData( :, :, history{ : } );

minDims = min( nDims, 2 );
slicedInfo.dataSlice = dataSlice;
slicedInfo.tableTitle = tableTitle;
slicedInfo.zeroBasedIndices = zeroBasedIndices;
slicedInfo.breakPoints1 = breakPoints{ 1 };

if minDims == 2
slicedInfo.breakPoints2 = breakPoints{ 2 };
end 

slicedData{ end  + 1 } = slicedInfo;
end 

function [ titleRptrForPreLookup, tableContent ] = generateTable( this, tableData, tableTitle, xLabels, yLabels )
R36
this
tableData
tableTitle string
xLabels string
yLabels string
end 
titleRptrForPreLookup = [  ];
[ sz, nDims ] = getTableDimensions( tableData );%#ok<ASGLU>
if ( nDims == 1 )
tableData = tableData( : );
end 
tableData = [ xLabels;[ yLabels( : ), num2cell( tableData ) ] ];
tableData = cellfun( @mlreportgen.utils.toString, tableData, 'UniformOutput', false );

titleStr = getDisplayLabel( this.src );

slicingTitle = strjoin( tableTitle );
titleStr = strjoin( [ titleStr, strtrim( slicingTitle ) ] );

baseTable = copy( this.DataReporter );

if isempty( baseTable.Title )
baseTable.Title = titleStr;
else 


appendTitle( baseTable, titleStr );
end 

if nDims == 1
tableContent = generateOneDimensionalTable( this, tableData );
else 
tableContent = generateTwoDimensionalTable( this, tableData );
end 


if ~isempty( baseTable ) && mlreportgen.report.Reporter.isInlineContent( baseTable.Title )
titleRptrForPreLookup = getTitleReporter( baseTable );
end 

end 

function oneDimensionalTable = generateOneDimensionalTable( h, tableData )

table = mlreportgen.dom.FormalTable(  );
table.StyleName = 'PreLookupOneDimensionalTableStyle';
tr = mlreportgen.dom.TableRow(  );
append( tr, mlreportgen.dom.TableHeaderEntry( h.src.BreakpointsHeader ) );
append( tr, mlreportgen.dom.TableHeaderEntry( getString( message( "lutdesigner:PreLookupReporter:Outputs" ) ) ) );
append( table, tr );



s = size( tableData );
for row = 1:s( 1 )
tableRow = mlreportgen.dom.TableRow(  );
tableEntry = mlreportgen.dom.TableEntry(  );

append( tableEntry, tableData{ row, 1 } );
tableEntry.StyleName = 'PreLookupInnerTableBreakPointStyle';

append( tableRow, tableEntry );
values = tableData{ row, 2 };
tableEntry = mlreportgen.dom.TableEntry( values );
append( tableRow, tableEntry );
append( table, tableRow );
end 
oneDimensionalTable = { table };
end 
end 

methods ( Static )

function path = getClassFolder(  )

[ path ] = fileparts( mfilename( 'fullpath' ) );
end 

function template = createTemplate( templatePath, type )






path = lutdesigner.report.PreLookup.getClassFolder(  );
template = mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

function classfile = customizeReporter( toClasspath )









classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
"lutdesigner.report.PreLookup" );
end 

function isOneDimensional = isOneDimensionalSliceData( slicedData )
isOneDimensional = ( length( fieldnames( slicedData ) ) == 4 );
end 


function isTwoDimensional = isTwoDimensionalSliceData( slicedData )
isTwoDimensional = ( length( fieldnames( slicedData ) ) == 5 );
end 


function table2 = createInnerTable( tableData )
table2 = mlreportgen.dom.Table(  );
table2.StyleName = 'PreLookupInnerTableStyle';
s = size( tableData );
for rownum = 1:s( 1 )
tableRow = mlreportgen.dom.TableRow(  );

for colnum = 1:s( 2 )
tableEntry = mlreportgen.dom.TableEntry( tableData{ rownum, colnum } );
if ( rownum == 1 || colnum == 1 )
tableEntry.StyleName = 'PreLookupInnerTableBreakPointStyle';
end 
append( tableRow, tableEntry );
end 
append( table2, tableRow );
end 
end 
end 


methods ( Access = protected, Hidden )

result = openImpl( reporter, impl, varargin )
end 

methods ( Access = private )
function setOutputType( h, type )
h.ReportOutputType = type;
end 

function format = getOutputType( h )
format = h.ReportOutputType;
end 

end 
end 


function mustBeBaseTable( table )
mlreportgen.report.validators.mustBeInstanceOf( 'mlreportgen.report.BaseTable', table );
end 


function mustBeFigure( figure )
mlreportgen.report.validators.mustBeInstanceOf( 'mlreportgen.report.Figure', figure );
end 

function mustBeLogical( varargin )
mlreportgen.report.validators.mustBeLogical( varargin{ : } );
end 

function mustBePreLookupObject( object )
if ~isempty( object ) && ~lutdesigner.report.utils.isPreLookup( object )
error( message( "slreportgen:report:error:invalidSourceObject" ) );
end 
end 

function mustBeValidMaxSize( size )
if ~isnumeric( size ) || size <= 0
error( message( "slreportgen:report:error:invalidMaxTableColumns" ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_tODVG.p.
% Please follow local copyright laws when handling this file.

