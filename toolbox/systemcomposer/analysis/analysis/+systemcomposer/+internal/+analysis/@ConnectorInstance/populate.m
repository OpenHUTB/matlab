function ok=populate(connector,connectorSpec,context)



    ok=true;

    connector.specification=connectorSpec;



    endPorts=connectorSpec.getPorts();
    assert(length(endPorts)>=2);

    isPhysical=isa(connectorSpec,'systemcomposer.architecture.model.design.NAryConnector');
    sep='->';
    if isPhysical

        sep=',';
    end

    name=[];
    for idx=1:numel(endPorts)
        endPort=endPorts(idx);
        if isa(endPort,'systemcomposer.architecture.model.design.ComponentPort')



            component=endPort.getComponent;
            sourceInstance=context.children.getByKey(component.getName);
            if isempty(sourceInstance)
                ok=false;
                return;
            end
            potentialSource=sourceInstance.ports.getByKey(endPort.getName);
            if isempty(potentialSource)
                ok=false;
                return;
            else
                connector.connectorEnds.add(potentialSource);
                if(isempty(name))
                    name=[component.getName,':',endPort.getName];
                else
                    name=[name,sep,component.getName,':',endPort.getName];
                end
            end
        else

            instancePorts=context.ports.toArray;
            sPort=[];
            for pi=1:length(instancePorts)
                iPort=instancePorts(pi);
                if isa(iPort.specification,'systemcomposer.architecture.model.design.ArchitecturePort')&&iPort.specification==endPort||...
                    isa(iPort.specification,'systemcomposer.architecture.model.design.ComponentPort')&&iPort.specification.getArchitecturePort==endPort
                    sPort=iPort;
                    break;
                end
            end
            if~isempty(sPort)
                connector.connectorEnds.add(sPort);
                if(isempty(name))
                    name=[sPort.parent.getName,':',sPort.getName];
                else
                    name=[name,sep,endPort.getArchitecture.getName,':',endPort.getName];
                end
            else

                connector.connectorEnds.add(context.ports.getByKey(endPort.getName));
                if(isempty(name))
                    name=[endPort.getArchitecture.getName,':',endPort.getName];
                else
                    name=[name,sep,endPort.parent.getName,':',endPort.getName];
                end
            end
        end
    end

    connector.setName(name);
end

