function isEmpty = graphInNativeContainerIsEmpty( graphContainerWrapper )




R36
graphContainerWrapper( 1, 1 )Simulink.ModelManagement.Project.Dependency.Container.ProjectGraphContainerWrapper;
end 

graph = graphContainerWrapper.getGraph(  );
isEmpty = isempty( graph.Nodes );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQo1h8i.p.
% Please follow local copyright laws when handling this file.

