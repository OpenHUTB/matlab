classdef ParameterOverrideWrapper<handle


    methods(Static)
        [overridesCache,originalValues,hModelWorkspace,dataDictionaryStates,...
        modelWorkspaceDirtyState,errors]=...
        overrideParameters(modelToRun,overridesStruct,fromIteration);

        resetOverridenParameters(hModelWorkspace,overridesStruct,originalValues,...
        dataDictionaryStates,modelWorkspaceDirtyState,modelToRun,originalModelDirtyState);
    end

    methods(Static,Access=private)
        setMaskParamValue(value,source,name,maskParam);

        [dataDictionaryStates,index]=addDataDictionary(dataDictionary,dataDictionaryStates);

        revertDataDictionaries(dataDictionaryStates);
    end
end
