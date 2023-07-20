function utilAdjustExecutionMode(mdladvObj,hDI)




    if~hDI.showExecutionMode
        return;
    end


    targetInterfaceTaskID=utilGetTargetInterfaceTask(hDI);
    inputParams=mdladvObj.getInputParameters(targetInterfaceTaskID);
    executionOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputFPGAExecutionMode'));

    executionOption.Entries=hDI.set('ExecutionMode');
    executionOption.Value=hDI.get('ExecutionMode');

end