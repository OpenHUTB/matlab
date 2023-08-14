function targetInterfaceTaskID=utilGetTargetInterfaceTask(hDI)




    if hDI.showExecutionMode
        targetInterfaceTaskID='com.mathworks.HDL.SetTargetInterfaceAndMode';
    else
        targetInterfaceTaskID='com.mathworks.HDL.SetTargetInterface';
    end
