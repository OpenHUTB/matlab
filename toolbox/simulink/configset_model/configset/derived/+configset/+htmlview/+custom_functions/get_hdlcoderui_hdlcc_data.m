
function[params,groups,FC]=get_hdlcoderui_hdlcc_data(cs)

    mcs=configset.internal.getConfigSetStaticData;
    mcc=mcs.getComponent('hdlcoderui.hdlcc');
    if isempty(mcc);compStatus=3;elseif isempty(mcc.Dependency);compStatus=0;else;compStatus=mcc.Dependency.getStatus(cs,'');end
    params={};


    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.HDLSubsystemEntries(cs,'HDLSubsystem'));
        p_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'HDLSubsystem');
        p_widgets=cell(1,4);

        w_options=configset.internal.util.convertToOptions(configset.internal.custom.HDLSubsystemEntries(cs,'HDLSubsystem'));
        p_widgets{1}={{'options',w_options}};

        w_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'RestoreFactoryDefaults');
        p_widgets{2}={{'st',w_st}};

        p_widgets{3}={};

        p_widgets{4}={};
        params{end+1}={0,{'options',p_options},{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'TargetDirectory');
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={2,{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_SynthesisToolValues(cs,'SynthesisTool',0);
        p_value=p_WidgetValues{1};
        p_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'SynthesisTool');
        params{end+1}={3,{'value',p_value},{'st',p_st}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.HDL_SynthesisToolEnums(cs,'SynthesisToolChipFamily'));
        p_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'SynthesisToolChipFamily');
        params{end+1}={4,{'options',p_options},{'st',p_st}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.HDL_SynthesisToolEnums(cs,'SynthesisToolDeviceName'));
        p_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'SynthesisToolDeviceName');
        params{end+1}={5,{'options',p_options},{'st',p_st}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.HDL_SynthesisToolEnums(cs,'SynthesisToolPackageName'));
        p_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'SynthesisToolPackageName');
        params{end+1}={6,{'options',p_options},{'st',p_st}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.HDL_SynthesisToolEnums(cs,'SynthesisToolSpeedValue'));
        p_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'SynthesisToolSpeedValue');
        params{end+1}={7,{'options',p_options},{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_WorkflowAdvisorStatus(cs,'TargetFrequency');
        params{end+1}={8,{'st',p_st}};
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
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={16,{'widgets',p_widgets}};
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
        p_WidgetValues=configset.internal.customwidget.HDLInputOutputTypeValue(cs,'InputType',0);
        p_value=p_WidgetValues{1};
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.HDLInputOutputTypeEnum(cs,'InputType'));
        params{end+1}={48,{'value',p_value},{'options',p_options}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDLInputOutputTypeValue(cs,'OutputType',0);
        p_value=p_WidgetValues{1};
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.HDLInputOutputTypeEnum(cs,'OutputType'));
        params{end+1}={49,{'value',p_value},{'options',p_options}};
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
        params{end+1}={59,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={60,{'widgets',p_widgets}};
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
        p_st=configset.internal.custom.enableDateCommentOnEmpty(cs,'DateComment');
        params{end+1}={127,{'st',p_st}};
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
        p_WidgetValues=configset.internal.customwidget.HDLCodingStandardCustomizationsValues(cs,'HDLCodingStandardCustomizations',0);
        p_widgets=cell(1,26);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};

        w_value=p_WidgetValues{3};
        p_widgets{3}={{'value',w_value}};

        w_value=p_WidgetValues{4};
        p_widgets{4}={{'value',w_value}};

        w_value=p_WidgetValues{5};
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoModuleInstanceEntityNameLength_min');
        p_widgets{5}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{6};
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoModuleInstanceEntityNameLength_max');
        p_widgets{6}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{7};
        p_widgets{7}={{'value',w_value}};

        w_value=p_WidgetValues{8};
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoSignalPortParamNameLength_min');
        p_widgets{8}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{9};
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoSignalPortParamNameLength_max');
        p_widgets{9}={{'value',w_value},{'st',w_st}};

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
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoConditionalRegionCheck_length');
        p_widgets{16}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{17};
        p_widgets{17}={{'value',w_value}};

        w_value=p_WidgetValues{18};
        p_widgets{18}={{'value',w_value}};

        w_value=p_WidgetValues{19};
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoIfElseChain_length');
        p_widgets{19}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{20};
        p_widgets{20}={{'value',w_value}};

        w_value=p_WidgetValues{21};
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoIfElseNesting_depth');
        p_widgets{21}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{22};
        p_widgets{22}={{'value',w_value}};

        w_value=p_WidgetValues{23};
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoMultiplierBitWidth_width');
        p_widgets{23}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{24};
        p_widgets{24}={{'value',w_value}};

        w_value=p_WidgetValues{25};
        p_widgets{25}={{'value',w_value}};

        w_value=p_WidgetValues{26};
        w_st=configset.internal.custom.HDLCodingStandardCustomizationsStatus(cs,'csoLineLength_length');
        p_widgets{26}={{'value',w_value},{'st',w_st}};
        params{end+1}={141,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_FloatingPointTargetValues(cs,'FloatingPointTargetConfiguration',0);
        p_widgets=cell(1,10);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'NFPLatencyStrategy');
        p_widgets{2}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{3};
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'HandleDenormals');
        p_widgets{3}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{4};
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'NFPAlgoMultStrategy');
        p_widgets{4}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{5};
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'FrequencyModeInitLogic');
        p_widgets{5}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{6};
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'FloatingPointDataTypeString');
        p_widgets{6}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{7};
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'FloatingPointDataTypeInsert');
        p_widgets{7}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{8};
        w_tableData=configset.internal.customwidget.HDLFloatIPConfigTable(cs,'FloatingPointIPConfigTable');
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'FloatingPointIPConfigTable');
        p_widgets{8}={{'value',w_value},{'tableData',w_tableData},{'st',w_st}};

        w_value=p_WidgetValues{9};
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'LatencyStrategy');
        p_widgets{9}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{10};
        w_st=configset.internal.custom.HDLFloatingPointTargetWidgetsStatus(cs,'LatencyModeObjective');
        p_widgets{10}={{'value',w_value},{'st',w_st}};
        params{end+1}={142,{'widgets',p_widgets}};
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
        p_widgets=cell(1,2);

        w_st=configset.internal.custom.HDL_testbenchEnabled(cs,'GenerateHDLTestBench');
        p_widgets{1}={{'st',w_st}};

        w_st=configset.internal.custom.HDL_testbenchEnabled(cs,'GenerateHDLTestBenchButton');
        p_widgets{2}={{'st',w_st}};
        params{end+1}={156,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'SimulationTool');
        params{end+1}={157,{'st',p_st}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_SimToolValues(cs,'GenerateCoSimModel',0);
        p_st=max([configset.internal.custom.HDL_edalinksinstalled(cs,'GenerateCoSimModel'),configset.internal.custom.HDL_testbenchEnabled(cs,'GenerateCoSimModel')]);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={158,{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_SimToolValues(cs,'GenerateSVDPITestBench',0);
        p_st=max([configset.internal.custom.HDL_edalinksinstalled(cs,'GenerateSVDPITestBench'),configset.internal.custom.HDL_testbenchEnabled(cs,'GenerateSVDPITestBench')]);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={159,{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_st=max([configset.internal.custom.HDL_edalinksinstalled(cs,'HDLCodeCoverage'),configset.internal.custom.HDL_testbenchEnabled(cs,'HDLCodeCoverage')]);
        params{end+1}={160,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'TestBenchPostfix');
        params{end+1}={161,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'ForceClock');
        params{end+1}={162,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'ClockHighTime');
        params{end+1}={163,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'ClockLowTime');
        params{end+1}={164,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'HoldTime');
        params{end+1}={165,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'ForceClockEnable');
        params{end+1}={167,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'TestBenchClockEnableDelay');
        params{end+1}={168,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'ForceReset');
        params{end+1}={169,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'ResetLength');
        params{end+1}={170,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'HoldInputDataBetweenSamples');
        params{end+1}={171,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'InitializeTestBenchInputs');
        params{end+1}={172,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'MultifileTestBench');
        params{end+1}={174,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'TestBenchDataPostfix');
        params{end+1}={175,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'TestBenchReferencePostFix');
        params{end+1}={176,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'UseFileIOInTestBench');
        params{end+1}={177,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'IgnoreDataChecking');
        params{end+1}={178,{'st',p_st}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_FPToleranceStrategyValues(cs,'FPToleranceStrategy',0);
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'FPToleranceStrategy');
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={179,{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_FPToleranceValues(cs,'FPToleranceValue',0);
        p_value=p_WidgetValues{1};
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'FPToleranceValue');
        params{end+1}={180,{'value',p_value},{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HDL_testbenchEnabled(cs,'SimulationLibPath');
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={181,{'st',p_st},{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={184,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={185,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={186,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={187,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={189,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={190,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={191,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={192,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_SynthTool(cs,'HDLSynthTool',0);
        p_value=p_WidgetValues{1};
        params{end+1}={194,{'value',p_value}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_SynthScriptValues(cs,'HDLSynthFilePostfix',0);
        p_value=p_WidgetValues{1};
        params{end+1}={195,{'value',p_value}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_SynthScriptValues(cs,'HDLSynthInit',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={196,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_SynthScriptValues(cs,'HDLSynthCmd',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={197,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_SynthScriptValues(cs,'HDLSynthTerm',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={198,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_LintTool(cs,'HDLLintTool',0);
        p_value=p_WidgetValues{1};
        params{end+1}={200,{'value',p_value}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_LintScriptValues(cs,'HDLLintInit',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={201,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_LintScriptValues(cs,'HDLLintCmd',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={202,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HDL_LintScriptValues(cs,'HDLLintTerm',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={203,{'widgets',p_widgets}};
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


    groups={};
















































































































































































































































