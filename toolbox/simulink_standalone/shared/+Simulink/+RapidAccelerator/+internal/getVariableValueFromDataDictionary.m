function variableValue=getVariableValueFromDataDictionary(dictionaryName,variableName)
    originalWarningState=warning;
    ocRestoreWarningState=onCleanup(@()warning(originalWarningState));
    warning('off','all');

    dictionaryPath=which(dictionaryName);
    dataDictionary=Simulink.data.dictionary.open(dictionaryPath);
    ocCloseDataDictionary=onCleanup(@()close(dataDictionary));
    designData=getSection(dataDictionary,'Design Data');
    variableEntry=designData.find('Name',variableName);

    if isempty(variableEntry)
        error(message(...
        'SimulinkStandalone:DataDictionaryVariableEvaluator:UnableToFindVariable',...
        variableName,...
dictionaryName...
        ));
    end

    variableValue=variableEntry.getValue;
end
