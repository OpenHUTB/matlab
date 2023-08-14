
function[params,groups,FC]=get_Simulink_RTWCC_data(cs)

    mcs=configset.internal.getConfigSetStaticData;
    mcc=mcs.getComponent('Simulink.RTWCC');
    if isempty(mcc);compStatus=3;elseif isempty(mcc.Dependency);compStatus=0;else;compStatus=mcc.Dependency.getStatus(cs,'');end
    params={};


    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.SystemTargetFile(cs,'SystemTargetFile',0);
        p_widgets=cell(1,3);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};

        w_value=p_WidgetValues{3};
        w_st=configset.internal.custom.STFDescription_status(cs,'STF_Description');
        p_widgets{3}={{'value',w_value},{'st',w_st}};
        params{end+1}={0,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.EmbeddedCoderDictionary(cs,'EmbeddedCoderDictionary',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={1,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.EmbeddedCoderDictionary(cs,'EmbeddedCoderDictionary',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={2,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    p_WidgetValues=configset.internal.customwidget.HardwareBoardAndSTFHyperlink(cs,'HardwareBoard',0);
    p_options=configset.internal.util.convertToOptions(configset.internal.custom.hardwareboard_entries(cs,'HardwareBoard'));
    p_widgets=cell(1,3);

    w_value=p_WidgetValues{1};
    w_options=configset.internal.util.convertToOptions(configset.internal.custom.hardwareboard_entries(cs,'HardwareBoard'));
    p_widgets{1}={{'value',w_value},{'options',w_options}};

    w_value=p_WidgetValues{2};
    p_widgets{2}={{'value',w_value}};

    w_value=p_WidgetValues{3};
    w_tooltip=configset.internal.customwidget.HardwareBoard_Unknown_TT(cs,'HardwareBoard_Unknown_Icon');
    w_st=configset.internal.custom.hardwareBoardUnknown(cs,'HardwareBoard_Unknown_Icon');
    p_widgets{3}={{'value',w_value},{'tooltip',w_tooltip},{'st',w_st}};
    params{end+1}={4,{'options',p_options},{'widgets',p_widgets}};



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.noToolchainApproach(cs,'MakeCommand');
        params{end+1}={10,{'st',p_st}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.resetUsingToolchainApproach(cs,'GenerateMakefile',0);
        p_value=p_WidgetValues{1};
        p_st=configset.internal.custom.noToolchainApproach(cs,'GenerateMakefile');
        params{end+1}={11,{'value',p_value},{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.noToolchainApproach(cs,'TemplateMakefile');
        params{end+1}={14,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.isLib(cs,'RTWUseLocalCustomCode');
        params{end+1}={30,{'st',p_st}};
    end



    if compStatus<3
        p_tooltip=configset.internal.custom.rtwUseSimCustomCode_TT(cs,'RTWUseSimCustomCode');
        params{end+1}={31,{'tooltip',p_tooltip}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={32,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={33,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={34,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={35,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={36,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={37,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={41,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={42,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.ToolchainValues(cs,'Toolchain',0);
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.Toolchain_entries(cs,'Toolchain'));
        p_st=configset.internal.custom.usingToolchainApproach(cs,'Toolchain');
        p_widgets=cell(1,4);

        w_value=p_WidgetValues{1};
        w_options=configset.internal.util.convertToOptions(configset.internal.custom.Toolchain_entries(cs,'Toolchain'));
        p_widgets{1}={{'value',w_value},{'options',w_options}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};

        w_value=p_WidgetValues{3};
        w_tooltip=configset.internal.customwidget.Toolchain_Unknown_TT(cs,'Toolchain_Toolchain_Unknown_Icon');
        w_st=configset.internal.custom.toolchainUnknown(cs,'Toolchain_Toolchain_Unknown_Icon');
        p_widgets{3}={{'value',w_value},{'tooltip',w_tooltip},{'st',w_st}};

        w_value=p_WidgetValues{4};
        p_widgets{4}={{'value',w_value}};
        params{end+1}={43,{'options',p_options},{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.BuildConfigValues(cs,'BuildConfiguration',0);
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.BuildConfiguration_entries(cs,'BuildConfiguration'));
        p_st=configset.internal.custom.usingToolchainApproach(cs,'BuildConfiguration');
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        w_options=configset.internal.util.convertToOptions(configset.internal.custom.BuildConfiguration_entries(cs,'BuildConfiguration'));
        w_st=configset.internal.custom.buildConfigStatus(cs,'BuildConfiguration');
        p_widgets{1}={{'value',w_value},{'options',w_options},{'st',w_st}};

        w_value=p_WidgetValues{2};
        w_tooltip=configset.internal.customwidget.BuildConfig_Unknown_TT(cs,'Toolchain_BuildConfig_Unknown_Icon');
        w_st=configset.internal.custom.buildConfigUnknown(cs,'Toolchain_BuildConfig_Unknown_Icon');
        p_widgets{2}={{'value',w_value},{'tooltip',w_tooltip},{'st',w_st}};
        params{end+1}={44,{'options',p_options},{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.CustomToolchainValues(cs,'CustomToolchainOptions',0);
        p_st=max([configset.internal.custom.CustomToolchainOptions(cs,'CustomToolchainOptions'),configset.internal.custom.usingToolchainApproach(cs,'CustomToolchainOptions')]);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        w_tableData=configset.internal.customwidget.CustomToolchainTable(cs,'CustomToolchainOptionsRead');
        w_st=configset.internal.custom.CustomToolchainOptions(cs,'CustomToolchainOptionsRead');
        p_widgets{1}={{'value',w_value},{'tableData',w_tableData},{'st',w_st}};

        w_value=p_WidgetValues{2};
        w_tableData=configset.internal.customwidget.CustomToolchainTable(cs,'CustomToolchainOptionsSpecify');
        w_st=configset.internal.custom.CustomToolchainOptions(cs,'CustomToolchainOptionsSpecify');
        p_widgets{2}={{'value',w_value},{'tableData',w_tableData},{'st',w_st}};
        params{end+1}={45,{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.silpilBlock(cs,'CreateSILPILBlock');
        params{end+1}={52,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_tooltip=configset.internal.custom.codeProfilingInstrumentation_TT(cs,'CodeProfilingInstrumentation');
        params{end+1}={56,{'tooltip',p_tooltip}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.CodeCoverageSettings(cs,'CodeCoverageSettings',0);
        p_tooltip=configset.internal.customwidget.CodeCoverageSettings_TT(cs,'CodeCoverageSettings');
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        w_tooltip=configset.internal.customwidget.CodeCoverageSettings_TT(cs,'CodeCoverageSettings');
        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.CodeCoverageSettings_entries(cs,'CodeCoverageSettings'));
        w_st=configset.internal.custom.CodeCoverageSettings_status(cs,'CodeCoverageSettings');
        p_widgets{1}={{'value',w_value},{'tooltip',w_tooltip},{'options',w_options},{'st',w_st}};

        w_value=p_WidgetValues{2};
        w_st=configset.internal.custom.CodeCoverageConfigure_status(cs,'CodeCoverageConfigure');
        p_widgets{2}={{'value',w_value},{'st',w_st}};
        params{end+1}={61,{'tooltip',p_tooltip},{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_tooltip=configset.internal.custom.SILDebugging_TT(cs,'SILDebugging');
        params{end+1}={66,{'tooltip',p_tooltip}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.setGenerateGPUCode(cs,'GenerateGPUCode',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={70,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        w_st=configset.internal.custom.CodeHighlightOption_status(cs,'CodeHighlightOption');
        p_widgets{2}={{'st',w_st}};
        params{end+1}={77,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.resetUsingToolchainApproach(cs,'RTWCompilerOptimization',0);
        p_value=p_WidgetValues{1};
        p_st=configset.internal.custom.noToolchainApproach(cs,'RTWCompilerOptimization');
        params{end+1}={89,{'value',p_value},{'st',p_st}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.ObjectivePriorities(cs,'ObjectivePriorities',0);
        p_widgets=cell(1,3);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};

        w_value=p_WidgetValues{3};
        p_widgets{3}={{'value',w_value}};
        params{end+1}={90,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_st=configset.internal.custom.noToolchainApproach(cs,'RTWCustomCompilerOptimizations');
        params{end+1}={91,{'st',p_st}};
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        w_st=configset.internal.custom.LaunchModelAdvisor_status(cs,'LaunchModelAdvisor');
        p_widgets{2}={{'st',w_st}};
        params{end+1}={92,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.DLTargetLibrary(cs,'DLTargetLibrary'));
        p_widgets{1}={{'options',w_options}};
        params{end+1}={113,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end


    groups={};









































    g_expand=configset.internal.custom.ToolchainSettingsToggle(cs,'CustomToolChainOptionsTableToggle');
    groups{end+1}={'CustomToolChainOptionsTableToggle',{'expand',g_expand}};


















































































