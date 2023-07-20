function newData=isNewDataAvailable(modelName)






    modelH=get_param(modelName,'handle');
    lacosi=Simulink.scopes.LAScope.GetInstanceForModel(modelH,modelName);
    if isempty(lacosi)||strcmp(get_param(modelH,'SignalLogging'),'off')
        newData=false;
    else
        newData=lacosi.IsNewDataAvailable;
    end

end