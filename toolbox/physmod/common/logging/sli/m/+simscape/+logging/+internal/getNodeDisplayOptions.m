function res = getNodeDisplayOptions( node, names, defaults )




arguments
    node simscape.logging.Node{ mustBeNonempty }
    names string
    defaults cell
end

if ~isscalar( node )
    node = node( 1 );
end
s = lGetCustomDisplayOptions( node );

res = defaults;
if ~isempty( s )
    for idx = 1:numel( names )
        v = s.( names( idx ) );
        if ~isempty( v )
            res{ idx } = v;
        end
    end
end

end

function customDisplay = lGetCustomDisplayOptions( node )

persistent DATA_MAP TAGS
if isempty( DATA_MAP )

    iconDir = [ matlabroot, '/toolbox/physmod/common/logging/sli/m/resources/icons/' ];
    if exist( iconDir, 'dir' )
        icons.statistics = [ iconDir, 'statistics.png' ];
        icons.zeroCrossing = [ iconDir, 'zero_crossing.png' ];
        icons.signalCrossings = [ iconDir, 'zc_crossings.png' ];
        icons.signalValues = [ iconDir, 'zc_values.png' ];
    else
        iconDir = [ matlabroot, '/toolbox/matlab/icons/' ];
        icons.statistics = [ iconDir, 'profiler.gif' ];
        icons.zeroCrossing = [ iconDir, 'pageicon.gif' ];
        icons.signalCrossings = [ iconDir, 'greenarrowicon.gif' ];
        icons.signalValues = [ iconDir, 'greenarrowicon.gif' ];
    end


    DATA_MAP.SimulationStatistics.Statistics =  ...
        struct( 'TreeNodeIcon', icons.statistics,  ...
        'TreeNodeLabelFcn', @lSimulationStatisticsTreeLabel,  ...
        'PrintStatusFcn', @lSimulationStatisticsPrintStatus,  ...
        'PrintLocationFcn', '',  ...
        'IsPlottedByParent', true,  ...
        'GetNodesToPlotFcn', @lSimulationStatisticsNodesToPlot,  ...
        'PlotNodeFcn', @lPlotSimulationStatistics );
    DATA_MAP.SimulationStatistics.ZeroCrossing =  ...
        struct( 'TreeNodeIcon', icons.zeroCrossing,  ...
        'TreeNodeLabelFcn', @lZeroCrossingTreeLabel,  ...
        'PrintStatusFcn', @lZeroCrossingPrintStatus,  ...
        'PrintLocationFcn', @lZeroCrossingPrintLocation,  ...
        'IsPlottedByParent', false,  ...
        'GetNodesToPlotFcn', @lZeroCrossingNodesToPlot,  ...
        'PlotNodeFcn', '' );
    DATA_MAP.ZeroCrossing.SignalCrossings =  ...
        struct( 'TreeNodeIcon', icons.signalCrossings,  ...
        'TreeNodeLabelFcn', '',  ...
        'PrintStatusFcn', @lZeroCrossingCrossingsPrintStatus,  ...
        'PrintLocationFcn', '',  ...
        'IsPlottedByParent', true,  ...
        'GetNodesToPlotFcn', '',  ...
        'PlotNodeFcn', @lPlotSignalCrossings );
    DATA_MAP.ZeroCrossing.SignalValues =  ...
        struct( 'TreeNodeIcon', icons.signalValues,  ...
        'TreeNodeLabelFcn', '',  ...
        'PrintStatusFcn', @lZeroCrossingValuesPrintStatus,  ...
        'PrintLocationFcn', '',  ...
        'IsPlottedByParent', true,  ...
        'GetNodesToPlotFcn', '',  ...
        'PlotNodeFcn', @lPlotSignalValues );
    TAGS = fields( DATA_MAP );
end
customDisplay = [  ];
for idx = 1:numel( TAGS )
    f = TAGS{ idx };
    if node.hasTag( f )
        t = node.getTag( f );
        d = DATA_MAP.( f );
        if isfield( d, t{ 2 } )
            customDisplay = d.( t{ 2 } );
        end
        break
    end
end
end

function res = lHasTagValue( node, name, value )

if numel( node ) > 1
    node = node( 1 );
end


res = node.hasTag( name ) && isequal( node.getTag( name ), { name, value } );
end

function label = lSimulationStatisticsTreeLabel( ~ )

label = 'SimulationStatistics (ZeroCrossings)';
end


function label = lZeroCrossingTreeLabel( node )

assert( numel( node ) == 1 );
numCrossings = sum( node.crossings.series.values );
switch numCrossings
    case 0
        label = sprintf( '%s - no crossings', node.id );
    case 1
        label = sprintf( '%s - 1 crossing', node.id );
    otherwise
        label = sprintf( '%s - %d crossings', node.id, numCrossings );
end
end

function [ statusTitle, statusDesc, statusUnit, statusStats ] =  ...
    lSimulationStatisticsPrintStatus( simulationStatisticsNode )

assert( numel( simulationStatisticsNode ) == 1,  ...
    'The simulation statistics node should be scalar' );

node = simulationStatisticsNode{ 1 };
statusTitle = getMessageFromCatalog( 'SelectedNodeStats' );


hasZCTag = @( n )lHasTagValue( n, 'SimulationStatistics', 'ZeroCrossing' );
isZC = @( x )( hasZCTag( x{ end  } ) );

loggedZeroCrossings = node.find( isZC );

if ~isempty( loggedZeroCrossings )
    numPoints = loggedZeroCrossings{ 1 }.values.series.points;

    countCrossings = @( n )sum( n.crossings.series.values(  ) );
    numCrossings = sum( cellfun( countCrossings, loggedZeroCrossings ) );

else
    numPoints = NaN;
    numCrossings = NaN;
end

[ statusDesc, statusUnit ] = lPrintNodeId( node );
statusStats = sprintf( [ '%s\n' ...
    , '%s\n' ...
    , '%s' ],  ...
    getMessageFromCatalog( 'NumTimeSteps', num2str( numPoints ) ),  ...
    getMessageFromCatalog( 'NumLoggedZeroCrossings', num2str( numel( loggedZeroCrossings ) ) ),  ...
    getMessageFromCatalog( 'NumZeroCrossings', num2str( numCrossings ) ) );
end

function [ str, nodeUnit ] = lPrintNodeId( node )


str = '';
nodeUnit = '';

if ( node( 1 ).hasSource(  ) )
    [ str, nodeUnit ] = lGetNodeDescription( node );
end
end

function [ nodeDesc, nodeUnit ] = lGetNodeDescription( node )

dimension = mat2str( size( node ) );

if isscalar( node )
    nodeDescription = node.id;
    node = node( 1 );
else
    nodeDescription = node.getDescription;
end

if isempty( nodeDescription )
    nodeTruncatedDesc = node.getName;
else




    maxSize = 35;
    if numel( nodeDescription ) > maxSize
        nodeTruncatedDesc = [ nodeDescription( 1:maxSize ), ' ' ...
            , getMessageFromCatalog( 'VariableDescriptionEllipsis' ) ];
    else
        nodeTruncatedDesc = nodeDescription;
    end
end

conversion = node.series.conversion;

descriptionMsg = getMessageFromCatalog( 'VariableDescription' );
conversionMsg = getMessageFromCatalog( 'UnitConversion', conversion );

if ~isempty( node.getDescription )
    nodeDesc = sprintf( '\n%s %s\n',  ...
        descriptionMsg, nodeTruncatedDesc );
    nodeUnit = sprintf( '%s\n', conversionMsg );
else

    dimensionMsg = getMessageFromCatalog( 'NodeDimension' );
    dimensionMsg = [ dimensionMsg, dimension ];
    nodeDesc = sprintf( '\n%s %s \n',  ...
        descriptionMsg, nodeTruncatedDesc );
    nodeUnit = sprintf( '%s \n', dimensionMsg );
end
end

function [ statusTitle, statusDesc, statusUnit, statusStats ] =  ...
    lZeroCrossingPrintStatus( zcNode )


[ statusTitle, statusDesc, statusUnit, statusStats ] =  ...
    lSimulationStatisticsPrintStatus( zcNode );
end

function [ statusTitle, statusDesc, statusUnit, statusStats ] =  ...
    lZeroCrossingCrossingsPrintStatus( zcCrossingsNode )

assert( numel( zcCrossingsNode ) == 1 );

node = zcCrossingsNode{ 1 };
statusTitle = getMessageFromCatalog( 'SelectedNodeStats' );
numPoints = node.series.points;
numCrossings = sum( node.series.values(  ) );

[ statusDesc, statusUnit ] = lPrintNodeId( node );
statusStats = sprintf( [ '%s\n' ...
    , '%s' ],  ...
    getMessageFromCatalog( 'NumTimeSteps', num2str( numPoints ) ),  ...
    getMessageFromCatalog( 'NumZeroCrossings', num2str( numCrossings ) ) );
end

function [ statusTitle, statusDesc, statusUnit, statusStats ] =  ...
    lZeroCrossingValuesPrintStatus( zcValuesNode )


assert( numel( zcValuesNode ) == 1 );

node = zcValuesNode{ 1 };
statusTitle = getMessageFromCatalog( 'SelectedNodeStats' );
numPoints = node.series.points;

[ statusDesc, statusUnit ] = lPrintNodeId( node );
statusStats = sprintf( '%s',  ...
    getMessageFromCatalog( 'NumTimeSteps', num2str( numPoints ) ) );
end

function [ str ] = lZeroCrossingPrintLocation( node )


assert( numel( node ) == 1 );

str = '';

key = 'ZeroCrossingLocation';
if node.hasTag( key )
    tag = node.getTag( key );
    fileLocation = tag{ 2 };
    if ~isempty( fileLocation )
        tokens = textscan( fileLocation, '%s%d%d', 'Delimiter', ',' );
        fileName = tokens{ 1 }{ 1 };

        if exist( which( fileName ), 'file' )
            str = sprintf( '%s %s',  ...
                getMessageFromCatalog( 'ZeroCrossingLocation', '' ), fileName );
        end
    else
        str = sprintf( '%s',  ...
            getMessageFromCatalog( 'ZeroCrossingLocation', getMessageFromCatalog( 'ZeroCrossingLocationUnAvailable' ) ) );
    end
end
end

function [ nodesToPlot, pathsToPlot, labelsToPlot, optionsToPlot ] =  ...
    lSimulationStatisticsNodesToPlot( nodes, paths, labels, options )

assert( numel( nodes ) == 1 );

nodesToPlot = nodes;
pathsToPlot = paths;
labelsToPlot = labels;

optionsToPlot = options;

optionsToPlot.layout = getMessageFromCatalog( 'PlotOverlay' );
optionsToPlot.legend = getMessageFromCatalog( 'PlotLegendNever' );

end

function [ nodesToPlot, pathsToPlot, labelsToPlot, optionsToPlot ] =  ...
    lZeroCrossingNodesToPlot( nodes, paths, ~, options )

assert( numel( nodes ) == 1 );
node = nodes{ 1 };
assert( numel( node ) == 1 );
assert( numel( paths ) == 1 );
path = paths{ 1 };
nodesToPlot = { node.crossings, node.values };
pathsToPlot = { [ path, { 'crossings' } ], [ path, { 'values' } ] };
labelsToPlot = { 'crossings', 'values' };

optionsToPlot = options;

optionsToPlot.layout = getMessageFromCatalog( 'PlotOverlay' );
optionsToPlot.legend = getMessageFromCatalog( 'PlotLegendNever' );

end

function lPlotSimulationStatistics( ~, nodes, ax, options, ~, ~, ~, ~, ~ )

if ~iscell( nodes )
    nodes = { nodes };
end
assert( numel( nodes ) == 1 );
statisticsNode = nodes{ 1 };

zcNodeIds = simscape.logging.internal.sortChildIds( statisticsNode );

time = [  ];values = [  ];
for i = 1:numel( zcNodeIds )
    zcNodes = statisticsNode.child( zcNodeIds{ i } );
    crossingNode = zcNodes( 1 ).crossings;
    if isempty( time )
        time = crossingNode.series.time;
    end
    if isempty( values )
        values = crossingNode.series.values;
    else


        values = [ values, crossingNode.series.values ];%#ok<AGROW>
    end
end

values = sum( values, 2 );


[ t, v ] = lPrepareCrossingDataForCumulativePlot( time, values );


plot( ax, t, v, 'Marker', 'x' );


title( ax, 'SimulationStatistics (ZeroCrossings)', 'Interpreter', 'none' );
xlabel( ax, getMessageFromCatalog( 'XAxisTime' ), 'Interpreter', 'none' );
ylabel( ax, getMessageFromCatalog( 'YAxisAllCrossings' ), 'Interpreter', 'none' );
grid( ax, 'on' );
xlim( ax, [ options.time.start, options.time.stop ] );
end

function lPlotZCSignal( ax, nodes, paths, ~, options, marker,  ...
    ylab, dataFcn )

if ~iscell( nodes )
    nodes = { nodes };
end

colors = colororder;
numColors = size( colors, 1 );
for i = 1:numel( nodes )
    node = nodes{ i };
    assert( numel( node ) == 1 );

    [ t, v ] = dataFcn( node.series.time, node.series.values );
    colorIdx = 1 + mod( i - 1, numColors );
    plot( ax, t, v, 'Marker', marker, 'Color', colors( colorIdx, : ) );
    hold( ax, 'on' );
end
hold( ax, 'off' );


legendSelection = options.legend;
legendEntries = cell( size( paths ) );
for idx = 1:numel( paths )
    legendEntries{ idx } = simscape.logging.internal.indexedPathLabel( paths{ idx }( 2:end  ) );
end

legendEntries = strrep( strrep( strrep( legendEntries,  ...
    '.SimulationStatistics', '' ),  ...
    '.values', '' ),  ...
    '.crossings', '' );

switch legendSelection
    case { getMessageFromCatalog( 'PlotLegendAuto' ), getMessageFromCatalog( 'PlotLegendAlways' ) }
        if ~isempty( legendEntries ) && ~isempty( get( ax, 'Children' ) )
            legend( ax, legendEntries, 'Interpreter', 'none' );
        end
    case getMessageFromCatalog( 'PlotLegendNever' )

end


title( ax, 'SimulationStatistics (ZeroCrossings)', 'Interpreter', 'none' );
xlabel( ax, getMessageFromCatalog( 'XAxisTime' ), 'Interpreter', 'none' );
ylabel( ax, ylab, 'Interpreter', 'none' );
grid( ax, 'on' );


xlim( ax, [ options.time.start, options.time.stop ] );
end

function lPlotSignalCrossings( ~, nodes, ax, options, ~, paths, labels, ~, ~ )

marker = options.marker;
if strcmpi( marker, getMessageFromCatalog( 'PlotMarkerNone' ) )
    marker = 'x';
end
lPlotZCSignal( ax, nodes, paths, labels, options, marker,  ...
    getMessageFromCatalog( 'YAxisCrossings' ),  ...
    @lPrepareCrossingDataForCumulativePlot );
end

function lPlotSignalValues( ~, nodes, ax, options, ~, paths, labels, ~, ~ )

marker = options.marker;
lPlotZCSignal( ax, nodes, paths, labels, options, marker,  ...
    getMessageFromCatalog( 'YAxisValues' ), @deal );
end

function [ tt, vv ] = lPrepareCrossingDataForCumulativePlot( t, v )

idx = find( v > 0 );
tstep = [ t( 1 );( 1 - eps ) * t( idx );t( idx ) ];
vstep = [ v( 1 );zeros( size( idx ) );v( idx ) ];
[ tt, idx ] = sort( tstep );
vv = cumsum( vstep( idx ) );
vv = [ vv( : );vv( end  ) ]';
tt = [ tt( : );t( end  ) ]';
end
