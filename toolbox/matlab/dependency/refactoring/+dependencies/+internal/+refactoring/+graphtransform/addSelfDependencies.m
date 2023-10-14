function graph = addSelfDependencies( graph, nodes )

arguments
    graph( 1, 1 )dependencies.internal.graph.MutableGraph;
    nodes( 1, : )dependencies.internal.graph.Node;
end

graph = i_addMatlabCodeSelfDependencies( graph, nodes );
graph = i_addLibraryForwardingTableDeps( graph, nodes );
end

function graph = i_addMatlabCodeSelfDependencies( graph, nodes )
import dependencies.internal.graph.Component;
import dependencies.internal.graph.Dependency;
filter = dependencies.internal.graph.NodeFilter.fileExtension( ".m" );

for mNode = nodes( filter.apply( nodes ) )
    line = i_findLine( mNode.Location{ 1 } );
    if line > 0
        graph.addDependency( Dependency.createSource(  ...
            Component.createLine( mNode, line ), mNode,  ...
            dependencies.internal.graph.Type( "MATLABFile,Name" ) ) );
    end
end
end

function graph = i_addLibraryForwardingTableDeps( graph, nodes )
import dependencies.internal.graph.DependencyFilter;
import dependencies.internal.graph.Type;

deps = graph.getDownstreamDependencies( nodes );

filter = DependencyFilter.dependencyType( "LibraryLink,ForwardingTable" ) &  ...
    DependencyFilter.hasRelationship( Type.SOURCE );

for dep = deps( filter.apply( deps ) )
    graph.addDependency( dependencies.internal.graph.Dependency(  ...
        dep.UpstreamComponent,  ...
        dep.UpstreamComponent,  ...
        dep.Type, dep.Relationship ) );
end

end

function line = i_findLine( file )
line =  - 1;

try
    tree = mtree( file, "-file" );
    switch tree.FileType
        case mtree.Type.FunctionFile
            funcs = tree.find( "Kind", "FUNCTION" );
            if ~isempty( funcs )
                line = funcs.first.Fname.lineno;
            end
            return ;
        case mtree.Type.ClassDefinitionFile
            classes = tree.find( "Kind", "CLASSDEF" );
            if ~isempty( classes )
                line = classes.first.lineno;
                [ ~, name ] = fileparts( file );
                subTree = classes.first.Tree;
                classID = subTree.find( "Kind", "ID", "String", name );
                line = classID.first.lineno;
                line = line( 1 );
            end
            return ;
    end
catch
end
end

