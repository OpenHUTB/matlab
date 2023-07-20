function populateDescendants(this)




    if isempty(this.parent)

        arch=this.instanceModel.specification;
    else
        arch=this.specification.getArchitecture();
    end
    archwrapper=systemcomposer.internal.getWrapperForImpl(arch);
    archwrapper.iterate('preorder',@this.buildNode,...
    'Recurse',false,"IncludePorts",false,this);



    it=systemcomposer.internal.analysis.createInstanceModelIterator('order',systemcomposer.IteratorDirection.PostOrder);
    it.begin(this);


    portUsages=[];
    connectorUsages=[];

    m=this.instanceModel.mapping.getByKey('Port');
    if~isempty(m)
        portUsages=m.usages;
    end
    m=this.instanceModel.mapping.getByKey('Connector');
    if~isempty(m)
        connectorUsages=m.usages;
    end

    while~isempty(it.getElement())
        nodeWrapper=it.getElement();
        node=it.getElement().getInstance;


        if~(isempty(portUsages)&&isempty(connectorUsages))
            specification=nodeWrapper.Specification;
            ports=specification.getActivePorts;
            for ci=1:length(ports)
                port=ports(ci);
                node.addPortFromSpecification(port.getImpl);
            end
        end


        if~isempty(connectorUsages)
            if isempty(node.specification)

                specification=archwrapper;
            else


                specification=nodeWrapper.Specification.Architecture;
            end



            if isempty(specification.Parent)
                ports=specification.getActivePorts;
                for ci=1:length(ports)
                    port=ports(ci);
                    if isempty(node.ports.getByKey(port.Name))
                        node.addPortFromSpecification(port.getImpl);
                    end
                end
            end

            connectors=specification.getActiveConnectors;
            for ci=1:length(connectors)
                connector=connectors(ci);
                node.addConnectorFromSpecification(connector.getImpl);
            end
        end

        it.next();
    end
end

