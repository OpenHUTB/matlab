function p=isColumnMajorContext(cfg)






    buildWorkflow=dlcoder_base.internal.getBuildWorkflow(cfg);
    if strcmp(buildWorkflow,'simulink')||strcmp(buildWorkflow,'simulation')
        p=strcmp(getConfigProp(cfg,'ArrayLayout'),'Column-major');
    else
        assert(strcmp(buildWorkflow,'matlab'),'Expected workflow is matlab.')
        p=~getConfigProp(cfg,'RowMajor');
    end

end
