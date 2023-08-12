function p = plotRigidBodyStructure_internal( G )








R36
G( 1, 1 )digraph
end 





allNodeTypes = { 'Frame', 'Geometry', 'Inertia', 'Graphic', 'Solid', 'RigidBody' };

nodeTypeMarkers = containers.Map(  ...
allNodeTypes, { 'o',  ...
'square',  ...
'square',  ...
'square',  ...
'square',  ...
'diamond',  ...
 } );

nodeTypeSizes = containers.Map(  ...
allNodeTypes, { 10,  ...
12,  ...
12,  ...
12,  ...
15,  ...
20,  ...
 } );

nodeTypeColors = containers.Map(  ...
allNodeTypes, { [ 0.0, 0.5020, 0.0 ],  ...
[ 1.0000, 0.5490, 0.0 ],  ...
[ 0.5020, 0.0, 0.5020 ],  ...
[ 0.0, 0.8078, 0.8196 ],  ...
[ 0.0, 0.0, 1.0 ],  ...
[ 1.0, 0.0, 0.0 ],  ...
 } );





transformColor = [ 0.1961, 0.8039, 0.1961 ];
connectionColor = [ 0.8588, 0.4392, 0.5765 ];

transformWidth = 3.0;
connectionWidth = 2.0;

arrowSize = 12;




numNodes = height( G.Nodes );
numEdges = height( G.Edges );
nodeTypes = G.Nodes.Type;
edgeTypes = G.Edges.Type;

nodeMarkers = cell( numNodes, 1 );
nodeSizes = zeros( numNodes, 1 );
nodeColors = zeros( numNodes, 3 );
for i = 1:numNodes
nodeType = nodeTypes{ i };
nodeMarkers{ i } = nodeTypeMarkers( nodeType );
nodeSizes( i ) = nodeTypeSizes( nodeType );
nodeColors( i, : ) = nodeTypeColors( nodeType );
end 

edgeColors = repmat( transformColor, numEdges, 1 );
edgeWidths = transformWidth * ones( numEdges, 1 );
arrowSizes = arrowSize * ones( numEdges, 1 );
edgeLabels = edgeTypes;
for i = 1:numEdges
if edgeTypes{ i } == "Conn"
edgeColors( i, : ) = connectionColor;
edgeWidths( i ) = connectionWidth;
arrowSizes( i ) = 0;
edgeLabels{ i } = G.Edges.Name{ i };
end 
end 



plot( [ NaN, NaN ], [ NaN, NaN ], 'o', 'Marker', nodeTypeMarkers( 'Frame' ),  ...
'MarkerSize', nodeTypeSizes( 'Frame' ), 'MarkerFaceColor', nodeTypeColors( 'Frame' ), 'MarkerEdgeColor', 'b' );
hold on;
legendNames = [ "Frame" ];
if any( strcmp( nodeTypes, 'Geometry' ) )
plot( [ NaN, NaN ], [ NaN, NaN ], 'o', 'Marker', nodeTypeMarkers( 'Geometry' ),  ...
'MarkerSize', nodeTypeSizes( 'Geometry' ), 'MarkerFaceColor', nodeTypeColors( 'Geometry' ), 'MarkerEdgeColor', 'b' );
legendNames = [ legendNames, "Geometry" ];
end 
if any( strcmp( nodeTypes, 'Inertia' ) )
plot( [ NaN, NaN ], [ NaN, NaN ], 'o', 'Marker', nodeTypeMarkers( 'Inertia' ),  ...
'MarkerSize', nodeTypeSizes( 'Inertia' ), 'MarkerFaceColor', nodeTypeColors( 'Inertia' ), 'MarkerEdgeColor', 'b' );
legendNames = [ legendNames, "Inertia" ];
end 
if any( strcmp( nodeTypes, 'Graphic' ) )
plot( [ NaN, NaN ], [ NaN, NaN ], 'o', 'Marker', nodeTypeMarkers( 'Graphic' ),  ...
'MarkerSize', nodeTypeSizes( 'Graphic' ), 'MarkerFaceColor', nodeTypeColors( 'Graphic' ), 'MarkerEdgeColor', 'b' );
legendNames = [ legendNames, "Graphic" ];
end 
if any( strcmp( nodeTypes, 'Solid' ) )
plot( [ NaN, NaN ], [ NaN, NaN ], 'o', 'Marker', nodeTypeMarkers( 'Solid' ),  ...
'MarkerSize', nodeTypeSizes( 'Solid' ), 'MarkerFaceColor', nodeTypeColors( 'Solid' ), 'MarkerEdgeColor', 'b' );
legendNames = [ legendNames, "Solid" ];
end 
if any( strcmp( nodeTypes, 'RigidBody' ) )
plot( [ NaN, NaN ], [ NaN, NaN ], 'o', 'Marker', nodeTypeMarkers( 'RigidBody' ),  ...
'MarkerSize', nodeTypeSizes( 'RigidBody' ), 'MarkerFaceColor', nodeTypeColors( 'RigidBody' ), 'MarkerEdgeColor', 'b' );
legendNames = [ legendNames, "Rigid Body" ];
end 
if ~isempty( edgeTypes ) && ~any( strcmp( nodeTypes, 'Conn' ) )
plot( [ NaN, NaN ], [ NaN, NaN ], '-', 'LineWidth', transformWidth, 'Color', transformColor );
legendNames = [ legendNames, "Rigid Transform" ];
end 
if any( strcmp( edgeTypes, 'Conn' ) )
plot( [ NaN, NaN ], [ NaN, NaN ], '-', 'LineWidth', connectionWidth, 'Color', connectionColor );
legendNames = [ legendNames, "Connection" ];
end 


p = plot( G, 'XData', G.Nodes.Location( :, 1 ), 'YData',  - G.Nodes.Location( :, 2 ), 'EdgeLabel', edgeLabels );
hold off;


p.Interpreter = 'none';
p.NodeLabelMode = 'auto';
p.MarkerSize = nodeSizes;
p.Marker = nodeMarkers;
p.NodeFontSize = 10;
p.LineWidth = edgeWidths;
p.NodeColor = nodeColors;
p.ArrowSize = arrowSizes;
p.EdgeColor = edgeColors;
p.ArrowPosition = 0.75;

ax = p.Parent;
set( ax, 'XTick', [  ], 'YTick', [  ] );
set( ax, 'TickLabelInterpreter', 'none' );

fig = ax.Parent;
dcm = datacursormode( fig );
dcm.Interpreter = 'none';

legend( legendNames );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpLB_EUL.p.
% Please follow local copyright laws when handling this file.

