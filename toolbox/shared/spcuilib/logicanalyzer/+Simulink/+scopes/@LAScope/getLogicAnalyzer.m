function laScope=getLogicAnalyzer(modelName)
    modelHandle=get_param(modelName,'Handle');
    laScope=Simulink.scopes.LAScope.GetNonEmptyInstanceForModel(modelHandle,modelName);
end

