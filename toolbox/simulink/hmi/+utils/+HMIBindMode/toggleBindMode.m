function toggleBindMode(editor,element)
    bdHandle=editor.getStudio().App.blockDiagramHandle;
    model=get_param(bdHandle,'object');
    requiresCheckBox=false;
    widgetBindingType=utils.getWidgetBindingType(element.handle);
    if(strcmp(widgetBindingType,'MultipleSignal'))
        requiresCheckBox=true;
    end
    bindModeSourceDataObj=BindMode.HMISourceData(model.Name,...
    element.getFullPathName,requiresCheckBox);
    BindMode.BindMode.enableBindMode(bindModeSourceDataObj);

    SLM3I.SLDomain.notifyWebManagerOfBindModeStateChange(bdHandle,true);
    SLM3I.SLDomain.notifyWebManagerOfBindModeTargetUpdate(bdHandle,element.handle);
end
