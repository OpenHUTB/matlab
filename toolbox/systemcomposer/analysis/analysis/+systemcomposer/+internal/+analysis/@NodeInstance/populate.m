function populate(node,componentSpec)

    node.setName(componentSpec.getName)


    specification=componentSpec.getArchitecture;
    components=specification.getComponents;
    for ci=1:length(components)
        component=components(ci);
        node.addNodeFromSpecification(component);
    end

    ports=componentSpec.getPorts;

    for ci=1:length(ports)
        port=ports(ci);
        node.addPortFromSpecification(port);
    end


    connectors=specification.getConnectors;
    for ci=1:length(connectors)
        connector=connectors(ci);
        node.addConnectorFromSpecification(connector);
    end

end

