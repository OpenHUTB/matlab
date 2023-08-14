function utilParseExecutionMode(mdladvObj,hDI)




    if hDI.showExecutionMode


        targetInterfaceTaskID=utilGetTargetInterfaceTask(hDI);
        inputParams=mdladvObj.getInputParameters(targetInterfaceTaskID);
        execModeOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputFPGAExecutionMode'));

        if~strcmp(execModeOption.Value,hDI.get('ExecutionMode'))
            hDI.set('ExecutionMode',execModeOption.Value);

        end

        system=mdladvObj.System;
        hDI.saveSyncModeSettingToModel(system,hDI.get('ExecutionMode'));

    end

