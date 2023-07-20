function recordCellArray=defineModelAdvisorChecks


























































































    recordCellArray={};
    modelAdvisor=ModelAdvisor.Root;




    stateflow.modeladvisor.checks.MLFBPreserveDimsCheck.register();


    slrapidAcceleratorSignalLoggingCheck=ModelAdvisor.Check('mathworks.design.CheckRapidAcceleratorSignalLogging');
    slrapidAcceleratorSignalLoggingCheck.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckRapidAcceleratorSignalLogging');
    slrapidAcceleratorSignalLoggingCheck.TitleTips=DAStudio.message('ModelAdvisor:engine:MACheckRapidAcceleratorSignalLogging');
    slrapidAcceleratorSignalLoggingCheck.setCallbackFcn(@ExecRapidAcceleratorSignalLoggingCheck,'None','StyleOne');
    slrapidAcceleratorSignalLoggingCheck.Value=true;
    slrapidAcceleratorSignalLoggingCheck.CSHParameters.MapKey='ma.simulink';
    slrapidAcceleratorSignalLoggingCheck.CSHParameters.TopicID='CheckRapidAcceleratorSignalLogging';
    slrapidAcceleratorSignalLoggingAction=ModelAdvisor.Action;
    slrapidAcceleratorSignalLoggingAction.setCallbackFcn(@ActionRapidAcceleratorSignalLoggingCheck);
    slrapidAcceleratorSignalLoggingAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    slrapidAcceleratorSignalLoggingAction.Description=DAStudio.message('ModelAdvisor:engine:MACheckRapidAcceleratorSignalLoggingActionDescription');
    slrapidAcceleratorSignalLoggingCheck.setAction(slrapidAcceleratorSignalLoggingAction);
    modelAdvisor.register(slrapidAcceleratorSignalLoggingCheck);


    virtualBusAcrossModelReferenceCheck=ModelAdvisor.Check('mathworks.design.CheckVirtualBusAcrossModelReference');
    virtualBusAcrossModelReferenceCheck.Title=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_Title');
    virtualBusAcrossModelReferenceCheck.TitleTips=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_Titletip');
    virtualBusAcrossModelReferenceCheck.setCallbackFcn(@checkVirtualBusAcrossModelReference,'None','StyleOne');
    virtualBusAcrossModelReferenceCheck.Value=false;
    virtualBusAcrossModelReferenceCheck.CSHParameters.MapKey='ma.simulink';
    virtualBusAcrossModelReferenceCheck.CSHParameters.TopicID='MACheckVirtualBusAcrossModelReference';

    virtualBusAcrossModelReferenceAction=ModelAdvisor.Action;
    virtualBusAcrossModelReferenceAction.setCallbackFcn(@actionVirtualBusAcrossModelReference);
    virtualBusAcrossModelReferenceAction.Name=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_ActionButtonName');
    virtualBusAcrossModelReferenceAction.Description=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_ActionButtonDescription');
    virtualBusAcrossModelReferenceCheck.CallbackContext='DIY';

    virtualBusAcrossModelReferenceCheck.setAction(virtualBusAcrossModelReferenceAction);
    modelAdvisor.register(virtualBusAcrossModelReferenceCheck);


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleIdentUnconnectLine');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentUnconnectLine');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleIdentUnconnectLine';
    rec.CallbackHandle=@ExecCheckUnconnected;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.UnconnectedLinesPorts';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;

    recordCellArray{end+1}=rec;





    rec=defineRootInportSpecCheck;

    recordCellArray{end+1}=rec;

    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MATitleCGSL_0101');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MATitleCGSL_0101_Tip');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='MATitle_cgsl_0101';
    rec.CallbackHandle=@ExecCGSL_0101;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ListViewVisible=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink Coder';
    rec.GroupID='Simulink Coder';
    rec.TitleID='mathworks.codegen.cgsl_0101';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.LicenseName={'Real-Time_Workshop'};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckSolver');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckSolver');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check solver for code generation';
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='MATitleCheckSolver';
    rec.CallbackHandle=@ExecCheckSolver;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink Coder';
    rec.GroupID='Simulink Coder';
    rec.TitleID='mathworks.codegen.SolverCodeGen';
    rec.LicenseName={'Real-Time_Workshop'};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:TitleMismatchedBusParameters');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:TitleTipMismatchedBusParameters');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle=DAStudio.message('ModelAdvisor:engine:TitleMismatchedBusParameters');
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='mathworks.design.MAMismatchedBusParameters';
    rec.CallbackHandle=@ExecIdentifyMismatchedBusParams;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.MismatchedBusParams';

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleIdentQuestBlocks');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentQuestBlocks');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='MATitleIdentQuestBlocks';
    rec.RAWTitle='';
    rec.CallbackHandle=@ExecCheckQuestBlock;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.VisibleInProductList=false;
    rec.Group='Simulink Coder';
    rec.GroupID='Simulink Coder';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.TitleID='mathworks.codegen.QuestionableBlks';
    rec.LicenseName={'Real-Time_Workshop'};

    recordCellArray{end+1}=rec;


    rec=defineCheckQuestionableBlocksCodegen;
    recordCellArray{end+1}=rec;


    rec=defineCheckQuestionableBlocksProduction;
    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckModelrefMismatch');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckModelrefMismatch');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='';
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='MATitleCheckModelrefMismatch';
    rec.CallbackHandle=@ExecCheckMdlrefBlock;
    rec.CallbackContext='none';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink Coder';
    rec.GroupID='Simulink Coder';
    rec.TitleID='mathworks.codegen.MdlrefConfigMismatch';
    rec.LicenseName={'Real-Time_Workshop'};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckModelRefSIMConfigCompliance');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckModelRefSIMConfigCompliance');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckModelRefSIMConfigCompliance';
    rec.CallbackHandle=@execCheckModelRefSIMConfigCompliance;
    rec.CallbackContext='none';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.ModelRefSIMConfigCompliance';

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckModelRefRTWConfigCompliance');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckModelRefRTWConfigCompliance');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='';
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='MATitleCheckModelRefRTWConfigCompliance';
    rec.CallbackHandle=@execCheckModelRefRTWConfigCompliance;
    rec.CallbackContext='none';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink Coder';
    rec.GroupID='Simulink Coder';
    rec.TitleID='mathworks.codegen.ModelRefRTWConfigCompliance';
    rec.LicenseName={'Real-Time_Workshop'};

    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.codegen.EnableLongLong');

    rec.Title=DAStudio.message('Simulink:tools:MATitleEnableLongLong');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitleTipEnableLongLong');
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleEnableLongLong';
    rec.Group='Embedded Coder';
    rec.LicenseName={'Real-Time_Workshop'};
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;
    rec.CallbackContext='PostCompile';

    modelAdvisor.publish(rec,'Embedded Coder');


    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.codegen.LUTRangeCheckCode');
    rec.Title=DAStudio.message('Simulink:tools:MATitleIdentLUTRangeCheckCode');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentLUTRangeCheckCode');
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleIdentLUTRangeCheckCode';
    rec.ListViewVisible=true;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Embedded Coder';
    rec.LicenseName={'RTW_Embedded_Coder'};
    rec.SupportExclusion=true;
    rec.SupportsEditTime=true;
    rec.SupportLibrary=true;
    recAction=ModelAdvisor.Action;
    recAction.setCallbackFcn(@actionRemoveLookupTableRangeCheckingCode);
    recAction.Name=DAStudio.message('Simulink:tools:MALookupTableRangeRemove');
    recAction.Description=DAStudio.message('Simulink:tools:MALUTRemoveRangeCheckCodeDscp');

    rec.setAction(recAction);
    modelAdvisor.publish(rec,'Embedded Coder');





    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:TitleIdentLogicBlockUseNonBooleanOutput');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:TitletipIdentLogicBlockUseNonBooleanOutput');
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='TitleIdentLogicBlockUseNonBooleanOutput';
    rec.CallbackHandle=@checkLogicBlockUseNonBooleanOutput;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.ListViewVisible=true;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Embedded Coder';
    rec.GroupID='Embedded Coder';
    rec.TitleID='mathworks.codegen.LogicBlockUseNonBooleanOutput';
    rec.LicenseName={'RTW_Embedded_Coder'};
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.ActionCallbackHandle=@actionChangeLogicBlockUseNonBooleanOutput;
    rec.ActionButtonName=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    rec.ActionDescription=DAStudio.message('ModelAdvisor:engine:ChangeLogicBlockUseNonBooleanOutputDscp');

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckHardImple');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckHardImple');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleCheckHardImple';
    rec.CallbackHandle=@ExecCheckHardware;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Embedded Coder';
    rec.GroupID='Embedded Coder';
    rec.TitleID='mathworks.codegen.HWImplementation';
    rec.LicenseName={'RTW_Embedded_Coder'};

    recordCellArray{end+1}=rec;


    dataFilePath=[matlabroot,filesep,'toolbox',filesep,...
    'simulink',filesep,'simulink',filesep,'modeladvisor',filesep,...
    '+internalcustomization',filesep,...
    'private',filesep];

    rec=ModelAdvisor.Check('mathworks.design.OptimizationSettings');

    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckOptimSetting');
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckOptimSetting';

    rec.setCallbackFcn(@(system,CheckObj,xmlfile)Advisor.authoring.CustomCheck.newStyleCheckCallback(system,CheckObj,[dataFilePath,'optimizeCodegen.xml']),'None','DetailStyle');
    rec.setReportCallbackFcn(@Advisor.authoring.CustomCheck.newStyleReportCallback);
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckOptimSetting');
    rec.Value=true;

    rec.TitleID='mathworks.design.OptimizationSettings';

    rec.setLicense({'RTW_Embedded_Coder'});

    act=ModelAdvisor.Action;
    act.setCallbackFcn(@(task)(Advisor.authoring.CustomCheck.actionCallback(task)));
    act.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    act.Description=DAStudio.message('Advisor:engine:CCActionDescription');
    rec.setAction(act)

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Simulink');




    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleIdentQuestSoftSpec');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentQuestSoftSpec');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleIdentQuestSoftSpec';
    rec.CallbackHandle=@ExecCheckSoftwareEnv;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Embedded Coder';
    rec.GroupID='Embedded Coder';
    rec.TitleID='mathworks.codegen.SWEnvironmentSpec';
    rec.LicenseName={'RTW_Embedded_Coder'};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleIdentQuestCodeInstr');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentQuestCodeInstr');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleIdentQuestCodeInstr';
    rec.CallbackHandle=@ExecCheckCodeInstrument;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Embedded Coder';
    rec.GroupID='Embedded Coder';
    rec.SupportExclusion=true;
    rec.TitleID='mathworks.codegen.CodeInstrumentation';
    rec.LicenseName={'RTW_Embedded_Coder'};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckSampleTime');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckSampleTime');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check sample times and tasking mode';
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='MATitleCheckSampleTime';
    rec.CallbackHandle=@ExecCheckTasking;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink Coder';
    rec.GroupID='Simulink Coder';
    rec.TitleID='mathworks.codegen.SampleTimesTaskingMode';
    rec.LicenseName={'Real-Time_Workshop'};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckBlockConstraintTunableParam');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckBlockConstraintTunableParam');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle=rec.Title;
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='MATitleCheckBlockConstraintTunableParam';
    rec.CallbackHandle=@ExecCheckTunableBlock;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink Coder';
    rec.GroupID='Simulink Coder';
    rec.SupportExclusion=true;
    rec.TitleID='mathworks.codegen.ConstraintsTunableParam';
    rec.LicenseName={'Real-Time_Workshop'};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckParamTunableIgnore');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckParamTunableIgnore');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check for parameter tunability info ignored by Simulink';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckParamTunableIgnore';
    rec.CallbackHandle=@ExecCheckTunableParams;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.ParamTunabilityIgnored';

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckImplicitSignalRes');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckImplicitSignalRes');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check for implicit signal resolution';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckImplicitSignalRes';
    rec.CallbackHandle=@ExecCheckImplicitSignal;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.ImplicitSignalResolution';

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckOptimalBusVirtual');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckOptimalBusVirtual');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check for optimal bus virtuality';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckOptimalBusVirtual';
    rec.CallbackHandle=@ExecCheckBusVirtual;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.OptBusVirtuality';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleReplaceZOHDelayByRTB');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipReplaceZOHDelayByRTB');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleReplaceZOHDelayByRTB';
    rec.ActionCallbackHandle=@ActionReplaceZOHDelayByRTB;
    rec.ActionButtonName=DAStudio.message('Simulink:tools:MAReplaceZOHDelayByRTBActionButtonName');
    rec.ActionDescription=DAStudio.message('Simulink:tools:MAReplaceZOHDelayByRTBActionDescription');
    rec.CallbackHandle=@ExecReplaceZOHDelayByRTB;
    rec.CallbackContext='Postcompile';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.ReplaceZOHDelayByRTB';
    rec.SupportExclusion=true;
    rec.SupportLibrary=false;

    recordCellArray{end+1}=rec;

    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckBusTreatedAsVector');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckBusTreatedAsVector');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check bus signals treated as vectors';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckBusTreatedAsVector';
    rec.CallbackHandle=@ExecCheckBusTreatedAsVector;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ActionCallbackHandle=modeladvisorprivate('getPrivateFunctionHandle','actionAddBus2Vec');
    rec.ActionButtonName=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    rec.ActionDescription=DAStudio.message('ModelAdvisor:styleguide:CommonMAMuxUsedFixMsg');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.BusTreatedAsVector';

    recordCellArray{end+1}=rec;

    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_Titletip');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check for large number of function arguments from virtual bus across model reference boundary';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MACheckVirtualBusAcrossModelReferenceArgs';
    rec.CallbackHandle=@checkVirtualBusAcrossModelReferenceArgs;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ActionCallbackHandle=@actionVirtualBusAcrossModelReferenceArgs;
    rec.ActionButtonName=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_ActionButtonName');
    rec.ActionDescription=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_ActionButtonDescription');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.CheckVirtualBusAcrossModelReferenceArgs';
    recordCellArray{end+1}=rec;



    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckDTAndScale');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckDTAndScale');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check for calls to slDataTypeAndScale';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckForCallsToSlDataTypeAndScale';
    rec.CallbackHandle=@DTAndScaleCallback;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.ListViewVisible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.CallslDataTypeAndScale';
    rec.SupportExclusion=true;
    rec.ActionCallbackHandle=@actionRemoveDTAndScale;
    rec.ActionButtonName=DAStudio.message('Simulink:tools:MADTAndScaleRemove');
    rec.ActionDescription=DAStudio.message('Simulink:tools:MADTAndScaleRemoveDscp_new');


    recordCellArray{end+1}=rec;

    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckForProperFcnCallRetVals');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckForProperFcnCallRetVals');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Check for potentially delayed function-call subsystem return values';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckForProperFcnCallRetVals';
    rec.CallbackHandle=@ExecCheckForProperFunctionCallReturnValues;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.DelayedFcnCallSubsys';
    rec.SupportExclusion=true;

    recordCellArray{end+1}=rec;



    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckDiscreteIntegBlockwInitialCondition');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitleChecktipDiscreteIntegBlockwInitialCondition');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckDiscreteIntegBlockwInitialCondition';
    rec.CallbackHandle=@ExecCheckDiscreteInt;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.DiscreteTimeIntegratorInitCondition';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;

    recordCellArray{end+1}=rec;



    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleIdentQuestSubsysSetting');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentQuestSubsysSetting');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleIdentQuestSubsysSetting';
    rec.CallbackHandle=@ExecCheckSubsys;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Embedded Coder';
    rec.GroupID='Embedded Coder';
    rec.TitleID='mathworks.codegen.QuestionableSubsysSetting';
    rec.SupportExclusion=true;
    rec.LicenseName={'RTW_Embedded_Coder'};

    recordCellArray{end+1}=rec;

    rec=ModelAdvisor.Check('mathworks.codegen.EfficientTunableParamExpr');
    rec.Title=DAStudio.message('Simulink:tools:MAEfficientTunableParamExprTitle');
    rec.TitleTips=DAStudio.message('Simulink:tools:MAEfficientTunableParamExprTips');



    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='EfficientTunableParamExpr';


    rec.setCallbackFcn(@EfficientTunableParamExprAlgo,'None','StyleOne');
    rec.setLicense({'RTW_Embedded_Coder'});
    recAction=ModelAdvisor.Action;
    recAction.setCallbackFcn(@(task)(Advisor.authoring.CustomCheck.actionCallback(task)));
    recAction.Name='Modify';
    recAction.Description=DAStudio.message('Simulink:tools:MAEfficientTunableParamExprActionDesciption');
    rec.setAction(recAction);
    modelAdvisor.publish(rec,'Embedded Coder');




    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleIdentSigsWithContTsAndNonFloatDataType');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitleIdentSigsWithContTsAndNonFloatDataType');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleIdentSigsWithContTsAndNonFloatDataType';
    rec.CallbackHandle=@ExecIdentSigsWithContTsAndNonFloatDataType;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.OutputSignalSampleTime';
    rec.LicenseName={};
    rec.SupportExclusion=true;

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckDisabledLinks');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckDisabledLinks');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckDisabledLinks';
    rec.CallbackHandle=@ExecCheckDisabledLibLinks;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.DisabledLibLinks';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.LicenseName={};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckParameterizedLinks');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckParameterizedLinks');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckParameterizedLinks';
    rec.CallbackHandle=@ExecCheckParameterizedLibLinks;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.ParameterizedLibLinks';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.LicenseName={};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckUnresolvedLinks');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckUnresolvedLinks');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckUnresolvedLinks';
    rec.CallbackHandle=@ExecCheckUnresolvedLibLinks;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.UnresolvedLibLinks';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.LicenseName={};


    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleIdentConfigSubsys');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentConfigSubsys');
    rec.TitleInRAWFormat=false;
    rec.RAWTitle='Identify Configurable Subsystem template blocks for Upgradation';
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitletipIdentConfigSubsys';
    rec.CallbackHandle=@Simulink.variant.upgradeAdvisor.checkConfigSubsys;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.SupportExclusion=true;
    rec.ListViewVisible=true;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.CSStoVSSConvert';
    rec.SupportLibrary=true;

    rec.ActionCallbackHandle=@Simulink.variant.upgradeAdvisor.convertListedCSSBlocksToVSS;
    rec.ActionButtonName=DAStudio.message('Simulink:tools:MAConfigSubsysAction');
    rec.ActionDescription=DAStudio.message('Simulink:tools:MAConfigSubsysActionDescription');

    recordCellArray{end+1}=rec;



    slConvertMdlrefVarToVSSCheck=ModelAdvisor.Check('mathworks.design.ConvertMdlrefVarToVSS');
    slConvertMdlrefVarToVSSCheck.Title=DAStudio.message('Simulink:tools:MATitleConvertMdlrefVarToVSS');
    slConvertMdlrefVarToVSSCheck.TitleTips=DAStudio.message('Simulink:tools:MATitletipConvertMdlrefVarToVSS');
    slConvertMdlrefVarToVSSCheck.CSHParameters.MapKey='ma.simulink';
    slConvertMdlrefVarToVSSCheck.CSHParameters.TopicID='MATitletipConvertMdlrefVarToVSS';
    slConvertMdlrefVarToVSSCheck.setCallbackFcn(@Simulink.variant.upgradeAdvisor.identifyMdlrefVarInMdl,'None','StyleOne');
    slConvertMdlrefVarToVSSCheck.Value=true;
    slConvertMdlrefVarToVSSCheck.SupportExclusion=true;
    slConvertMdlrefVarToVSSCheck.SupportLibrary=true;

    slConvertMdlrefVarToVSSAction=ModelAdvisor.Action;
    slConvertMdlrefVarToVSSAction.Name=DAStudio.message('Simulink:tools:MAConvertMdlrefVarToVSSCheckActionButtonName');
    slConvertMdlrefVarToVSSAction.Description=DAStudio.message('Simulink:tools:MAConvertMdlrefVarToVSSCheckActionButtonDescription');
    slConvertMdlrefVarToVSSAction.setCallbackFcn(@Simulink.variant.upgradeAdvisor.convertMdlrefVarToVSSWithMdlChoices);

    slConvertMdlrefVarToVSSCheck.setAction(slConvertMdlrefVarToVSSAction);
    modelAdvisor.register(slConvertMdlrefVarToVSSCheck);


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleFcnCallUsageCheck');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipFcnCallUsageCheck');
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='mathworks.design.CheckForProperFcnCallUsage';

    rec.ActionButtonName=...
    DAStudio.message('Simulink:tools:MAFcnCallUsageCheckActionButtonName');
    rec.ActionDescription=...
    DAStudio.message('Simulink:tools:MAFcnCallUsageCheckActionDescription');
    rec.ActionCallbackHandle=@ActionFcnCallUsageCheck;

    rec.CallbackHandle=@ExecFcnCallUsageCheck;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.CheckForProperFcnCallUsage';
    rec.LicenseName={};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckForProperMergeBlockUsage');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MATitletipCheckForProperMergeBlockUsage');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckForProperMergeBlockUsage';
    rec.CallbackHandle=@ExecMergeUsageAnalysis;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ListViewVisible=true;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.MergeBlkUsage';
    rec.LicenseName={};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckForProperOutportBlockUsage');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MATitletipCheckForProperOutportBlockUsage');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckForProperOutportBlockUsage';
    rec.ActionCallbackHandle=@ActionOutportInitParamsCheck;
    rec.ActionButtonName=...
    DAStudio.message('Simulink:tools:MAOutportCondSubsysCheckActionButtonName');
    rec.ActionDescription=...
    DAStudio.message('Simulink:tools:MAOutportCondSubsysCheckActionDescription');
    rec.CallbackHandle=@ExecOutportAnalysis;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ListViewVisible=true;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.InitParamOutportMergeBlk';
    rec.LicenseName={};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckForProperDiscreteBlockUsage');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MATitletipCheckForProperDiscreteBlockUsage');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckForProperDiscreteBlockUsage';
    rec.ActionCallbackHandle=@ActionOutportInitParamsCheck;
    rec.ActionButtonName=...
    DAStudio.message('Simulink:tools:MADiscreteIntegratorCheckActionButtonName');
    rec.ActionDescription=...
    DAStudio.message('Simulink:tools:MADiscreteIntegratorCheckActionDescription');
    rec.CallbackHandle=@ExecDiscreteIntegratorAnalysis;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ListViewVisible=true;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.DiscreteBlock';
    rec.LicenseName={};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckForModelLevelMessages');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MATitletipCheckForModelLevelMessages');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckForModelLevelMessages';
    rec.ActionCallbackHandle=@ActionSimplifiedModeCheck;
    rec.ActionButtonName=...
    DAStudio.message('Simulink:tools:MASimplifiedModeCheckActionButtonName');
    rec.ActionDescription=...
    DAStudio.message('Simulink:tools:MASimplifiedModeCheckActionDescription');
    rec.CallbackHandle=@ExecModelLevelAnalysis;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.ModelLevelMessages';
    rec.LicenseName={};

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckOldMaskedBuiltinBlocks');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MACheckOldMaskedBuiltinBlocks');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckOldMaskedBuiltinBlocks';
    rec.CallbackHandle=@checkOldMaskedBuiltInBlocks;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ActionCallbackHandle=@actionUpdateOldMaskedBuiltInBlocks;
    rec.ActionButtonName=DAStudio.message('ModelAdvisor:engine:MAUpdateButtonCheckOldMaskedBuiltinBlocks');
    rec.ActionDescription=DAStudio.message('ModelAdvisor:engine:MAActionOldMaskedBuiltinBlocks');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;


    rec.TitleID='mathworks.design.CheckAndUpdateOldMaskedBuiltinBlocks';
    rec.SupportExclusion=true;
    rec.LicenseName={};
    rec.SupportLibrary=true;
    rec.VisibleInProductList=false;

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckMaskDisplayImageFormat');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MACheckMaskDisplayImageFormat');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckMaskDisplayImageFormat';
    rec.CallbackHandle=@checkMaskDisplayImageFormat;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ActionCallbackHandle=@actionUpdateMaskDisplayImageFormat;
    rec.ActionButtonName=DAStudio.message('ModelAdvisor:engine:MAUpdateButtonCheckMaskDisplayImageFormat');
    rec.ActionDescription=DAStudio.message('ModelAdvisor:engine:MAActionCheckMaskDisplayImageFormat');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.CheckMaskDisplayImageFormat';
    rec.SupportExclusion=true;
    rec.LicenseName={};
    rec.SupportLibrary=true;

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckMaskRunInitFlag');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:MACheckMaskRunInitFlag');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckMaskRunInitFlag';
    rec.CallbackHandle=@checkMaskRunInitFlag;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.ActionCallbackHandle=@actionUpdateMaskRunInitFlag;
    rec.ActionButtonName=DAStudio.message('ModelAdvisor:engine:MAUpdateButtonCheckMaskRunInitFlag');
    rec.ActionDescription=DAStudio.message('ModelAdvisor:engine:MAActionCheckMaskRunInitFlag');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.CheckMaskRunInitFlag';
    rec.SupportExclusion=true;
    rec.LicenseName={};
    rec.SupportLibrary=true;

    recordCellArray{end+1}=rec;


    codeReuseCheck=ModelAdvisor.Check('mathworks.codegen.SubsysCodeReuse');
    codeReuseCheck.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckSubsysCodeReuse');
    codeReuseCheck.TitleTips=DAStudio.message('ModelAdvisor:engine:MATitleCheckSubsysCodeReuse_tip');
    codeReuseCheck.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:engine:MATitleCheckSubsysCodeReuse',@ExecCheckSubsysCodeReuse),...
    'PostCompile','DetailStyle');
    codeReuseCheck.CSHParameters.MapKey='ma.rtw';
    codeReuseCheck.CSHParameters.TopicID='MATitleCheckSubsysCodeReuse';
    codeReuseCheck.Visible=true;
    codeReuseCheck.Enable=true;
    codeReuseCheck.Value=false;
    codeReuseCheck.Group='Simulink Coder';
    codeReuseCheck.SupportExclusion=true;
    codeReuseCheck.SupportLibrary=false;
    codeReuseCheck.LicenseName={'Real-Time_Workshop'};

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    codeReuseCheck.setInputParametersLayoutGrid([1,4]);
    codeReuseCheck.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(codeReuseCheck,'Simulink Coder');

    rec=defineCheckQuestionableRowMajorBlocksCodeGen;
    recordCellArray{end+1}=rec;

    rec=defineCheckRowMajorAlgorithm;
    recordCellArray{end+1}=rec;

    rec=defineCheckRowMajorUnsetSFunction;
    recordCellArray{end+1}=rec;


    slGetParamCompiledSampleTimeCheck=ModelAdvisor.Check('mathworks.design.CallsGetParamCompiledSampleTime');
    slGetParamCompiledSampleTimeCheck.Title=DAStudio.message('ModelAdvisor:engine:MATitleCheckGetParamCompiledSampleTime');
    slGetParamCompiledSampleTimeCheck.TitleTips=DAStudio.message('ModelAdvisor:engine:MATitletipCheckGetParamCompiledSampleTime');
    slGetParamCompiledSampleTimeCheck.setCallbackFcn(@checkForGetParamCompiledSampleTime,'None','StyleOne');
    slGetParamCompiledSampleTimeCheck.Value=true;
    slGetParamCompiledSampleTimeCheck.CSHParameters.MapKey='ma.simulink';
    slGetParamCompiledSampleTimeCheck.CSHParameters.TopicID='MATitleCheckForCallsToGetParamCompiledSampleTime';
    modelAdvisor.register(slGetParamCompiledSampleTimeCheck);


    slParameterTuningCheck=ModelAdvisor.Check('mathworks.design.ParameterTuning');
    slParameterTuningCheck.Title=DAStudio.message('ModelAdvisor:engine:MATitleParameterTuningCheck');
    slParameterTuningCheck.TitleTips=DAStudio.message('ModelAdvisor:engine:MATitletipParameterTuningCheck');
    slParameterTuningCheck.setCallbackFcn(@ExecParameterTuningCheck,'DIY','StyleOne');
    slParameterTuningCheck.Value=false;
    slParameterTuningCheck.CSHParameters.MapKey='ma.simulink';
    slParameterTuningCheck.CSHParameters.TopicID='ParameterTuning';

    slParameterTuningAction=ModelAdvisor.Action;
    slParameterTuningAction.setCallbackFcn(@ActionParameterTuningCheck);
    slParameterTuningAction.Name=DAStudio.message('ModelAdvisor:engine:MAParameterTuningCheckButtonName');
    slParameterTuningAction.Description=DAStudio.message('ModelAdvisor:engine:MAParameterTuningActionDescription');
    slParameterTuningCheck.setAction(slParameterTuningAction);

    modelAdvisor.register(slParameterTuningCheck);











    function ResultDescription=ExecCheckDisabledLibLinks(system)

        ResultDescription={};



        handles=find_system(system,'RegExp','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','on',...
        'AncestorBlock','.');
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

        ft=ModelAdvisor.FormatTemplate('ListTemplate');

        handles=mdladvObj.filterResultWithExclusion(handles);
        ft.setSubBar(false);
        if~isempty(handles)
            ft.setSubResultStatus('warn');
            ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultCheckDisabledLinks',DAStudio.message('Simulink:studio:RestoreLibraryLink_Text'),DAStudio.message('Simulink:studio:LibraryLinkMenu_Text')));
            ft.setListObj(handles);
            mdladvObj.setCheckResultStatus(false);
        else
            ft.setSubResultStatus('pass');
            mdladvObj.setCheckResultStatus(true);
        end
        ResultDescription{end+1}=ft;









        function[ResultDescription,ResultHandles]=ExecCheckParameterizedLibLinks(system)

            ResultDescription={};
            ResultHandles={};








            linkblocks=find_system(system,'LookUnderMasks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LinkStatus','resolved');


            confblocks=find_system(system,'LookUnderMasks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','BlockType','SubSystem','BlockChoice','.');
            allblocks=[linkblocks(:);confblocks(:)];

            linkdata=get_param(allblocks,'LinkData');
            hasdata=~cellfun('isempty',linkdata);
            handles=allblocks(hasdata);

            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


            handles=mdladvObj.filterResultWithExclusion(handles);

            if~isempty(handles)
                description=DAStudio.message('Simulink:tools:MAResultCheckParameterizedLinks');
                mdladvObj.setCheckResultStatus(false);
            else
                description=['<p /><font color="#008000">',...
                DAStudio.message('Simulink:tools:MAPassedMsg'),...
                '</font>'];
                mdladvObj.setCheckResultStatus(true);
            end

            ResultHandles{end+1}=handles;
            ResultDescription{end+1}=description;









            function[ResultDescription,ResultHandles]=ExecCheckUnresolvedLibLinks(system)

                ResultDescription={};
                ResultHandles={};



                handles=find_system(system,'LookUnderMasks','on','FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LinkStatus','unresolved');

                mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


                handles=mdladvObj.filterResultWithExclusion(handles);

                if~isempty(handles)
                    description=DAStudio.message('Simulink:tools:MAResultCheckUnresolvedLinks');
                    mdladvObj.setCheckResultStatus(false);
                else
                    description=['<p /><font color="#008000">',...
                    DAStudio.message('Simulink:tools:MAPassedMsg'),...
                    '</font>'];
                    mdladvObj.setCheckResultStatus(true);
                end

                ResultHandles{end+1}=handles;
                ResultDescription{end+1}=description;










                function[ResultDescription,ResultHandles]=...
                    ExecIdentSigsWithContTsAndNonFloatDataType(system)

                    ResultDescription={};
                    ResultHandles={};

                    handles=IdentSigsWithContTsAndNonFloatDataType(system);
                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


                    handles=mdladvObj.filterResultWithExclusion(handles);

                    if~isempty(handles)
                        description=DAStudio.message('ModelAdvisor:engine:SigsWithContTsAndNonFloatDataTypeWarn');
                        mdladvObj.setCheckResultStatus(false);
                    else
                        description=['<p /><font color="#008000">',...
                        DAStudio.message('Simulink:tools:MAPassedMsg'),...
                        '</font>'];
                        mdladvObj.setCheckResultStatus(true);
                    end

                    ResultHandles{end+1}=handles;
                    ResultDescription{end+1}=description;








                    function[ResultDescription,ResultHandles]=ExecCheckQuestBlock(system)
                        ResultDescription={};
                        ResultHandles={};

                        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                        mdladvObj.setCheckResultStatus(false);



                        xlateTagPrefix='Simulink:ModelAdvisor:';
                        [bResultStatus,ResultDescription,ResultHandles]=ModelAdvisor.Common.modelAdvisorCheck_QuestionableBlocks(system,xlateTagPrefix);


                        ft=ModelAdvisor.FormatTemplate('ListTemplate');
                        ft.setSubTitle(DAStudio.message([xlateTagPrefix,'GainBlocksSubTitle']));
                        ft.setInformation(DAStudio.message([xlateTagPrefix,'GainBlocksInformation']))


                        hScope=get_param(system,'Handle');


                        uBlocks=find_system(hScope,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','BlockType','Gain','Gain','1');

                        currentResult=uBlocks;


                        currentResult=mdladvObj.filterResultWithExclusion(currentResult);

                        if~isempty(currentResult)
                            bResultStatus=0;
                            ft.setRecAction(DAStudio.message([xlateTagPrefix,'CheckGainRecAct']));
                            ft.setListObj(currentResult);
                            ft.setSubResultStatus('Warn');
                            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'GainBlocksWarning']));
                            mdladvObj.setCheckResultStatus(false);
                        else
                            ft.setSubResultStatus('Pass');
                            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'GainBlocksPassed']));
                        end


                        ft.setSubBar(0);
                        ResultDescription{end+1}=ft;
                        ResultHandles{end+1}=[];

                        if(bResultStatus)
                            mdladvObj.setCheckResultStatus(true);
                        end







                        function[ResultDescription,ResultHandles]=ExecCheckMdlrefBlock(system)
                            ResultDescription={};
                            ResultHandles={};


                            passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                            model=bdroot(system);
                            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                            mdladvObj.setCheckResultStatus(false);

                            try




                                mdlList=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',1);
                                mdlList=mdladvObj.filterResultWithExclusion(mdlList);

                                numMdls=length(mdlList);

                                if numMdls>1
                                    try
                                        evalc(['slbuild(''',model,''',''StandaloneCoderTarget'',''OnlyCheckConfigsetMismatch'',true)']);
                                    catch E
                                        result=E.message;
                                        resultIdx=strfind(result,'The following Configuration parameter option(s)');
                                        if~isempty(resultIdx)
                                            ResultDescription{end+1}=['<p />',DAStudio.message('ModelAdvisor:engine:CheckMdlrefBlockWarn1'),' <pre>',result(resultIdx:end),'</pre>'];
                                            ResultHandles{end+1}={};
                                        else
                                            ResultDescription{end+1}=['<p /><font color="red">',DAStudio.message('ModelAdvisor:engine:CheckMdlrefBlockWarn2'),'</font><p /><pre>',result,'</pre>'];
                                            ResultHandles{end+1}={};

                                            mdladvObj.setCheckErrorSeverity(100);
                                        end
                                    end
                                end
                            catch E
                                result=E.message;
                                ResultDescription{end+1}=['<p /><font color="red">',DAStudio.message('ModelAdvisor:engine:CheckMdlrefBlockWarn2'),' </font><p /><pre>',result,'</pre>'];
                                ResultHandles{end+1}={};

                                mdladvObj.setCheckErrorSeverity(100);
                            end

                            if isempty(ResultDescription)
                                ResultDescription{end+1}=passString;
                                ResultHandles{end+1}={};
                                mdladvObj.setCheckResultStatus(true);
                            else
                                mdladvObj.setCheckResultStatus(false);
                            end






                            function ResultDescription=ExecCheckUnconnected(system)
                                mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                mdladvObj.setCheckResultStatus(false);
                                xlateTagPrefix='ModelAdvisor:engine:';
                                [bResult,ResultDescription]=...
                                ModelAdvisor.Common.modelAdvisorCheck_UnconnectedObjects(system,xlateTagPrefix);
                                mdladvObj.setCheckResultStatus(bResult);








                                function ExecCheckSolver(system)

                                    passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                    model=bdroot(system);
                                    encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
                                    encodedModelName=[encodedModelName{:}];
                                    hScope=get_param(system,'Handle');
                                    hModel=get_param(model,'Handle');
                                    cs=getActiveConfigSet(model);
                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                    mdladvObj.setCheckResultStatus(false);

                                    thisSolver=get_param(cs,'SolverType');
                                    if(hScope==hModel)
                                        switch thisSolver
                                        case{'Fixed-step'}










                                            result=passString;
                                            mdladvObj.setCheckResultStatus(true);

                                        case{'Variable-step'}
                                            result=DAStudio.message('Simulink:tools:MACheckSolverVariableStep',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:VariableStepSolver'),'''SolverType''',encodedModelName),get_param(cs,'Solver'));
                                            mdladvObj.setCheckResultStatus(false);
                                        otherwise
                                            mdladvObj.setCheckResultStatus(false);
                                            DAStudio.error('Simulink:tools:MAUnrecognizedSolver',thisSolver);
                                        end
                                    else
                                        result=passString;
                                        mdladvObj.setCheckResultStatus(true);
                                    end


                                    if~strcmp(get_param(cs,'MultiTaskRateTransMsg'),'error')
                                        msgToUser=DAStudio.message('ModelAdvisor:engine:CheckSolverWarn',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:Multitaskratetransition'),'''MultiTaskRateTransMsg''',encodedModelName));
                                        if strcmp(result,passString)
                                            result=msgToUser;
                                        else
                                            result=[result,msgToUser];
                                        end
                                        mdladvObj.setCheckResultStatus(false);
                                    end


                                    if~strcmp(get_param(cs,'MultiTaskCondExecSysMsg'),'error')
                                        msgToUser=DAStudio.message('ModelAdvisor:engine:CheckSolverWarn',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:MultitaskConditionallyExecute'),'''MultiTaskCondExecSysMsg''',encodedModelName));
                                        if strcmp(result,passString)
                                            result=msgToUser;
                                        else
                                            result=[result,msgToUser];
                                        end
                                        mdladvObj.setCheckResultStatus(false);
                                    end


                                    if~strcmp(get_param(cs,'MultiTaskDSMMsg'),'error')
                                        msgToUser=DAStudio.message('ModelAdvisor:engine:CheckSolverWarn',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:MultitaskDataStore'),'''MultiTaskDSMMsg''',encodedModelName));
                                        if strcmp(result,passString)
                                            result=msgToUser;
                                        else
                                            result=[result,msgToUser];
                                        end
                                        mdladvObj.setCheckResultStatus(false);
                                    end

                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                    mdladvObj.setCheckResult(result);






                                    function ResultDescription=ExecIdentifyMismatchedBusParams(system)

                                        ResultDescription={};
                                        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
                                        mdladvObj.setCheckResultStatus(false);

                                        verInfo=ver;
                                        productNames={verInfo.Name};
                                        hasSimulinkCoder=any(strcmp(productNames,'Simulink Coder'));
                                        if license('test','Real-Time_Workshop')&&hasSimulinkCoder

                                            model=bdroot(system);
                                            [cleanup,ft]=coder.advisor.internal.updateDiagram(model);
                                            if~isempty(ft)

                                                ResultDescription{end+1}=ft;

                                                mdladvObj.setCheckErrorSeverity(1);
                                                return
                                            end


                                            ftBlocks=ModelAdvisor.FormatTemplate('TableTemplate');
                                            ftBlocks.setColTitles({DAStudio.message('Simulink:tools:MADTAndScaleBlockName'),...
                                            DAStudio.message('Simulink:tools:MADTAndScaleParamName')});
                                            ftBlocks.setInformation(DAStudio.message('ModelAdvisor:engine:TitleTipMismatchedBusParametersBlocks'));


                                            ftObj=ModelAdvisor.FormatTemplate('TableTemplate');
                                            ftObj.setColTitles({DAStudio.message('ModelAdvisor:engine:SignalObject'),...
                                            DAStudio.message('ModelAdvisor:engine:Workspace'),...
                                            DAStudio.message('Simulink:tools:MADTAndScaleParamName')});
                                            ftObj.setInformation(DAStudio.message('ModelAdvisor:engine:TitleTipMismatchedBusParametersObjects'));
                                            ftObj.setSubBar(0);

                                            allSigObjsInModelWks={};


                                            modelWS=get_param(model,'ModelWorkspace');
                                            allVarsInWks=modelWS.data;
                                            for idx=1:length(allVarsInWks)
                                                if isa(allVarsInWks(idx).Value,'Simulink.Signal')
                                                    allSigObjsInModelWks{end+1}=allVarsInWks(idx).Name;
                                                end
                                            end

                                            failedBlocks={};
                                            failedObjects={};


                                            if isempty(strmatch(get_param(model,'StrictBusMsg'),{'None','Warning'},'exact'))&&...
                                                strcmp(get_param(model,'UnderspecifiedInitializationDetection'),'Simplified')
                                                allBlocks=slInternal('busDiagnostics','getBlocksWithMismatchedBusParameter',...
                                                get_param(system,'Handle'));
                                                allBlocks=mdladvObj.filterResultWithExclusion(allBlocks);
                                                if~isempty(allBlocks)
                                                    allBlockNamesAndHandles=cell(length(allBlocks),2);
                                                    for idx=1:length(allBlocks)
                                                        allBlockNamesAndHandles{idx,1}=[get_param(allBlocks(idx),'Parent'),'/',get_param(allBlocks(idx),'Name')];
                                                        allBlockNamesAndHandles{idx,2}=allBlocks(idx);
                                                    end
                                                    [sortedBlockNames,sortedIdx]=sort(allBlockNamesAndHandles(:,1));
                                                    blockHandles=allBlockNamesAndHandles(:,2);
                                                    orderedBlocksAndHandles=[sortedBlockNames,blockHandles(sortedIdx)];
                                                    for idx=1:length(sortedBlockNames)

                                                        blockSupport=slInternal('busDiagnostics','getBusParameterNames',...
                                                        orderedBlocksAndHandles{idx,2});
                                                        for jdx=1:length(blockSupport.BusParameterNames)
                                                            obj=get(orderedBlocksAndHandles{idx,2},'Object');
                                                            if(isa(obj,'Simulink.DataStoreMemory'))&&...
                                                                obj.isSynthesized
                                                                workspaceDetails=DAStudio.message('ModelAdvisor:engine:BaseWorkspace');
                                                                if~isempty(strmatch(obj.DataStoreName,allSigObjsInModelWks,'exact'))
                                                                    workspaceDetails=DAStudio.message('ModelAdvisor:engine:ModelWorkspace');
                                                                end
                                                                failedObjects=[failedObjects;{obj.DataStoreName,workspaceDetails,...
                                                                blockSupport.BusParameterNames{jdx}}];%#ok<AGROW>
                                                            else
                                                                failedBlocks=[failedBlocks;{orderedBlocksAndHandles{idx,1},...
                                                                blockSupport.BusParameterNames{jdx}}];%#ok<AGROW>
                                                            end
                                                        end
                                                    end
                                                end
                                            end


                                            if isempty(failedBlocks)&&isempty(failedObjects)
                                                ftBlocks.setSubResultStatus('pass');
                                                ftBlocks.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:PassResultStatusMismatchedBusParametersBlocks'));
                                                mdladvObj.setCheckResultStatus(true);
                                                ResultDescription{end+1}=ftBlocks;

                                                ftObj.setSubResultStatus('pass');
                                                ftObj.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:PassResultStatusMismatchedBusParametersObjects'));
                                                mdladvObj.setCheckResultStatus(true);
                                                ResultDescription{end+1}=ftObj;
                                            else
                                                if~isempty(failedBlocks)
                                                    ftBlocks.setSubResultStatus('warn');
                                                    ftBlocks.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:WarnResultStatusMismatchedBusParametersBlocks'));
                                                    ftBlocks.setTableInfo(failedBlocks);
                                                    ftBlocks.setRecAction({DAStudio.message('ModelAdvisor:engine:RecActionMismatchedBusParametersBlocks')});
                                                    ResultDescription{end+1}=ftBlocks;
                                                else
                                                    ftBlocks.setSubResultStatus('pass');
                                                    ftBlocks.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:PassResultStatusMismatchedBusParametersBlocks'));
                                                    ResultDescription{end+1}=ftBlocks;
                                                end

                                                if~isempty(failedObjects)
                                                    ftObj.setSubResultStatus('warn');
                                                    ftObj.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:WarnResultStatusMismatchedBusParametersObjects'));
                                                    ftObj.setTableInfo(failedObjects);
                                                    ftObj.setRecAction({DAStudio.message('ModelAdvisor:engine:RecActionMismatchedBusParametersObjects')});
                                                    ResultDescription{end+1}=ftObj;
                                                else
                                                    ftObj.setSubResultStatus('pass');
                                                    ftObj.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:PassResultStatusMismatchedBusParametersObjects'));
                                                    ResultDescription{end+1}=ftObj;
                                                end
                                            end
                                            delete(cleanup);
                                        else


                                            ResultDescription{end+1}=DAStudio.message('ModelAdvisor:engine:StuctMismatchSkipped');
                                            mdladvObj.setCheckResultStatus(true);
                                        end






                                        function result=ExecCheckHardware(system)


                                            model=bdroot(system);
                                            encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
                                            encodedModelName=[encodedModelName{:}];
                                            cs=getActiveConfigSet(model);
                                            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                            mdladvObj.setCheckResultStatus(false);
                                            ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                            ft.setInformation(DAStudio.message('ModelAdvisor:engine:CheckHardwareInfo'));
                                            ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:CheckHardwareSubtitle'));
                                            WarnMsg='';
                                            RecActionMsg='';
                                            isUnspecifiedHW=false;
                                            targetHWSpecified=~strcmp(get_param(cs,'TargetHWDeviceType'),'Unspecified');

                                            if checkDeviceType(cs,'32-bit Generic')
                                                isUnspecifiedHW=true;
                                                WarnMsg=DAStudio.message('ModelAdvisor:engine:CheckHardwareUnspecified',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:CheckHardwareDeviceType'),'''ProdHWDeviceType''',encodedModelName));
                                                RecActionMsg=DAStudio.message('ModelAdvisor:engine:CheckHardwareRecAction',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:CheckHardwareDeviceType'),'''ProdHWDeviceType''',encodedModelName));

                                            elseif~checkDeviceType(cs,'ASIC/FPGA')
                                                if strcmp(get_param(cs,'ProdEndianess'),'Unspecified')
                                                    isUnspecifiedHW=true;
                                                    unspecParam='''ProdEndianess''';
                                                    WarnMsg=DAStudio.message('ModelAdvisor:engine:CheckHardwareUnspecified',...
                                                    loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:CheckHardwareByteordering'),...
                                                    unspecParam,encodedModelName));
                                                    RecActionMsg=[RecActionMsg,DAStudio.message('ModelAdvisor:engine:CheckHardwareRecAction1',...
                                                    loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:CheckHardwareByteordering'),...
                                                    unspecParam,encodedModelName))];
                                                end
                                                if strcmp(get_param(cs,'ProdIntDivRoundTo'),'Undefined')
                                                    isUnspecifiedHW=true;
                                                    unspecParam='''ProdIntDivRoundTo''';
                                                    if isUnspecifiedHW
                                                        WarnMsg=[WarnMsg,' and ',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:CheckHardwareSignedIntDivRounding'),unspecParam,encodedModelName),'. '];
                                                    else
                                                        isUnspecifiedHW=true;
                                                        WarnMsg=[WarnMsg,DAStudio.message('ModelAdvisor:engine:CheckHardwareUnspecified',...
                                                        loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:CheckHardwareSignedIntDivRounding'),...
                                                        unspecParam,encodedModelName)),' '];
                                                    end
                                                    RecActionMsg=[RecActionMsg,' ',DAStudio.message('ModelAdvisor:engine:CheckHardwareRecAction2',...
                                                    loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:CheckHardwareSignedIntDivRounding'),...
                                                    unspecParam,encodedModelName))];
                                                end

                                                if targetHWSpecified
                                                    targetEndianessUndefined=strcmp(get_param(cs,'TargetEndianess'),'Unspecified');
                                                    targetIntDivRoundToUndefined=strcmp(get_param(cs,'TargetIntDivRoundTo'),'Undefined');

                                                    if targetEndianessUndefined
                                                        isUnspecifiedHW=true;
                                                        unspecParam='''TargetEndianess''';
                                                        WarnMsg=[WarnMsg,' ',DAStudio.message('ModelAdvisor:engine:CheckHardwareUnspecified',unspecParam)];
                                                        RecActionMsg=[RecActionMsg,' ',DAStudio.message('ModelAdvisor:engine:CheckHardwareRecAction1',unspecParam)];
                                                    end

                                                    if targetIntDivRoundToUndefined
                                                        unspecParam='''TargetIntDivRoundTo''';
                                                        if targetEndianessUndefined
                                                            WarnMsg=[WarnMsg,' and ''TargetIntDivRoundTo'''];
                                                        else
                                                            isUnspecifiedHW=true;
                                                            WarnMsg=[WarnMsg,DAStudio.message('ModelAdvisor:engine:CheckHardwareUnspecified',unspecParam)];
                                                        end
                                                        RecActionMsg=[RecActionMsg,' ',DAStudio.message('ModelAdvisor:engine:CheckHardwareRecAction2',unspecParam)];
                                                    end
                                                else
                                                    isUnspecifiedHW=true;
                                                end
                                            end

                                            if isUnspecifiedHW
                                                if~targetHWSpecified
                                                    WarnMsg=[WarnMsg,DAStudio.message('ModelAdvisor:engine:CheckHardwareWarn')];
                                                end

                                                ft.setSubResultStatus('warn');
                                                ft.setSubResultStatusText(WarnMsg);
                                                ft.setRecAction(RecActionMsg);
                                            else
                                                ft.setSubResultStatus('pass');
                                                ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CheckHardwarePass'));
                                            end

                                            ProdBitPerChar=num2str(get_param(cs,'ProdBitPerChar'));
                                            ProdBitPerShort=num2str(get_param(cs,'ProdBitPerShort'));
                                            ProdBitPerInt=num2str(get_param(cs,'ProdBitPerInt'));
                                            ProdBitPerLong=num2str(get_param(cs,'ProdBitPerLong'));
                                            ProdShiftRightIntArith=get_param(cs,'ProdShiftRightIntArith');
                                            ProdBitPerLongLong=num2str(get_param(cs,'ProdBitPerLongLong'));
                                            ProdLongLongMode=num2str(get_param(cs,'ProdLongLongMode'));
                                            try
                                                TargetBitPerChar=num2str(get_param(cs,'TargetBitPerChar'));
                                                TargetBitPerShort=num2str(get_param(cs,'TargetBitPerShort'));
                                                TargetBitPerInt=num2str(get_param(cs,'TargetBitPerInt'));
                                                TargetBitPerLong=num2str(get_param(cs,'TargetBitPerLong'));
                                                TargetShiftRightIntArith=get_param(cs,'TargetShiftRightIntArith');
                                                TargetEndianess=get_param(cs,'TargetEndianess');
                                                TargetIntDivRoundTo=get_param(cs,'TargetIntDivRoundTo');
                                                TargetBitPerLongLong=num2str(get_param(cs,'TargetBitPerLongLong'));
                                                TargetLongLongMode=num2str(get_param(cs,'TargetLongLongMode'));
                                            catch %#ok<*CTCH>
                                                TargetBitPerChar='Unspecified';
                                                TargetBitPerShort='Unspecified';
                                                TargetBitPerInt='Unspecified';
                                                TargetBitPerLong='Unspecified';
                                                TargetShiftRightIntArith='Unspecified';
                                                TargetEndianess='Unspecified';
                                                TargetIntDivRoundTo='Unspecified';
                                                TargetBitPerLongLong='Unspecified';
                                                TargetLongLongMode='Unspecified';
                                            end

                                            ft1=ModelAdvisor.FormatTemplate('TableTemplate');
                                            ft1.setSubTitle(DAStudio.message('ModelAdvisor:engine:CheckHardwareMatchSubTitle'));
                                            ft1.setInformation(DAStudio.message('ModelAdvisor:engine:CheckHardwareMatchInfo'));
                                            ft1.setColTitles({DAStudio.message('ModelAdvisor:engine:CheckHardwareMatchCol1'),DAStudio.message('ModelAdvisor:engine:CheckHardwareMatchCol2'),DAStudio.message('ModelAdvisor:engine:CheckHardwareMatchCol3')});
                                            ft1.setSubBar(false);
                                            tableInfo={};
                                            if~strcmp(ProdBitPerChar,TargetBitPerChar)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CCharBits')},{locCreateIgnorePortion(ProdBitPerChar)},{locCreateIgnorePortion(TargetBitPerChar)}];
                                            end
                                            if~strcmp(ProdBitPerShort,TargetBitPerShort)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CShortBits')},{locCreateIgnorePortion(ProdBitPerShort)},{locCreateIgnorePortion(TargetBitPerShort)}];
                                            end
                                            if~strcmp(ProdBitPerInt,TargetBitPerInt)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CIntBits')},{locCreateIgnorePortion(ProdBitPerInt)},{locCreateIgnorePortion(TargetBitPerInt)}];
                                            end
                                            if~strcmp(ProdBitPerLong,TargetBitPerLong)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CLongBits')},{locCreateIgnorePortion(ProdBitPerLong)},{locCreateIgnorePortion(TargetBitPerLong)}];
                                            end
                                            if~strcmp(ProdBitPerLongLong,TargetBitPerLongLong)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CLongLongBits')},{locCreateIgnorePortion(ProdBitPerLongLong)},{locCreateIgnorePortion(TargetBitPerLongLong)}];
                                            end
                                            if~strcmp(ProdLongLongMode,TargetLongLongMode)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CheckLongLongMode')},{locCreateIgnorePortion(ProdLongLongMode)},{locCreateIgnorePortion(TargetLongLongMode)}];
                                            end
                                            if~strcmp(ProdShiftRightIntArith,TargetShiftRightIntArith)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CheckHardwareShift')},{locCreateIgnorePortion(ProdShiftRightIntArith)},{locCreateIgnorePortion(TargetShiftRightIntArith)}];
                                            end
                                            if~strcmp(get_param(cs,'ProdEndianess'),TargetEndianess)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CheckHardwareByteordering')},{locCreateIgnorePortion(get_param(cs,'ProdEndianess'))},{locCreateIgnorePortion(TargetEndianess)}];
                                            end
                                            if~strcmp(get_param(cs,'ProdIntDivRoundTo'),TargetIntDivRoundTo)
                                                tableInfo=[tableInfo;{DAStudio.message('ModelAdvisor:engine:CheckHardwareSignedInt')},{locCreateIgnorePortion(get_param(cs,'ProdIntDivRoundTo'))},{locCreateIgnorePortion(TargetIntDivRoundTo)}];
                                            end

                                            if isempty(tableInfo)
                                                ft1.setSubResultStatus('Pass');
                                                ft1.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CheckHardwareMatchPass'));
                                                if~isUnspecifiedHW
                                                    mdladvObj.setCheckResultStatus(true);
                                                end
                                            else
                                                ft1.setSubResultStatus('Warn');
                                                ft1.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CheckHardwareMatchWarn'));
                                                ft1.setRecAction(DAStudio.message('ModelAdvisor:engine:CheckHardwareMatchRecAction'));
                                                ft1.setTableInfo(tableInfo);
                                            end

                                            result={ft,ft1};





                                            function flag=checkDeviceType(cs,typeString)






                                                try
                                                    flag=RTW.isHWDeviceTypeEq(get_param(cs,'ProdHWDeviceType'),typeString);
                                                catch ME
                                                    switch ME.identifier
                                                    case 'RTW:targetRegistry:badHWType'
                                                        if strcmp(typeString,'32-bit Generic')
                                                            flag=false;
                                                        elseif strcmp(typeString,'ASIC/FPGA')
                                                            flag=true;
                                                        end
                                                    otherwise
                                                        rethrow(ME)
                                                    end
                                                end






                                                function[ResultDescription,ResultHandles]=ExecCheckSoftwareEnv(system)
                                                    ResultDescription={};
                                                    ResultHandles={};


                                                    passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                    model=bdroot(system);
                                                    encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
                                                    encodedModelName=[encodedModelName{:}];
                                                    cs=getActiveConfigSet(model);
                                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                    mdladvObj.setCheckResultStatus(false);


                                                    isERT=strcmp(get_param(cs,'IsERTTarget'),'on');

                                                    subTemplate='';
                                                    subTemplateSF=[];

                                                    if isERT
                                                        if strcmp(safe_get_param(cs,'SupportContinuousTime'),'on')
                                                            subTemplate=[subTemplate,DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnvSelected',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:MAcontinuoustime'),'SupportContinuousTime',encodedModelName)),...
                                                            ' ',DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnv1')];
                                                        end
                                                        if strcmp(safe_get_param(cs,'SupportNonFinite'),'on')
                                                            subTemplate=[subTemplate,DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnvSelected',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:MANonFiniteNum'),'SupportNonFinite',encodedModelName)),...
                                                            ' ',DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnv1')];
                                                        end
                                                        if strcmp(safe_get_param(cs,'SupportNonInlinedSFcns'),'on')
                                                            subTemplate=[subTemplate,DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnvSelected',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:NoninlinedSFunctions'),'SupportNonInlinedSFcns',encodedModelName)),...
                                                            ' ',DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnv1')];
                                                        end
                                                        if strcmp(safe_get_param(cs,'InlinedPrmAccess'),'Macros')&&strcmp(safe_get_param(cs,'InlineParams'),'on')
                                                            inlinedParamAccessLink=loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:ScalarInlinedParams'),'''InlinedPrmAccess''',encodedModelName);
                                                            if slfeature('InlinePrmsAsCodeGenOnlyOption')
                                                                subTemplate=[subTemplate,'<p />You selected both ',inlinedParamAccessLink,' as <code>Macros</code> and ',...
                                                                loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:InlineParams'),'''DefaultParameterBehavior''',encodedModelName),'. ',DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnv2',inlinedParamAccessLink)];
                                                            else
                                                                subTemplate=[subTemplate,'<p />You selected both ',inlinedParamAccessLink,' as <code>Macros</code> and ',...
                                                                loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:InlineParams'),'''InlineParams''',encodedModelName),'. ',DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnv2',inlinedParamAccessLink)];
                                                            end
                                                        end
                                                        if strcmp(safe_get_param(cs,'LifeSpan'),'auto')
                                                            subTemplate=[subTemplate...
                                                            ,DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnvDefault',...
                                                            loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:MALifeSpan'),'LifeSpan',encodedModelName),'auto')];
                                                        end
                                                    end


                                                    if safe_get_param(cs,'MaxIdLength')>31
                                                        subTemplate=[subTemplate,DAStudio.message('Simulink:tools:MAMaxIdLengthLargerThan31',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:MaxIDLength'),'''MaxIdLength''',encodedModelName),num2str(safe_get_param(cs,'MaxIdLength')))];
                                                    end


                                                    currentResult=subTemplateSF;


                                                    currentResult=mdladvObj.filterResultWithExclusion(currentResult);

                                                    if~isempty(currentResult)
                                                        currentDescription=[subTemplate,DAStudio.message('ModelAdvisor:engine:CheckSoftwareEnvStateflow')];
                                                        mdladvObj.setCheckResultStatus(false);
                                                    elseif~isempty(subTemplate)
                                                        currentDescription=subTemplate;
                                                        mdladvObj.setCheckResultStatus(false);
                                                    else
                                                        currentDescription=passString;
                                                        mdladvObj.setCheckResultStatus(true);
                                                    end
                                                    ResultDescription{end+1}=currentDescription;
                                                    ResultHandles{end+1}=currentResult;






                                                    function[ResultDescription,ResultHandles]=ExecCheckCodeInstrument(system)
                                                        ResultDescription={};
                                                        ResultHandles={};


                                                        passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                        model=bdroot(system);
                                                        encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
                                                        encodedModelName=[encodedModelName{:}];
                                                        hScope=get_param(system,'Handle');
                                                        cs=getActiveConfigSet(model);
                                                        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                        mdladvObj.setCheckResultStatus(false);


                                                        isERT=strcmp(get_param(cs,'IsERTTarget'),'on');

                                                        subTemplate='';

                                                        if isERT
                                                            if strcmp(safe_get_param(cs,'MatFileLogging'),'on')
                                                                subTemplate=[subTemplate,DAStudio.message('ModelAdvisor:engine:CheckCodeInstrumentMatFile',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:MATfilelogging'),'MatFileLogging',encodedModelName))];
                                                            end
                                                        end

                                                        if strcmp(safe_get_param(cs,'ExtMode'),'on')&&~(strcmpi(safe_get_param(cs,'SystemTargetFile'),'xpctarget.tlc')...
                                                            ||strcmpi(safe_get_param(cs,'SystemTargetFile'),'xpctargetert.tlc')...
                                                            ||strcmpi(safe_get_param(cs,'SystemTargetFile'),'slrt.tlc')...
                                                            ||strcmpi(safe_get_param(cs,'SystemTargetFile'),'slrtert.tlc'))
                                                            subTemplate=[subTemplate,DAStudio.message('ModelAdvisor:engine:CheckCodeInstrumentExtMode',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:ExternalMode'),'ExtMode',encodedModelName))];
                                                        end

                                                        if strcmp(safe_get_param(cs,'RTWCAPIParams'),'on')||strcmp(safe_get_param(cs,'RTWCAPISignals'),'on')...
                                                            ||strcmp(safe_get_param(cs,'RTWCAPIStates'),'on')||strcmp(safe_get_param(cs,'RTWCAPIRootIO'),'on')
                                                            msg=(DAStudio.message('ModelAdvisor:engine:CAPIinterface'));
                                                            htmlStr=['<a href="matlab: modeladvisorprivate openSimprmAdvancedPage ',encodedModelName,' Interface "> ',msg,'</a>'];
                                                            subTemplate=[subTemplate,DAStudio.message('ModelAdvisor:engine:CheckCodeInstrumentCAPI',htmlStr)];
                                                        end
                                                        if~isempty(subTemplate)
                                                            ResultDescription{end+1}=subTemplate;
                                                            ResultHandles{end+1}={};
                                                        end


                                                        uBlocks=[];
                                                        if~strcmpi(get_param(cs,'AssertControl'),'DisableAll')


                                                            uBlocks=[find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'BlockType','Assertion');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_Gradient');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_DGap');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_DRange');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_SGap');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_SRange');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_DMin');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_DMax');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_Resolution');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_SMin');
                                                            find_system(hScope,...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'Findall','on',...
                                                            'LookUnderMasks','on',...
                                                            'MaskType','Checks_SMax');];
                                                        end

                                                        tmpuBlocks=[];
                                                        for blockCount=1:length(uBlocks)
                                                            if~loc_InsideVerificationSubsys(uBlocks(blockCount))
                                                                tmpuBlocks(end+1)=uBlocks(blockCount);
                                                            end
                                                        end

                                                        currentResult=tmpuBlocks;


                                                        currentResult=mdladvObj.filterResultWithExclusion(currentResult);

                                                        if~isempty(currentResult)
                                                            currentDescription=DAStudio.message('ModelAdvisor:engine:CheckCodeInstrumentMdlVerEnable',encodedModelName);
                                                            ResultDescription{end+1}=currentDescription;
                                                            ResultHandles{end+1}=currentResult;
                                                        end



                                                        if strcmp(safe_get_param(cs,'IgnoreTestpoints'),'off')


                                                            uBlocks=find_system(hScope,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','TestPoint','on');

                                                            uBlocks=mdladvObj.filterResultWithExclusion(uBlocks);

                                                            currentResult=uBlocks;
                                                            if~isempty(currentResult)
                                                                currentDescription=DAStudio.message('ModelAdvisor:engine:CheckCodeInstrumentTestPoint');
                                                                if isERT
                                                                    currentDescription=[currentDescription,DAStudio.message('ModelAdvisor:engine:CheckCodeInstrumentRecAction',...
                                                                    loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:IgnoreTestPointSignals'),'''IgnoreTestpoints''',encodedModelName))];
                                                                end
                                                                ResultDescription{end+1}=currentDescription;
                                                                ResultHandles{end+1}=currentResult;
                                                            end
                                                        end

                                                        if isempty(ResultDescription)
                                                            ResultDescription{end+1}=passString;
                                                            ResultHandles{end+1}={};
                                                            mdladvObj.setCheckResultStatus(true);
                                                        else
                                                            mdladvObj.setCheckResultStatus(false);
                                                        end



                                                        function isInside=loc_InsideVerificationSubsys(block)
                                                            isInside=false;
                                                            parentSubsystem=get_param(block,'Parent');
                                                            while~isempty(parentSubsystem)
                                                                if strcmp(get_param(block,'BlockType'),'SubSystem')&&strcmp(get_param(block,'MaskType'),'VerificationSubsystem')
                                                                    isInside=true;
                                                                    break
                                                                end
                                                                block=parentSubsystem;
                                                                parentSubsystem=get_param(block,'Parent');
                                                            end






































                                                            function result=ExecCheckTasking(system)

                                                                passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                                model=bdroot(system);
                                                                encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
                                                                encodedModelName=[encodedModelName{:}];
                                                                hScope=get_param(system,'Handle');
                                                                hModel=get_param(model,'Handle');
                                                                mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                mdladvObj.setCheckResultStatus(false);



                                                                hBlks=find_system(hScope,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Type','block');



                                                                compiledTs=get_param(hBlks,'CompiledSampleTime');
                                                                if length(hBlks)>1
                                                                    compiledTs=vertcat(compiledTs{:});
                                                                end
                                                                if iscell(compiledTs)
                                                                    compiledTs=vertcat(compiledTs{:});
                                                                end

                                                                thisSolverType=get_param(hModel,'SolverType');

                                                                if strcmpi(thisSolverType,'Variable-step')
                                                                    result=DAStudio.message('ModelAdvisor:engine:SolverTypeNotSupported');
                                                                else
                                                                    nTs=0;

                                                                    if hModel==hScope
                                                                        baseTs=get_param(hModel,'FixedStep');
                                                                    else
                                                                        baseTs=get_param(hScope,'CompiledSampleTime');
                                                                        baseTs=baseTs(1);
                                                                    end

                                                                    if ischar(baseTs)&&~strcmpi(strtrim(baseTs),'auto')&&~isempty(baseTs)



                                                                        if~strcmpi(get_param(hModel,'SampleTimeConstraint'),'STIndependent')
                                                                            if hModel==hScope
                                                                                try
                                                                                    baseTs=slResolve(baseTs,hModel);
                                                                                catch E
                                                                                    rethrow(E);
                                                                                end
                                                                            end

                                                                            i=1;
                                                                            while i<=size(compiledTs,1)
                                                                                if((compiledTs(i,1)==baseTs)&&(compiledTs(i,2))==0)

                                                                                    compiledTs(i,:)=[];
                                                                                    i=i-1;
                                                                                end
                                                                                i=i+1;
                                                                            end
                                                                            nTs=nTs+1;
                                                                        end
                                                                    end

                                                                    if~isempty(compiledTs)
                                                                        compiledTs(compiledTs(:,1)==Inf,:)=[];
                                                                        compiledTs(compiledTs(:,1)==0,:)=[];
                                                                        compiledTs(compiledTs(:,1)==-1,:)=[];
                                                                        compiledTs(isnan(compiledTs(:,1)),:)=[];
                                                                    end
                                                                    while~isempty(compiledTs)
                                                                        compiledTs(compiledTs(:,1)==compiledTs(1,1)&compiledTs(:,2)==compiledTs(1,2),:)=[];
                                                                        nTs=nTs+1;
                                                                    end


                                                                    thisTaskingMode=get_param(hModel,'EnableMultiTasking');
                                                                    isFPGA=RTW.isHWDeviceTypeEq(get_param(hModel,'ProdHWDeviceType'),'ASIC/FPGA');
                                                                    if(nTs==1)
                                                                        result=passString;
                                                                        mdladvObj.setCheckResultStatus(true);
                                                                    else
                                                                        if strcmp(thisTaskingMode,'off')&&~isFPGA
                                                                            result=DAStudio.message('ModelAdvisor:engine:CheckTaskingRecAction',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:ConfigureMdl'),'EnableMultiTasking',encodedModelName));
                                                                            mdladvObj.setCheckResultStatus(false);
                                                                        elseif strcmp(thisTaskingMode,'on')&&isFPGA
                                                                            result=DAStudio.message('ModelAdvisor:engine:CheckTaskingRecAction1',loc_CreateConfigSetHref(DAStudio.message('ModelAdvisor:engine:ConfigureTasking'),'EnableMultiTasking',encodedModelName));
                                                                            mdladvObj.setCheckResultStatus(false);
                                                                        else
                                                                            result=passString;
                                                                            mdladvObj.setCheckResultStatus(true);
                                                                        end
                                                                    end
                                                                end




                                                                function result=ExecCheckTunableParams(system)
                                                                    result='';

                                                                    passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                                    model=bdroot(system);
                                                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                    mdladvObj.setCheckResultStatus(false);


                                                                    tunableVarsMdls=modeladvisorprivate('mdladv_mdlref','FindModelsWithModelRefAndTunableVars',model);
                                                                    if isempty(tunableVarsMdls)


                                                                        isRefSel=mdladvObj.TreatAsMdlref;
                                                                        if isRefSel

                                                                            if~isempty(get_param(model,'TunableVars'))
                                                                                tunableVarsMdls={model};
                                                                            end
                                                                        end
                                                                    end
                                                                    if isempty(tunableVarsMdls)
                                                                        result=passString;
                                                                        mdladvObj.setCheckResultStatus(true);
                                                                    else
                                                                        result=[result,''];
                                                                        result=[result,DAStudio.message('ModelAdvisor:engine:CheckTunableParamsWarn')];
                                                                        result=[result,'<form method="GET" action="matlab: modeladvisorprivate mdladv_mdlref " name="f">'];



                                                                        for i=1:length(tunableVarsMdls)
                                                                            encMdlName=modeladvisorprivate('HTMLencode',tunableVarsMdls{i},'encode');
                                                                            result=[result,'<p /><a href="matlab: modeladvisorprivate mdladv_mdlref ConvertTunableVarsToParameterObjects '...
                                                                            ,encMdlName{:},'"> ',tunableVarsMdls{i},' </a>'];
                                                                        end
                                                                        result=[result,'</form>'];
                                                                        mdladvObj.setCheckResultStatus(false);
                                                                    end




                                                                    function result=ExecCheckImplicitSignal(system)
                                                                        result='';

                                                                        passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                                        model=bdroot(system);
                                                                        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                        mdladvObj.setCheckResultStatus(false);


                                                                        [ImplicitSignalResoluMdls,failedModelRefs]=modeladvisorprivate('mdladv_mdlref','FindModelsWithImplicitSignalResolution',model);

                                                                        if isempty(ImplicitSignalResoluMdls)
                                                                            if isempty(failedModelRefs)
                                                                                result=passString;
                                                                                mdladvObj.setCheckResultStatus(true);
                                                                            end
                                                                        else
                                                                            result=[result,DAStudio.message('ModelAdvisor:engine:CheckImplicitSignalRecAction')];
                                                                            for i=1:length(ImplicitSignalResoluMdls)
                                                                                encMdlName=modeladvisorprivate('HTMLencode',ImplicitSignalResoluMdls{i},'encode');
                                                                                result=[result,'<p /><a href="matlab: modeladvisorprivate mdladv_mdlref DisableImplicitSignalResolution '...
                                                                                ,encMdlName{:},'"> ',ImplicitSignalResoluMdls{i},' </a>'];%#ok<AGROW>
                                                                            end
                                                                            mdladvObj.setCheckResultStatus(false);
                                                                        end

                                                                        if~isempty(failedModelRefs)
                                                                            mdladvObj.setCheckResultStatus(false);
                                                                            result=[result,DAStudio.message('ModelAdvisor:engine:CheckImplicitSignalMissingModelRef')];
                                                                            for j=1:length(failedModelRefs)
                                                                                result=[result,failedModelRefs{j}];%#ok<AGROW>
                                                                            end
                                                                        end




                                                                        function[ResultDescription,ResultDetails]=DTAndScaleCallback(system)

                                                                            ResultDescription={};
                                                                            ResultDetails={};
                                                                            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                            mdladvObj.setCheckResultStatus(false);
                                                                            needEnableAction=false;


                                                                            [unfiltered_changed,skipped,unfiltered_mustChangeFlags]=slprivate('slRemoveDataTypeAndScale_private',system,0,0);
                                                                            changed=struct('BlockName',{},'ParamName',{},'OldDTStr',{},'NewDTStr',{});
                                                                            skip=struct('BlockName',{},'ParamName',{},'OldDTStr',{},'NewDTStr',{});
                                                                            mustChangeFlags=[];

                                                                            for i=1:length(unfiltered_changed)
                                                                                if~isempty(mdladvObj.filterResultWithExclusion({unfiltered_changed(i).BlockName}))
                                                                                    changed(end+1)=unfiltered_changed(i);
                                                                                    mustChangeFlags(end+1)=unfiltered_mustChangeFlags(i);
                                                                                end
                                                                            end

                                                                            for i=1:length(skipped)
                                                                                if~isempty(mdladvObj.filterResultWithExclusion({skipped(i).BlockName}))
                                                                                    skip(end+1)=skipped(i);
                                                                                end
                                                                            end

                                                                            L0=length(find(mustChangeFlags));
                                                                            L1=length(changed)-L0;
                                                                            L2=length(skip);
                                                                            errorBlks=cell(L0,1);
                                                                            supportBlks=cell(L1,1);
                                                                            skipBlks=cell(L2,1);
                                                                            errorParams=cell(1,1);
                                                                            supportParams=cell(1,1);
                                                                            skipParams=cell(1,1);
                                                                            allParams=cell(1,1);
                                                                            numAllParams=1;
                                                                            errorParams{1}='Path';
                                                                            supportParams{1}='Path';
                                                                            skipParams{1}='Path';
                                                                            allParams{1}='Path';

                                                                            if(L0==0&&L1==0&&L2==0)
                                                                                mdladvObj.setCheckResultStatus(true);
                                                                            end
                                                                            if L0~=0
                                                                                mdladvObj.setCheckErrorSeverity(1);
                                                                            end


                                                                            ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                            ft.setCheckText(DAStudio.message('Simulink:tools:MATitletipCheckDTAndScale'));
                                                                            ft.setSubTitle(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub0'));
                                                                            ft.setInformation(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub0Info'));
                                                                            docLinkSfunction0{1}={DAStudio.message('Simulink:tools:MACheckDTAndScaleSub01Link')};
                                                                            ft.setRefLink(docLinkSfunction0);
                                                                            if~L0
                                                                                ft.setSubResultStatus('Pass');
                                                                                ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MADTAndScaleSub0NoCase'));
                                                                                ResultDescription{end+1}=ft;
                                                                                ResultDetails{end+1}={};
                                                                            else
                                                                                needEnableAction=true;
                                                                                ft.setSubResultStatus('Fail');
                                                                                ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MADTAndScaleSub0Case'));
                                                                                ft.setSubBar(0);
                                                                                ResultDescription{end+1}=ft;
                                                                                ResultDetails{end+1}={};


                                                                                ft0=ModelAdvisor.FormatTemplate('TableTemplate');
                                                                                info={};
                                                                                ft0.setColTitles({DAStudio.message('Simulink:tools:MADTAndScaleBlockName'),...
                                                                                DAStudio.message('Simulink:tools:MADTAndScaleParamName'),...
                                                                                DAStudio.message('Simulink:tools:MADTAndScaleCurStr'),...
                                                                                DAStudio.message('Simulink:tools:MADTAndScaleNewStr')});

                                                                                must_change_items=changed(logical(mustChangeFlags));


                                                                                paramPrompts=loc_getDialogParamGuiName(must_change_items);

                                                                                numParams=1;
                                                                                for n=1:L0
                                                                                    blkName=must_change_items(n).BlockName;
                                                                                    paramName=must_change_items(n).ParamName;
                                                                                    errorBlks{n}=blkName;
                                                                                    if(~ismember({paramName},errorParams))
                                                                                        numParams=numParams+1;
                                                                                        errorParams{numParams}=paramName;
                                                                                        numAllParams=numAllParams+1;
                                                                                        allParams{numAllParams}=paramName;
                                                                                    end
                                                                                    info=[info;{locGenerateLinkForBlock(blkName),paramPrompts{n},...
                                                                                    must_change_items(n).OldDTStr,...
                                                                                    must_change_items(n).NewDTStr}];%#ok<AGROW>
                                                                                end

                                                                                ft0.setTableInfo(info);
                                                                                ft0.setRecAction(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub0RecAction',DAStudio.message('Simulink:tools:MADTAndScaleRemove')));
                                                                                ResultDescription{end+1}=ft0;
                                                                                ResultDetails{end+1}={};

                                                                                myLVParam0=ModelAdvisor.ListViewParameter;
                                                                                myLVParam0.Name=DAStudio.message('Simulink:tools:MACheckDTAndScaleSub0');
                                                                                myLVParam0.Data=get_param(errorBlks,'object')';
                                                                                myLVParam0.Attributes=errorParams;
                                                                            end



                                                                            ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                            ft.setSubTitle(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub1'));
                                                                            ft.setInformation(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub1Info'));
                                                                            docLinkSfunction1{1}={DAStudio.message('Simulink:tools:MACheckDTAndScaleSub01Link')};
                                                                            ft.setRefLink(docLinkSfunction1);
                                                                            if~L1
                                                                                ft.setSubResultStatus('Pass');
                                                                                ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MADTAndScaleSub1NoCase'));
                                                                                ResultDescription{end+1}=ft;
                                                                                ResultDetails{end+1}={};
                                                                            else
                                                                                needEnableAction=true;
                                                                                ft.setSubResultStatus('Warn');
                                                                                ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MADTAndScaleSub1Case'));
                                                                                ft.setSubBar(0);
                                                                                ResultDescription{end+1}=ft;
                                                                                ResultDetails{end+1}={};


                                                                                ft1=ModelAdvisor.FormatTemplate('TableTemplate');
                                                                                info={};
                                                                                ft1.setColTitles({DAStudio.message('Simulink:tools:MADTAndScaleBlockName'),...
                                                                                DAStudio.message('Simulink:tools:MADTAndScaleParamName'),...
                                                                                DAStudio.message('Simulink:tools:MADTAndScaleCurStr'),...
                                                                                DAStudio.message('Simulink:tools:MADTAndScaleNewStr')});

                                                                                may_change_items=changed(~mustChangeFlags);


                                                                                paramPrompts=loc_getDialogParamGuiName(may_change_items);

                                                                                numParams=1;
                                                                                for n=1:L1
                                                                                    blkName=may_change_items(n).BlockName;
                                                                                    paramName=may_change_items(n).ParamName;
                                                                                    supportBlks{n}=blkName;
                                                                                    if(~ismember({paramName},supportParams))
                                                                                        numParams=numParams+1;
                                                                                        supportParams{numParams}=paramName;
                                                                                    end
                                                                                    if(~ismember({paramName},allParams))
                                                                                        numAllParams=numAllParams+1;
                                                                                        allParams{numAllParams}=paramName;
                                                                                    end
                                                                                    info=[info;{locGenerateLinkForBlock(blkName),paramPrompts{n},...
                                                                                    may_change_items(n).OldDTStr,may_change_items(n).NewDTStr}];%#ok<AGROW>
                                                                                end

                                                                                ft1.setTableInfo(info);
                                                                                ft1.setRecAction(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub1RecAction',DAStudio.message('Simulink:tools:MADTAndScaleRemove')));
                                                                                ResultDescription{end+1}=ft1;
                                                                                ResultDetails{end+1}={};

                                                                                myLVParam1=ModelAdvisor.ListViewParameter;
                                                                                myLVParam1.Name=DAStudio.message('Simulink:tools:MACheckDTAndScaleSub1');
                                                                                myLVParam1.Data=get_param(supportBlks,'object')';
                                                                                myLVParam1.Attributes=supportParams;

                                                                            end


                                                                            ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                            ft.setSubTitle(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub2'));
                                                                            ft.setInformation(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub2Info'));
                                                                            docLinkSfunction2{1}={DAStudio.message('Simulink:tools:MACheckDTAndScaleSub2Link')};
                                                                            ft.setRefLink(docLinkSfunction2);
                                                                            ft.setSubBar(0);
                                                                            if~L2
                                                                                ft.setSubResultStatus('Pass');
                                                                                ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MADTAndScaleSub2NoCase'));
                                                                                ResultDescription{end+1}=ft;
                                                                                ResultDetails{end+1}={};
                                                                            else
                                                                                ft.setSubResultStatus('Warn');
                                                                                ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MADTAndScaleSub2Case'));
                                                                                ResultDescription{end+1}=ft;
                                                                                ResultDetails{end+1}={};


                                                                                ft2=ModelAdvisor.FormatTemplate('TableTemplate');
                                                                                info={};
                                                                                ft2.setColTitles({DAStudio.message('Simulink:tools:MADTAndScaleBlockName'),...
                                                                                DAStudio.message('Simulink:tools:MADTAndScaleParamName'),...
                                                                                DAStudio.message('Simulink:tools:MADTAndScaleCurStr')});


                                                                                paramPrompts=loc_getDialogParamGuiName(skip);

                                                                                numParams=1;
                                                                                for n=1:L2

                                                                                    blkName=skip(n).BlockName;
                                                                                    skipBlks{n}=blkName;
                                                                                    paramName=skip(n).ParamName;
                                                                                    if(~ismember({paramName},skipParams))
                                                                                        numParams=numParams+1;
                                                                                        skipParams{numParams}=paramName;
                                                                                    end
                                                                                    if(~ismember({paramName},allParams))
                                                                                        numAllParams=numAllParams+1;
                                                                                        allParams{numAllParams}=paramName;
                                                                                    end

                                                                                    info=[info;{locGenerateLinkForBlock(blkName),paramPrompts{n},...
                                                                                    skip(n).OldDTStr}];%#ok<AGROW>
                                                                                end

                                                                                ft2.setTableInfo(info);
                                                                                ft2.setRecAction(DAStudio.message('Simulink:tools:MACheckDTAndScaleSub2RecAction'));
                                                                                ft2.setSubBar(0);
                                                                                ResultDescription{end+1}=ft2;
                                                                                ResultDetails{end+1}={};

                                                                                myLVParam2=ModelAdvisor.ListViewParameter;
                                                                                myLVParam2.Name=DAStudio.message('Simulink:tools:MACheckDTAndScaleSub2');
                                                                                myLVParam2.Data=get_param(skipBlks,'object')';
                                                                                myLVParam2.Attributes=skipParams;
                                                                            end


                                                                            views={};
                                                                            if(L0)
                                                                                views{end+1}=myLVParam0;
                                                                            end
                                                                            if(L1)
                                                                                views{end+1}=myLVParam1;
                                                                            end
                                                                            if(L2)
                                                                                views{end+1}=myLVParam2;
                                                                            end
                                                                            if(logical(L0)+logical(L1)+logical(L2))>1
                                                                                myLVParam3=ModelAdvisor.ListViewParameter;
                                                                                myLVParam3.Name=DAStudio.message('Simulink:tools:MADTAndScaleAllBlocks');
                                                                                myLVParam3.Data=get_param(vertcat(errorBlks,supportBlks,skipBlks),'object')';
                                                                                myLVParam3.Attributes=allParams;
                                                                                views{end+1}=myLVParam3;
                                                                            end
                                                                            mdladvObj.setListViewParameters(views);
                                                                            mdladvObj.setActionEnable(needEnableAction);









                                                                            function prompts=loc_getDialogParamGuiName(s)

                                                                                if isempty(s)
                                                                                    prompts=[];
                                                                                    return;
                                                                                else
                                                                                    L=length(s);
                                                                                    prompts=cell(L,1);
                                                                                end

                                                                                for n=1:L
                                                                                    blk=s(n).BlockName;
                                                                                    param=s(n).ParamName;
                                                                                    dlgParList=get_param(blk,'IntrinsicDialogParameters');
                                                                                    if strcmp(get_param(blk,'Mask'),'on')
                                                                                        maskParList=get_param(blk,'DialogParameters');
                                                                                        fldNames=fieldnames(maskParList);
                                                                                        for k=1:length(fldNames)


                                                                                            dlgParList.(fldNames{k})=maskParList.(fldNames{k});
                                                                                        end
                                                                                    end

                                                                                    if isfield(dlgParList,param)&&isfield(dlgParList.(param),'Prompt')
                                                                                        str=strtrim(dlgParList.(param).Prompt);
                                                                                        if isempty(str)
                                                                                            prompts{n}=param;
                                                                                        elseif~isequal(str(end),':')
                                                                                            prompts{n}=str;
                                                                                        else
                                                                                            prompts{n}=str(1:end-1);
                                                                                        end
                                                                                    else
                                                                                        prompts{n}=param;
                                                                                    end

                                                                                end





                                                                                function result=actionRemoveDTAndScale(taskobj)

                                                                                    mdladvObj=taskobj.MAObj;
                                                                                    system=getfullname(mdladvObj.System);


                                                                                    changed=slRemoveDataTypeAndScale(system,1,0);
                                                                                    L1=length(changed);


                                                                                    result=ModelAdvisor.Paragraph;

                                                                                    report_paragraph=ModelAdvisor.Paragraph;
                                                                                    report_text=ModelAdvisor.Text(DAStudio.message('Simulink:tools:MADTAndScaleRemoveCase'));
                                                                                    line_break=ModelAdvisor.LineBreak;
                                                                                    report_paragraph.addItem([report_text,line_break]);

                                                                                    report_table=ModelAdvisor.Table(L1,4);
                                                                                    report_table.setColHeading(1,DAStudio.message('Simulink:tools:MADTAndScaleBlockName'));
                                                                                    report_table.setColHeading(2,DAStudio.message('Simulink:tools:MADTAndScaleParamName'));
                                                                                    report_table.setColHeading(3,DAStudio.message('Simulink:tools:MADTAndScaleOldStr'));
                                                                                    report_table.setColHeading(4,DAStudio.message('Simulink:tools:MADTAndScaleCurStr'));
                                                                                    report_table.setColHeadingAlign(1,'center');
                                                                                    report_table.setColHeadingAlign(2,'center');
                                                                                    report_table.setColHeadingAlign(3,'center');
                                                                                    report_table.setColHeadingAlign(4,'center');

                                                                                    for n=1:L1
                                                                                        blkName=changed(n).BlockName;
                                                                                        paramName=changed(n).ParamName;
                                                                                        report_table.setEntry(n,1,locGenerateLinkForBlock(blkName));
                                                                                        report_table.setEntry(n,2,paramName);
                                                                                        report_table.setEntry(n,3,changed(n).OldDTStr);
                                                                                        report_table.setEntry(n,4,changed(n).NewDTStr);
                                                                                    end
                                                                                    report_paragraph.addItem(report_table);
                                                                                    result.addItem(report_paragraph);

                                                                                    mdladvObj.setActionEnable(false);




                                                                                    function[ResultDescription,ResultHandles]=ExecCheckBusVirtual(system)
                                                                                        ResultDescription={};
                                                                                        ResultHandles={};


                                                                                        passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                                                        hScope=get_param(system,'Handle');
                                                                                        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                                        mdladvObj.setCheckResultStatus(false);

                                                                                        hBlocks=[];


                                                                                        hInports=find_system(hScope,...
                                                                                        'SearchDepth',1,...
                                                                                        'BlockType','Inport',...
                                                                                        'UseBusObject','on',...
                                                                                        'BusOutputAsStruct','off');
                                                                                        numInports=length(hInports);
                                                                                        for idx=1:numInports
                                                                                            if cand_nonvirtual_bus_inport(hInports(idx))
                                                                                                hBlocks=[hBlocks;hInports(idx)];
                                                                                            end
                                                                                        end





                                                                                        hBuscreators1=find_system(hScope,...
                                                                                        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                        'Findall','on',...
                                                                                        'LookUnderMasks','on',...
                                                                                        'BlockType','BusCreator',...
                                                                                        'UseBusObject','on',...
                                                                                        'NonVirtualBus','off');
                                                                                        hBuscreators2=find_system(hScope,...
                                                                                        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                        'Findall','on',...
                                                                                        'LookUnderMasks','on',...
                                                                                        'BlockType','BusCreator',...
                                                                                        'UseBusObject','off');
                                                                                        hBuscreators=[hBuscreators1;hBuscreators2];
                                                                                        numBuscreators=length(hBuscreators);
                                                                                        for idx=1:numBuscreators
                                                                                            if cand_nonvirtual_bus_creator(hBuscreators(idx))
                                                                                                hBlocks=[hBlocks;hBuscreators(idx)];
                                                                                            end
                                                                                        end


                                                                                        currentResult=hBlocks;

                                                                                        currentResult=mdladvObj.filterResultWithExclusion(currentResult);

                                                                                        if~isempty(currentResult)
                                                                                            currentDescription=['The following blocks specify a virtual bus ',...
                                                                                            'that crosses a model boundary. To improve the efficiency of code ',...
                                                                                            'generated from this model, consider changing the blocks to specify ',...
                                                                                            'a nonvirtual bus:'];
                                                                                            mdladvObj.setCheckResultStatus(false);
                                                                                        else
                                                                                            currentDescription=passString;
                                                                                            mdladvObj.setCheckResultStatus(true);
                                                                                        end
                                                                                        ResultDescription{end+1}=currentDescription;
                                                                                        ResultHandles{end+1}=currentResult;

                                                                                        function[oDesc,oHandles]=ExecCheckForProperFunctionCallReturnValues(system)
                                                                                            oDesc={};
                                                                                            oHandles={};


                                                                                            passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                                                            hModel=get_param(bdroot(system),'Handle');
                                                                                            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                                            mdladvObj.setCheckResultStatus(false);

                                                                                            tblkPortPairs=get_param(hModel,'PotentiallyDelayedFcnCallSSRetVals');
                                                                                            blkPortPairs=struct('Block',{},'Port',{});
                                                                                            for i=1:length(tblkPortPairs)

                                                                                                filteredBlock=mdladvObj.filterResultWithExclusion({tblkPortPairs(i).Block});
                                                                                                if~isempty(filteredBlock)
                                                                                                    blkPortPairs(end+1)=tblkPortPairs(i);
                                                                                                end
                                                                                            end

                                                                                            if~isempty(blkPortPairs)

                                                                                                [oDesc,oHandles]=locFormatBlkPortPairsForErrDisp(blkPortPairs);

                                                                                                oDesc=[{DAStudio.message('Simulink:tools:MAMsgHiddenBufCausingLoop')},oDesc];
                                                                                                oHandles=[{[]},oHandles];
                                                                                                mdladvObj.setCheckResultStatus(false);
                                                                                            else
                                                                                                oDesc{end+1}=passString;
                                                                                                oHandles{end+1}=[];
                                                                                                mdladvObj.setCheckResultStatus(true);
                                                                                            end


                                                                                            function[desc,hand]=locFormatBlkPortPairsForErrDisp(pairs)

                                                                                                desc={};
                                                                                                hand={};
                                                                                                sep=',';

                                                                                                hand{end+1}=[pairs(1).Block];
                                                                                                str=num2str(pairs(1).Port);

                                                                                                for i=2:length(pairs)
                                                                                                    if pairs(i).Block==pairs(i-1).Block
                                                                                                        str=[str,sep,num2str(pairs(i).Port)];
                                                                                                    else
                                                                                                        desc{end+1}=DAStudio.message('Simulink:tools:MABlkPortPairListItem',str);
                                                                                                        hand{end+1}=[pairs(i).Block];
                                                                                                        str=num2str(pairs(i).Port);
                                                                                                    end
                                                                                                end
                                                                                                desc{end+1}=DAStudio.message('Simulink:tools:MABlkPortPairListItem',str);


                                                                                                function result=ExecOutportAnalysis(system)
                                                                                                    result=ExecMigrationAnalysis(system,'slanalyze_outport','MAOutportCondSubsysCheck','MATitleCheckForProperOutportBlockUsage');

                                                                                                    function result=ExecModelLevelAnalysis(system)
                                                                                                        result=ExecMigrationAnalysis(system,'slanalyze_modelref','MAModelLevelMessagesCheck','MATitleCheckForModelLevelMessages');

                                                                                                        function result=ExecMergeUsageAnalysis(system)
                                                                                                            result=ExecMigrationAnalysis(system,'slanalyze_merge','MAMergeBlockCheck','MATitleCheckForProperMergeBlockUsage');

                                                                                                            function result=ExecDiscreteIntegratorAnalysis(system)
                                                                                                                result=ExecMigrationAnalysis(system,'slanalyze_discreteint','MADiscreteIntegratorCheck','MATitleCheckForProperDiscreteBlockUsage');

                                                                                                                function ResultDescription=ExecMigrationAnalysis(system,fcnName,checkKey,checkTitleKey)





                                                                                                                    ResultDescription={};

                                                                                                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                                                                    mdladvObj.setCheckResultStatus(false);


                                                                                                                    xlatePrefix='Simulink:tools:';
                                                                                                                    msgIDPrefix=[xlatePrefix,checkKey];
                                                                                                                    checkTitle=DAStudio.message(['ModelAdvisor:engine:',checkTitleKey]);

                                                                                                                    try

                                                                                                                        if get_param(bdroot(system),'handle')~=get_param(system,'handle')
                                                                                                                            ResultDescription=DAStudio.message('Simulink:tools:MAUnableToRunCheckOnSubsystem');
                                                                                                                            mdladvObj.setCheckResultStatus(false);
                                                                                                                        elseif~strcmpi(...
                                                                                                                            get_param(system,'UnderspecifiedInitializationDetection'),'Classic')


                                                                                                                            ft=locOutportInitGetOverallFormatTemplate(msgIDPrefix,checkTitle,checkTitleKey);
                                                                                                                            ft.setSubResultStatus('Pass');
                                                                                                                            ResultDescription{end+1}=ft;
                                                                                                                            mdladvObj.setCheckResultStatus(true);
                                                                                                                        else


                                                                                                                            if(isempty(mdladvObj.ActiveCheck.Action))

                                                                                                                                currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
                                                                                                                                messageInfo=slprivate(fcnName,system);
                                                                                                                            else

                                                                                                                                [messageInfo,migrateInfo]=slprivate(fcnName,system);
                                                                                                                                currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
                                                                                                                                currentCheckObj.Action.Enable=false;
                                                                                                                            end


                                                                                                                            [modelRequiresManualFixes,handlesToHighlite,ResultDescription]=...
                                                                                                                            locMigrationCheckDisplayMessages(system,msgIDPrefix,checkTitle,checkTitleKey,messageInfo,ResultDescription,currentCheckObj);

                                                                                                                            checkStatus=(length(ResultDescription)==1);
                                                                                                                            mdladvObj.setCheckResultStatus(checkStatus);
                                                                                                                            mdladvObj.setCheckResultMap(handlesToHighlite);

                                                                                                                            if~(isempty(mdladvObj.ActiveCheck.Action)||...
                                                                                                                                modelRequiresManualFixes||...
                                                                                                                                isempty(fieldnames(migrateInfo)))


                                                                                                                                currentCheckObj.Action.Enable=true;



                                                                                                                                currentCheckObj.ResultData=migrateInfo;
                                                                                                                            end
                                                                                                                        end
                                                                                                                    catch err



                                                                                                                        failMsg=DAStudio.message(['Simulink:tools:','MAMergeAnalysisError']);
                                                                                                                        ResultDescription=['<p /><font color="#800000">',failMsg,'</font>'...
                                                                                                                        ,'<p />',strrep(err.message,sprintf('\n'),'<br />')];



                                                                                                                        for k=1:length(err.stack)
                                                                                                                            stackDump=DAStudio.message(...
                                                                                                                            'Simulink:tools:MAErrorStackDump',...
                                                                                                                            err.stack(k).file,err.stack(k).line);
                                                                                                                            ResultDescription=[ResultDescription,'<p />==&gt; ',stackDump];
                                                                                                                        end

                                                                                                                        mdladvObj.setCheckResultStatus(false);
                                                                                                                    end







                                                                                                                    function dstString=locHTMLEncode(srcString)
                                                                                                                        EncodeTable=...
                                                                                                                        {'<','&#60;';...
                                                                                                                        '>','&#62;';...
                                                                                                                        '&','&#38;';...
                                                                                                                        '#','&#35;';...
                                                                                                                        };

                                                                                                                        dstString='';
                                                                                                                        for i=1:length(srcString)
                                                                                                                            for j=1:length(EncodeTable)
                                                                                                                                dstSubString=strrep(srcString(i),EncodeTable(j,1),EncodeTable(j,2));
                                                                                                                                if~strcmp(dstSubString,srcString(i))
                                                                                                                                    break
                                                                                                                                end
                                                                                                                            end
                                                                                                                            dstString=[dstString,dstSubString];
                                                                                                                        end








                                                                                                                        function htmlResult=locGenerateLinkForBlock(block)

                                                                                                                            parentPath=get_param(block,'Parent');
                                                                                                                            if~isempty(parentPath)
                                                                                                                                parentPath=[parentPath,'/'];
                                                                                                                            end

                                                                                                                            blockPath=[parentPath,strrep(get_param(block,'Name'),'/','//')];
                                                                                                                            encodedBlockPath=modeladvisorprivate('HTMLjsencode',blockPath,'encode');
                                                                                                                            encodedBlockPath=[encodedBlockPath{:}];

                                                                                                                            htmlBlockName=locHTMLEncode(blockPath);
                                                                                                                            htmlBlockName=[htmlBlockName{:}];

                                                                                                                            htmlResult=...
                                                                                                                            ['<a href="matlab: modeladvisorprivate(''hiliteSystem'','...
                                                                                                                            ,'modeladvisorprivate(''HTMLjsencode'',''',encodedBlockPath...
                                                                                                                            ,''',''decode''))">',htmlBlockName,'</a>'];








                                                                                                                            function htmlResult=locGenerateHTMLMergeTree(treeNode,depth)

                                                                                                                                htmlIndent='';

                                                                                                                                for k=1:depth-1
                                                                                                                                    htmlIndent=[htmlIndent,'<td>&nbsp;</td>'];
                                                                                                                                end

                                                                                                                                if(depth>0)
                                                                                                                                    htmlIndent=[htmlIndent,'<td valign="top" align="right">&#8226;</td>'];
                                                                                                                                end


                                                                                                                                mergeBlkObj=get(treeNode.Handle,'Object');
                                                                                                                                htmlResult.blkHandle=mergeBlkObj.getTrueOriginalBlock;
                                                                                                                                htmlResult.blkName=mergeBlkObj.getFullName;

                                                                                                                                htmlResult.reportString{:}=...
                                                                                                                                ['<table cellspacing="2" cellpadding="0" border="0"><tr>'...
                                                                                                                                ,htmlIndent...
                                                                                                                                ,'<td align="left">'...
                                                                                                                                ,locGenerateLinkForBlock(htmlResult.blkHandle),'</td>'...
                                                                                                                                ,'</tr></table>'];

                                                                                                                                if~isempty(treeNode.Children)
                                                                                                                                    htmlResult.reportString=...
                                                                                                                                    [htmlResult.reportString{:},'<br />'];
                                                                                                                                    for k=1:length(treeNode.Children)
                                                                                                                                        htmlResult=[htmlResult...
                                                                                                                                        ,locGenerateHTMLMergeTree(treeNode.Children(k),depth+1)];
                                                                                                                                    end
                                                                                                                                end




                                                                                                                                function result=ActionOutportInitParamsCheck(taskobj)

                                                                                                                                    mdladvObj=taskobj.MAObj;
                                                                                                                                    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};


                                                                                                                                    model=mdladvObj.System;
                                                                                                                                    migrateInfo=currentCheckObj.ResultData;
                                                                                                                                    try
                                                                                                                                        result=slprivate('slmigrate_outport_and_discrete_int',model,migrateInfo);
                                                                                                                                    catch lastErr
                                                                                                                                        result=DAStudio.message(...
                                                                                                                                        'Simulink:tools:OutportMigrateUnexpectedError',lastErr.message);
                                                                                                                                    end



                                                                                                                                    function result=ActionSimplifiedModeCheck(taskobj)

                                                                                                                                        mdladvObj=taskobj.MAObj;
                                                                                                                                        model=mdladvObj.System;
                                                                                                                                        try
                                                                                                                                            result=slprivate('slmigrate_simplifiedMode',model,false);
                                                                                                                                        catch lastErr
                                                                                                                                            result=DAStudio.message(...
                                                                                                                                            'Simulink:tools:OutportMigrateUnexpectedError',lastErr.message);
                                                                                                                                        end











                                                                                                                                        function result=strIsGreaterThan(S1,S2)

                                                                                                                                            sub1=length(strfind(S1,'/'));
                                                                                                                                            sub2=length(strfind(S2,'/'));
                                                                                                                                            if(sub1<sub2)
                                                                                                                                                result=-1;
                                                                                                                                            elseif(sub1>sub2)
                                                                                                                                                result=+1;
                                                                                                                                            else


                                                                                                                                                i=1;
                                                                                                                                                while((i<length(S1))&&...
                                                                                                                                                    (i<length(S2))&&...
                                                                                                                                                    (S1(i)==S2(i)))
                                                                                                                                                    i=i+1;
                                                                                                                                                end

                                                                                                                                                if(S1(i)<S2(i))
                                                                                                                                                    result=-1;
                                                                                                                                                elseif(S1(i)>S2(i))
                                                                                                                                                    result=+1;
                                                                                                                                                else

                                                                                                                                                    if(length(S1)==length(S2))
                                                                                                                                                        result=0;
                                                                                                                                                    elseif(length(S1)<length(S2))
                                                                                                                                                        result=-1;
                                                                                                                                                    else
                                                                                                                                                        result=+1;
                                                                                                                                                    end
                                                                                                                                                end
                                                                                                                                            end







                                                                                                                                            function result=FindZOHUDReplacedBlocks(~)
                                                                                                                                                result={};




                                                                                                                                                UD=find_system('LookInsideSubsystemReference','off',...
                                                                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                                                'BlockType','UnitDelay');
                                                                                                                                                DLY=find_system('LookInsideSubsystemReference','off',...
                                                                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                                                'BlockType','Delay',...
                                                                                                                                                'DelayLengthSource','Dialog',...
                                                                                                                                                'InitialConditionSource','Dialog',...
                                                                                                                                                'ExternalReset','None',...
                                                                                                                                                'ShowEnablePort','off',...
                                                                                                                                                'UseCircularBuffer','off');
                                                                                                                                                ZOH=find_system('LookInsideSubsystemReference','off',...
                                                                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                                                'BlockType','ZeroOrderHold');


                                                                                                                                                replBlocks={};
                                                                                                                                                for i=1:length(UD)
                                                                                                                                                    tmpcell=get_param(UD(i),'CompiledSampleTime');
                                                                                                                                                    if(iscell(tmpcell{1}))
                                                                                                                                                        replBlocks{end+1}=UD{i};%#ok<AGROW> 
                                                                                                                                                    end
                                                                                                                                                end
                                                                                                                                                for i=1:length(DLY)
                                                                                                                                                    tmpcell=get_param(DLY(i),'CompiledSampleTime');
                                                                                                                                                    if(iscell(tmpcell{1}))
                                                                                                                                                        replBlocks{end+1}=DLY{i};%#ok<AGROW> 
                                                                                                                                                    end
                                                                                                                                                end
                                                                                                                                                for i=1:length(ZOH)
                                                                                                                                                    tmpcell=get_param(ZOH(i),'CompiledSampleTime');
                                                                                                                                                    if(iscell(tmpcell{1}))
                                                                                                                                                        replBlocks{end+1}=ZOH{i};%#ok<AGROW> 
                                                                                                                                                    end
                                                                                                                                                end


                                                                                                                                                replhdl=zeros(size(replBlocks));
                                                                                                                                                for i=1:length(replBlocks)
                                                                                                                                                    handlCell=get_param(replBlocks(i),'Handle');
                                                                                                                                                    replhdl(i)=handlCell{1};
                                                                                                                                                end

                                                                                                                                                replfilt={};
                                                                                                                                                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
                                                                                                                                                for i=1:length(replhdl)

                                                                                                                                                    filteredBlock=mdladvObj.filterResultWithExclusion(replhdl(i));
                                                                                                                                                    if~isempty(filteredBlock)
                                                                                                                                                        replfilt{end+1}=replBlocks{i};%#ok<AGROW> 
                                                                                                                                                    end
                                                                                                                                                end


                                                                                                                                                replnm=replfilt;
                                                                                                                                                sorted=false;
                                                                                                                                                lst=length(replnm);
                                                                                                                                                while((lst>1)&&(sorted==false))
                                                                                                                                                    lst=lst-1;
                                                                                                                                                    sorted=true;
                                                                                                                                                    for i=1:lst
                                                                                                                                                        if(strIsGreaterThan(replnm{i},replnm{i+1})==1)
                                                                                                                                                            tmpnm=replnm{i};
                                                                                                                                                            replnm{i}=replnm{i+1};
                                                                                                                                                            replnm{i+1}=tmpnm;
                                                                                                                                                            sorted=false;
                                                                                                                                                        end
                                                                                                                                                    end
                                                                                                                                                end


                                                                                                                                                result=replnm;







                                                                                                                                                function[ResultDescription,ResultHandles]=ExecReplaceZOHDelayByRTB(system)

                                                                                                                                                    ResultDescription={};
                                                                                                                                                    ResultHandles={};
                                                                                                                                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                                                                                                    mdladvObj.setCheckResultStatus(false);

                                                                                                                                                    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
                                                                                                                                                    currentCheckObj.Action.Enable=false;

                                                                                                                                                    xlateTagPrefix='Simulink:tools:';
                                                                                                                                                    ft=ModelAdvisor.FormatTemplate('ListTemplate');


                                                                                                                                                    currentResult=FindZOHUDReplacedBlocks();


                                                                                                                                                    if~isempty(currentResult)
                                                                                                                                                        ft.setSubResultStatus('Warn');
                                                                                                                                                        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'MAMsgReplaceZOHDelayByRTBWarn']));
                                                                                                                                                        ft.setListObj(currentResult);
                                                                                                                                                        ft.setRecAction(DAStudio.message([xlateTagPrefix,'MAMsgReplaceZOHDelayByRTBSuggest']));
                                                                                                                                                        currentCheckObj.Action.Enable=true;
                                                                                                                                                    else
                                                                                                                                                        ft.setSubResultStatus('Pass');
                                                                                                                                                        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'MANonReplaceZOHDelayByRTBPass']));
                                                                                                                                                        mdladvObj.setCheckResultStatus(true);
                                                                                                                                                    end

                                                                                                                                                    ft.setSubBar(0);
                                                                                                                                                    ResultDescription{end+1}=ft;
                                                                                                                                                    ResultHandles{end+1}=[];







                                                                                                                                                    function result=ActionReplaceZOHDelayByRTB(taskobj)
                                                                                                                                                        nl=sprintf('\n');
                                                                                                                                                        result=[];
                                                                                                                                                        replBlocks={};


                                                                                                                                                        replBlocks=FindZOHUDReplacedBlocks();


                                                                                                                                                        result=['<ul> <li> ',DAStudio.message('Simulink:tools:MAReplaceZOHDelayByRTBActionResults'),nl,'<ul> '];
                                                                                                                                                        for i=1:length(replBlocks)
                                                                                                                                                            blkName=replBlocks{i};
                                                                                                                                                            dispBlkName=regexprep(blkName,nl,' ');
                                                                                                                                                            codeBlkName=modeladvisorprivate('HTMLjsencode',blkName,'encode');
                                                                                                                                                            codeBlkName=[codeBlkName{:}];
                                                                                                                                                            result=[result,nl,' <li> <a href="matlab:modeladvisorprivate(''hiliteSystem'',''',codeBlkName,''')">',dispBlkName,'</a></li>'];
                                                                                                                                                            oldBlk=get_param(replBlocks(i),'Handle');
                                                                                                                                                            oldBlkTs=get_param(oldBlk{1},'CompiledSampleTime');
                                                                                                                                                            oldBlkType=get_param(oldBlk{1},'BlockType');
                                                                                                                                                            switch oldBlkType
                                                                                                                                                            case 'Delay'
                                                                                                                                                                outTs=min(oldBlkTs{1},oldBlkTs{2});
                                                                                                                                                                inTs=max(oldBlkTs{1},oldBlkTs{2});
                                                                                                                                                                oldIC=get_param(oldBlk{1},'InitialCondition');
                                                                                                                                                            case 'UnitDelay'
                                                                                                                                                                outTs=min(oldBlkTs{1},oldBlkTs{2});
                                                                                                                                                                inTs=max(oldBlkTs{1},oldBlkTs{2});
                                                                                                                                                                oldIC=get_param(oldBlk{1},'InitialCondition');
                                                                                                                                                            case 'ZeroOrderHold'
                                                                                                                                                                outTs=max(oldBlkTs{1},oldBlkTs{2});
                                                                                                                                                                inTs=min(oldBlkTs{1},oldBlkTs{2});
                                                                                                                                                                oldIC=0;
                                                                                                                                                            end

                                                                                                                                                            newBlk='built-in/RateTransition';
                                                                                                                                                            slInternal('replace_block',oldBlk{1},newBlk);
                                                                                                                                                            set_param(blkName,'X0',num2str(oldIC));

                                                                                                                                                            set_param(blkName,'OutPortSampleTimeOpt','Specify');
                                                                                                                                                            set_param(blkName,'OutPortSampleTime',num2str(outTs(1)));


                                                                                                                                                        end
                                                                                                                                                        result=[result,nl,'</ul> </li> </ul>'];



                                                                                                                                                        function ResultDescription=ExecFcnCallUsageCheck(system)
                                                                                                                                                            ResultDescription=checkFcnCallUsage(system,locGetFcnCallUsageChecklist());


                                                                                                                                                            function result=ActionFcnCallUsageCheck(~)

                                                                                                                                                                result=actionFcnCallUsage();


                                                                                                                                                                function ResultDescription=ExecRapidAcceleratorSignalLoggingCheck(system)
                                                                                                                                                                    ResultDescription=checkRapidAcceleratorSignalLogging(system);


                                                                                                                                                                    function result=ActionRapidAcceleratorSignalLoggingCheck(taskobj)
                                                                                                                                                                        result=actionRapidAcceleratorSignalLogging(taskobj);


                                                                                                                                                                        function ResultDescription=checkVirtualBusAcrossModelReference(system)
                                                                                                                                                                            ResultDescription=virtualBusAcrossModelReferenceCheck(system);


                                                                                                                                                                            function result=actionVirtualBusAcrossModelReference(taskobj)
                                                                                                                                                                                result=virtualBusAcrossModelReferenceAction(taskobj);


                                                                                                                                                                                function ResultDescription=checkVirtualBusAcrossModelReferenceArgs(system)
                                                                                                                                                                                    ResultDescription=virtualBusAcrossModelReferenceArgsCheck(system);


                                                                                                                                                                                    function result=actionVirtualBusAcrossModelReferenceArgs(taskobj)
                                                                                                                                                                                        result=virtualBusAcrossModelReferenceArgsAction(taskobj);








                                                                                                                                                                                        function checklist=locGetFcnCallUsageChecklist
                                                                                                                                                                                            checklist={...
                                                                                                                                                                                            'FcnCallInpInsideContextMsg','error','Diagnostics/Connectivity';...
                                                                                                                                                                                            };


                                                                                                                                                                                            function[modelRequiresManualFixes,handlesToHighlite,result]=locMigrationCheckDisplayMessages(system,msgIDPrefix,checkTitle,checkTitleKey,messageInfo,result,currentCheckObj)

                                                                                                                                                                                                xlatePrefix='Simulink:tools:';

                                                                                                                                                                                                listIdx=0;

                                                                                                                                                                                                modelRequiresManualFixes=false;

                                                                                                                                                                                                handlesToHighlite=[];

                                                                                                                                                                                                msgIDSet=fieldnames(messageInfo);


                                                                                                                                                                                                errorSet=[];
                                                                                                                                                                                                warnSet=[];
                                                                                                                                                                                                for msgIdx=1:length(msgIDSet)
                                                                                                                                                                                                    msgID=msgIDSet{msgIdx};
                                                                                                                                                                                                    if strcmp(messageInfo.(msgID).MessageType,'Warning')
                                                                                                                                                                                                        warnSet(end+1)=msgIdx;
                                                                                                                                                                                                    else
                                                                                                                                                                                                        errorSet(end+1)=msgIdx;
                                                                                                                                                                                                    end
                                                                                                                                                                                                end
                                                                                                                                                                                                msgIDSet=msgIDSet([errorSet(:)',warnSet(:)']);


                                                                                                                                                                                                ft=locOutportInitGetOverallFormatTemplate(msgIDPrefix,checkTitle,checkTitleKey);
                                                                                                                                                                                                ft.setSubResultStatus('Warn');

                                                                                                                                                                                                ft.setListObj(get_param(system,'Handle'));





                                                                                                                                                                                                if~isempty(errorSet)
                                                                                                                                                                                                    recActionMsgID=[msgIDPrefix,'RecActionOverallHasError'];
                                                                                                                                                                                                    ft.setSubResultStatus('Fail');
                                                                                                                                                                                                elseif~isempty(warnSet)
                                                                                                                                                                                                    recActionMsgID=[msgIDPrefix,'RecActionOverallNoErrorButHasWarning'];
                                                                                                                                                                                                else
                                                                                                                                                                                                    recActionMsgID=[msgIDPrefix,'RecActionOverallNoErrorNoWarning'];
                                                                                                                                                                                                    ft.setSubResultStatus('Pass');
                                                                                                                                                                                                end
                                                                                                                                                                                                recAction=DAStudio.message(recActionMsgID);


                                                                                                                                                                                                if(strcmp(msgIDPrefix,'Simulink:tools:MAModelLevelMessagesCheck'))
                                                                                                                                                                                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                                                                                                                                                    deriveFromChecks={'mathworks.design.MergeBlkUsage',...
                                                                                                                                                                                                    'mathworks.design.InitParamOutportMergeBlk',...
                                                                                                                                                                                                    'mathworks.design.DiscreteBlock'};
                                                                                                                                                                                                    allpass=ones(length(deriveFromChecks),1);
                                                                                                                                                                                                    for i=1:length(deriveFromChecks)
                                                                                                                                                                                                        allpass(i)=mdladvObj.getCheckResultStatus(deriveFromChecks{i});
                                                                                                                                                                                                    end
                                                                                                                                                                                                    if(any(~allpass))
                                                                                                                                                                                                        paragraph=ModelAdvisor.Paragraph;
                                                                                                                                                                                                        addItem(paragraph,ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAModelLevelMessagesCheckRecActionOtherChecks')));
                                                                                                                                                                                                        addItem(paragraph,ModelAdvisor.LineBreak);
                                                                                                                                                                                                        for i=[find(~allpass)]'
                                                                                                                                                                                                            formattedcheckTitle=ModelAdvisor.Text(mdladvObj.getCheckObj(deriveFromChecks{i}).Title);
                                                                                                                                                                                                            setColor(formattedcheckTitle,'warn');
                                                                                                                                                                                                            addItem(paragraph,[ModelAdvisor.LineBreak,formattedcheckTitle]);
                                                                                                                                                                                                        end
                                                                                                                                                                                                        addItem(paragraph,[ModelAdvisor.LineBreak,...
                                                                                                                                                                                                        ModelAdvisor.LineBreak,...
                                                                                                                                                                                                        ModelAdvisor.Text(DAStudio.message([recActionMsgID,'OtherChecksFail']))]);
                                                                                                                                                                                                        ft.setRecAction(paragraph);
                                                                                                                                                                                                    end
                                                                                                                                                                                                else
                                                                                                                                                                                                    ft.setRecAction(recAction);
                                                                                                                                                                                                end

                                                                                                                                                                                                result{end+1}=ft;


                                                                                                                                                                                                for msgIdx=1:length(msgIDSet)
                                                                                                                                                                                                    msgID=msgIDSet{msgIdx};

                                                                                                                                                                                                    headingMsgID=[msgIDPrefix,'Heading',msgID];
                                                                                                                                                                                                    descMsgID=[msgIDPrefix,'Desc',msgID];

                                                                                                                                                                                                    heading=DAStudio.message(headingMsgID);
                                                                                                                                                                                                    msgDescription=DAStudio.message(descMsgID);

                                                                                                                                                                                                    currentResult=messageInfo.(msgID);
                                                                                                                                                                                                    objects=currentResult.Objects;
                                                                                                                                                                                                    assert(~isempty(objects));

                                                                                                                                                                                                    msgType=currentResult.MessageType;


                                                                                                                                                                                                    ft=ModelAdvisor.FormatTemplate('ListTemplate');

                                                                                                                                                                                                    ft.setSubTitle(heading);
                                                                                                                                                                                                    ft.setInformation(msgDescription);

                                                                                                                                                                                                    ft.RefLink=locOutportInitGetRefLink(...
                                                                                                                                                                                                    msgID,heading,headingMsgID,msgIDPrefix,xlatePrefix);

                                                                                                                                                                                                    ft.setSubResultStatus(locOutportInitGetMessageStatus(msgType));


                                                                                                                                                                                                    if isstruct(objects(1))

                                                                                                                                                                                                        for libIdx=1:length(objects)
                                                                                                                                                                                                            for instIdx=1:length(objects(libIdx).Instances)
                                                                                                                                                                                                                instMsgs=objects(libIdx).Instances(instIdx).Messages;
                                                                                                                                                                                                                instMsgTypes={};
                                                                                                                                                                                                                for instMsgIdx=1:length(instMsgs)
                                                                                                                                                                                                                    instMsgID=instMsgs{instMsgIdx};
                                                                                                                                                                                                                    instMsgTypes{instMsgIdx}=...
                                                                                                                                                                                                                    messageInfo.(instMsgID).MessageType;%#ok
                                                                                                                                                                                                                end
                                                                                                                                                                                                                objects(libIdx).Instances(instIdx).MessageTypes=...
                                                                                                                                                                                                                instMsgTypes;
                                                                                                                                                                                                            end
                                                                                                                                                                                                        end
                                                                                                                                                                                                        listObj=locOutportInitGenerateLibraryListObj(...
                                                                                                                                                                                                        objects,msgIDPrefix,xlatePrefix);
                                                                                                                                                                                                        handlesToExplore=[objects.Handle];
                                                                                                                                                                                                    else
                                                                                                                                                                                                        [listObj,handlesToExplore]=...
                                                                                                                                                                                                        locOutportInitGenerateRegularListObj(objects,msgIDPrefix);
                                                                                                                                                                                                    end

                                                                                                                                                                                                    ft.setListObj(listObj);
                                                                                                                                                                                                    clear listObj

                                                                                                                                                                                                    statusMsgID=[msgIDPrefix,'Status',msgID];
                                                                                                                                                                                                    statusText=DAStudio.message(statusMsgID);
                                                                                                                                                                                                    ft.setSubResultStatusText(statusText);

                                                                                                                                                                                                    recActionMsgID=[msgIDPrefix,'RecAction',msgID];
                                                                                                                                                                                                    recAction=DAStudio.message(recActionMsgID);
                                                                                                                                                                                                    ft.setRecAction(recAction);

                                                                                                                                                                                                    result{end+1}=['<a name="',headingMsgID,'"></a>'];%#ok
                                                                                                                                                                                                    result{end+1}=ft;%#ok


                                                                                                                                                                                                    if~isempty(handlesToExplore)
                                                                                                                                                                                                        listIdx=listIdx+1;
                                                                                                                                                                                                        currentCheckObj.ListViewParameters{listIdx}.Name=heading;

                                                                                                                                                                                                        for blkIdx=1:length(handlesToExplore)
                                                                                                                                                                                                            currentCheckObj.ListViewParameters{listIdx}.Data(blkIdx)=...
                                                                                                                                                                                                            get_param(handlesToExplore(blkIdx),'Object');
                                                                                                                                                                                                        end

                                                                                                                                                                                                        currentCheckObj.ListViewParameters{listIdx}.Attributes=...
                                                                                                                                                                                                        currentResult.ParamsToExplore;

                                                                                                                                                                                                        handlesToHighlite=[handlesToHighlite,handlesToExplore];%#ok<AGROW>
                                                                                                                                                                                                    end


                                                                                                                                                                                                    if strcmpi(msgType,'Error')
                                                                                                                                                                                                        modelRequiresManualFixes=true;
                                                                                                                                                                                                    end
                                                                                                                                                                                                end



                                                                                                                                                                                                function ft=locOutportInitGetOverallFormatTemplate(msgIDPrefix,checkTitle,checkTitleKey)

                                                                                                                                                                                                    ft=ModelAdvisor.FormatTemplate('ListTemplate');

                                                                                                                                                                                                    overallHeading=DAStudio.message([msgIDPrefix,'HeadingOverall']);
                                                                                                                                                                                                    overallDesc=DAStudio.message([msgIDPrefix,'DescOverall']);

                                                                                                                                                                                                    ft.setSubTitle(overallHeading);
                                                                                                                                                                                                    ft.setInformation(overallDesc);

                                                                                                                                                                                                    ft.RefLink{end+1}=locOutportInitGenerateRefLink(...
                                                                                                                                                                                                    'ma.simulink',...
                                                                                                                                                                                                    checkTitleKey,...
                                                                                                                                                                                                    checkTitle);
                                                                                                                                                                                                    ft.refLink{end+1}=locOutportInitGenerateRefLink(...
                                                                                                                                                                                                    'Simulink.ConfigSet.ListView',...
                                                                                                                                                                                                    'Tag_ConfigSet_Debug_UnderspecifiedInitializationDetection',...
                                                                                                                                                                                                    DAStudio.message('RTW:configSet:debugDetectUnderspecifiedInitName'));



                                                                                                                                                                                                    function refLink=locOutportInitGetRefLink(...
                                                                                                                                                                                                        msgID,heading,headingMsgID,msgIDPrefix,xlatePrefix)

                                                                                                                                                                                                        refLink={};

                                                                                                                                                                                                        refLink{end+1}=locOutportInitGenerateRefLink(...
                                                                                                                                                                                                        'ma.simulink',...
                                                                                                                                                                                                        headingMsgID(length(xlatePrefix)+1:end),...
                                                                                                                                                                                                        heading);

                                                                                                                                                                                                        switch msgID
                                                                                                                                                                                                        case 'BlockDiagramErrorNeedMergeDiagnostics'
                                                                                                                                                                                                            refLink{end+1}=locOutportInitGenerateRefLink(...
                                                                                                                                                                                                            'Simulink.ConfigSet.ListView',...
                                                                                                                                                                                                            'Tag_ConfigSet_Debug_MergeDetectMultiDrivingBlocksExec',...
                                                                                                                                                                                                            DAStudio.message('RTW:configSet:debugDetectMultiDrivingBlocksExecName'));

                                                                                                                                                                                                        case 'OutportErrorBufferConflict'
                                                                                                                                                                                                            refLink{end+1}={['<a href="matlab: load_system(sprintf('''...
                                                                                                                                                                                                            ,'sl_subsys_semantics'')); open_system(sprintf('''...
                                                                                                                                                                                                            ,'sl_subsys_semantics/ Function-call\nsubsystems''))'...
                                                                                                                                                                                                            ,'">sl_subsys_semantics/ Function-call subsystems</a>']};
                                                                                                                                                                                                        case 'SubSystemWarningCondSubsysMovingBlocksIntoContextFromOutputSide'
                                                                                                                                                                                                            refLink{end+1}=locOutportInitGenerateRefLink(...
                                                                                                                                                                                                            'Simulink.SLDialogSource.SubSystem',...
                                                                                                                                                                                                            'Propagate_execution_context_across_subsystem_boundary',...
                                                                                                                                                                                                            DAStudio.message([msgIDPrefix,'PropCECAcrossSSBoundary']));

                                                                                                                                                                                                        case 'DiscreteIntegratorWarningInitBehaviorChange'
                                                                                                                                                                                                            map_path=[docroot,'/toolbox/simulink/slref/simulink_ref.map'];
                                                                                                                                                                                                            refLink{end+1}=...
                                                                                                                                                                                                            {['<a href="matlab:helpview(''',map_path,''','...
                                                                                                                                                                                                            ,'''discretetimeintegrator'')">'...
                                                                                                                                                                                                            ,DAStudio.message([msgIDPrefix,'DiscreteIntegrator']),'</a>']};
                                                                                                                                                                                                        end



                                                                                                                                                                                                        function refLink=locOutportInitGenerateRefLink(mapKey,topicID,linkText)

                                                                                                                                                                                                            linkText=strtrim(linkText);
                                                                                                                                                                                                            if linkText(end)==':'
                                                                                                                                                                                                                linkText=linkText(1:end-1);
                                                                                                                                                                                                            end
                                                                                                                                                                                                            refLink={['<a href="matlab:helpview(''mapkey:'...
                                                                                                                                                                                                            ,mapKey,''','''...
                                                                                                                                                                                                            ,topicID,''')">'...
                                                                                                                                                                                                            ,linkText,'</a>']};



                                                                                                                                                                                                            function status=locOutportInitGetMessageStatus(msgType)

                                                                                                                                                                                                                switch msgType
                                                                                                                                                                                                                case{'Error','Disposition'}
                                                                                                                                                                                                                    status='Fail';
                                                                                                                                                                                                                case 'Warning'
                                                                                                                                                                                                                    status='Warn';
                                                                                                                                                                                                                otherwise
                                                                                                                                                                                                                    assert(true,['Unknown message type ''',msgType,'''.']);
                                                                                                                                                                                                                end

                                                                                                                                                                                                                function msgID=locOutportInitGetStatusMessageID(msgType)

                                                                                                                                                                                                                    switch msgType
                                                                                                                                                                                                                    case{'Error','Disposition'}
                                                                                                                                                                                                                        msgID='FailedMsg';
                                                                                                                                                                                                                    case 'Warning'
                                                                                                                                                                                                                        msgID='WarningMsg';
                                                                                                                                                                                                                    otherwise
                                                                                                                                                                                                                        assert(true,['Unknown message type ''',msgType,'''.']);
                                                                                                                                                                                                                    end



                                                                                                                                                                                                                    function[result,nonLibHandles]=...
                                                                                                                                                                                                                        locOutportInitGenerateRegularListObj(handles,msgIDPrefix)

                                                                                                                                                                                                                        result={};
                                                                                                                                                                                                                        nonLibHandles=[];
                                                                                                                                                                                                                        for blkIdx=1:length(handles)
                                                                                                                                                                                                                            blkHandle=handles(blkIdx);


                                                                                                                                                                                                                            blockResult=locGenerateLinkForBlock(blkHandle);


                                                                                                                                                                                                                            if strcmp(get_param(blkHandle,'Type'),'block')
                                                                                                                                                                                                                                libBlk=get_param(blkHandle,'ReferenceBlock');
                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                libBlk='';
                                                                                                                                                                                                                            end

                                                                                                                                                                                                                            if isempty(libBlk)
                                                                                                                                                                                                                                nonLibHandles(end+1)=blkHandle;
                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                blockResult=...
                                                                                                                                                                                                                                [blockResult,'<ul><li><font size="-1"><b>'...
                                                                                                                                                                                                                                ,DAStudio.message([msgIDPrefix,'LibraryBlock'])...
                                                                                                                                                                                                                                ,':</b></font> ',locGenerateLinkForBlock(libBlk),'</li></ul>'];
                                                                                                                                                                                                                            end

                                                                                                                                                                                                                            result{end+1}=blockResult;
                                                                                                                                                                                                                        end



                                                                                                                                                                                                                        function result=...
                                                                                                                                                                                                                            locOutportInitGenerateLibraryListObj(libraryInfo,msgIDPrefix,xlatePrefix)

                                                                                                                                                                                                                            result={};
                                                                                                                                                                                                                            for libIdx=1:length(libraryInfo)
                                                                                                                                                                                                                                libHandle=libraryInfo(libIdx).Handle;
                                                                                                                                                                                                                                blockResult=locGenerateLinkForBlock(libHandle);
                                                                                                                                                                                                                                if~isempty(libraryInfo(libIdx).Instances)
                                                                                                                                                                                                                                    blockResult=[blockResult,'<ul>'];
                                                                                                                                                                                                                                    for instIdx=1:length(libraryInfo(libIdx).Instances)
                                                                                                                                                                                                                                        handle=libraryInfo(libIdx).Instances(instIdx).Handle;
                                                                                                                                                                                                                                        blockResult=[blockResult,'<li><font size="-1">'...
                                                                                                                                                                                                                                        ,'<b>',DAStudio.message([msgIDPrefix,'Instance'])...
                                                                                                                                                                                                                                        ,' ',mat2str(instIdx),':</b></font> '...
                                                                                                                                                                                                                                        ,locGenerateLinkForBlock(handle),'</li>'];

                                                                                                                                                                                                                                        msgs=libraryInfo(libIdx).Instances(instIdx).Messages;
                                                                                                                                                                                                                                        if~isempty(msgs)
                                                                                                                                                                                                                                            blockResult=[blockResult,'<ul>'];
                                                                                                                                                                                                                                            msgTypes=libraryInfo(libIdx).Instances(instIdx).MessageTypes;
                                                                                                                                                                                                                                            for msgIdx=1:length(msgs)
                                                                                                                                                                                                                                                statusMsgID=...
                                                                                                                                                                                                                                                [xlatePrefix...
                                                                                                                                                                                                                                                ,locOutportInitGetStatusMessageID(msgTypes{msgIdx})];
                                                                                                                                                                                                                                                headingMsgID=[msgIDPrefix,'Heading',msgs{msgIdx}];
                                                                                                                                                                                                                                                blockResult=[blockResult,'<li><font size="-1"><i>'...
                                                                                                                                                                                                                                                ,DAStudio.message(statusMsgID)...
                                                                                                                                                                                                                                                ,':</i></font> '...
                                                                                                                                                                                                                                                ,'<a href="#',headingMsgID,'">'...
                                                                                                                                                                                                                                                ,DAStudio.message(headingMsgID),'</a></li>'];
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                            blockResult=[blockResult,'</ul>'];
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    blockResult=[blockResult,'</ul>'];
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                result{end+1}=blockResult;
                                                                                                                                                                                                                            end








                                                                                                                                                                                                                            function[ResultDescription,ResultHandles]=ExecCheckSubsys(system)
                                                                                                                                                                                                                                ResultDescription={};
                                                                                                                                                                                                                                ResultHandles={};


                                                                                                                                                                                                                                hScope=get_param(system,'Handle');
                                                                                                                                                                                                                                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
                                                                                                                                                                                                                                mdladvObj.setCheckResultStatus(false);
                                                                                                                                                                                                                                cs=getActiveConfigSet(bdroot(hScope));
                                                                                                                                                                                                                                op=cs.get_param('ObjectivePriorities');

                                                                                                                                                                                                                                model=bdroot(system);
                                                                                                                                                                                                                                [cleanup,ft]=coder.advisor.internal.updateDiagram(model);
                                                                                                                                                                                                                                if~isempty(ft)

                                                                                                                                                                                                                                    ResultDescription{end+1}=ft;
                                                                                                                                                                                                                                    ResultHandles{end+1}=[];

                                                                                                                                                                                                                                    mdladvObj.setCheckErrorSeverity(1);
                                                                                                                                                                                                                                    return
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                skipFirstPart=false;

                                                                                                                                                                                                                                EfficiencyRAM=false;
                                                                                                                                                                                                                                EfficiencyROM=false;
                                                                                                                                                                                                                                EfficiencySpeed=false;
                                                                                                                                                                                                                                firstStatus=false;
                                                                                                                                                                                                                                secondStatus=false;

                                                                                                                                                                                                                                for i=1:length(op)
                                                                                                                                                                                                                                    if strcmpi(op{i},'Execution efficiency')
                                                                                                                                                                                                                                        EfficiencySpeed=true;
                                                                                                                                                                                                                                        continue;
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    if strcmpi(op{i},'ROM efficiency')
                                                                                                                                                                                                                                        EfficiencyROM=true;
                                                                                                                                                                                                                                        continue;
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    if strcmpi(op{i},'RAM efficiency')
                                                                                                                                                                                                                                        EfficiencyRAM=true;
                                                                                                                                                                                                                                        continue;
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                if EfficiencySpeed&&~EfficiencyRAM&&~EfficiencyROM
                                                                                                                                                                                                                                    skipFirstPart=true;
                                                                                                                                                                                                                                    firstStatus=true;
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                if~skipFirstPart




                                                                                                                                                                                                                                    hBlocks=find_system(hScope,...
                                                                                                                                                                                                                                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                                                                                                                                    'BlockType','SubSystem',...
                                                                                                                                                                                                                                    'RTWSystemCode','Nonreusable function');
                                                                                                                                                                                                                                    hNVBlocks=[];

                                                                                                                                                                                                                                    for idx=1:length(hBlocks)
                                                                                                                                                                                                                                        if~loc_IsVirtualSubsystem(hBlocks(idx))
                                                                                                                                                                                                                                            if strcmp('void_void',get_param(hBlocks(idx),'FunctionInterfaceSpec'))
                                                                                                                                                                                                                                                hNVBlocks(end+1)=hBlocks(idx);
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                    firstResult=hNVBlocks;

                                                                                                                                                                                                                                    firstResult=mdladvObj.filterResultWithExclusion(firstResult);
                                                                                                                                                                                                                                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                                                                                                                                                    if isempty(firstResult)
                                                                                                                                                                                                                                        firstDescription=DAStudio.message('ModelAdvisor:engine:CodegenerationfunctionpackagingPass');
                                                                                                                                                                                                                                        ft.setSubResultStatus('Pass');
                                                                                                                                                                                                                                        firstStatus=true;
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        firstDescription=DAStudio.message('ModelAdvisor:engine:CodegenerationfunctionpackagingWarn');
                                                                                                                                                                                                                                        ft.setSubResultStatus('Warn');
                                                                                                                                                                                                                                        ft.setListObj(firstResult);
                                                                                                                                                                                                                                        firstStatus=false;
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    ft.setSubResultStatusText(firstDescription);
                                                                                                                                                                                                                                    ResultDescription{end+1}=ft;
                                                                                                                                                                                                                                    ResultHandles{end+1}=firstResult;
                                                                                                                                                                                                                                end



                                                                                                                                                                                                                                if strcmp(cs.get_param('UtilityFuncGeneration'),'Shared location')
                                                                                                                                                                                                                                    skipSecondPart=true;
                                                                                                                                                                                                                                    noSecondPart=false;

                                                                                                                                                                                                                                    skipMsg=DAStudio.message('ModelAdvisor:engine:CodegenerationfunctionpackagingSkipSharedLocation');
                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                    skipSecondPart=false;
                                                                                                                                                                                                                                    noSecondPart=true;

                                                                                                                                                                                                                                    secondResult={};
                                                                                                                                                                                                                                    resultIdx=0;




                                                                                                                                                                                                                                    subsys=find_system(hScope,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
                                                                                                                                                                                                                                    for idx=1:length(subsys)
                                                                                                                                                                                                                                        rtwSysCode=get_param(subsys(idx),'RTWSystemCode');
                                                                                                                                                                                                                                        if strcmp(rtwSysCode,'Reusable function')
                                                                                                                                                                                                                                            noSecondPart=false;
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        rtwInfo=get_param(subsys(idx),'CompiledRTWSystemInfo');
                                                                                                                                                                                                                                        if~isempty(rtwInfo)
                                                                                                                                                                                                                                            if(rtwInfo(1)==2&&rtwInfo(3)==1)
                                                                                                                                                                                                                                                resultIdx=resultIdx+1;
                                                                                                                                                                                                                                                secondResult{resultIdx}=subsys(idx);%#ok
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                if noSecondPart
                                                                                                                                                                                                                                    secondStatus=true;
                                                                                                                                                                                                                                else

                                                                                                                                                                                                                                    ft=ModelAdvisor.FormatTemplate('ListTemplate');

                                                                                                                                                                                                                                    if skipSecondPart
                                                                                                                                                                                                                                        secondStatus=true;
                                                                                                                                                                                                                                        secondResult=[];
                                                                                                                                                                                                                                        ft.setSubResultStatus('Pass');
                                                                                                                                                                                                                                        ft.setSubResultStatusText(skipMsg);
                                                                                                                                                                                                                                    else

                                                                                                                                                                                                                                        secondResult=mdladvObj.filterResultWithExclusion(secondResult);
                                                                                                                                                                                                                                        if isempty(secondResult)
                                                                                                                                                                                                                                            secondDescription=DAStudio.message('Simulink:tools:MADescrDetectReusableSubsystemNotReused');
                                                                                                                                                                                                                                            ft.setSubResultStatus('Pass');
                                                                                                                                                                                                                                            secondStatus=true;
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            secondDescription=DAStudio.message('Simulink:tools:MADetectReusableSubsystemNotReusedWarningMsg');
                                                                                                                                                                                                                                            ft.setSubResultStatus('Warn');
                                                                                                                                                                                                                                            ft.setListObj(secondResult);
                                                                                                                                                                                                                                            secondStatus=false;
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        ft.setSubResultStatusText(secondDescription);

                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    ResultHandles{end+1}=secondResult;
                                                                                                                                                                                                                                    ResultDescription{end+1}=ft;
                                                                                                                                                                                                                                end




                                                                                                                                                                                                                                if~isempty(ft)
                                                                                                                                                                                                                                    ft.setSubBar(false);
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                mdladvObj.setCheckResultStatus(firstStatus&&secondStatus);

                                                                                                                                                                                                                                if isempty(ResultDescription)&&(firstStatus&&secondStatus)
                                                                                                                                                                                                                                    ResultDescription{end+1}=['<p /><font color="#008000">',...
                                                                                                                                                                                                                                    DAStudio.message('Simulink:tools:MAPassedMsg'),...
                                                                                                                                                                                                                                    '</font>'];
                                                                                                                                                                                                                                    ResultHandles{end+1}=[];
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                delete(cleanup);









                                                                                                                                                                                                                                function ResultDescription=ExecCheckTunableBlock(system)
                                                                                                                                                                                                                                    ResultDescription={};
                                                                                                                                                                                                                                    ResultHandles={};



                                                                                                                                                                                                                                    passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                                                                                                                                                                                                    model=bdroot(system);
                                                                                                                                                                                                                                    cs=getActiveConfigSet(model);
                                                                                                                                                                                                                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                                                                                                                                                                                    mdladvObj.setCheckResultStatus(false);



                                                                                                                                                                                                                                    inlineParams=get_param(cs,'InlineParams');




                                                                                                                                                                                                                                    lookups_1=find_system(model,...
                                                                                                                                                                                                                                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                                                                                                                                    'RegExp','Off',...
                                                                                                                                                                                                                                    'FollowLinks','on',...
                                                                                                                                                                                                                                    'LookUnderMasks','graphical',...
                                                                                                                                                                                                                                    'Type','block',...
                                                                                                                                                                                                                                    'BlockType','Lookup');

                                                                                                                                                                                                                                    lookups_2=find_system(model,...
                                                                                                                                                                                                                                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                                                                                                                                    'RegExp','Off',...
                                                                                                                                                                                                                                    'FollowLinks','on',...
                                                                                                                                                                                                                                    'LookUnderMasks','graphical',...
                                                                                                                                                                                                                                    'Type','block',...
                                                                                                                                                                                                                                    'BlockType','Lookup2D');



                                                                                                                                                                                                                                    newLookUps=find_system(model,...
                                                                                                                                                                                                                                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                                                                                                                                    'RegExp','Off',...
                                                                                                                                                                                                                                    'FollowLinks','on',...
                                                                                                                                                                                                                                    'LookUnderMasks','graphical',...
                                                                                                                                                                                                                                    'Type','block',...
                                                                                                                                                                                                                                    'BlockType','Lookup_n-D');


                                                                                                                                                                                                                                    if strcmpi(inlineParams,'on')

                                                                                                                                                                                                                                        isTunableBlk=Advisor.Utils.Simulink.isTunableBlockParameter(lookups_1,'InputValues');
                                                                                                                                                                                                                                        isTunableBlk=isTunableBlk|Advisor.Utils.Simulink.isTunableBlockParameter(lookups_1,'OutputValues');
                                                                                                                                                                                                                                        lookups_1=lookups_1(isTunableBlk);


                                                                                                                                                                                                                                        isTunableBlk=Advisor.Utils.Simulink.isTunableBlockParameter(lookups_2,'RowIndex');
                                                                                                                                                                                                                                        isTunableBlk=isTunableBlk|Advisor.Utils.Simulink.isTunableBlockParameter(lookups_2,'ColumnIndex');
                                                                                                                                                                                                                                        isTunableBlk=isTunableBlk|Advisor.Utils.Simulink.isTunableBlockParameter(lookups_2,'OutputValues');
                                                                                                                                                                                                                                        lookups_2=lookups_2(isTunableBlk);


                                                                                                                                                                                                                                        isTunableBlk=false(size(newLookUps));
                                                                                                                                                                                                                                        for n=1:length(newLookUps)
                                                                                                                                                                                                                                            dimensions=str2double(get_param(newLookUps{n},'NumberOfTableDimensions'));

                                                                                                                                                                                                                                            for dim=1:dimensions
                                                                                                                                                                                                                                                if Advisor.Utils.Simulink.isTunableBlockParameter(newLookUps(n),['BreakpointsForDimension',num2str(dim)])
                                                                                                                                                                                                                                                    isTunableBlk(n)=true;
                                                                                                                                                                                                                                                    break;
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        newLookUps=newLookUps(isTunableBlk);
                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                    lookups_1=mdladvObj.filterResultWithExclusion(lookups_1);

                                                                                                                                                                                                                                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                                                                                                                                                    ft.setSubTitle(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParams1DTitle'));
                                                                                                                                                                                                                                    ft.setCheckText(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParamsDescription'));

                                                                                                                                                                                                                                    if~isempty(lookups_1)
                                                                                                                                                                                                                                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CodegenerationfunctionpackagingWarn1'));
                                                                                                                                                                                                                                        ft.SubResultStatus='Warn';
                                                                                                                                                                                                                                        ft.setListObj(lookups_1);
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParams1DPass'));
                                                                                                                                                                                                                                        ft.SubResultStatus='Pass';
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    ResultDescription{end+1}=ft;



                                                                                                                                                                                                                                    lookups_2=mdladvObj.filterResultWithExclusion(lookups_2);
                                                                                                                                                                                                                                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                                                                                                                                                    ft.setSubTitle(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParams2DTitle'));
                                                                                                                                                                                                                                    if~isempty(lookups_2)
                                                                                                                                                                                                                                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:LookupTableTunableParams'));
                                                                                                                                                                                                                                        ft.SubResultStatus='Warn';
                                                                                                                                                                                                                                        ft.setListObj(lookups_2);
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParams2DPass'));
                                                                                                                                                                                                                                        ft.SubResultStatus='Pass';
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    ResultDescription{end+1}=ft;



                                                                                                                                                                                                                                    newLookUps=mdladvObj.filterResultWithExclusion(newLookUps);

                                                                                                                                                                                                                                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                                                                                                                                                    ft.setSubTitle(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParamsNewTitle'));
                                                                                                                                                                                                                                    ft.SubBar=false;
                                                                                                                                                                                                                                    if~isempty(newLookUps)
                                                                                                                                                                                                                                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParamsNew'));
                                                                                                                                                                                                                                        ft.SubResultStatus='Warn';
                                                                                                                                                                                                                                        ft.setRecAction(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParamsNewRecAct'));
                                                                                                                                                                                                                                        ft.setListObj(newLookUps);
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:do178b:LookupTableTunableParamsNewPass'));
                                                                                                                                                                                                                                        ft.SubResultStatus='Pass';
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    ResultDescription{end+1}=ft;

                                                                                                                                                                                                                                    if isempty(newLookUps)&&isempty(lookups_2)&&isempty(lookups_1)
                                                                                                                                                                                                                                        mdladvObj.setCheckResultStatus(true);
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        mdladvObj.setCheckResultStatus(false);
                                                                                                                                                                                                                                    end








                                                                                                                                                                                                                                    function[ResultDescription,ResultHandles]=ExecCheckDiscreteInt(system)
                                                                                                                                                                                                                                        ResultDescription={};
                                                                                                                                                                                                                                        ResultHandles={};


                                                                                                                                                                                                                                        passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
                                                                                                                                                                                                                                        model=bdroot(system);
                                                                                                                                                                                                                                        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                                                                                                                                                                                        mdladvObj.setCheckResultStatus(false);




                                                                                                                                                                                                                                        integrators=find_system(model,...
                                                                                                                                                                                                                                        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                                                                                                                                        'RegExp','Off',...
                                                                                                                                                                                                                                        'FollowLinks','on',...
                                                                                                                                                                                                                                        'LookUnderMasks','graphical',...
                                                                                                                                                                                                                                        'Type','block',...
                                                                                                                                                                                                                                        'BlockType','DiscreteIntegrator');

                                                                                                                                                                                                                                        ints_w_issue=[];
                                                                                                                                                                                                                                        for idx=1:length(integrators)
                                                                                                                                                                                                                                            one_int=char(integrators(idx));


                                                                                                                                                                                                                                            if strcmpi(get_param(one_int,'InitialConditionSource'),'external')...
                                                                                                                                                                                                                                                &&strcmpi(get_param(one_int,'ShowStatePort'),'on')

                                                                                                                                                                                                                                                if strcmpi(get_param(one_int,'ExternalReset'),'none')
                                                                                                                                                                                                                                                    ic_type='2';
                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                    ic_type='3';
                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                ports=get_param(one_int,'PortConnectivity');
                                                                                                                                                                                                                                                ic_port=-1;
                                                                                                                                                                                                                                                for port_idx=1:length(ports)
                                                                                                                                                                                                                                                    if strcmp(ports(port_idx).Type,ic_type)...
                                                                                                                                                                                                                                                        &&~isempty(ports(port_idx).SrcBlock)
                                                                                                                                                                                                                                                        ic_port=ports(port_idx).SrcBlock;
                                                                                                                                                                                                                                                        break;
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                if ic_port~=-1

                                                                                                                                                                                                                                                    ic_block_type=get_param(ic_port,'BlockType');
                                                                                                                                                                                                                                                    if isempty(regexpi(ic_block_type,'^(InitialCondition|Constant)$'))

                                                                                                                                                                                                                                                        ints_w_issue=[ints_w_issue;integrators(idx)];
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                        ints_w_issue=mdladvObj.filterResultWithExclusion(ints_w_issue);

                                                                                                                                                                                                                                        if~isempty(ints_w_issue)
                                                                                                                                                                                                                                            ResultDescription{end+1}=DAStudio.message('ModelAdvisor:engine:DiscreteTimeIntegratorIC');
                                                                                                                                                                                                                                            ResultHandles{end+1}=ints_w_issue;
                                                                                                                                                                                                                                            mdladvObj.setCheckResultStatus(false);
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            ResultDescription{end+1}=passString;
                                                                                                                                                                                                                                            ResultHandles{end+1}={};
                                                                                                                                                                                                                                            mdladvObj.setCheckResultStatus(true);
                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                        function ResultDescription=checkForGetParamCompiledSampleTime(system)

                                                                                                                                                                                                                                            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                                                                                                                                                                                                                            mdladvObj.setCheckResultStatus(true);

                                                                                                                                                                                                                                            try

                                                                                                                                                                                                                                                [mFilesOfConcern]=modeladvisorprivate('findMFilesGettingCompiledSampleTime',false);

                                                                                                                                                                                                                                            catch E
                                                                                                                                                                                                                                                mdladvObj.setCheckResultStatus(false);
                                                                                                                                                                                                                                                ResultDescription=E.message;
                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                            if(isempty(mFilesOfConcern))
                                                                                                                                                                                                                                                ResultDescription=DAStudio.message('ModelAdvisor:engine:MACheckGetParamCompiledSampleTimePassed');
                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                            mdladvObj.setCheckResultStatus(false);
                                                                                                                                                                                                                                            ResultDescription=ModelAdvisor.Paragraph;
                                                                                                                                                                                                                                            ResultDescription.addItem(DAStudio.message('ModelAdvisor:engine:MACheckGetParamCompiledSampleTimeFailedHeader'));
                                                                                                                                                                                                                                            ResultDescription.addItem(ModelAdvisor.LineBreak);
                                                                                                                                                                                                                                            ResultDescription.addItem(ModelAdvisor.LineBreak);

                                                                                                                                                                                                                                            if(~isempty(mFilesOfConcern))

                                                                                                                                                                                                                                                ResultDescription.addItem(DAStudio.message('ModelAdvisor:engine:MACheckGetParamCompiledSampleTimeMFileListHeader'));
                                                                                                                                                                                                                                                ResultDescription.addItem('<ul>');

                                                                                                                                                                                                                                                for idx=1:length(mFilesOfConcern)



                                                                                                                                                                                                                                                    ResultDescription.addItem(['<li><!-- mdladv_ignore_start --> <a href="matlab:open('''...
                                                                                                                                                                                                                                                    ,mFilesOfConcern{idx}...
                                                                                                                                                                                                                                                    ,''')">'...
                                                                                                                                                                                                                                                    ,mFilesOfConcern{idx}...
                                                                                                                                                                                                                                                    ,'</a> <!-- mdladv_ignore_finish --> </li>']);
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                ResultDescription.addItem('</ul>');
                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                            ResultDescription.addItem(DAStudio.message('ModelAdvisor:engine:MACheckGetParamCompiledSampleTimeFailedFooter'));
                                                                                                                                                                                                                                            ResultDescription.addItem([' <a href="matlab:modeladvisorprivate(''findMFilesGettingCompiledSampleTime'',true)">'...
                                                                                                                                                                                                                                            ,DAStudio.message('ModelAdvisor:engine:MACheckGetParamCompiledSampleTimeClick'),'</a>']);



                                                                                                                                                                                                                                            function ResultDescription=ExecParameterTuningCheck(system)
                                                                                                                                                                                                                                                ResultDescription=checkParameterTuning(system);




                                                                                                                                                                                                                                                function ResultDescription=ActionParameterTuningCheck(system)
                                                                                                                                                                                                                                                    ResultDescription=actionParameterTuning(system);





                                                                                                                                                                                                                                                    function answer=loc_IsVirtualSubsystem(subsystemID)
                                                                                                                                                                                                                                                        answer=strcmp(get_param(subsystemID,'Virtual'),'on');





























                                                                                                                                                                                                                                                        function BlockDataTypeTable=loc_createBlockDataTypeTable
                                                                                                                                                                                                                                                            BlockDataTypeTable=[];
                                                                                                                                                                                                                                                            idx=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Band-Limited\nWhite Noise');
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Chirp Signal');
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='Clock';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='DigitalClock';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='FromFile';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='FromWorkspace';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='DiscretePulseGenerator';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2ParamName='PulseType';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2ParamValue='Time based';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;


                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Ramp');
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Repeating\nSequence');
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).MaskType='Sigbuilder block';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SignalGenerator';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='Sin';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2ParamName='SineType';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2ParamValue='Time based';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='Step';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='Stop';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='ToFile';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='Derivative';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='Integrator';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='StateSpace';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='TransferFcn';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='TransportDelay';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='VariableTransportDelay';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='ZeroPole';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Math\nOperations/Algebraic Constraint');
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Signal\nRouting/Manual Switch');
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Discrete/First-Order\nHold');
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;


                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='InitialCondition';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='HitCross';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='MATLABFcn';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).MaskType='Fixed-Point Repeating Sequence Interpolated';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;

                                                                                                                                                                                                                                                            idx=idx+1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).BlockType='SubSystem';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).ReferenceBlock='';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).MaskType='Fixed-Point Derivative';
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).RTWenable=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C1=1;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C2=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).C3=0;
                                                                                                                                                                                                                                                            BlockDataTypeTable(idx).N1=0;





















                                                                                                                                                                                                                                                            function htmlStr=loc_CreateConfigSetHref(inputStr,configsetParam,encodedModelName)
                                                                                                                                                                                                                                                                htmlStr=['<a href="matlab: modeladvisorprivate openCSAndHighlight ',encodedModelName,' ',configsetParam,'"> ',inputStr,'</a>'];

                                                                                                                                                                                                                                                                function value=safe_get_param(cs,paramName)
                                                                                                                                                                                                                                                                    if cs.isValidParam(paramName)
                                                                                                                                                                                                                                                                        value=get_param(cs,paramName);
                                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                                        value='not valid field';
                                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                                    function[goodDsts,badDsts]=cand_nonvirtual_bus_dst(port)
                                                                                                                                                                                                                                                                        outline=get_param(port,'Line');
                                                                                                                                                                                                                                                                        goodDsts=0;
                                                                                                                                                                                                                                                                        badDsts=0;
                                                                                                                                                                                                                                                                        if isempty(outline)||~ishandle(outline)
                                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                        dsts=get_param(outline,'DstBlockHandle');
                                                                                                                                                                                                                                                                        numDsts=length(dsts);
                                                                                                                                                                                                                                                                        for idx=1:numDsts
                                                                                                                                                                                                                                                                            dstBlk=dsts(idx);
                                                                                                                                                                                                                                                                            if(strcmp(get_param(dstBlk,'BlockType'),'ModelReference')==1||...
                                                                                                                                                                                                                                                                                strcmp(get_param(dstBlk,'BlockType'),'Outport')==1)
                                                                                                                                                                                                                                                                                goodDsts=goodDsts+1;
                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                badDsts=badDsts+1;
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                        end





                                                                                                                                                                                                                                                                        function goodDsts=cand_nonvirtual_bus_dst_1(port)
                                                                                                                                                                                                                                                                            outline=get_param(port,'Line');
                                                                                                                                                                                                                                                                            goodDsts=0;
                                                                                                                                                                                                                                                                            if isempty(outline)||~ishandle(outline)
                                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            dsts=get_param(outline,'DstBlockHandle');
                                                                                                                                                                                                                                                                            numDsts=length(dsts);
                                                                                                                                                                                                                                                                            for idx=1:numDsts
                                                                                                                                                                                                                                                                                dstBlk=dsts(idx);
                                                                                                                                                                                                                                                                                if(strcmp(get_param(dstBlk,'BlockType'),'ModelReference')==1||...
                                                                                                                                                                                                                                                                                    strcmp(get_param(dstBlk,'BlockType'),'Outport')==1||...
                                                                                                                                                                                                                                                                                    strcmp(get_param(dstBlk,'BlockType'),'SubSystem')==1)
                                                                                                                                                                                                                                                                                    goodDsts=goodDsts+1;
                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                                            function value=cand_nonvirtual_bus_inport(block)
                                                                                                                                                                                                                                                                                ports=get_param(block,'PortHandles');
                                                                                                                                                                                                                                                                                outport=ports.Outport;
                                                                                                                                                                                                                                                                                [goodDsts,badDsts]=cand_nonvirtual_bus_dst(outport);
                                                                                                                                                                                                                                                                                value=goodDsts>0&&badDsts==0;

                                                                                                                                                                                                                                                                                function value=cand_nonvirtual_bus_creator(block)
                                                                                                                                                                                                                                                                                    ports=get_param(block,'PortHandles');
                                                                                                                                                                                                                                                                                    outport=ports.Outport;

                                                                                                                                                                                                                                                                                    goodDsts=cand_nonvirtual_bus_dst_1(outport);
                                                                                                                                                                                                                                                                                    value=goodDsts>0;


                                                                                                                                                                                                                                                                                    function outputStr=locCreateIgnorePortion(inputStr)
                                                                                                                                                                                                                                                                                        outputStr=['<!-- mdladv_ignore_start -->',inputStr,'<!-- mdladv_ignore_finish -->'];

                                                                                                                                                                                                                                                                                        function possibleMoot=locSwitchBlockSaturMoot(curBlockObj,compiledPortDataType)


                                                                                                                                                                                                                                                                                            possibleMoot=false;
                                                                                                                                                                                                                                                                                            if isa(curBlockObj,'Simulink.Switch')||isa(curBlockObj,'Simulink.MultiPortSwitch')

                                                                                                                                                                                                                                                                                                allInportTypes=unique(compiledPortDataType.Inport);
                                                                                                                                                                                                                                                                                                allOutportTypes=unique(compiledPortDataType.Outport);

                                                                                                                                                                                                                                                                                                if isequal(allInportTypes,allOutportTypes)
                                                                                                                                                                                                                                                                                                    possibleMoot=true;
                                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                            end


















