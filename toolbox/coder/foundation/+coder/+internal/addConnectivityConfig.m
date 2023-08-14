function addConnectivityConfig(lTargetRegistry,config)
















    refreshConfig(lTargetRegistry)

    if nargin~=2
        DAStudio.error('RTW:targetRegistry:invalidNumInput');
    end


    if~isa(config,'rtw.connectivity.ConfigRegistry')
        DAStudio.error('RTW:targetRegistry:invalidMember')
    end


    configs=lTargetRegistry.ConnectivityConfigs;


    if~isempty(configs)
        if any(strcmp({configs.ConfigName},config.ConfigName))
            DAStudio.error('RTW:targetRegistry:duplicateConnectivityConfigName',...
            config.ConfigName)
        end
    end


    if~isempty(configs)
        matchIdx=find(strcmp({configs.ConfigClass},config.ConfigClass));
        if~isempty(matchIdx)

            existingConfig=configs(matchIdx(1));
            DAStudio.error('RTW:targetRegistry:duplicateConnectivityClass',...
            config.ConfigName,...
            config.ConfigClass,...
            existingConfig.ConfigName);
        end
    end


    if~isempty(config.TemplateMakefile)&&~isempty(config.Toolchain)
        configLink=rtw.pil.ModelBlockPIL.getConfigsHyperlink(config);
        DAStudio.error('PIL:pil:PILConfigCannotHaveBothToolchainAndTMF',configLink);
    end



    appendConnectivityConfig(lTargetRegistry,config);
