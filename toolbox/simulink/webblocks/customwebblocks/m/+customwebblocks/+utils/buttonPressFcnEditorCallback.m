function buttonPressFcnEditorCallback(dialog,obj)
    blockHandle=get(obj.blockObj,'handle');
    currentConfig=jsondecode(get_param(blockHandle,'Configuration'));


    newPressFcn=dialog.getWidgetValue('pressFcn');
    if ischar(newPressFcn)
        currentPressFcn=currentConfig.components(2).settings.pressFcn;
        if~strcmp(currentPressFcn,newPressFcn)
            DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'PressFcn',newPressFcn,'undoable');
        end
        dialog.clearWidgetDirtyFlag('pressFcn');
    end
end
