function dlValidateCrossCompile(dlCroscompilersRegistry,codeConfig)




    supportedToolchains=dlCroscompilersRegistry.m_supportedCrossCompilerToolChains;
    crossCompileTargetType=supportedToolchains(codeConfig.Toolchain);
    if strcmp(crossCompileTargetType,'Linux')
        validateCrossCompilationTargetgetObj=dltargets.arm_neon.ValidateCrossCompileForLinux(codeConfig);
    end

    validateCrossCompilationTargetgetObj.validate();
end
