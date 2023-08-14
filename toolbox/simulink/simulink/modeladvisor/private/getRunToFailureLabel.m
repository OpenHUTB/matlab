

function label=getRunToFailureLabel(taskId)
    if strcmp(taskId,'com.mathworks.Simulink.ModelReferenceAdvisor.MainGroup')
        label=DAStudio.message('Simulink:tools:MAConvert');
    elseif strncmp(taskId,'com.mathworks.HDL.',18)
        label=DAStudio.message('Simulink:tools:MARunAll');
    else
        label=DAStudio.message('Simulink:tools:MARunToFailure');
    end
end

