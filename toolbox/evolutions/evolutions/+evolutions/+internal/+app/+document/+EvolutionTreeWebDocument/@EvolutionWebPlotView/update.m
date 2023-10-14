function update( this, rootEvolution, evolutionCreated )

clearCachedData( this );
this.Syntax.modify( @( operations )clearPlot( this, operations ) );

if ~isempty( rootEvolution )
    this.Syntax.modify( @( operations )createTreePlot( this, rootEvolution ) );

    gatherLayoutInfo( this );

    this.Syntax.modify( @( operations )drawRectanglesWithText( this, rootEvolution, operations ) );
    addNodeStyle( this );
    if ( evolutionCreated )

        activeId = this.ActiveEi.Parent.Id;
        activeNode = this.EvolutionIdToNode( activeId );

        selector = this.Editor.getSelection(  );
        selector.select( activeNode );
    else

        activeId = this.ActiveEi.Id;
        activeNode = this.EvolutionIdToNode( activeId );
        conn = activeNode.connections;

        selector = this.Editor.getSelection(  );
        this.Syntax.modify( @( operations )setConnTitle( this, conn, operations ) );
        selector.select( conn );
    end
end



this.Editor.getCanvas(  ).fitToView(  );
end


function setConnTitle( ~, conn, operations )
if ( ~isempty( conn ) )
    operations.setTag( conn, 'ActiveEvolutionConnection' );
end
end

function clearPlot( this, operations )
root = this.Syntax.root;
for i = numel( root.entities ): - 1:1
    destroy( operations, root.entities( i ), true );
end
end

function clearCachedData( this )
this.RootEi = [  ];
this.CurrentEi = [  ];
this.ActiveEi = [  ];
this.SelectedNode = [  ];
end

function createTreePlot( this, rootEvolution )
this.EvolutionIdToNode = containers.Map;
this.EvolutionIdToInfo = containers.Map;
this.RootEi = rootEvolution;
eis = gatherAllEis( this, rootEvolution );
numEvs = numel( eis );

this.NodeMap = containers.Map;
tableCell = cell( numEvs, 1 );
edgeMatrix = zeros( numEvs - 1, 2 );

for evIdx = 1:numEvs
    curEi = eis( evIdx );
    tableCell{ evIdx } = char( curEi.Id );

    nodeInfo = evolutions.internal.report.NodeInfo;
    nodeInfo.Index = evIdx;
    nodeInfo.Ei = curEi;
    nodeInfo.Name = curEi.getName;
    this.NodeMap( curEi.Id ) = nodeInfo;
end

this.NodeTable = table( tableCell, 'VariableNames', { 'Id' } );
edgeIdx = 0;

for evIdx = 1:numEvs
    curEi = eis( evIdx );
    curId = curEi.Id;
    for childIdx = 1:numel( curEi.Children )

        edgeIdx = edgeIdx + 1;
        infoOne = this.NodeMap( curId );
        infoTwo = this.NodeMap( curEi.Children( childIdx ).Id );
        edgeMatrix( edgeIdx, : ) = [ infoOne.Index,  ...
            infoTwo.Index ];
    end
end


this.EdgeTable = table( edgeMatrix, 'VariableNames', { 'EndNodes' } );
this.Digraph = digraph( this.EdgeTable, this.NodeTable );



plot = matlab.graphics.chart.primitive.GraphPlot( 'BasicGraph',  ...
    MLDigraph( this.Digraph ), 'Layout', 'layered' );
XCoordinates = plot.XData;
YCoordinates = plot.YData;

nodeKeys = this.NodeMap.keys;
this.IndexToXY = containers.Map( 'KeyType', 'double',  ...
    'ValueType', 'any' );
for keyIdx = 1:numel( nodeKeys )
    curKey = nodeKeys{ keyIdx };
    nodeInfo = this.NodeMap( curKey );
    nodeInfo.X = XCoordinates( nodeInfo.Index );
    nodeInfo.Y = YCoordinates( nodeInfo.Index );
    this.IndexToXY( nodeInfo.Index ) = [  ...
        XCoordinates( nodeInfo.Index ),  ...
        YCoordinates( nodeInfo.Index ) ];
end
end

function eis = gatherAllEis( this, ei )
eis = ei;
eis = addChildrenRecursively( this, eis, ei );
end

function eis = addChildrenRecursively( this, eis, ei )
if ei.IsWorking
    this.CurrentEi = ei.Parent;
    this.ActiveEi = ei;
end
children = ei.Children;
for chdIdx = 1:numel( children )
    curChild = children( chdIdx );
    eis = [ eis, curChild ];%#ok<AGROW>
    eis = addChildrenRecursively( this, eis, curChild );
end
end

function gatherLayoutInfo( this )




this.LayoutInfo.xMinDist = inf;
this.LayoutInfo.xLines = [  ];
this.LayoutInfo.xMin = [  ];
this.LayoutInfo.xMax = [  ];
this.LayoutInfo.yLines = 0;
this.LayoutInfo.yLinesDist = inf;
this.LayoutInfo.yMin = [  ];
this.LayoutInfo.yMax = [  ];


nodeInfos = this.NodeMap.values;
numPoints = numel( nodeInfos );


xVals = zeros( 1, numPoints );
yVals = zeros( 1, numPoints );



yBuckets = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
for infosIdx = 1:numPoints
    curInfo = nodeInfos{ infosIdx };
    curX = curInfo.X;
    curY = curInfo.Y;
    xVals( infosIdx ) = curX;
    yVals( infosIdx ) = curY;
    if yBuckets.isKey( curY )
        xLineVals = yBuckets( curY );
        xLineVals = [ xLineVals, curX ];%#ok<AGROW>
        yBuckets( curY ) = xLineVals;
    else
        yBuckets( curY ) = curX;
    end
end


xVals = unique( xVals );
yVals = unique( yVals );


this.LayoutInfo.xMin = xVals( 1 );
this.LayoutInfo.xMax = xVals( end  );
this.LayoutInfo.yMin = yVals( 1 );
this.LayoutInfo.yMax = yVals( end  );


this.LayoutInfo.xLines = numel( xVals );
this.LayoutInfo.yLines = numel( yVals );



yBucketKeys = yBuckets.keys;
for keyIdx = 1:numel( yBucketKeys )
    curKey = yBucketKeys{ keyIdx };
    xVals = yBuckets( curKey );
    numVals = numel( xVals );
    if numVals > 1

        xVals = sort( xVals );
        curDist = xVals( 2 ) - xVals( 1 );
        if curDist < this.LayoutInfo.xMinDist
            this.LayoutInfo.xMinDist = curDist;
        end
    end
end


if this.LayoutInfo.yLines > 1
    this.LayoutInfo.yLinesDist = yVals( 2 ) - yVals( 1 );
end
end


function drawRectanglesWithText( this, rootEvolution, operations )
nodeKeys = this.NodeMap.keys;

lenNodeKeys = numel( nodeKeys );
eis = gatherAllEis( this, rootEvolution );
numEvs = numel( eis );

for keyIdx = 1:lenNodeKeys
    curKey = nodeKeys{ keyIdx };
    nodeInfo = this.NodeMap( curKey );

    node = operations.createEntity( this.Syntax.root );

    if isequal( nodeInfo.Ei, this.ActiveEi )
        operations.setType( node, 'evolutions.ActiveEvolutionGlyph' );

        operations.setAttributeValue( node, 'Name', 'ProjectName' );



        operations.setTag( node, 'Active Evolution' );
    end

    setNodeProperties( this, node, nodeInfo, operations );

    this.EvolutionIdToNode( nodeInfo.Ei.Id ) = node;
    this.EvolutionIdToInfo( nodeInfo.Ei.Id ) = nodeInfo.Ei;


    buildInputOutputPorts( node, operations, numel( nodeInfo.Ei.Children ) );
end


for evIdx = 1:numEvs
    curEi = eis( evIdx );
    curId = curEi.Id;
    operations.setAttributeValue( this.EvolutionIdToNode( curId ), "evolutionId", string( curId ) )


    if ( evIdx == 1 )
        operations.setAttributeValue( this.EvolutionIdToNode( curId ), "levelNumber", string( evIdx ) );
    end
    for childIdx = 1:numel( curEi.Children )
        from = this.EvolutionIdToNode( curId );
        to = this.EvolutionIdToNode( curEi.Children( childIdx ).Id );
        connection = operations.createConnection( from.ports( 2 ), to.ports( 1 ) );

        operations.setAttributeValue( connection, 'connectionTitle', string( connection.uuid ) )
        operations.setAttributeValue( connection, 'fromEvolutionId', string( curId ) );
        operations.setAttributeValue( connection, 'toEvolutionId', string( curEi.Children( childIdx ).Id ) );
        operations.setAttributeValue( connection,  ...
            'toEvolutionName', string( curEi.Children( childIdx ).getName ) );

        operations.setAttributeValue( this.EvolutionIdToNode( curEi.Children( childIdx ).Id ), "childNumber", string( childIdx ) );
    end
end
end



function setNodeProperties( this, node, nodeInfo, operations )
[ recLength, recHeight ] = calculateRectangleDims( this );

operations.setTitle( node, nodeInfo.Ei.getName );
operations.setShape( node, diagram.interface.Shape.Rectangle );
operations.setAttributeValue( node, 'EvolutionId', nodeInfo.Ei.Id );
operations.setSize( node, recLength * 150, recHeight * 150 );
operations.setPosition( node, ( nodeInfo.X - recLength / 2 ) * 130,  - ( nodeInfo.Y - recHeight / 2 ) * 130 );
end

function [ recLength, recHeight ] = calculateRectangleDims( this )
if this.LayoutInfo.xLines == 1
    recLength = this.SingleXRowNodeFill;
else
    recLength = this.LayoutInfo.xMinDist *  ...
        this.MultipleXRowNodeFill;
end

if this.LayoutInfo.yLines == 1
    recHeight = this.SingleYRowNodeFill;
else
    recHeight = this.LayoutInfo.yLinesDist *  ...
        this.MultipleYRowNodeFill;
end
end

function buildInputOutputPorts( node, operations, number )

inPort = createPort( node, operations, diagram.interface.Location.Top, 'Input' );
outPort = createPort( node, operations, diagram.interface.Location.Bottom, 'Output' );
operations.setAttributeValue( inPort, 'PortType', 'Input' );
operations.setAttributeValue( outPort, 'PortType', 'Output' );


operations.setAttributeValue( outPort, 'OutPortChildren', string( number ) );
end

function port = createPort( node, operations, location, portType )
arguments
    node
    operations
    location
    portType
end
port = operations.createPort( node );
operations.setLocation( port, location );
operations.setAttributeValue( port, 'PortType', portType );
end



