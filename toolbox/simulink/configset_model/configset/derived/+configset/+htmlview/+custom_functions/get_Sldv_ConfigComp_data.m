
function[params,groups,FC]=get_Sldv_ConfigComp_data(cs)

    mcs=configset.internal.getConfigSetStaticData;
    mcc=mcs.getComponent('Sldv.ConfigComp');
    if isempty(mcc);compStatus=3;elseif isempty(mcc.Dependency);compStatus=0;else;compStatus=mcc.Dependency.getStatus(cs,'');end
    params={};


    if compStatus<3
        p_widgets=cell(1,3);

        p_widgets{1}={};

        w_disp=configset.internal.customwidget.SldvCompatibilityButtonPrompt(cs,'CheckCompatibility');
        w_st=configset.internal.custom.disableAnalysisBtn(cs,'CheckCompatibility');
        p_widgets{2}={{'disp',w_disp},{'prompt',w_disp},{'st',w_st}};

        w_disp=configset.internal.customwidget.SldvAnalyzeButtonPrompt(cs,'Analyze');
        w_st=configset.internal.custom.disableAnalysisBtn(cs,'Analyze');
        p_widgets{3}={{'disp',w_disp},{'prompt',w_disp},{'st',w_st}};
        params{end+1}={0,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.sldvRebuildModelRepresentation(cs,'DVRebuildModelRepresentation');
        params{end+1}={4,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.sldvValidateTCInParallel(cs,'DVUseParallel');
        params{end+1}={7,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.sldvValidateTCInParallel(cs,'DVUseParallel');
        params{end+1}={8,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={10,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={12,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.noValueWhenDisabled(cs,'DVBlockReplacementRulesList',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={16,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.noValueWhenDisabled(cs,'DVBlockReplacementModelFileName',0);
        p_value=p_WidgetValues{1};
        params{end+1}={17,{'value',p_value}};
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        w_st=configset.internal.custom.disableOnStandalone(cs,'DVLaunchVariantManager');
        p_widgets{2}={{'st',w_st}};
        params{end+1}={18,{'widgets',p_widgets}};
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
        p_WidgetValues=configset.internal.customwidget.noValueWhenDisabled(cs,'DVParametersConfigFileName',0);
        p_widgets=cell(1,3);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};

        w_value=p_WidgetValues{3};
        p_widgets{3}={{'value',w_value}};
        params{end+1}={23,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_st=configset.internal.custom.sldvTestGeneratedCodeTestGen(cs,'DVTestgenTarget');
        params{end+1}={24,{'st',p_st}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.modelCoverageEntries(cs,'DVModelCoverageObjectives'));
        params{end+1}={25,{'options',p_options}};
    end



    if compStatus<3
        p_st=configset.internal.custom.sldvStrictEnhancedMCDCDisplay(cs,'DVStrictEnhancedMCDC');
        params{end+1}={26,{'st',p_st}};
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
        params{end+1}={30,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={32,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={35,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={37,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={39,{'widgets',p_widgets}};
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
        p_WidgetValues=configset.internal.customwidget.noValueWhenDisabled(cs,'DVMaxViolationSteps',0);
        p_value=p_WidgetValues{1};
        params{end+1}={76,{'value',p_value}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.noValueWhenDisabled(cs,'DVDataFileName',0);
        p_value=p_WidgetValues{1};
        params{end+1}={78,{'value',p_value}};
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
        p_WidgetValues=configset.internal.customwidget.noValueWhenDisabled(cs,'DVHarnessModelFileName',0);
        p_value=p_WidgetValues{1};
        params{end+1}={83,{'value',p_value}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.harnessSource_entries(cs,'DVHarnessSource'));
        p_widgets{1}={{'options',w_options}};
        params{end+1}={86,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.sldvTestLicense(cs,'DVSlTestFileName');
        params{end+1}={88,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.sldvTestLicense(cs,'DVSlTestHarnessName');
        params{end+1}={90,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.sldvTestLicense(cs,'DVSlTestHarnessSource');
        params{end+1}={92,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.noValueWhenDisabled(cs,'DVReportFileName',0);
        p_value=p_WidgetValues{1};
        params{end+1}={96,{'value',p_value}};
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
        p_WidgetValues=configset.internal.customwidget.sldvParameterTableValues(cs,'DVParameterNames',0);
        p_widgets=cell(1,8);

        w_value=p_WidgetValues{1};
        w_tableData=configset.internal.customwidget.sldvParameterTable(cs,'sldvParamConfigTable');
        p_widgets{1}={{'value',w_value},{'tableData',w_tableData}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};

        w_value=p_WidgetValues{3};
        p_widgets{3}={{'value',w_value}};

        w_value=p_WidgetValues{4};
        p_widgets{4}={{'value',w_value}};

        w_value=p_WidgetValues{5};
        w_st=configset.internal.custom.sldvParamTableEnable(cs,'sldvParamConfigLocate');
        p_widgets{5}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{6};
        w_st=configset.internal.custom.sldvParamTableEnable(cs,'sldvParamConfigRefreshModel');
        p_widgets{6}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{7};
        p_widgets{7}={{'value',w_value}};

        w_value=p_WidgetValues{8};
        p_widgets{8}={{'value',w_value}};
        params{end+1}={103,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end


    groups={};



























































































































