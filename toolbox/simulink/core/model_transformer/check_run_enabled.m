function run_enabled=check_run_enabled(task)
    run_enabled=0;

    VariantTaskObj=task.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.Const2Variant');

    if strcmpi(task.ID,'com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant')
        if((task.State==ModelAdvisor.CheckStatus.NotRun)||(task.State>=ModelAdvisor.CheckStatus.Warning))
            run_enabled=1;
        end
    elseif strcmpi(task.ID,'com.mathworks.Simulink.MdlTransformer.IdentifyVariantCandidate')
        prevTask=task.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
        if(task.State==ModelAdvisor.CheckStatus.NotRun)&&(prevTask.State==ModelAdvisor.CheckStatus.Passed)
            run_enabled=1;
        end
    elseif strcmpi(task.ID,'com.mathworks.Simulink.MdlTransformer.VariantTransform')
        prevTask=task.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantCandidate');
        if((task.State==ModelAdvisor.CheckStatus.NotRun)||(task.State>=ModelAdvisor.CheckStatus.Warning))&&(prevTask.State==ModelAdvisor.CheckStatus.Passed)
            run_enabled=1;
        end
    end
end