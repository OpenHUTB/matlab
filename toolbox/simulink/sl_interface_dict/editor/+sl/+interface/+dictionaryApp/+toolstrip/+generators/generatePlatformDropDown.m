function generatedWidget=generatePlatformDropDown(cbinfo)




    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    platformsIdsMappedToDict=guiObj.getMappedPlatformIds();
    builtInPlatformMappingIds=guiObj.getBuiltInPlatformIds();


    generatedWidgetType=cbinfo.EventData.type;
    generatedWidgetId=cbinfo.EventData.namespace;
    generatedWidget=dig.GeneratedWidget(generatedWidgetId,generatedWidgetType);


    nativeButton=generatedWidget.Widget.addChild('ListItem','nativePlatformButton');
    nativeButton.ActionId='nativePlatformAction';




    for i=1:length(builtInPlatformMappingIds)
        platformMappingId=builtInPlatformMappingIds{i};
        addBuiltInPlatformToDropDown(generatedWidget,platformMappingId);
    end



    functionPlatformMappingIds=platformsIdsMappedToDict;
    idxToRemove=contains(functionPlatformMappingIds,builtInPlatformMappingIds);
    functionPlatformMappingIds(idxToRemove)=[];
    for i=1:length(functionPlatformMappingIds)

        functionPlatformMappingId=functionPlatformMappingIds{i};
        platformButtonId=[functionPlatformMappingId,' Button'];
        functionPlatformButton=generatedWidget.Widget.addChild('ListItem',platformButtonId);


        action=createFunctionPlatformSelectionAction(generatedWidget,functionPlatformMappingId);
        functionPlatformButton.ActionId=[generatedWidgetId,':',action.name];
    end
end



function addBuiltInPlatformToDropDown(generatedWidget,platformMappingId)
    switch platformMappingId
    case 'AUTOSARClassic'
        autosarClassicButton=generatedWidget.Widget.addChild('ListItem','AUTOSARClassicPlatformButton');
        autosarClassicButton.ActionId='AUTOSARClassicPlatformAction';
    otherwise
        assert(false,'Unexpected installed platform when generating platform drop down widget');
    end
end

function action=createFunctionPlatformSelectionAction(generatedWidget,platformId)
    actionId=[platformId,' Action'];
    action=generatedWidget.createAction(actionId);
    action.text=platformId;
    action.description=DAStudio.message('interface_dictionary:toolstrip:SDPPlatformDescription');
    action.enabled=true;
    action.icon='SDPPlatform';
    action.qabEligible=false;
    action.setCallbackFromArray(...
    @(cbinfo)sl.interface.dictionaryApp.toolstrip.callbacks.changePlatform(platformId,cbinfo),...
    dig.model.FunctionType.Action);
    action.eventDataType=dig.model.EventDataType.Boolean;
end


