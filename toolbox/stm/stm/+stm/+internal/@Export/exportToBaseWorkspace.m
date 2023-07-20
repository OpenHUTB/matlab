

function[varNameIsAvailable,invalidNameError,errorMessage]=...
    exportToBaseWorkspace(varName,valuesStruct,forceOverwrite,activeApp,runIDs,signalIDs)
    import stm.internal.Export;
    errorMessage='';

    [varNameIsAvailable,invalidNameError]=Export.isVarNameAvailable(varName,forceOverwrite);

    try
        if varNameIsAvailable
            if isempty(runIDs)&&isempty(signalIDs)
                varArray=stm.internal.Export.convertStructToVariableArray(valuesStruct);
                assignin('base',varName,varArray);
            else
                engine=Simulink.sdi.Instance.engine;
                [variableExist,data]=engine.exportToBaseWorkspace(runIDs,signalIDs,...
                activeApp,varName);

                if variableExist

                    assignin('base',varName,data);
                end
            end
        end
    catch me
        varNameIsAvailable=false;
        invalidNameError=true;
        errorMessage=me.message;
    end
end
