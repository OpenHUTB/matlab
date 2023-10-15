function p = plotKinematicGraph_internal( G, nameValueArgs )

arguments
    G( 1, 1 )digraph
    nameValueArgs.Layout( 1, 1 )string{ mustBeMember( nameValueArgs.Layout, [ "tree", "circle", "snake", "layered" ] ) } = "tree"
end


nodeColor = [ 0, 0, 1 ];
explicitJointColor = [ 0, 1, 0 ];
implicitJointColor = [ .8, 1, .8 ];


numJoints = height( G.Edges );


expJointIndices = find( G.Edges.Explicit );
impJointIndices = find( ~G.Edges.Explicit );


edgeColors = repmat( explicitJointColor, numJoints, 1 );
lineStyles = repmat( "-", numJoints, 1 );


edgeColors( impJointIndices, : ) = repmat( implicitJointColor, numel( impJointIndices ), 1 );


if ( nameValueArgs.Layout == "tree" )
    [ x, y ] = treeLocations( G );
elseif ( nameValueArgs.Layout == "circle" )
    [ x, y ] = circleLocations( G );
elseif ( nameValueArgs.Layout == "snake" )
    [ x, y ] = snakeLocations( G );
elseif ( nameValueArgs.Layout == "layered" )

end


lineWidth = 3.0;



plot( [ NaN, NaN ], [ NaN, NaN ], 'o', 'Marker', 'o',  ...
    'MarkerSize', 10, 'MarkerFaceColor', nodeColor, 'MarkerEdgeColor', 'b' );
hold on;
legendNames = [ "Body" ];
if ~isempty( expJointIndices )
    plot( [ NaN, NaN ], [ NaN, NaN ], '-', 'LineWidth', lineWidth, 'Color', explicitJointColor );
    if ~isempty( impJointIndices )
        legendNames = [ legendNames, "Explicit Joint" ];
    else
        legendNames = [ legendNames, "Joint" ];
    end
end
if ~isempty( impJointIndices )
    plot( [ NaN, NaN ], [ NaN, NaN ], '-', 'LineWidth', lineWidth, 'Color', implicitJointColor );
    legendNames = [ legendNames, "Implicit Joint" ];
end


if ( nameValueArgs.Layout == "layered" )

    p = plot( G, 'Layout', 'layered', 'EdgeLabel', G.Edges.Name );
else

    p = plot( G, 'EdgeLabel', G.Edges.Name, 'XData', x', 'YData', y' );
end
hold off;


p.Interpreter = 'none';
p.NodeLabelMode = 'auto';
p.MarkerSize = 10;
p.Marker = 'o';
p.LineWidth = lineWidth;
p.NodeColor = nodeColor;
p.ArrowSize = 12;
p.EdgeColor = edgeColors;
p.LineStyle = lineStyles;

ax = p.Parent;
set( ax, 'XTick', [  ], 'YTick', [  ] );
set( ax, 'TickLabelInterpreter', 'none' );

fig = ax.Parent;
dcm = datacursormode( fig );
dcm.Interpreter = 'none';

legend( legendNames );

end


function [ x, y ] = treeLocations( G )
x = G.Nodes.Location( :, 1 );
y =  - G.Nodes.Location( :, 2 );
end


function [ x, y ] = circleLocations( G )
locs = double( G.Nodes.Location );
posns = locs( :, 1 );
posQuantum = 1;
minPos = min( posns );
halfRange = range( posns ) / 2;
mid = minPos + halfRange;
halfRange = halfRange + posQuantum / 2;
angles = ( ( posns - mid ) / halfRange - 0.5 ) * pi;
x = locs( :, 2 ) .* cos( angles );
y = locs( :, 2 ) .* sin( angles );
end


function [ x, y ] = snakeLocations( G )
n = height( G.Nodes );
indices = ( 0:( n - 1 ) )';
numCols = ceil( sqrt( n ) );
row = floor( indices / numCols );
m = mod( row, 2 );
x = ( indices - row * numCols ) .* ( (  - 1 ) .^ m ) + ( m * ( numCols - 1 ) );
y =  - row;
end


