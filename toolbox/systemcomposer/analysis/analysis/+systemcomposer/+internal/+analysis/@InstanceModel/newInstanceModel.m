function instanceModel=newInstanceModel(specification,model)

    instanceModel=systemcomposer.internal.analysis.InstanceModel(model);
    instanceModel.specification=specification;


    node=systemcomposer.internal.analysis.NodeInstance(model);
    node.instanceModel=instanceModel;
    node.Name=specification.Name;
    instanceModel.root=node;

    for ci=1:specification.ChildComponents.Size
        component=specification.ChildComponents.at(ci);
        instanceModel.root.addNodeFromSpecification(component);
    end

    ports=specification.Ports.toArray;

    for ci=1:length(ports)
        port=ports(ci);
        instanceModel.root.addPortFromSpecification(port);
    end


    connectors=specification.Connectors.toArray;
    for ci=1:length(connectors)
        connector=connectors(ci);
        instanceModel.root.addConnectorFromSpecification(connector);
    end
    instanceModel.root.graph=instanceModel.root.createGraph();
end

