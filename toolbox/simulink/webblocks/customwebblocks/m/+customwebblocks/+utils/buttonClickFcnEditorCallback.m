function buttonClickFcnEditorCallback(dialog,obj)
    blockHandle=get(obj.blockObj,'handle');
    currentConfig=jsondecode(get_param(blockHandle,'Configuration'));


    newClickFcn=dialog.getWidgetValue('clickFcn');
    if ischar(newClickFcn)
        currentClickFcn=currentConfig.components(2).settings.clickFcn;
        if~strcmp(currentClickFcn,newClickFcn)
            DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'ClickFcn',newClickFcn,'undoable');
        end
        dialog.clearWidgetDirtyFlag('clickFcn');
    end
end
