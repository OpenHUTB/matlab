function buttonTextMultipleValuesCallback(dialog,obj)
    blockHandle=get(obj.blockObj,'handle');
    currentConfig=jsondecode(get_param(blockHandle,'Configuration'));


    newButtonText=dialog.getWidgetValue('buttonText');


    newButtonTextMultipleValues=dialog.getWidgetValue('buttonTextMultipleValues');
    if dialog.isVisible('buttonTextMultipleValues')&&...
        ~isempty(newButtonTextMultipleValues)
        newButtonText=newButtonTextMultipleValues;
        shouldUpdate=true;
    else
        defaultState=currentConfig.components(2).settings.states(1);
        currentButtonText=defaultState.label.text.content;
        shouldUpdate=~strcmp(currentButtonText,newButtonText);
    end
    if shouldUpdate
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'ButtonText',newButtonText,'undoable');
        dialog.clearWidgetDirtyFlag('buttonText');
        dialog.clearWidgetDirtyFlag('buttonTextMultipleValues');
    end
end
