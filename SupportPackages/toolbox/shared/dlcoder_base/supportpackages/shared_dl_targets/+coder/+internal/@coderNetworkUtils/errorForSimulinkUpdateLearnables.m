function errorForSimulinkUpdateLearnables(ctx)







    buildWorkflow=dlcoder_base.internal.getBuildWorkflow(ctx);
    if strcmpi(buildWorkflow,'simulink')||strcmpi(buildWorkflow,'simulation')
        error(message('dlcoder_spkg:simulink:SimulinkNotSupportSetLearnables'));
    end
end