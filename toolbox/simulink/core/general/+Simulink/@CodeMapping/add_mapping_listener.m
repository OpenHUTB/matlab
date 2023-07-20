





function add_mapping_listener(sourceModel,sourceBlock,dialog,portObj)
    mappings=get_param(sourceBlock,'Mappings');
    if~isempty(mappings)
        [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(sourceModel);
        if strcmp(mappingType,'AutosarTarget')
            eventName='AutosarMappingEntityUpdated';
        elseif strcmp(mappingType,'CoderDictionary')
            eventName='CoderDictionaryInportMappingEntityUpdated';
        end
        mapPortObj=Simulink.CodeMapping.findBlockMapping(mappings,eventName);
        if isempty(mapPortObj)
            return;
        end
        mappingUpdatedEventListener=event.listener(mapPortObj,eventName,...
        @(s,e)Simulink.CodeMapping.handle_mapping_updated_event(s,e,portObj));

        listeners=Simulink.CodeMapping.setGetListeners;

        if isempty(listeners{4})
            modelHandle=get_param(sourceModel,'Handle');
            modelCloseListener=Simulink.listener(modelHandle,'CloseEvent',...
            @Simulink.CodeMapping.onModelClose);
            listeners{4}=[listeners{4},modelCloseListener];
        end

        if~isempty(listeners{1})
            openHandleIdx=find(listeners{1}==portObj.handle,1);
        else
            openHandleIdx=[];
        end
        if isempty(openHandleIdx)
            listeners{1}=[listeners{1},portObj.handle];
            listeners{2}=[listeners{2},mappingUpdatedEventListener];
            listeners{3}=[listeners{3},{dialog}];
        else
            listeners{3}{openHandleIdx}=[listeners{3}{openHandleIdx},dialog];
        end
        Simulink.CodeMapping.setGetListeners(listeners);
    end
end
