
function[params,groups,FC]=get_Simulink_TargetCC_data(cs)

    mcs=configset.internal.getConfigSetStaticData;
    mcc=mcs.getComponent('Simulink.TargetCC');
    if isempty(mcc);compStatus=3;elseif isempty(mcc.Dependency);compStatus=0;else;compStatus=mcc.Dependency.getStatus(cs,'');end
    params={};


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

        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.targetLangStandard_entries(cs,'TargetLangStandard'));
        p_widgets{1}={{'options',w_options}};
        params{end+1}={9,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.CodeReplacementLibrary_values(cs,'CodeReplacementLibrary',0);
        p_tooltip=configset.internal.custom.CodeReplacementLibrary_TT(cs,'CodeReplacementLibrary');
        p_widgets=cell(1,4);

        w_value=p_WidgetValues{1};
        w_tooltip=configset.internal.custom.CodeReplacementLibrary_TT(cs,'CodeReplacementLibrary');
        w_options=configset.internal.util.convertToOptions(configset.internal.custom.CodeReplacementLibrary_entries(cs,'CodeReplacementLibrary'));
        p_widgets{1}={{'value',w_value},{'tooltip',w_tooltip},{'options',w_options}};

        w_value=p_WidgetValues{2};
        w_tooltip=configset.internal.custom.CodeReplacementLibrary_MultiSelection_TT(cs,'SelectedCodeReplacementLibrary');
        p_widgets{2}={{'value',w_value},{'tooltip',w_tooltip}};

        w_value=p_WidgetValues{3};
        p_widgets{3}={{'value',w_value}};

        w_value=p_WidgetValues{4};
        p_widgets{4}={{'value',w_value}};
        params{end+1}={10,{'tooltip',p_tooltip},{'widgets',p_widgets}};
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
        p_WidgetValues=configset.internal.customwidget.GenerateFullHeaderValue(cs,'GenerateFullHeader',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={17,{'widgets',p_widgets}};
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
        p_st=configset.internal.custom.cppClassGenMode(cs,'IncludeFileDelimiter');
        params{end+1}={37,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_tooltip=configset.internal.custom.logVarNameModifier_TT(cs,'LogVarNameModifier');
        params{end+1}={40,{'tooltip',p_tooltip}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.codeInterfacePackaging_entries(cs,'CodeInterfacePackaging'));
        p_widgets{1}={{'options',w_options}};
        params{end+1}={43,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,2);

        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.codeInterfacePackaging_entries(cs,'CodeInterfacePackaging'));
        p_widgets{1}={{'options',w_options}};

        w_st=configset.internal.custom.disableOnStandalone(cs,'CPPClassCustomize');
        p_widgets{2}={{'st',w_st}};
        params{end+1}={44,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.PurelyIntegerCodeValues(cs,'PurelyIntegerCode',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={45,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_disp=configset.internal.custom.SupportNonFinitePrompt(cs,'SupportNonFinite');
        params{end+1}={46,{'disp',p_disp},{'prompt',p_disp}};
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

        p_widgets{1}={};
        params{end+1}={54,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={55,{'widgets',p_widgets}};
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
        p_WidgetValues=configset.internal.customwidget.InstructionSetExtensions_values(cs,'InstructionSetExtensions',0);
        p_tooltip=configset.internal.custom.InstructionSetExtensions_TT(cs,'InstructionSetExtensions');
        p_st=configset.internal.custom.InstructionSetExtensionsAvailable(cs,'InstructionSetExtensions');
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        w_tooltip=configset.internal.custom.InstructionSetExtensions_TT(cs,'InstructionSetExtensions');
        w_options=configset.internal.util.convertToOptions(configset.internal.custom.InstructionSetExtensions_entries(cs,'InstructionSetExtensions'));
        p_widgets{1}={{'value',w_value},{'tooltip',w_tooltip},{'options',w_options}};
        params{end+1}={86,{'tooltip',p_tooltip},{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_st=configset.internal.custom.OptimizeReductionsDependency(cs,'OptimizeReductions');
        params{end+1}={87,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.OptimizeReductionsDependency(cs,'OptimizeReductions');
        params{end+1}={88,{'st',p_st}};
    end



    if compStatus<3
    end


    groups={};
