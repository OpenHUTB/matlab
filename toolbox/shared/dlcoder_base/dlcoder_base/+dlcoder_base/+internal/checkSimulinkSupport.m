function checkSimulinkSupport(dlTargeLib,ctx)






    buildWorkflow=dlcoder_base.internal.getBuildWorkflow(ctx);


    if(strcmpi(buildWorkflow,'simulink')||strcmpi(buildWorkflow,'simulation'))
        unSupportedTargets={'cmsisnn'};
        if any(strcmpi(dlTargeLib,unSupportedTargets))
            error(message('dlcoder_spkg:simulink:UnsupportedWorkflow',dlTargeLib));
        end

    end

end
