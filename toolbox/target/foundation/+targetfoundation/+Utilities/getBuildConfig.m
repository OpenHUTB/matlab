function buildCfg=getBuildConfig(buildCfg)




    if any(strcmp(buildCfg,{'Custom','Debug','Release'}))
        buildCfg=[buildCfg,'MW'];
    end