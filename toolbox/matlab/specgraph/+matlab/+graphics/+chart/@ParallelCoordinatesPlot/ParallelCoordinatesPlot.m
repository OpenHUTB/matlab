classdef ( ConstructOnLoad, Sealed )ParallelCoordinatesPlot <  ...
matlab.graphics.chart.CartesianChartContainer &  ...
matlab.graphics.chart.internal.UserChartUpdateShim &  ...
matlab.graphics.chartcontainer.mixin.ColorOrderMixin &  ...
matlab.graphics.datatip.internal.mixin.DataTipMixin








properties ( Dependent )
SourceTable
CoordinateVariables
GroupVariable
end 

properties ( Dependent )
Data
GroupData
CoordinateData
Color
FontSize
end 

properties ( Dependent )
LegendTitle matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
CoordinateLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
DataLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
end 

properties ( Hidden, AffectsObject, Access = private )
Data_I
GroupData_I
CoordinateData_I
Color_I = get( groot, 'FactoryAxesColorOrder' );
end 

properties ( AffectsObject, Hidden, AbortSet )
LegendTitle_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
CoordinateLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
DataLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
end 

properties ( AffectsObject, Hidden )
SourceTable_I tabular = table.empty(  );
CoordinateVariables_I = ''
GroupVariable_I = ''
end 

properties ( AffectsObject, AbortSet )
FontName matlab.internal.datatype.matlab.graphics.datatype.FontName = get( groot, 'FactoryAxesFontName' )
end 

properties ( Access = private, AbortSet )


UsingTableForData = true;
end 

properties ( Access = private )


DataDirty logical = false


VariableName = ''
GroupVariableName char = ''
end 

properties ( Dependent )
CoordinateTickLabels
DataNormalization
LineWidth
LineStyle
LineAlpha
MarkerStyle
MarkerSize
LegendVisible matlab.internal.datatype.matlab.graphics.datatype.on_off
Jitter
end 

properties ( Hidden, AffectsObject )
CoordinateTickLabels_I
DataNormalization_I char{ mustBeMember( DataNormalization_I, { 'none', 'zscore', 'norm', 'scale', 'range', 'center' } ) } = 'range'
LineWidth_I = 1
LineStyle_I = "-"
LineAlpha_I = 0.7
MarkerStyle_I = "none"
MarkerSize_I = 6
LegendVisible_I matlab.internal.datatype.matlab.graphics.datatype.on_off = 'on'
Jitter_I = 0.1
FontSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive = get( groot, 'FactoryAxesFontSize' )
end 

properties ( Access = private, Transient, NonCopyable )

MarkedCleanListener


LegendHandle
end 

properties ( Access = private )

PrintSettingsCache
LooseInsetCache;



DataStorage


DragPositionCache
CoordinateVariablesCache
CoordinateDataCache
CoordinateTickLabelsCache


RestoreViewXLimCache
RestoreViewYLimCache
end 

properties ( Access = protected, Transient, NonCopyable )

SavedXLim
SavedYLim



SavedXLimCache
SavedYLimCache
end 

properties ( Access = 'protected' )
ColorOrderInternalMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
end 


properties ( Transient, NonCopyable, Hidden, Access = { ?ChartTestFriend,  ...
?tOrangeChartWithcolororder } )

LineHandles



DatatipLineHandle



NormalizedData



DatatipIndices
PlotIndex


YRulers
end 

properties ( Transient, NonCopyable, Hidden, Access =  ...
{ ?matlab.graphics.chart.internal.parallelplot.DragToRearrange } )

OriginalIndex
end 

properties ( Access = 'private' )

GroupIndex double
NumGroups double = 1;
GroupNames



Categories
IsCategorical logical

MaxValues
MinValues
IsSingleUniquePoint logical
end 

properties ( Access = { ?matlab.graphics.chart.internal.parallelplot.Controller } )
NumColumns
end 

properties ( Transient, NonCopyable, Access = 'private' )


UpdatePlot logical = true
UpdateLines logical = true
UpdateData logical = true
end 

properties ( Hidden, AbortSet )

LegendVisibleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
LegendTitleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
CoordinateLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
DataLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
MarkerStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';


FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CoordinateDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
CoordinateTickLabelsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
end 

properties ( Transient, NonCopyable, Hidden, AbortSet,  ...
Access = { ?matlab.graphics.chart.internal.parallelplot.Controller } )
Controller
end 

properties ( Transient, NonCopyable, Hidden, AbortSet,  ...
Access = { ?matlab.graphics.chart.internal.parallelplot.Controller,  ...
?matlab.graphics.chart.internal.parallelplot.DragToRearrange,  ...
?matlab.graphics.chart.internal.parallelplot.InteractionStrategy } )
EnableInteractions( 1, 1 )logical = true

SwapInProgress( 1, 1 )logical = false
end 


properties ( Access = { ?ChartTestFriend }, Hidden, Transient, NonCopyable )
PanInteraction
ScrollZoomInteraction
PanZoomActionUpdatePending = false
end 


properties ( Access = { ?ChartTestFriend }, Hidden, Transient, NonCopyable )
PointDatatip;
Linger;
end 

methods ( Hidden, Access = protected )
function tf = useGcfBehavior( ~ )

tf = false;
end 
end 

methods ( Access = protected, Hidden )

function setup( pc )
pc.Description = 'ParallelCoordinatesPlot';


ax = pc.Axes;
ax.Description = 'ParallelCoordinatesPlot Axes';


ax.Units = 'normalized';
ax.XAxis = matlab.graphics.axis.decorator.NumericRuler;
ax.YAxis( 1 ).Visible = 'off';
ax.YAxis( 1 ).Label.Visible = 'on';





ax.XAxis.PrimitiveChildEnabled = 'off';
ax.YAxis( 1 ).PrimitiveChildEnabled = 'off';
ax.Visible = 'off';
ax.TickLabelInterpreter = 'none';
ax.XLabel.String = '';
ax.YLabel.String = '';
ax.Internal = true;
set( hggetbehavior( ax, 'pan' ), 'Enable', false );
set( hggetbehavior( ax, 'zoom' ), 'Enable', false );



addlistener( ax.Title, 'String', 'PostSet', @( ~, ~ )set( pc, 'Title', ax.Title.String_I ) );
addlistener( ax.XLabel, 'String', 'PostSet', @( ~, ~ )set( pc, 'CoordinateLabel', ax.XLabel.String_I ) );
addlistener( ax.YLabel, 'String', 'PostSet', @( ~, ~ )set( pc, 'DataLabel', ax.YLabel.String_I ) );


pc.addDependencyConsumed( { 'ref_frame', 'resolution' } );


pc.LegendHandle = matlab.graphics.illustration.internal.ColorLegend( pc.Axes );
pc.LegendHandle.IsLine = true;
pc.LegendHandle.Legend.Location = 'northeastoutside';
legendcolorbarlayout( ax, 'addToTree', pc.LegendHandle.Legend );


pc.initializeDatatip(  );



addlistener( ax, 'Hit', @( e, d )pc.showContextMenu( d ) );


pc.MarkedCleanListener = addlistener( pc, 'MarkedClean',  ...
@( ~, ~ )markedCleanCallback( pc ) );
end 


update( pc, updateState );
doLayout( pc, updateState );

function s = getTypeName( ~ )
s = 'parallelplot';
end 


function [ parent, args ] = parseCustomArgs( ~, varargin )
parent = [  ];
args = varargin;
end 

function showContextMenu( pc, evd )
if pc.UsingTableForData
showContextMenu@matlab.graphics.datatip.internal.mixin.DataTipMixin( pc, evd );
end 
end 
end 


methods 

function set.Data( pc, data )




matrixMode = ~pc.UsingTableForData || width( pc.SourceTable ) == 0;
assert( matrixMode, message( 'MATLAB:graphics:parallelplot:TableWorkflow', 'Data' ) );


validateattributes( data, { 'numeric' }, { 'real', 'nonsparse', '2d' }, '', 'Data' );



pc.Data_I = data;
pc.NormalizedData = data;

if isempty( pc.CoordinateData )
pc.CoordinateData_I = 1:size( pc.Data_I, 2 );
end 


pc.UsingTableForData = false;
pc.UpdateData = true;
pc.UpdatePlot = true;
end 

function data = get.Data( pc )
if pc.UsingTableForData

updateTableData( pc );
end 
data = pc.Data_I;
end 


function set.CoordinateData( pc, cData )


matrixMode = ~pc.UsingTableForData || width( pc.SourceTable ) == 0;
assert( matrixMode, message( 'MATLAB:graphics:parallelplot:TableWorkflow', 'CoordinateData' ) );


validateattributes( cData, { 'numeric', 'logical' }, { 'real', 'nonsparse', 'vector', 'integer' }, '', 'CoordinateData' );

if islogical( cData )
d = find( cData );
else 
d = cData;
end 


if any( d > size( pc.Data_I, 2 ) ) || any( d < 0 ) || isempty( d )
throwAsCaller( MException( message( 'MATLAB:graphics:parallelplot:InvalidCoordinateDataSize' ) ) );
end 

pc.CoordinateDataMode = 'manual';
pc.CoordinateData_I = cData;


pc.UsingTableForData = false;
pc.UpdateData = true;
pc.UpdatePlot = true;
end 

function cData = get.CoordinateData( pc )
cData = pc.CoordinateData_I;
end 


function set.SourceTable( pc, tbl )
import matlab.graphics.chart.internal.validateTableSubscript



assert( pc.UsingTableForData,  ...
message( 'MATLAB:graphics:parallelplot:MatrixWorkflow', 'SourceTable' ) );


assert( isa( tbl, 'tabular' ),  ...
message( 'MATLAB:graphics:parallelplot:InvalidSourceTable' ) );




var = pc.CoordinateVariables_I;
if islogical( var )
var = find( var );
end 
varName = cell( size( var ) );
if strcmp( pc.CoordinateDataMode, 'manual' )
for idx = 1:length( var )
[ varName{ idx }, ~, err ] = validateTableSubscript( tbl,  ...
var( idx ), 'CoordinateVariables' );
if ~isempty( err )
throwAsCaller( err );
end 
end 
else 
varName = tbl.Properties.VariableNames;
pc.CoordinateVariables_I = varName;
pc.CoordinateData_I = 1:length( varName );
end 

[ gVarName, ~, errG ] = validateTableSubscript(  ...
tbl, pc.GroupVariable_I, 'GroupVariable' );


pc.VariableName = varName;
pc.GroupVariableName = gVarName;



if ~isempty( errG )
throwAsCaller( errG );
end 

pc.initializeDataTipConfiguration(  );


pc.SourceTable_I = tbl;


pc.DataDirty = true;


if strcmp( pc.LegendTitleMode, 'auto' )
pc.LegendHandle.TitleString = gVarName;
end 

pc.UpdateData = true;
pc.UpdatePlot = true;
end 

function tbl = get.SourceTable( pc )
tbl = pc.SourceTable_I;
end 


function set.CoordinateVariables( pc, var )


assert( pc.UsingTableForData,  ...
message( 'MATLAB:graphics:parallelplot:MatrixWorkflow', 'CoordinateVariables' ) );


import matlab.graphics.chart.internal.validateTableSubscript
tbl = pc.SourceTable_I;

v = [  ];
if ischar( var ) || iscellstr( var )%#ok<ISCLSTR>
var = string( var );
elseif islogical( var )
v = var;
var = find( var );
end 
validateattributes( var, { 'numeric', 'string' }, { 'nonempty', 'vector' },  ...
'', 'CoordinateVariables' );


varnames = cell( 1, length( var ) );
pc.CoordinateData_I = zeros( 1, length( var ) );
for idx = 1:length( var )
[ varName, var( idx ), err ] = validateTableSubscript( tbl, var( idx ), 'CoordinateVariables' );
if isempty( err )
varnames{ idx } = varName;
else 
throwAsCaller( err );
end 


assert( ~isempty( varName ), message( 'MATLAB:table:UnrecognizedVarName', '' ) );


[ ~, pc.CoordinateData_I( idx ) ] = ismember( varName,  ...
pc.SourceTable.Properties.VariableNames );
end 
pc.VariableName = varnames;
pc.CoordinateDataMode = 'manual';


pc.DataDirty = true;
pc.UpdateData = true;
pc.UpdatePlot = true;


if islogical( v )
var = v;
end 
pc.CoordinateVariables_I = var;
pc.initializeDataTipConfiguration(  );
end 

function var = get.CoordinateVariables( pc )



if isnumeric( pc.CoordinateVariables_I ) || islogical( pc.CoordinateVariables_I )
var = pc.CoordinateVariables_I;
else 
var = cellstr( pc.CoordinateVariables_I );
end 
end 


function set.GroupVariable( pc, var )


assert( pc.UsingTableForData,  ...
message( 'MATLAB:graphics:parallelplot:MatrixWorkflow', 'GroupVariable' ) );


import matlab.graphics.chart.internal.validateTableSubscript
tbl = pc.SourceTable_I;
[ varName, ~, err ] = validateTableSubscript( tbl, var, 'GroupVariable' );
if isempty( err )
pc.GroupVariableName = varName;
else 
throwAsCaller( err );
end 



if isempty( varName )
validateAndSetGroupInfo( pc, [  ] );
else 
validateAndSetGroupInfo( pc, pc.SourceTable.( varName ) );
end 


if strcmp( pc.LegendTitleMode, 'auto' )
pc.LegendHandle.TitleString = varName;
end 


pc.GroupVariable_I = var;


pc.DataDirty = true;
pc.UpdateData = true;
pc.UpdatePlot = true;
end 

function var = get.GroupVariable( pc )
var = pc.GroupVariable_I;
end 
end 


methods 


function grp = get.GroupData( pc )
grp = pc.GroupData_I;
end 

function set.GroupData( pc, group )


matrixMode = ~pc.UsingTableForData || width( pc.SourceTable ) == 0;
assert( matrixMode, message( 'MATLAB:graphics:parallelplot:TableWorkflow', 'GroupData' ) );



validateAndSetGroupInfo( pc, group );
end 


function set.Color( pc, clr )

validateattributes( clr, { 'numeric', 'char', 'string', 'cell' },  ...
{ 'real', 'nonsparse', '2d' }, '', 'Color' );


pc.UpdateLines = true;

if isnumeric( clr )


validateattributes( clr, { 'numeric' }, { '>=', 0, '<=', 1 }, '', 'Color' );
if ~isequal( size( clr, 2 ), 3 )
throwAsCaller( MException( message( 'MATLAB:graphics:parallelplot:InvalidNumericColorSize' ) ) );
end 

pc.Color_I = clr;
else 



pc.Color_I = matlab.graphics.chart.ScatterHistogramChart ...
.colorStringToRGB( string( clr ), pc.Axes );
end 
pc.ColorMode = 'manual';
end 

function c = get.Color( pc )
if strcmp( pc.ColorMode, 'auto' )
forceFullUpdate( pc, 'all', 'Color' );
end 
c = pc.Color_I;
end 


function ticks = get.CoordinateTickLabels( pc )
ticks = pc.Axes.XTickLabels;
end 

function set.CoordinateTickLabels( pc, tickLabs )
pc.Axes.TickLabelInterpreter = 'none';


try 
pc.Axes.XTickLabels = tickLabs;
catch e
throwAsCaller( e );
end 


if ( size( tickLabs, 1 ) == 1 ) && ( ischar( tickLabs ) || isstring( tickLabs ) ...
 || iscellstr( tickLabs ) )
tickLabs = strrep( tickLabs, newline, ' ' );
end 

pc.CoordinateTickLabels_I = tickLabs;
pc.CoordinateTickLabelsMode = 'manual';
end 


function std = get.DataNormalization( pc )
std = pc.DataNormalization_I;
end 

function set.DataNormalization( pc, method )


validateattributes( string( method ), { 'string' }, { 'scalar' }, '', 'DataNormalization' );

pc.DataNormalization_I = method;


pc.DataDirty = true;
pc.updateNormalizedData(  );

if isempty( pc.NormalizedData )
return 
end 

ncols = size( pc.NormalizedData, 2 );


if pc.UsingTableForData
isNum = ~pc.IsCategorical;
else 
isNum = true( 1, ncols );
end 

for idx = 1:ncols

data = pc.NormalizedData( :, idx );


isNan = isnan( data );
isInf = ~isfinite( data );
data( isNan | isInf ) = [  ];


if ~strcmp( method, 'none' ) && isNum( idx )
data = normalize( data, method );
elseif ~isNum( idx )

data = normalize( data, 'range' );
end 


pc.NormalizedData( ~isNan & ~isInf, idx ) = data;
end 



d = pc.NormalizedData( isfinite( pc.NormalizedData ) );
maxV = max( d, [  ], 'all', 'omitnan' );
minV = min( d, [  ], 'all', 'omitnan' );




isCat = ~isNum;
if ~all( isCat ) && ~isempty( maxV ) && ~isempty( minV )
pc.NormalizedData( :, isCat ) = pc.NormalizedData( :, isCat ) *  ...
( maxV - minV ) + minV;
end 

pc.UpdatePlot = true;
pc.UpdateData = true;
end 


function titl = get.LegendTitle( pc )
titl = pc.LegendTitle_I;
end 

function set.LegendTitle( pc, titl )


try 
pc.LegendTitle_I = titl;
catch e
throwAsCaller( e );
end 
pc.LegendTitleMode = 'manual';
end 

function legTitle = get.LegendTitle_I( pc )
legTitle = pc.LegendHandle.TitleString;
end 

function set.LegendTitle_I( pc, legTitle )

pc.LegendHandle.TitleString = legTitle;%#ok<MCSUP>
end 


function xlabel = get.CoordinateLabel( pc )
xlabel = pc.Axes.XLabel.String;
end 

function set.CoordinateLabel( pc, xlabel )
try 
pc.Axes.XLabel.String_I = xlabel;
pc.Axes.XLabel.StringMode = 'manual';
catch e
throwAsCaller( e )
end 
pc.CoordinateLabel_I = xlabel;
pc.CoordinateLabelMode = 'manual';
end 


function ylabel = get.DataLabel( pc )
ylabel = pc.Axes.YLabel.String;
end 

function set.DataLabel( pc, ylabel )
try 
pc.Axes.YLabel.String_I = ylabel;
pc.Axes.YLabel.StringMode = 'manual';
catch e
throwAsCaller( e );
end 
pc.DataLabel_I = ylabel;
pc.DataLabelMode = 'manual';
end 


function lw = get.LineWidth( pc )
lw = pc.LineWidth_I;
end 

function set.LineWidth( pc, lw )

validateattributes( lw, { 'numeric' }, { 'vector', 'nonempty', 'real', 'finite', 'positive' },  ...
'', 'LineWidth' );
pc.LineWidth_I = lw;
pc.UpdateLines = true;
end 


function la = get.LineAlpha( pc )
la = pc.LineAlpha_I;
end 

function set.LineAlpha( pc, la )

validateattributes( la, { 'numeric' }, { 'vector', 'nonempty', 'real', '>=', 0, '<=', 1 }, '', 'LineAlpha' );
pc.LineAlpha_I = la;
pc.UpdateLines = true;
end 


function ls = get.LineStyle( pc )
ls = pc.LineStyle_I;
end 

function set.LineStyle( pc, ls )
if ischar( ls )
ls = string( ls );
end 

validateattributes( ls, { 'char', 'cell', 'string' }, { 'vector', 'nonempty' }, '', 'LineStyle' );
mustBeMember( ls, { '-', '--', ':', '-.', 'none' } );
pc.LineStyleMode = 'manual';
pc.LineStyle_I = string( ls );
pc.UpdateLines = true;
end 


function ms = get.MarkerStyle( pc )
ms = pc.MarkerStyle_I;
end 

function set.MarkerStyle( pc, ms )

if ischar( ms )
ms = string( ms );
end 
validateattributes( ms, { 'char', 'cell', 'string' }, { 'vector', 'nonempty' }, '', 'MarkerStyle' );
mustBeMember( ms, { 'o', '+', '*', '.', 'x',  ...
'square', 's', 'diamond', 'd', '^', 'v', '>', '<', 'pentagram', 'p',  ...
'hexagram', 'h', 'none' } );
pc.MarkerStyleMode = 'manual';
pc.MarkerStyle_I = string( ms );
pc.UpdateLines = true;
end 


function ms = get.MarkerSize( pc )
ms = pc.MarkerSize_I;
end 

function set.MarkerSize( pc, ms )

validateattributes( ms, { 'numeric' }, { 'vector', 'nonempty', 'real' }, '', 'MarkerSize' );
pc.MarkerSize_I = ms;
pc.UpdateLines = true;
end 


function set.Jitter( pc, jit )
validateattributes( jit, { 'numeric' }, { 'scalar', '>=', 0, '<=', 1 }, '', 'Jitter' );
pc.Jitter_I = jit;

if isempty( pc.NormalizedData )
return 
end 

maxND = max( pc.NormalizedData, [  ], 1, 'omitnan' );
minND = min( pc.NormalizedData, [  ], 1, 'omitnan' );
maxND( ~isfinite( maxND ) ) = 1;
minND( ~isfinite( minND ) ) = 0;
pc.IsSingleUniquePoint = maxND == minND;



for idx = 1:size( pc.NormalizedData, 2 )





unq = unique( pc.NormalizedData( :, idx ) );
unq( ismissing( unq ) ) = [  ];
sclFctr = jit * max( [ ( maxND( idx ) - minND( idx ) ), 1 ] ) / max( [ length( unq ), 1 ] );


customStream = RandStream( 'dsfmt19937' );
pc.NormalizedData( :, idx ) = pc.NormalizedData( :, idx ) +  ...
sclFctr * ( rand( customStream, size( pc.NormalizedData, 1 ), 1 ) - 0.5 );
end 

pc.MaxValues = max( pc.NormalizedData, [  ], 1, 'omitnan' );
pc.MinValues = min( pc.NormalizedData, [  ], 1, 'omitnan' );

pc.UpdateData = true;
end 

function jit = get.Jitter( pc )
jit = pc.Jitter_I;
end 


function set.FontName( pc, fontName )

if isvalid( pc.Axes )
pc.Axes.FontName = fontName;
pc.LegendHandle.FontName = fontName;%#ok<MCSUP>


pc.FontName = fontName;
end 
end 


function val = get.FontSize( pc )
val = pc.FontSize_I;
end 

function set.FontSize( pc, fontSize )
pc.FontSizeMode = 'manual';
pc.FontSize_I = fontSize;
end 

function set.FontSize_I( pc, fontSize )

if isvalid( pc.Axes )
pc.LegendHandle.FontSize = fontSize;%#ok<MCSUP>
pc.Axes.FontSize = fontSize;


pc.FontSize_I = fontSize;
end 
end 


function leg = get.LegendVisible( pc )
leg = pc.LegendVisible_I;
end 

function set.LegendVisible( pc, leg )
validateattributes( string( leg ), { 'string' }, { 'scalar' }, '', 'LegendVisible' );

pc.LegendVisibleMode = 'manual';
pc.LegendVisible_I = leg;

if ~isempty( pc.LegendHandle.Categories )
pc.LegendHandle.Visible = leg;
end 
end 
end 


methods 
function set.DataStorage( pc, data )




pc.SavedXLim = data.XLimits;%#ok<MCSUP>
pc.SavedYLim = data.YLimits;%#ok<MCSUP>
end 

function data = get.DataStorage( pc )




data.XLimits = pc.Axes.XLim;
data.YLimits = pc.Axes.YLim;
end 

end 

methods ( Hidden, Access = 'private' )

function validateAndSetGroupInfo( pc, group )
if pc.UsingTableForData
varName = 'GroupVariable';
else 
varName = 'GroupData';
end 


validateattributes( group, { 'numeric', 'categorical', 'logical',  ...
'char', 'string', 'cell' }, { 'real', 'nonsparse', '2d' }, '', varName );



if ~isempty( group ) && ~( iscategorical( group ) && isempty( categories( group ) ) )

if iscell( group ) && ~iscellstr( group )%#ok<ISCLSTR>
throwAsCaller( MException( message( 'MATLAB:graphics:parallelplot:InvalidGroupDataCell' ) ) );
end 


grp = group;
if ischar( grp )
grp = string( grp );
end 



try 
grp = categorical( grp );
catch e
throwAsCaller( MException( message( 'MATLAB:graphics:parallelplot:InvalidCategoryNames' ) ) );
end 




pc.GroupIndex = findgroups( grp );
pc.GroupNames = string( unique( grp, 'stable' ) );
pc.GroupIndex = pc.GroupIndex( : );
pc.GroupNames = pc.GroupNames( : );


ind = isnan( pc.GroupIndex );
if any( ind )
nanVal = max( pc.GroupIndex ) + 1;
pc.GroupIndex( ind ) = nanVal;



pc.GroupNames( ismissing( pc.GroupNames ) ) = "<undefined>";
pc.GroupNames = unique( pc.GroupNames, 'stable' );
end 



pc.NumGroups = numel( pc.GroupNames );



[ ~, ~, pc.GroupIndex ] = unique( pc.GroupIndex, 'stable' );

pc.GroupData_I = group;
else 
pc.NumGroups = 1;
pc.GroupIndex = [  ];
pc.GroupNames = [  ];
pc.GroupData_I = [  ];
end 


if strcmp( pc.ColorMode, 'auto' )
if ~isempty( pc.Parent ) && strcmp( pc.ColorOrderInternalMode, 'auto' )
pc.ColorOrderInternal = get( pc.Parent, 'DefaultAxesColorOrder' );
end 
pc.Color_I = pc.ColorOrderInternal;
end 


pc.UpdatePlot = true;
end 


function updateTableData( pc )




if pc.UsingTableForData && pc.DataDirty




pc.Categories = cell( 1, length( pc.VariableName ) );
pc.IsCategorical = false( 1, length( pc.VariableName ) );
pc.NormalizedData = [  ];
for idx = 1:length( pc.VariableName )
d = pc.SourceTable.( pc.VariableName{ idx } );
if ~isnumeric( d )
if ischar( d ) || iscellstr( d )%#ok<ISCLSTR>
d = string( d );
end 
[ d, pc.Categories{ idx } ] = findgroups( d );
pc.IsCategorical( idx ) = true;
end 



d = double( d );
pc.NormalizedData = [ pc.NormalizedData, d ];
end 



if ~isempty( pc.GroupVariableName )
pc.GroupIndex = ones( size( pc.NormalizedData, 1 ), 1 );
pc.DataDirty = false;

validateAndSetGroupInfo( pc, pc.SourceTable.( pc.GroupVariableName ) );
end 


pc.DataDirty = false;
end 
end 

function updateNormalizedData( pc )


if pc.UsingTableForData
pc.DataDirty = true;
pc.updateTableData(  );
else 
cData = pc.CoordinateData;
ncols = size( pc.Data_I, 2 );
if ~isempty( cData ) && isnumeric( cData ) && ( min( cData ) < 1 ||  ...
max( cData ) > ncols )
if strcmp( pc.CoordinateDataMode, 'auto' )
pc.CoordinateData_I = 1:ncols;
else 
throwAsCaller( MException( message( 'MATLAB:graphics:parallelplot:InvalidCoordinateDataSize' ) ) );
end 
elseif islogical( cData ) && ~isequal( length( cData ), ncols )
if strcmp( pc.CoordinateDataMode, 'auto' )
pc.CoordinateData_I = true( 1, ncols );
else 
throwAsCaller( MException( message( 'MATLAB:graphics:parallelplot:InvalidCoordinateDataSize' ) ) );
end 
end 

pc.NormalizedData = double( pc.Data_I( :, pc.CoordinateData ) );
end 
pc.NumColumns = size( pc.NormalizedData, 2 );
end 

end 


methods ( Hidden, Access = { ?ChartTestFriend,  ...
?matlab.graphics.chart.internal.parallelplot.Controller,  ...
?matlab.graphics.chart.internal.parallelplot.DragToRearrange } )
function obj = getInternalChildren( pc )
obj.Axes = pc.Axes;
obj.Legend = pc.LegendHandle.Legend;
end 

function disableLinger( obj )
obj.Linger.disable(  );
end 
end 

methods ( Hidden, Access = 'protected' )

function postSetUnits( pc )
units = pc.Units;
pc.Axes.Units_I = units;
pc.LegendHandle.Legend.Units = units;
end 

function data = getPositionStorageImpl( obj )
data = getPositionStorageImpl@matlab.graphics.chart.CartesianChartContainer( obj );



app = data.ActivePositionProperty;
data.ActivePositionProperty = regexprep( app, '^inner', '' );
end 

function setColorOrderInternal( pc, listOfColors )
pc.ColorOrderInternalMode = 'manual';
pc.ColorMode = 'auto';
pc.UpdatePlot = 1;
pc.Color_I = listOfColors;
end 
end 

methods ( Access = protected )
function dtConfig = getDefaultDataTipConfiguration( pc )
dtConfig = string.empty( 0, 1 );
if ~isempty( pc.SourceTable )


dtConfig{ end  + 1 } = pc.SourceTable.Properties.DimensionNames{ 1 };

if ~isempty( pc.GroupVariableName )
groupString = getString( message( 'MATLAB:Chart:DatatipGroup' ) );
dtConfig{ end  + 1 } = groupString;
end 

for i = 1:numel( pc.VariableName )
dtConfig{ end  + 1 } = pc.VariableName{ i };%#ok<AGROW>
end 
end 
end 
end 

methods ( Hidden, Access = 'protected', Static )
function tightInsetPoints = getTightInsetFromAxes( ax, updateState )
layout = ax.GetLayoutInformation(  );


posPoints = updateState.convertUnits( 'canvas', ax.Units, 'pixels', layout.Position );

decPBPoints = updateState.convertUnits( 'canvas', ax.Units, 'pixels', layout.DecoratedPlotBox );

tightInsetPoints = [ 0, 0, 0, 0 ];
tightInsetPoints( 1:2 ) = [  ...
posPoints( 1 ) - decPBPoints( 1 ),  ...
posPoints( 2 ) - decPBPoints( 2 ) ];
tightInsetPoints( 3:4 ) = [  ...
decPBPoints( 3 ) - posPoints( 3 ) - tightInsetPoints( 1 ),  ...
decPBPoints( 4 ) - posPoints( 4 ) - tightInsetPoints( 2 ) ];

tightInsetPoints( tightInsetPoints < 0 ) = 0;
end 

function data = makePlottableData( data )


data = [ data, nan( size( data, 1 ), 1 ) ]';
data = data( : );
end 
end 


methods ( Hidden, Access = 'private' )
function plotLines( pc )


ind = pc.CoordinateData_I;
if islogical( ind )
ind = find( ind );
end 
indCoords = 1:length( ind );




ax = pc.Axes;
cla( ax );
delete( ax.YAxis( 2:end  ) );
ax.XAxis.TickValues = indCoords;
hold( ax, 'on' );



pc.LineHandles = cell( 1, pc.NumGroups );


pc.PlotIndex = [  ];
for grp = 1:pc.NumGroups
clr = pc.Color_I;
if isempty( pc.GroupData )
pc.GroupIndex = true( size( pc.NormalizedData, 1 ), 1 );
end 
mbrs = pc.GroupIndex == grp;

if isempty( mbrs )
continue ;
end 
mbrs = find( mbrs );

ydata = matlab.graphics.chart.ParallelCoordinatesPlot ...
.makePlottableData( pc.NormalizedData( mbrs, : ) );
xdata = matlab.graphics.chart.ParallelCoordinatesPlot ...
.makePlottableData( repmat( indCoords, numel( mbrs ), 1 ) );




lhandles = plot( ax, xdata, ydata,  ...
'LineStyle', pc.LineStyle_I( grp ), 'Color', [ clr( grp, : ), pc.LineAlpha_I( grp ) ],  ...
'LineWidth', pc.LineWidth_I( grp ), 'Marker', pc.MarkerStyle_I( grp ),  ...
'MarkerSize', pc.MarkerSize_I( grp ) );


for indx = 1:length( lhandles )


bh = hggetbehavior( lhandles( indx ), 'DataCursor' );
bh.UpdateFcn = { @matlab.graphics.chart.ParallelCoordinatesPlot.datatipCallback, pc };
bh.Enable = 0;
setappdata( lhandles( indx ), 'grp', grp )
setappdata( lhandles( indx ), 'gind', mbrs( indx ) );


addlistener( lhandles( indx ), 'Hit', @( e, d )pc.showContextMenu( d ) );
end 

set( lhandles, 'Tag', 'coords' );

pc.LineHandles{ grp } = lhandles;
pc.PlotIndex = vertcat( pc.PlotIndex, mbrs );
end 


pc.DatatipLineHandle = plot( ax, indCoords, nan( size( indCoords ) ),  ...
'PickableParts', 'none', 'Hittest', 'off', 'Visible', 'off',  ...
'Color', [ 0, 0, 0 ], 'HandleVisibility', 'off' );


for ncols = 1:pc.NumColumns
m = matlab.graphics.axis.decorator.NumericRuler;
ax.DecorationContainer.addNode( m );
m.Axis = 1;
m.FirstCrossoverValue = ncols;
m.InverseCrossoverValue = Inf;
m.AxesLayer = 'top';
m.Internal = true;
end 


pc.YRulers = pc.Axes.YAxis;


pc.Axes.YAxis( 1 ).Visible = 'off';
pc.Axes.YAxis( 1 ).Label.Visible = 'on';
pc.Axes.Visible = 'on';
end 

function plotLegend( pc )

if isempty( pc.GroupData_I )
pc.LegendVisible = 'off';
pc.LegendVisibleMode = 'auto';
end 
leg = pc.LegendHandle;


grp = unique( pc.GroupIndex, 'stable' );
if ~isempty( grp )
leg.ColorList = pc.Color_I( grp, : );
end 


cats = string( pc.GroupNames );
if ~isempty( grp ) && ~isempty( cats )
cats = cats( grp );
end 
leg.Legend.PositionMode = 'auto';
leg.Categories = cats;
leg.LineStyleList = pc.LineStyle;
leg.LineWidthList = pc.LineWidth;
leg.LineAlphaList = pc.LineAlpha;
leg.categoricalLegend(  );
leg.Legend.Interpreter = 'none';
end 
end 

methods ( Access = 'private' )
function markedCleanCallback( pc )
if ~isvalid( pc.Axes ) || pc.SetupUpdateBlock
return ;
end 

if isempty( pc.PanInteraction )

pc.Controller = matlab.graphics.chart.internal.parallelplot.Controller( pc );
pc.Controller.AxesRulerHitArea.HandleVisibility = 'off';


pc.initializePalette(  );


pc.setupMouseInteraction(  );
end 



if ~isequal( length( pc.YRulers( 2:end  ) ), size( pc.NormalizedData, 2 ) )
return 
end 





ax = matlab.graphics.axis.Axes( 'OuterPosition', pc.Axes.OuterPosition );
ax.Visible = 'off';
pc.addNode( ax );



d = pc.NormalizedData;
d( ~isfinite( d ) ) = [  ];
range = double( [ min( d, [  ], 'all', 'omitnan' ),  ...
max( d, [  ], 'all', 'omitnan' ) ] );

yylim = [  ];
if ~isempty( range ) && all( isfinite( range ) ) && range( 2 ) > range( 1 )
yylim = range + [  - .05, .05 ] * diff( range );
end 



if ~isequal( pc.RestoreViewYLimCache, yylim ) && ~isequal( pc.SavedYLim, yylim ) ...
 && ~isempty( yylim )

pc.Axes.YLim = yylim;


pc.RestoreViewYLimCache = pc.Axes.YLim;
pc.SavedYLim = pc.Axes.YLim;
pc.SavedYLimCache = pc.Axes.YLim;

elseif ~isempty( pc.SavedYLim ) && ~isequal( pc.SavedYLimCache, pc.SavedYLim )
pc.SavedYLimCache = pc.SavedYLim;
pc.Axes.YLim = pc.SavedYLim;
end 

xxlim = [  ];
if isscalar( pc.NumColumns ) && isfinite( pc.NumColumns ) &&  ...
pc.NumColumns > 0
xxlim = [ 0.5, pc.NumColumns + 0.5 ];
end 

if ~isequal( pc.RestoreViewXLimCache, xxlim ) && ~isequal( pc.SavedXLim, xxlim ) ...
 && ~isempty( xxlim )


pc.Axes.XLim = xxlim;

pc.RestoreViewXLimCache = pc.Axes.XLim;
pc.SavedXLim = pc.Axes.XLim;
pc.SavedXLimCache = pc.Axes.XLim;

elseif ~isempty( pc.SavedXLim ) && ~isequal( pc.SavedXLimCache, pc.SavedXLim )
pc.SavedXLimCache = pc.SavedXLim;
pc.Axes.XLim = pc.SavedXLim;
end 

for idx = 1:pc.NumColumns


yruler = pc.YRulers( idx + 1 );

if ~isempty( pc.IsCategorical ) && pc.IsCategorical( idx )
if isempty( pc.Categories{ idx } )
yruler.TickValues = [  ];
yruler.TickLabels = [  ];
else 




c = pc.Categories{ idx };
yruler.TickValues = linspace( pc.MinValues( idx ),  ...
pc.MaxValues( idx ), length( c ) );
yruler.TickLabels = string( c );
end 
else 

if strcmp( pc.DataNormalization, 'range' )

coordD = pc.CoordinateData_I;
if islogical( pc.CoordinateData )
coordD = find( coordD );
end 
ind = coordD( idx );

if pc.UsingTableForData
scatter( ax, pc.SourceTable.( ind ), pc.SourceTable.( ind ) );
else 
scatter( ax, pc.Data( :, ind ), pc.Data( :, ind ) );
end 




axis( ax, 'tight' );


labs = ax.YAxis.TickValues;

if idx > length( pc.MinValues ) || idx > length( pc.MaxValues )
continue 
end 



if pc.IsSingleUniquePoint( idx )


pt = mean( [ pc.MinValues( idx ), pc.MaxValues( idx ) ] );



ticks = linspace( pt - 1, pt + 1, 11 );



ptD = ax.Children.YData( 1 );
labs = linspace( ptD - 1, ptD + 1, 11 );


if isfinite( pt ) && isfinite( ptD )
yruler.TickValues = ticks;
yruler.TickLabels = labs;
else 
yruler.TickValues = linspace( 0, 1, 11 );
yruler.TickLabels = linspace( 0, 1, 11 );
end 
else 




lowP = ( ax.XAxis.TickValues( 1 ) - ax.YLim( 1 ) ) /  ...
( ax.YLim( 2 ) - ax.YLim( 1 ) );
upP = ( ax.YLim( 2 ) - ax.XAxis.TickValues( end  ) ) /  ...
( ax.YLim( 2 ) - ax.YLim( 1 ) );
ticks = linspace( lowP, 1 - upP, length( labs ) );

diffLabs = diff( labs );
yruler.TickLabels = [ labs( 1 ) - diffLabs( 1 ), labs, labs( end  ) + diffLabs( 1 ) ];

diffTicks = diff( ticks );
yruler.TickValues = [ ticks( 1 ) - diffTicks( 1 ), ticks, ticks( end  ) + diffTicks( 1 ) ];
end 
end 
end 




axle = yruler.Axle;
if ~isempty( axle )
axle.PickableParts = 'none';
axle.HitTest = 'off';
end 
majtickchld = yruler.MajorTickChild;
if ~isempty( majtickchld )
majtickchld.PickableParts = 'none';
majtickchld.HitTest = 'off';
end 
end 


c = categorical( string( pc.Axes.XTickLabels ) );
scatter( ax, c, c );
pc.Axes.XAxis.TickLabelRotation = ax.XTickLabelRotation;



delete( ax );
end 
end 


methods ( Hidden )
function scaleForPrinting( pc, flag, scale )





switch lower( flag )
case 'modify'

settings.LineWidth = pc.LineWidth;
settings.MarkerSize = pc.MarkerSize;
settings.Units = pc.Units;
if strcmpi( pc.PositionConstraint, 'outerposition' )
settings.OuterPosition = pc.OuterPosition;
else 
settings.InnerPosition = pc.InnerPosition;
end 
settings.LooseInsetCache = pc.LooseInsetCache;
pc.PrintSettingsCache = settings;



scopeGuard = onCleanup( @(  )pc.enableSubplotListeners(  ) );
pc.disableSubplotListeners(  );
pc.Units = 'normalized';
delete( scopeGuard );


if scale ~= 1
pc.MarkerSize = settings.MarkerSize ./ scale;
end 
case 'revert'
settings = pc.PrintSettingsCache;

if ~isempty( settings )


pc.LineWidth = settings.LineWidth;
pc.MarkerSize = settings.MarkerSize;



scopeGuard = onCleanup( @(  )pc.enableSubplotListeners(  ) );
pc.disableSubplotListeners(  );
pc.Units = settings.Units;
delete( scopeGuard );

scopeGuard = onCleanup( @(  )pc.enableSubplotListeners(  ) );
pc.disableSubplotListeners(  );
if strcmpi( pc.PositionConstraint, 'outerposition' )
pc.OuterPosition = settings.OuterPosition;
else 
pc.InnerPosition = settings.InnerPosition;
end 
delete( scopeGuard );
pc.LooseInsetCache = settings.LooseInsetCache;
end 


pc.PrintSettingsCache = [  ];
end 
end 

function disableSubplotListeners( pc )
parent = pc.Parent;
if isscalar( parent ) && isvalid( parent )
slm = getappdata( parent, 'SubplotListenersManager' );
if ~isempty( slm )
disable( slm );
end 
end 
end 

function enableSubplotListeners( pc )
parent = pc.Parent;
if isscalar( parent ) && isvalid( parent )
slm = getappdata( parent, 'SubplotListenersManager' );
if ~isempty( slm )
enable( slm );
end 
end 
end 
end 


methods ( Hidden )
function setupMouseInteraction( pc )

ax = pc.Axes;
disableDefaultInteractivity( ax );
strategy = matlab.graphics.interaction.uiaxes ...
.AxesInteractionStrategy( ax );
strategy.Chart = pc;
fig = ancestor( pc, 'figure' );

pan = matlab.graphics.interaction.uiaxes.Pan( ax, fig,  ...
'WindowMousePress', 'WindowMouseMotion', 'WindowMouseRelease' );
pan.strategy = strategy;
pan.enable(  )

sz = matlab.graphics.interaction.uiaxes.ScrollZoom( ax, fig,  ...
'WindowScrollWheel', 'WindowMouseMotion' );
sz.strategy = strategy;
sz.enable(  )

pc.PanInteraction = pan;
pc.ScrollZoomInteraction = sz;
end 


function initializePalette( pc )

[ tb, btn ] = axtoolbar( pc.Axes, { 'restoreview' } );
if ~isempty( tb )
tb.Visible = 'on';
tb.HandleVisibility = 'off';
tb.Serializable = 'off';

btn.Visible = 'on';
btn.HandleVisibility = 'off';
btn.ButtonPushedFcn = @( ~, ~ )restoreView( pc );
end 
end 

function restoreView( pc )


if ~isempty( pc.RestoreViewXLimCache )
pc.Axes.XLim = pc.RestoreViewXLimCache;
end 
if ~isempty( pc.RestoreViewYLimCache )
pc.Axes.YLim = pc.RestoreViewYLimCache;
end 
end 
end 


methods ( Hidden )
function initializeDatatip( pc )





hCursor = matlab.graphics.shape.internal.PointDataCursor(  );
hCursor.Interpolate = 'off';
hTip = matlab.graphics.shape.internal.PointDataTip( hCursor,  ...
'Draggable', 'off', 'Visible', 'off', 'HandleVisibility', 'off',  ...
'DataTipStyle', matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly );
hLocator = hTip.LocatorHandle;
hLocator.PickableParts = 'none';
hLocator.HitTest = 'off';



hTip.TipHandle.Text.PickableParts = 'none';
hTip.TipHandle.Rectangle.PickableParts = 'none';
scribePeer = hTip.TipHandle.ScribeHost.getScribePeer(  );
scribePeer.PickableParts = 'none';
hLocator.setMarkerPickableParts( 'none' );

pc.PointDatatip = hTip;


hLinger = matlab.graphics.interaction.actions.Linger( pc.Axes );
hLinger.IncludeChildren = true;
hLinger.LingerResetMethod = 'exitaxes';
hLinger.LingerTime = 1;
hLinger.enable(  );
addlistener( hLinger, 'EnterObject', @( ~, e )pc.updateDatatip( e ) );
addlistener( hLinger, 'ExitObject', @( ~, e )pc.updateDatatip( e ) );
addlistener( hLinger, 'LingerOverObject', @( ~, e )pc.lingerFcn( e ) );
addlistener( hLinger, 'LingerReset', @( ~, e )pc.updateDatatip( e ) );
pc.Linger = hLinger;
end 

function updateDatatip( pc, eventobj )

hTip = pc.PointDatatip;


if isempty( hTip ) || ~isvalid( hTip )
initializeDatatip( pc );
hTip = pc.PointDatatip;
end 

if eventobj.EventName == "EnterObject"






dataSource = eventobj.HitObject;
if ~isa( dataSource, 'matlab.graphics.chart.primitive.Line' ) ...
 || ~isvalid( dataSource )
return ;
end 
hTip.DataSource = dataSource;





hCursor = hTip.Cursor;
dataIndex = hCursor.DataIndex;
newIndex = eventobj.NearestPoint;
movePoint = ~isequal( dataIndex, newIndex );
if movePoint
hCursor.DataIndex = newIndex;
end 
toggleDatatipLocator( hTip, 'on' );




grpind = getappdata( dataSource, 'grp' );
ind = eventobj.NearestPoint;

ncols = size( pc.NormalizedData, 2 );
indByGroup = ceil( ind / ( ncols + 1 ) );
linind = ( indByGroup - 1 ) * ( ncols + 1 );


lineHdl = pc.DatatipLineHandle;
lineHdl.YData = dataSource.YData( linind + 1:linind + ncols );
lineHdl.LineWidth = 2 * pc.LineWidth_I( grpind );
lineHdl.LineStyle = pc.LineStyle_I( grpind );
lineHdl.Marker = pc.MarkerStyle_I( grpind );
lineHdl.MarkerSize = pc.MarkerSize_I( grpind );
lineHdl.Visible = 'on';
elseif eventobj.EventName == "LingerReset"



hTip.DataTipStyle = matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly;
toggleDatatipLocator( hTip, 'off' );
else 


if isvalid( hTip )
toggleDatatipLocator( hTip, 'off' );
end 


if isgraphics( pc.DatatipLineHandle )
pc.DatatipLineHandle.Visible = 'off';
end 
end 
end 

function lingerFcn( pc, ~ )
hTip = pc.PointDatatip;

if isvalid( hTip )
showTip = hTip.Visible == "on";
if showTip
hTip.DataTipStyle = matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerAndTip;
end 
end 
end 
end 

methods ( Hidden )
function moveRulerAndData( pc, orgind, ~, pos )





if ( pos < 1 )
pos = 1;
end 
d = size( pc.NormalizedData, 2 );
if pos > d
pos = d;
end 




movePerc = 0.02;
if isempty( pc.DragPositionCache )
pc.DragPositionCache = pos;
else 
if abs( pc.DragPositionCache - pos ) < movePerc
return 
end 
end 


pc.ScrollZoomInteraction.disable(  );
pc.PanInteraction.disable(  );






if ~isempty( pc.OriginalIndex )
orgind = pc.OriginalIndex;
end 


swapPerc = 0.99;


yrulers = pc.YRulers;
yrulers( ( orgind ) + 1 ).FirstCrossoverValue = pos;


inddiff = orgind - pos;
newind = orgind;

doSwap = abs( inddiff ) > swapPerc;


signdiff =  - sign( inddiff );


pc.SwapInProgress = true;
if doSwap
newind = round( pos );


yrulers( ( orgind ) + 1 ).FirstCrossoverValue = orgind;







for ind = orgind:signdiff:newind - signdiff
ind2 = ind + signdiff;



tempVals = yrulers( ind + 1 ).TickValues;
tempLabels = yrulers( ind + 1 ).TickLabels;
yrulers( ind + 1 ).TickValues = yrulers( ind2 + 1 ).TickValues;
yrulers( ind + 1 ).TickLabels = yrulers( ind2 + 1 ).TickLabels;
yrulers( ind2 + 1 ).TickValues = tempVals;
yrulers( ind2 + 1 ).TickLabels = tempLabels;




if isempty( pc.CoordinateTickLabelsCache )
pc.CoordinateTickLabelsCache = pc.CoordinateTickLabels_I;
end 
pc.CoordinateTickLabelsCache( [ ind2, ind ] ) =  ...
pc.CoordinateTickLabelsCache( [ ind, ind2 ] );





pc.Axes.XAxis.TickLabels( [ ind2, ind ] ) =  ...
pc.Axes.XAxis.TickLabels( [ ind, ind2 ] );


if pc.UsingTableForData
if isempty( pc.CoordinateVariablesCache )
pc.CoordinateVariablesCache = pc.CoordinateVariables_I;
end 
pc.CoordinateVariablesCache( [ ind, ind2 ] ) =  ...
pc.CoordinateVariablesCache( [ ind2, ind ] );
pc.VariableName( [ ind2, ind ] ) = pc.VariableName( [ ind, ind2 ] );
end 



if isempty( pc.CoordinateDataCache )
pc.CoordinateDataCache = pc.CoordinateData_I;
end 
pc.CoordinateDataCache( [ ind, ind2 ] ) =  ...
pc.CoordinateDataCache( [ ind2, ind ] );


if ~isempty( pc.OriginalIndex ) && pc.UsingTableForData
pc.IsCategorical( [ ind, ind2 ] ) = pc.IsCategorical( [ ind2, ind ] );
if any( pc.IsCategorical )
pc.Categories( [ ind, ind2 ] ) = pc.Categories( [ ind2, ind ] );
end 
end 
end 
end 


ncols = pc.NumColumns;
pltLines = vertcat( pc.LineHandles{ : } );

for idx = 1:length( pltLines )
x = pltLines( idx ).XData;
x( newind:ncols + 1:end  ) = floor( pos );

if doSwap



for ind = orgind:signdiff:newind - signdiff
ind2 = ind + signdiff;


y = pltLines( idx ).YData;
yorg = y( ind:ncols + 1:end  );
ynew = y( ind2:ncols + 1:end  );
y( ind:ncols + 1:end  ) = ynew;
y( ind2:ncols + 1:end  ) = yorg;


pltLines( idx ).YData = y;


x( ind:ncols + 1:end  ) = ind;
end 
end 
pltLines( idx ).XData = x;
end 


pc.SwapInProgress = false;
pc.OriginalIndex = newind;
pc.DragPositionCache = pos;


pc.DataDirty = true;
pc.UpdateData = true;
pc.UpdatePlot = true;
end 

function snapRulersAndData( pc )


if pc.SwapInProgress
return 
end 


yruler = [ pc.YRulers( 2:end  ).FirstCrossoverValue ];
ind = find( yruler ~= floor( yruler ) );


if ~isempty( ind )
pc.YRulers( ind + 1 ).FirstCrossoverValue = ind;
pltLines = vertcat( pc.LineHandles{ : } );
for idx = 1:pc.NumGroups
x = pltLines( idx ).XData;
x( ind:pc.NumColumns + 1:end  ) = ind;
pltLines( idx ).XData = x;
end 
end 


pc.resetCoordinateDataWithCache(  );


pc.ScrollZoomInteraction.enable(  );
pc.PanInteraction.enable(  );
end 

function resetCoordinateDataWithCache( pc )

if ~isempty( pc.CoordinateDataCache )
pc.CoordinateData_I = pc.CoordinateDataCache;
pc.CoordinateDataCache = [  ];
end 
if ~isempty( pc.CoordinateVariablesCache )
pc.CoordinateVariables_I = pc.CoordinateVariablesCache;
pc.CoordinateVariablesCache = [  ];
end 
if ~isempty( pc.CoordinateTickLabelsCache )
pc.CoordinateTickLabels_I = pc.CoordinateTickLabelsCache;
pc.CoordinateTickLabelsCache = [  ];
end 
end 
end 

methods ( Static, Hidden )
datatipTxt = datatipCallback( ~, evt, pc );
end 


methods ( Access = 'protected', Hidden )
function groups = getPropertyGroups( hObj )
if hObj.UsingTableForData
groups = matlab.mixin.util.PropertyGroup(  ...
{ 'SourceTable', 'CoordinateVariables', 'GroupVariable' } );
else 
groups = matlab.mixin.util.PropertyGroup(  ...
{ 'Data', 'CoordinateData', 'GroupData' } );
end 
end 
end 


methods ( Hidden )
function ignore = mcodeIgnoreHandle( ~, ~ )

ignore = false;
end 
mcodeConstructor( pc, code );
end 
end 

function toggleDatatipLocator( hTip, onoff )
hTip.Visible = onoff;
hLocator = hTip.LocatorHandle;
hLocator.ScribeMarkerHandleEdge.Visible = onoff;
hLocator.ScribeMarkerHandleFace.Visible = onoff;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwSVtgD.p.
% Please follow local copyright laws when handling this file.

