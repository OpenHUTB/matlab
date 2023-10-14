classdef ReportGenerator < handle

    events ( NotifyAccess = private )
        GenerationStarted
        GenerationProgress
        GenerationFinished
    end

    events
        Cancel
    end

    properties ( SetAccess = immutable )
        FileNodes
        Graph
        Problems
        ProductNodes
        RootFolders
        SessionProperties
        SharedProductNodes
        ToolboxNodes
        DiagramFile
    end

    properties ( Constant, GetAccess = private )
        DependencyTableHeaders = arrayfun(  ...
            @getResource, [  ...
            "FileDetailsFileNameHeader",  ...
            "FileDetailsImpactedComponentHeader",  ...
            "FileDetailsRequiredComponentHeader",  ...
            "FileDetailsDependencyTypeHeader" ] );
        ProductDependencyTableHeaders = arrayfun(  ...
            @getResource, [  ...
            "FileDetailsProductHeader",  ...
            "FileDetailsImpactedComponentHeader",  ...
            "FileDetailsDependencyTypeHeader" ] );
        ExternalToolboxDependencyTableHeaders = arrayfun(  ...
            @getResource, [  ...
            "FileDetailsExternalToolboxHeader",  ...
            "FileDetailsImpactedComponentHeader",  ...
            "FileDetailsDependencyTypeHeader" ] );
    end

    properties ( Access = private )
        CancelRequested( 1, 1 )logical = false;
    end

    methods
        function this = ReportGenerator( graph, nameValueArgs )
            arguments
                graph( 1, 1 )
                nameValueArgs.Properties( :, 1 )struct = struct.empty( 0, 1 )
                nameValueArgs.RootFolders( :, 1 )string = string.empty( 0, 1 )
                nameValueArgs.Attributes( 1, 1 ) ...
                    dependencies.internal.attribute.GraphAttributes
            end

            this.Graph = i_validateGraph( graph );
            this.FileNodes = i_getSortedFileNodes( graph );

            if ~isfield( nameValueArgs, "Attributes" )
                nameValueArgs.Attributes =  ...
                    dependencies.internal.attribute.analyze( this.Graph );
            end

            this.Problems = i_getProblems(  ...
                this.FileNodes, nameValueArgs.Attributes );
            [ this.ProductNodes, this.SharedProductNodes ] = i_getSortedProducts( graph );
            this.ToolboxNodes = i_getSortedToolboxNodes( graph );
            this.RootFolders = nameValueArgs.RootFolders;
            this.SessionProperties = nameValueArgs.Properties;
            this.DiagramFile = tempname + ".png";
        end

        generateReport( this, target );
    end
end



function graph = i_validateGraph( graph )
deps = graph.Dependencies;
if ~isempty( deps )
    deps = arrayfun( @i_flipFileDependencyIfRequirementLink, deps );
end
graph = dependencies.internal.graph.Graph( graph.Nodes, deps );
end


function dep = i_flipFileDependencyIfRequirementLink( dep )
if ~dep.DownstreamNode.isFile(  )
    return
end
baseType = dep.Type.Base.ID;
if baseType ~= "RequirementInfo"
    return
end
dep = dependencies.internal.graph.Dependency(  ...
    dep.DownstreamNode, dep.DownstreamComponent.Path,  ...
    dep.UpstreamNode, dep.UpstreamComponent.Path,  ...
    dep.Type.ID, dep.Relationship.ID );
end


function nodes = i_getSortedFileNodes( graph )
nodeFilter = dependencies.internal.graph.NodeFilter.nodeType(  ...
    dependencies.internal.graph.Type.FILE );
nodes = graph.Nodes( nodeFilter.apply( graph.Nodes ) );
nodes = i_sortByProperty(  ...
    @( node )upper( getNameFromFileNode( node ) ), nodes );
end


function nodes = i_getSortedToolboxNodes( graph )
nodeFilter = dependencies.internal.graph.NodeFilter.nodeType(  ...
    dependencies.internal.graph.Type.TOOLBOX );
nodes = graph.Nodes( nodeFilter.apply( graph.Nodes ) );
nodes = i_sortByProperty( @getNameFromToolboxNode, nodes );
end


function [ products, sharedProducts ] = i_getSortedProducts( graph )
import dependencies.internal.graph.Node;
import dependencies.internal.graph.Type;
nodeFilter = dependencies.internal.graph.NodeFilter.nodeType( Type.PRODUCT );
nodes = graph.Nodes( nodeFilter.apply( graph.Nodes ) );
sharedFilter = arrayfun( @isMultiProduct, nodes );
products = i_sortProductNodesByProductName( nodes( ~sharedFilter ) );
sharedProducts = i_sortProductNodesByProductName( nodes( sharedFilter ) );
end


function nodes = i_sortProductNodesByProductName( nodes )
nodes = i_sortByProperty( @getJointSortedProductNames, nodes );
end


function sorted = i_sortByProperty( getPropertyFunc, array )
props = arrayfun( getPropertyFunc, array );
[ ~, indices ] = sort( props );
sorted = array( indices );
end


function problems = i_getProblems( fileNodes, graphAttributes )
problems = containers.Map(  );
minSeverity = dependencies.internal.attribute.Severity.Warning;
for node = fileNodes
    key = node.Location{ 1 };
    attributes = graphAttributes.getAttributes( node, minSeverity );
    problems( key ) = attributes;
end
end

