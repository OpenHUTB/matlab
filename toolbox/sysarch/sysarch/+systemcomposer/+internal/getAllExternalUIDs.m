function[componentsUID,portsUID,connectionsUID,interfacesUID]=getAllExternalUIDs(model)




    componentsUID={};
    portsUID={};
    connectionsUID={};
    interfacesUID={};
    externalUID='';
    if isa(model,'systemcomposer.arch.Component')
        externalUID=get(model,'ExternalUID');

        if(model.isReference)

            componentsUID=[componentsUID;externalUID];

            return;
        end
    end

    componentsUID=[componentsUID;externalUID];

    rootArch=model.Architecture;

    childComponents=get(rootArch,'Components');
    for compItr=1:numel(childComponents)
        childCompUID={};
        childPortsUID={};
        childConnUID={};
        if isa(childComponents(compItr),'systemcomposer.arch.VariantComponent')

            variantUID=get(childComponents(compItr),'ExternalUID');
            componentsUID=[componentsUID;variantUID];
            choices=childComponents(compItr).getChoices;
            for choiceItr=1:numel(choices)


                [choiceCompUID,choicePortsUID,choiceConnUID]=systemcomposer.internal.getAllExternalUIDs(choices(choiceItr));

                childCompUID=[choiceCompUID;childCompUID];
                childPortsUID=[choicePortsUID;childPortsUID];
                childConnUID=[choiceConnUID;childConnUID];
            end


            ports=get(childComponents(compItr),'Ports');
            for portItr=1:numel(ports)
                portUID=get(ports(portItr),'ExternalUID');
                portsUID=[portsUID;portUID];
            end
        else

            [childCompUID,childPortsUID,childConnUID]=systemcomposer.internal.getAllExternalUIDs(childComponents(compItr));
        end


        componentsUID=[componentsUID;childCompUID];
        portsUID=[portsUID;childPortsUID];
        connectionsUID=[connectionsUID;childConnUID];
    end




    ports=get(rootArch,'Ports');
    for portItr=1:numel(ports)
        portUID=get(ports(portItr),'ExternalUID');
        portsUID=[portsUID;portUID];
    end


    connections=get(rootArch,'Connectors');
    for connItr=1:numel(connections)
        connUID=get(connections(connItr),'ExternalUID');
        connectionsUID=[connectionsUID;connUID];
    end


    if isa(model,'systemcomposer.arch.Model')

        interfaces=model.InterfaceDictionary.Interfaces;
        for intItr=1:numel(interfaces)

            interface=interfaces(intItr);
            interfaceExternalUID=interface.ExternalUID;
            if~isempty(interfaceExternalUID)
                interfacesUID=[interfacesUID;interfaceExternalUID];
            end

            if~isa(interface,'systemcomposer.ValueType')
                interfaceElements=interface.Elements;
                for elemItr=1:numel(interfaceElements)
                    element=interfaceElements(elemItr);
                    elementUID=element.ExternalUID;
                    if~isempty(elementUID)
                        interfacesUID=[interfacesUID;elementUID];
                    end
                end
            end
        end
    end

