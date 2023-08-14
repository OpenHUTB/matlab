function chevronHdls=getChevronsForBadges(zcIdentifier,modelName)


    chevronHdls=[];
    parentSystem='';
    semanticItem=sysarch.resolveZCElement(zcIdentifier,modelName);
    if isa(semanticItem,'systemcomposer.architecture.model.design.Port')


        if isa(semanticItem,'systemcomposer.architecture.model.design.ArchitecturePort')
            portHdls=systemcomposer.utils.getSimulinkPeer(semanticItem);
            parentSystem=get_param(portHdls(1),'Parent');
        end
        for i=1:numel(portHdls)
            if strcmpi(get_param(portHdls(i),'type'),'Block')&&...
                (strcmpi(get_param(portHdls(i),'BlockType'),'Inport')||...
                strcmpi(get_param(portHdls(i),'BlockType'),'Outport'))
                ph=get_param(portHdls(i),'PortHandles');
                if~isempty(ph.Outport)
                    chevronHdls=[chevronHdls,ph.Outport];%#ok<*AGROW>
                elseif~isempty(ph.Inport)
                    chevronHdls=[chevronHdls,ph.Inport];
                end
            end
        end
    end

end