function setNativeGraphInJavaContainer(container,graph)




    factory=Simulink.ModelManagement.Project.Dependency.GraphFactory;
    factory.addNode(graph.Nodes);
    factory.addDependency(graph.Dependencies);
    jGraph=factory.create();

    jGraph.addData(i_createData('checksum',graph,jGraph));
    jGraph.addData(i_createData('onPath',graph,jGraph));

    container.graphUpdated(jGraph);

end

function data=i_createData(id,graph,jGraph)
    import com.mathworks.toolbox.slproject.extensions.dependency.loadsave.util.MappedData
    paths={};
    props={};
    for node=graph.Nodes
        if node.isFile
            if node.hasProperty(id)
                paths{end+1}=node.Location{1};
                props{end+1}=char(node.getProperty(id));
            end
        end
    end
    data=MappedData.createVertexData(id,jGraph.getDependencyGraph(),paths,props);
end
