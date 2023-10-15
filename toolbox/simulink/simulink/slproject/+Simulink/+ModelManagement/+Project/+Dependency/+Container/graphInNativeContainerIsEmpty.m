function isEmpty = graphInNativeContainerIsEmpty( graphContainerWrapper )

arguments
    graphContainerWrapper( 1, 1 )Simulink.ModelManagement.Project.Dependency.Container.ProjectGraphContainerWrapper;
end

graph = graphContainerWrapper.getGraph(  );
isEmpty = isempty( graph.Nodes );
end
