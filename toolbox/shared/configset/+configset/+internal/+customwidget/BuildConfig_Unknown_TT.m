function tooltip=BuildConfig_Unknown_TT(cs,~)




    cs=cs.getConfigSet;

    tcName=cs.get_param('Toolchain');
    if isempty(tcName)
        tcName=coder.make.internal.getInfo('default-toolchain');
    end

    bcName=cs.get_param('BuildConfiguration');
    if isempty(bcName)
        bcName=coder.make.internal.getDefaultBuildConfigurationName;
    end

    tooltip=message('coder_compile:toolchain:CannotFindBuildConfig',tcName,bcName).getString();



