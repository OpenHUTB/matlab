function buildDirectory=getBuildDirectory(buildContext,dlConfig)




    if strcmp(dlcoder_base.internal.getBuildWorkflow(buildContext),'simulation')&&isempty(buildContext.BuildDir)

        assert(strcmp(dlConfig.TargetLibrary,'none')&&dlcoderfeature('LibraryFreeSimulinkSimulation'),...
        'Build directory is expected to be empty only for library-free Simulink simulation')




        buildDirectory=sfprivate('get_sf_proj',pwd,bdroot,bdroot,'sfun','src');
    else
        buildDirectory=buildContext.BuildDir;
    end
end
