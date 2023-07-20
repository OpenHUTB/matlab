function updateDefaultColorForUncheckedSignals(modelName,widgetID,isLibWidget)




    modelHandle=get_param(modelName,'Handle');
    defaultColor=utils.getNextScopeDefaultColor(modelName,widgetID,isLibWidget);
    defaultColor=int32(defaultColor*255);
    lineColorTuple=num2str(defaultColor);

    Simulink.HMI.WebHMI.updateScopeDialogDefaultColor(...
    modelHandle,widgetID,lineColorTuple,isLibWidget);
end