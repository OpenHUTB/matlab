
function[params,groups,FC]=get_SimulinkDesktopRealTime_SimulinkDesktopRealTimeERTCC_data(cs)

    mcs=configset.internal.getConfigSetStaticData;
    mcc=mcs.getComponent('SimulinkDesktopRealTime.SimulinkDesktopRealTimeERTCC');
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

        p_widgets{1}={};
        params{end+1}={104,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.ExtModeTransport(cs,'ExtModeTransport'));
        p_widgets{1}={{'options',w_options}};
        params{end+1}={108,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.extModeOptionsVisible(cs,'ExtModeAutomaticAllocSize');
        params{end+1}={112,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.extModeOptionsVisible(cs,'ExtModeMaxTrigDuration');
        params{end+1}={113,{'st',p_st}};
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
        p_widgets=cell(1,3);

        p_widgets{1}={};

        p_widgets{2}={};

        w_st=configset.internal.custom.disableOnEmpty(cs,'ERTSrcFileBannerTemplate_Edit');
        p_widgets{3}={{'st',w_st}};
        params{end+1}={122,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,3);

        p_widgets{1}={};

        p_widgets{2}={};

        w_st=configset.internal.custom.disableOnEmpty(cs,'ERTHdrFileBannerTemplate_Edit');
        p_widgets{3}={{'st',w_st}};
        params{end+1}={123,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,3);

        p_widgets{1}={};

        p_widgets{2}={};

        w_st=configset.internal.custom.disableOnEmpty(cs,'ERTDataSrcFileTemplate_Edit');
        p_widgets{3}={{'st',w_st}};
        params{end+1}={124,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,3);

        p_widgets{1}={};

        p_widgets{2}={};

        w_st=configset.internal.custom.disableOnEmpty(cs,'ERTDataHdrFileTemplate_Edit');
        p_widgets{3}={{'st',w_st}};
        params{end+1}={125,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,3);

        p_widgets{1}={};

        p_widgets{2}={};

        w_st=configset.internal.custom.disableOnEmpty(cs,'ERTCustomFileTemplate_Edit');
        p_widgets{3}={{'st',w_st}};
        params{end+1}={126,{'widgets',p_widgets}};
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
        p_st=configset.internal.custom.cppClassGenMode(cs,'EnableDataOwnership');
        params{end+1}={131,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.cppClassGenMode(cs,'GlobalDataDefinition');
        params{end+1}={134,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.cppClassGenMode(cs,'DataDefinitionFile');
        params{end+1}={135,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.cppClassGenMode(cs,'GlobalDataReference');
        params{end+1}={136,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.cppClassGenMode(cs,'DataReferenceFile');
        params{end+1}={139,{'st',p_st}};
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
        p_st=configset.internal.custom.ImplementImageWithCVMatDepend(cs,'ImplementImageWithCVMat');
        params{end+1}={149,{'st',p_st}};
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
        p_WidgetValues=configset.internal.customwidget.ReplacementTypes(cs,'ReplacementTypes',0);
        p_widgets=cell(1,51);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};

        w_value=p_WidgetValues{3};
        p_widgets{3}={{'value',w_value}};

        w_value=p_WidgetValues{4};
        p_widgets{4}={{'value',w_value}};

        w_value=p_WidgetValues{5};
        p_widgets{5}={{'value',w_value}};

        w_value=p_WidgetValues{6};
        p_widgets{6}={{'value',w_value}};

        w_value=p_WidgetValues{7};
        p_widgets{7}={{'value',w_value}};

        w_value=p_WidgetValues{8};
        p_widgets{8}={{'value',w_value}};

        w_value=p_WidgetValues{9};
        p_widgets{9}={{'value',w_value}};

        w_value=p_WidgetValues{10};
        p_widgets{10}={{'value',w_value}};

        w_value=p_WidgetValues{11};
        p_widgets{11}={{'value',w_value}};

        w_value=p_WidgetValues{12};
        p_widgets{12}={{'value',w_value}};

        w_value=p_WidgetValues{13};
        p_widgets{13}={{'value',w_value}};

        w_value=p_WidgetValues{14};
        p_widgets{14}={{'value',w_value}};

        w_value=p_WidgetValues{15};
        p_widgets{15}={{'value',w_value}};

        w_value=p_WidgetValues{16};
        p_widgets{16}={{'value',w_value}};

        w_value=p_WidgetValues{17};
        p_widgets{17}={{'value',w_value}};

        w_value=p_WidgetValues{18};
        p_widgets{18}={{'value',w_value}};

        w_value=p_WidgetValues{19};
        p_widgets{19}={{'value',w_value}};

        w_value=p_WidgetValues{20};
        p_widgets{20}={{'value',w_value}};

        w_value=p_WidgetValues{21};
        p_widgets{21}={{'value',w_value}};

        w_value=p_WidgetValues{22};
        p_widgets{22}={{'value',w_value}};

        w_value=p_WidgetValues{23};
        p_widgets{23}={{'value',w_value}};

        w_value=p_WidgetValues{24};
        p_widgets{24}={{'value',w_value}};

        w_value=p_WidgetValues{25};
        p_widgets{25}={{'value',w_value}};

        w_value=p_WidgetValues{26};
        p_widgets{26}={{'value',w_value}};

        w_value=p_WidgetValues{27};
        p_widgets{27}={{'value',w_value}};

        w_value=p_WidgetValues{28};
        p_widgets{28}={{'value',w_value}};

        w_value=p_WidgetValues{29};
        p_widgets{29}={{'value',w_value}};

        w_value=p_WidgetValues{30};
        p_widgets{30}={{'value',w_value}};

        w_value=p_WidgetValues{31};
        p_widgets{31}={{'value',w_value}};

        w_value=p_WidgetValues{32};
        p_widgets{32}={{'value',w_value}};

        w_value=p_WidgetValues{33};
        p_widgets{33}={{'value',w_value}};

        w_value=p_WidgetValues{34};
        p_widgets{34}={{'value',w_value}};

        w_value=p_WidgetValues{35};
        p_widgets{35}={{'value',w_value}};

        w_value=p_WidgetValues{36};
        p_widgets{36}={{'value',w_value}};

        w_value=p_WidgetValues{37};
        p_widgets{37}={{'value',w_value}};

        w_value=p_WidgetValues{38};
        p_widgets{38}={{'value',w_value}};

        w_value=p_WidgetValues{39};
        p_widgets{39}={{'value',w_value}};

        w_value=p_WidgetValues{40};
        p_widgets{40}={{'value',w_value}};

        w_value=p_WidgetValues{41};
        p_widgets{41}={{'value',w_value}};

        w_value=p_WidgetValues{42};
        p_widgets{42}={{'value',w_value}};

        w_value=p_WidgetValues{43};
        p_widgets{43}={{'value',w_value}};

        w_value=p_WidgetValues{44};
        p_widgets{44}={{'value',w_value}};

        w_value=p_WidgetValues{45};
        p_widgets{45}={{'value',w_value}};

        w_value=p_WidgetValues{46};
        p_widgets{46}={{'value',w_value}};

        w_value=p_WidgetValues{47};
        p_widgets{47}={{'value',w_value}};

        w_value=p_WidgetValues{48};
        p_widgets{48}={{'value',w_value}};

        w_value=p_WidgetValues{49};
        p_widgets{49}={{'value',w_value}};

        w_value=p_WidgetValues{50};
        p_widgets{50}={{'value',w_value}};

        w_value=p_WidgetValues{51};
        p_widgets{51}={{'value',w_value}};
        params{end+1}={157,{'widgets',p_widgets}};
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
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.msListParams(cs,'MemSecDataConstants'));
        params{end+1}={174,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.msListSignals(cs,'MemSecDataIO'));
        params{end+1}={175,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.msListSignals(cs,'MemSecDataInternal'));
        params{end+1}={176,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.msListParams(cs,'MemSecDataParameters'));
        params{end+1}={177,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.msListFunctions(cs,'MemSecFuncInitTerm'));
        params{end+1}={178,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.msListFunctions(cs,'MemSecFuncExecute'));
        params{end+1}={179,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.msListFunctions(cs,'MemSecFuncSharedUtil'));
        params{end+1}={180,{'options',p_options}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupConstants'));
        params{end+1}={183,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupRootIO'));
        params{end+1}={184,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupRootInputs'));
        params{end+1}={185,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupRootOutputs'));
        params{end+1}={186,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupInternal'));
        params{end+1}={187,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupParameters'));
        params{end+1}={188,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupDataTransfer'));
        params{end+1}={189,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupSharedLocalDataStores'));
        p_st=configset.internal.custom.showGroupSharedLocalDataStores(cs,'GroupSharedLocalDataStores');
        params{end+1}={190,{'options',p_options},{'st',p_st}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupInstanceSpecificParameters'));
        params{end+1}={191,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.coderGroupNameList(cs,'GroupModelData'));
        params{end+1}={192,{'options',p_options}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end


    groups={};





















































































































