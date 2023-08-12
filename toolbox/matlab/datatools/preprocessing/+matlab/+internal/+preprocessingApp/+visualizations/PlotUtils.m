classdef PlotUtils






methods ( Static )


function plotType = getPlotType( yData )
if isnumeric( yData ) || isduration( yData ) || isdatetime( yData )
if ~isduration( yData ) && ~isdatetime( yData )
plotType = "plot";
else 
plotType = "histogram";
end 
elseif iscategorical( yData ) || isordinal( yData )
plotType = "histogram";
else 
plotType = "strhistogram";
end 
end 

function [ plotType, unpreprocessedPlot, preprocessedPlot ] = plotData( axesObj, xData, yData, xOrigData, yOrigData, dataVars, isTimetableTimeVar, plotName, plotType, displayPref )
R36
axesObj
xData
yData
xOrigData
yOrigData
dataVars( 1, : )string = "", 
isTimetableTimeVar( 1, : )logical = false
plotName( 1, 1 )string = ""
plotType( 1, 1 )string = ""
displayPref = [ 1, 1 ]
end 
if strlength( plotType ) <= 0
plotType = matlab.internal.preprocessingApp.visualizations.PlotUtils.getPlotType( yData );
end 

yData = prepDataForPlotting( yData, plotType );
yOrigData = prepDataForPlotting( yOrigData, plotType );
[ unpreprocessedPlot, preprocessedPlot ] = updatePlot( axesObj, xData, yData, xOrigData, yOrigData, dataVars, isTimetableTimeVar, plotName, plotType, displayPref );
end 


function result = testprepDataForPlotting( yData, plotType, plotWidth )
R36
yData
plotType
plotWidth( 1, 1 )double = 1000
end 
result = prepDataForPlotting( yData, plotType, plotWidth );
end 


function testupdatePlot( axesObj, xData, yData, xOrigData, yOrigData,  ...
dataVars, plotName, isTimetableTimeVar, plotType, displayPref )
updatePlot( axesObj, xData, yData, xOrigData, yOrigData,  ...
dataVars, plotName, isTimetableTimeVar, plotType, displayPref );
end 
end 
end 

function [ newYData ] = prepDataForPlotting( yData, plotType, plotWidth )
R36
yData
plotType
plotWidth( 1, 1 )double = 1000
end 
newYData = yData;
if strcmp( plotType, "strhistogram" )



minPixelsPerBar = 15;
maxBars = floor( plotWidth / minPixelsPerBar );


try 
newYData = categorical( yData );
catch 
newYData = categorical( cellfun( @num2str, yData, "UniformOutput", 0 ) );
end 
cats = categories( newYData );
counts = countcats( newYData );
t = table( cats, counts );
t = sortrows( t, 'cats', "ascend" );


if length( cats ) > maxBars
itemsPerBin = floor( height( t ) / maxBars );
remainder = height( t ) - ( maxBars * itemsPerBin );


while remainder > itemsPerBin
maxBars = maxBars - 1;
itemsPerBin = floor( height( t ) / maxBars );
remainder = height( t ) - ( maxBars * itemsPerBin );
end 



newCats = string.empty;
for i = 1:maxBars
startIndex = ( i - 1 ) * itemsPerBin + 1;
endIndex = startIndex + itemsPerBin - 1;
newCatName = string( t.cats{ startIndex } ) + " - " + string( t.cats{ endIndex } );
newCatCount = sum( t.counts( startIndex:endIndex ) );
newCats = [ newCats, repmat( newCatName, 1, newCatCount ) ];%#ok<AGROW>
end 
if remainder > 0
newCatCount = sum( t.counts( endIndex + 1:end  ) );
newCatName = string( t.cats{ endIndex + 1 } ) + " - " + string( t.cats{ end  } );
newCats = [ newCats, repmat( newCatName, 1, newCatCount ) ];
end 
newYData = categorical( newCats );
end 
end 
end 

function [ unpreprocessedPlot, preprocessedPlot ] = updatePlot( axesObj, xData, yData, xOrigData, yOrigData, dataVars, isTimetableTimeVar, plotName, plotType, displayPref )
cla( axesObj );

axesObj.YLimMode = 'auto';
axesObj.XLimMode = 'auto';
if isempty( yOrigData ) || ~strcmp( class( yOrigData ), class( yData ) ) ||  ...
isempty( xOrigData ) || ~strcmp( class( xOrigData ), class( xData ) )
yOrigData = yData;
xOrigData = xData;
end 

unpreprocessedPlot = [  ];
preprocessedPlot = [  ];
switch plotType
case "strhistogram"
if displayPref( 1 ) == 1
unpreprocessedPlot = histogram( axesObj, yOrigData );
hold( axesObj, 'on' );
end 
if displayPref( 2 ) == 1
preprocessedPlot = histogram( axesObj, yData );
end 

axesObj.XLabel.String = dataVars( 1 );
axesObj.YLabel.String =  ...
getString( message( 'MATLAB:datatools:preprocessing:visualizations:plotutils:StrHistogram_YLabel' ) );
preprocessedPlot.FaceColor = [ 0, 0.4470, 0.7410 ];
unpreprocessedPlot.FaceColor = [ 0.3010, 0.7450, 0.9330 ];
case "histogram"
if displayPref( 1 ) == 1
if ~isdatetime( yOrigData ) && ~isduration( yOrigData ) && ~iscalendarduration( yOrigData )
unpreprocessedPlot = histogram( axesObj, yOrigData, 'EdgeColor', [ 0.3010, 0.7450, 0.9330 ], 'DisplayOrder', 'descend' );
else 
unpreprocessedPlot = histogram( axesObj, yOrigData, 'EdgeColor', [ 0.3010, 0.7450, 0.9330 ] );
end 
hold( axesObj, 'on' );
end 

if displayPref( 2 ) == 1
if ~isdatetime( yData ) && ~isduration( yData ) && ~iscalendarduration( yData )
preprocessedPlot = histogram( axesObj, yData, 'EdgeColor', [ 0, 0.4470, 0.7410 ], 'DisplayOrder', 'descend' );
else 
preprocessedPlot = histogram( axesObj, yData, 'EdgeColor', [ 0, 0.4470, 0.7410 ] );
end 
end 
axesObj.XLabel.String = dataVars( 1 );
if ( isTimetableTimeVar )
axesObj.YLabel.String =  ...
getString( message( 'MATLAB:datatools:preprocessing:visualizations:plotutils:Histogram_YLabel' ) );
set( axesObj, 'yscale', 'log' );
else 
axesObj.YLabel.String =  ...
getString( message( 'MATLAB:datatools:preprocessing:visualizations:plotutils:StrHistogram_YLabel' ) );
end 
preprocessedPlot.FaceColor = [ 0, 0.4470, 0.7410 ];
unpreprocessedPlot.FaceColor = [ 0.3010, 0.7450, 0.9330 ];
case "plot"
if displayPref( 1 ) == 1
unpreprocessedPlot = plot( axesObj, xOrigData, yOrigData );
hold( axesObj, 'on' );
end 

if displayPref( 2 ) == 1
preprocessedPlot = plot( axesObj, xData, yData );
end 
if isequal( length( dataVars ), 2 )
axesObj.XLabel.String = dataVars( 2 );
end 
axesObj.YLabel.String = dataVars( 1 );
preprocessedPlot.Color = [ 0, 0.4470, 0.7410 ];
unpreprocessedPlot.Color = [ 0.3010, 0.7450, 0.9330 ];
case "stem"
if displayPref( 1 ) == 1
unpreprocessedPlot = stem( yOrigData, 'Marker', 'none' );
hold( axesObj, 'on' );
end 

if displayPref( 2 ) == 1
preprocessedPlot = stem( yData, 'Marker', 'none' );
end 
axesObj.XLabel.String =  ...
getString( message( 'MATLAB:datatools:preprocessing:visualizations:plotutils:Stem_XLabel' ) );
axesObj.Ylabel.String = dataVars( 1 );
end 

axesObj.Title.String = plotName;
axesObj.Title.Interactions = [  ];



hold( axesObj, 'off' );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpZbfRy0.p.
% Please follow local copyright laws when handling this file.

