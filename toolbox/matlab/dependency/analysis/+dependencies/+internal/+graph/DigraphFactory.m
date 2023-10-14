classdef DigraphFactory < handle




    properties ( Constant, Access = private )
        NodeFilter( 1, 1 )dependencies.internal.graph.NodeFilter = i_createNodeFilter;
        DependencyFilter( 1, 1 )dependencies.internal.graph.DependencyFilter = i_createDependencyFilter;
    end

    properties ( Access = private )
        Graph( 1, 1 )dependencies.internal.graph.MutableGraph;
    end

    methods

        function this = DigraphFactory(  )
            this.Graph = dependencies.internal.graph.MutableGraph;
        end

        function addNode( this, nodes )
            idx = this.NodeFilter.apply( nodes );
            this.Graph.addNode( nodes( idx ) );
        end

        function addDependency( this, dependencies )
            idx = this.DependencyFilter.apply( dependencies );
            this.Graph.addDependency( dependencies( idx ) );
        end

        function addGraph( this, graph )
            this.addNode( graph.Nodes );
            this.addDependency( graph.Dependencies );
        end

        function graph = create( this )
            nodes = this.Graph.Nodes;

            nodeTable = i_makeNodeTable( i_getPaths( nodes ), [ nodes.Resolved ] );
            edgeTable = i_makeEdgeTableFromDependencies( this.Graph.Dependencies );

            graph = digraph( edgeTable, nodeTable );
            graph = reordernodes( graph, sort( graph.Nodes.Name ) );
        end
    end

    methods ( Static )
        function digraph = createFrom( graph )
            factory = dependencies.internal.graph.DigraphFactory;
            factory.addGraph( graph );
            digraph = factory.create(  );
        end
    end

end

function filter = i_createNodeFilter
import dependencies.internal.graph.NodeFilter.nodeType;
import dependencies.internal.graph.Type;
filter = nodeType( Type.FILE );
end

function filter = i_createDependencyFilter
import dependencies.internal.graph.DependencyFilter.upstream;
import dependencies.internal.graph.DependencyFilter.downstream;
isFile = i_createNodeFilter;
filter = all( upstream( isFile ), downstream( isFile ) );
end

function nodeTable = i_makeNodeTable( nodePaths, resolved )
arguments
    nodePaths( :, 1 )cell;
    resolved( :, 1 )logical;
end
nodeTable = table( nodePaths, resolved, 'VariableNames', [ "Name", "Resolved" ] );
end

function edgeTable = i_makeEdgeTableFromDependencies( deps )
if isempty( deps )
    edgeTable = i_makeEdgeTable( [  ], [  ], [  ], [  ], [  ], [  ], [  ], [  ], [  ] );
    return ;
end

upPaths = i_getPaths( [ deps.UpstreamNode ] );
downPaths = i_getPaths( [ deps.DownstreamNode ] );
upComps = [ deps.UpstreamComponent ];
downComps = [ deps.DownstreamComponent ];
types = [ deps.Type ];
relationships = [ deps.Relationship ];
edgeTable = i_makeEdgeTable(  ...
    upPaths, downPaths,  ...
    cellstr( [ upComps.Path ] ), i_lineNumbersToCellstr( [ upComps.LineNumber ] ), cellstr( [ upComps.EnclosingFunction ] ), cellstr( [ upComps.BlockPath ] ),  ...
    cellstr( [ downComps.Path ] ),  ...
    cellstr( [ types.ID ] ), cellstr( [ relationships.ID ] ) );
end

function edgeTable = i_makeEdgeTable( upPaths, downPaths, upCompPaths, upLineNumbers, upEnclosingFunctions, upBlockPaths, downCompPaths, types, relationships )
arguments
    upPaths( :, 1 )cell;
    downPaths( :, 1 )cell;
    upCompPaths( :, 1 )cell;
    upLineNumbers( :, 1 )cell;
    upEnclosingFunctions( :, 1 )cell;
    upBlockPaths( :, 1 )cell;
    downCompPaths( :, 1 )cell;
    types( :, 1 )cell;
    relationships( :, 1 )cell;
end
edgeTable = table(  ...
    [ upPaths, downPaths ], upCompPaths, upEnclosingFunctions, upLineNumbers, upBlockPaths, downCompPaths, types, relationships, 'VariableNames',  ...
    [ "EndNodes", "UpstreamComponent", "UpstreamEnclosingFunction", "UpstreamLineNumber", "UpstreamBlockPath", "DownstreamComponent", "Type", "Relationship" ] );
end

function paths = i_getPaths( nodes )
paths = cell( size( nodes ) );
for n = 1:numel( nodes )
    paths{ n } = nodes( n ).Location{ 1 };
end
end

function strs = i_lineNumbersToCellstr( numbers )
strs = string( numbers' );
invalidLineNumbers = ( strs == "0" )';
strs( invalidLineNumbers ) = "";
strs = cellstr( strs )';
end

