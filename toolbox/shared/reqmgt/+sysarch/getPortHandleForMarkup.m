function[portHandle,parentSystem]=getPortHandleForMarkup(zcIdentifier,modelName)




    portHandle=[];
    parentSystem='';
    semanticItem=sysarch.resolveZCElement(zcIdentifier,modelName);
    if isa(semanticItem,'systemcomposer.architecture.model.design.Port')


        if isa(semanticItem,'systemcomposer.architecture.model.design.ArchitecturePort')


            compPort=semanticItem.getParentComponentPort;

            if~isempty(compPort)
                portHandle=systemcomposer.utils.getSimulinkPeer(compPort);
                parentSystem=get_param(get_param(portHandle,'Parent'),'Parent');
            else


                portHandle=[];
            end
        end

        for i=1:numel(portHandle)
            if strcmpi(get_param(portHandle(i),'type'),'Block')&&...
                (strcmpi(get_param(portHandle(i),'BlockType'),'Inport')||...
                strcmpi(get_param(portHandle(i),'BlockType'),'Outport'))
                ph=get_param(portHandle(i),'PortHandles');
                if~isempty(ph.Outport)
                    portHandle=[portHandle,ph.Outport];%#ok<*AGROW>
                elseif~isempty(ph.Inport)
                    portHandle=[portHandle,ph.Inport];
                end
            end
        end
    end

end
