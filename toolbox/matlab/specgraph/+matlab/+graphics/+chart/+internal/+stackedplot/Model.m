classdef Model < handle




properties ( Dependent )

XData
YData
SourceTable
DisplayVariables
XVariable
CombineMatchingNames


XData_I
YData_I
SourceTable_I
DisplayVariables_I
XVariable_I
CombineMatchingNames_I

DisplayVariablesMode
end 

properties ( NonCopyable )
Presenter matlab.graphics.chart.internal.stackedplot.Presenter
end 

properties ( Access = private )
ChartData matlab.graphics.chart.internal.stackedplot.ChartData
WarningFun function_handle
end 

properties ( Access = private, Dependent )
InputType
end 

properties ( Access = private )
ModelStrategyFactory
NumAxesStrategy
AxesXDataStrategy
AxesYDataStrategy
AxesSeriesIndicesStrategy
AxesLineStylesStrategy
AxesLabelsStrategy
LegendLabelsStrategy
XLabelStrategy
XLimitsStrategy
YLimitsStrategy
AutoDisplayVariablesStrategy
PlotMappingStrategy
AxesPlotTypeStrategy
PropertyGroupsStrategy
ValidationStrategy
XVariableValidationStrategy
DisplayVariablesValidationStrategy
CollapseLegendStrategy
ChartLegendVisibleStrategy
ChartLegendLabelsStrategy
end 

methods 
function obj = Model( chartData, warningFun )
obj.ChartData = chartData;
obj.WarningFun = warningFun;
obj.updateStrategies(  );
end 

function state = copyState( obj )
state = copy( obj.ChartData );
end 

function xData = get.XData( obj )
xData = obj.ChartData.XData;
end 

function set.XData( obj, xData )
classes = [ "datetime", "duration", "numeric", "logical" ];
attributes = "vector";
className = obj.Presenter.ChartClassName;
varName = "XData";
validateattributes( xData, classes, attributes, className, varName );
if ~isempty( xData ) && ~isempty( obj.ChartData.SourceTable )
error( message( "MATLAB:stackedplot:IncompatibleArrayInput" ) );
end 
obj.XData_I = xData;
end 

function set.XData_I( obj, xData )
obj.ChartData.XData = xData;
obj.updateStrategies(  );
end 

function yData = get.YData( obj )
yData = obj.ChartData.YData;
end 

function set.YData( obj, yData )
classes = [ "numeric", "logical", "datetime", "duration", "categorical" ];
attributes = string.empty;
className = obj.Presenter.ChartClassName;
varName = "YData";
validateattributes( yData, classes, attributes, className, varName );
if ~isempty( yData ) && ~isempty( obj.ChartData.SourceTable )
error( message( "MATLAB:stackedplot:IncompatibleArrayInput" ) );
end 
obj.YData_I = yData;
end 

function set.YData_I( obj, yData )
obj.ChartData.YData = yData;
obj.updateStrategies(  );
end 

function sourceTable = get.SourceTable( obj )
sourceTable = obj.ChartData.SourceTable;
end 

function set.SourceTable( obj, sourceTable )
import matlab.graphics.chart.internal.stackedplot.validateSourceTable

validateSourceTable( sourceTable );
if ~isequal( size( sourceTable ), [ 0, 0 ] ) && ~( isempty( obj.ChartData.XData ) && isempty( obj.ChartData.YData ) )





error( message( 'MATLAB:stackedplot:IncompatibleTableInput' ) );
end 
obj.SourceTable_I = sourceTable;
if obj.ChartData.DisplayVariablesMode == "auto"
obj.AutoDisplayVariablesStrategy.setAutoDisplayVariables( obj.ChartData, obj.WarningFun );
end 
end 

function set.SourceTable_I( obj, sourceTable )
obj.ChartData.SourceTable = sourceTable;
obj.updateStrategies(  );
end 

function displayVariables = get.DisplayVariables( obj )
displayVariables = obj.ChartData.DisplayVariables;
end 

function set.DisplayVariables( obj, displayVariables )
obj.ChartData.DisplayVariables = obj.DisplayVariablesValidationStrategy.validateDisplayVariables( obj.ChartData, displayVariables, obj.Presenter.ChartClassName );
obj.ChartData.DisplayVariablesMode = "manual";
end 

function set.DisplayVariables_I( obj, displayVariables )
obj.ChartData.DisplayVariables = displayVariables;
end 

function displayVariablesMode = get.DisplayVariablesMode( obj )
displayVariablesMode = obj.ChartData.DisplayVariablesMode;
end 

function set.DisplayVariablesMode( obj, displayVariablesMode )
obj.ChartData.DisplayVariablesMode = displayVariablesMode;
end 

function xVariable = get.XVariable( obj )
xVariable = obj.ChartData.XVariable;
end 

function set.XVariable( obj, xVariable )
obj.XVariable_I = obj.XVariableValidationStrategy.validateXVariable( obj.ChartData, xVariable, obj.Presenter.ChartClassName );
end 

function set.XVariable_I( obj, xVariable )
obj.ChartData.XVariable = xVariable;
end 

function combineMatchingNames = get.CombineMatchingNames( obj )
combineMatchingNames = obj.ChartData.CombineMatchingNames;
end 

function set.CombineMatchingNames( obj, cnames )
if isequal( cnames, 1 )
obj.CombineMatchingNames_I = true;
return 
elseif isequal( cnames, 0 )
obj.CombineMatchingNames_I = false;
return 
end 
if isequal( cnames, [  ] )
cnames = false;
elseif ~( islogical( cnames ) && isscalar( cnames ) )
error( message( "MATLAB:stackedplot:InvalidCombineMatchingNames" ) );
end 
obj.CombineMatchingNames_I = cnames;
end 

function set.CombineMatchingNames_I( obj, combineMatchingNames )
obj.ChartData.CombineMatchingNames = combineMatchingNames;
end 
end 

methods 
function type = get.InputType( obj )

t = obj.ChartData.SourceTable;
if isequal( size( t ), [ 0, 0 ] )
type = "array";
elseif istimetable( t )
type = "timetable";
elseif istable( obj.ChartData.SourceTable )
type = "table";
elseif iscell( t ) && istimetable( t{ 1 } )
type = "multi-timetable";
elseif iscell( t ) && istable( t{ 1 } )
type = "multi-table";
else 
assert( false );
end 
end 
end 

methods ( Access = private )
function updateStrategies( obj )
obj.ModelStrategyFactory = matlab.graphics.chart.internal.stackedplot.model.strategy.factory.ModelStrategyFactory.createModelStrategyFactory( obj.InputType );
obj.NumAxesStrategy = obj.ModelStrategyFactory.createNumAxesStrategy(  );
obj.AxesXDataStrategy = obj.ModelStrategyFactory.createAxesXDataStrategy(  );
obj.AxesYDataStrategy = obj.ModelStrategyFactory.createAxesYDataStrategy(  );
obj.AxesSeriesIndicesStrategy = obj.ModelStrategyFactory.createAxesSeriesIndicesStrategy(  );
obj.AxesLineStylesStrategy = obj.ModelStrategyFactory.createAxesLineStylesStrategy(  );
obj.AxesLabelsStrategy = obj.ModelStrategyFactory.createAxesLabelsStrategy(  );
obj.LegendLabelsStrategy = obj.ModelStrategyFactory.createLegendLabelsStrategy(  );
obj.XLabelStrategy = obj.ModelStrategyFactory.createXLabelStrategy(  );
obj.XLimitsStrategy = obj.ModelStrategyFactory.createXLimitsStrategy(  );
obj.YLimitsStrategy = obj.ModelStrategyFactory.createYLimitsStrategy(  );
obj.AutoDisplayVariablesStrategy = obj.ModelStrategyFactory.createAutoDisplayVariablesStrategy(  );
obj.PlotMappingStrategy = obj.ModelStrategyFactory.createPlotMappingStrategy(  );
obj.AxesPlotTypeStrategy = obj.ModelStrategyFactory.createAxesPlotTypeStrategy(  );
obj.PropertyGroupsStrategy = obj.ModelStrategyFactory.createPropertyGroupsStrategy(  );
obj.ValidationStrategy = obj.ModelStrategyFactory.createValidationStrategy(  );
obj.XVariableValidationStrategy = obj.ModelStrategyFactory.createXVariableValidationStrategy(  );
obj.DisplayVariablesValidationStrategy = obj.ModelStrategyFactory.createDisplayVariablesValidationStrategy(  );
obj.CollapseLegendStrategy = obj.ModelStrategyFactory.createCollapseLegendStrategy(  );
obj.ChartLegendVisibleStrategy = obj.ModelStrategyFactory.createChartLegendVisibleStrategy(  );
obj.ChartLegendLabelsStrategy = obj.ModelStrategyFactory.createChartLegendLabelsStrategy(  );
end 
end 

methods 
function numAxes = getNumAxes( obj )
numAxes = obj.NumAxesStrategy.getNumAxes( obj.ChartData );
end 

function x = getAxesXData( obj, varargin )
s = obj.AxesXDataStrategy;
x = obj.applyForAxes( @s.getAxesXData, varargin{ : } );
end 

function y = getAxesYData( obj, varargin )
s = obj.AxesYDataStrategy;
y = obj.applyForAxes( @s.getAxesYData, varargin{ : } );
end 

function c = getAxesSeriesIndices( obj, varargin )
s = obj.AxesSeriesIndicesStrategy;
c = obj.applyForAxes( @s.getAxesSeriesIndices, varargin{ : } );
end 

function c = getAxesLineStyles( obj, varargin )
s = obj.AxesLineStylesStrategy;
c = obj.applyForAxes( @s.getAxesLineStyles, varargin{ : } );
end 

function labels = getAxesLabels( obj, varargin )
s = obj.AxesLabelsStrategy;
labels = obj.applyForAxes( @s.getAxesLabels, varargin{ : } );
for i = 1:length( labels )
if iscell( labels{ i } ) && isscalar( labels{ i } )
labels{ i } = labels{ i }{ 1 };
end 
end 
end 

function labels = getLegendLabels( obj, varargin )
s = obj.LegendLabelsStrategy;
labels = obj.applyForAxes( @s.getLegendLabels, varargin{ : } );
end 

function xLabel = getXLabel( obj )
xLabel = obj.XLabelStrategy.getXLabel( obj.ChartData );
end 

function xLimits = getXLimits( obj )
xLimits = obj.XLimitsStrategy.getXLimits( obj.ChartData );
end 

function yLimits = getYLimits( obj, axesIndex )
yLimits = obj.YLimitsStrategy.getYLimits( obj.ChartData, axesIndex );
end 

function [ axesMapping, plotMapping ] = mapPlotObjects( obj, oldState )
[ axesMapping, plotMapping ] = obj.PlotMappingStrategy.mapPlotObjects( obj.ChartData, oldState );
end 

function plotType = getAxesPlotType( obj, varargin )
s = obj.AxesPlotTypeStrategy;
plotType = obj.applyForAxes( @s.getAxesPlotType, varargin{ : } );
end 

function groups = getPropertyGroups( obj )
groups = obj.PropertyGroupsStrategy.getPropertyGroups( obj.ChartData );
end 

function labels = getCollapseLegend( obj, varargin )
s = obj.CollapseLegendStrategy;
labels = obj.applyForAxes( @s.getCollapseLegend, varargin{ : } );
end 

function visible = getChartLegendVisible( obj )
visible = obj.ChartLegendVisibleStrategy.getChartLegendVisible(  );
end 

function labels = getChartLegendLabels( obj )
labels = obj.ChartLegendLabelsStrategy.getChartLegendLabels( obj.ChartData );
end 

function validate( obj )

import matlab.graphics.chart.internal.stackedplot.getValidVariableNames


if ~isempty( obj.ChartData.XVariable )
try 
obj.XVariableValidationStrategy.validateXVariable( obj.ChartData, obj.ChartData.XVariable, obj.Presenter.ChartClassName );
catch ME

obj.WarningFun( message( "MATLAB:stackedplot:InvalidXVariableRemoved", ME.message ) );
obj.ChartData.XVariable = [  ];
end 
end 


if obj.ChartData.DisplayVariablesMode == "auto"
obj.AutoDisplayVariablesStrategy.setAutoDisplayVariables( obj.ChartData, obj.WarningFun );
else 
validVars = getValidVariableNames( obj.ChartData.SourceTable );
obj.DisplayVariables = removeInvalidDisplayVariables( obj, validVars );
end 

obj.ValidationStrategy.validate( obj.ChartData );
end 

function varIndex = getVariableIndex( obj )
varIndex = obj.ChartData.getVariableIndex(  );
end 

function innerVarIdx = getInnerVariableIndex( obj )
innerVarIdx = obj.ChartData.getInnerVariableIndex(  );
end 
end 

methods ( Access = private )
function v = applyForAxes( obj, fcn, axesIndex )







R36
obj
fcn
axesIndex = 1:obj.getNumAxes(  )
end 
if nargin == 3 && isscalar( axesIndex )
v = fcn( obj.ChartData, axesIndex );
else 
v = cell( length( axesIndex ), 1 );
for i = 1:length( axesIndex )
v{ i } = fcn( obj.ChartData, axesIndex( i ) );
end 
end 
end 
end 
end 

function vars = removeInvalidDisplayVariables( obj, validVars )

if iscellstr( obj.ChartData.DisplayVariables )
vars = obj.ChartData.DisplayVariables;
vars( ~ismember( vars, validVars ) ) = [  ];
else 
vars = obj.ChartData.DisplayVariables;
for i = length( vars ): - 1:1
currvar = vars{ i };
if ~iscell( currvar )
currvar = { currvar };
end 
currvar( ~ismember( currvar, validVars ) ) = [  ];
if isscalar( currvar )
vars{ i } = currvar{ 1 };
elseif isempty( currvar )
vars( i ) = [  ];
else 
vars{ i } = currvar;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeGMNNh.p.
% Please follow local copyright laws when handling this file.

