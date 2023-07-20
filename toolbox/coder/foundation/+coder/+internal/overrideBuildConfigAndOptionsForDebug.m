function[lBuildConfiguration_out,lCustomToolchainOptions_out]=...
overrideBuildConfigAndOptionsForDebug...
    (lToolchainOrTMF,lBuildConfiguration,lCustomToolchainOptions,...
    lBuildInfo)








    [lToolchainInfo,lTMFProperties]=...
    coder.make.internal.resolveToolchainOrTMF(lToolchainOrTMF);

    if isempty(lTMFProperties)
        [~,isCMake]=coder.make.internal.buildMethodIsCMake(lToolchainInfo);
        if isCMake
            strategy=coder.internal.CMakeBuildConfigurationDebugOverrideRules(lToolchainInfo);
        else
            strategy=coder.internal.ToolchainBuildConfigurationDebugOverrideRules(lToolchainInfo);
        end
    else
        strategy=coder.internal.TMFBuildConfigurationDebugOverrideRules();
    end


    lBuildConfiguration_out=strategy.updateBuildConfiguration(lBuildConfiguration);


    lCustomToolchainOptions_out=strategy.updateCustomToolchainOptions(lBuildConfiguration,lCustomToolchainOptions);


    strategy.updateBuildInfo(lBuildInfo);
