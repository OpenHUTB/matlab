function nodes=definePerformanceAdvisorTask




    nodes={};

    taskLvlOne=0;


    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor');
    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorDialogSchema;
    TAN.DisplayName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PerformanceAdvisor');
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Desc');
    TAN.HelpMethod='helpview';
    TAN.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'simulink_performance_advisor_overview'};
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.Baseline';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.Simulation';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.SimulationTargets';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.FinalValidation';






    TAN.setInputParametersCallbackFcn(@topNodeParamCallBack);



    vs1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActModeV1');
    vs2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActModeV2');
    vs3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActModeV3');

    inputParam1=ModelAdvisor.InputParameter;
    inputParam1.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActModeButton');
    inputParam1.Type='enum';
    inputParam1.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActModeTip');
    inputParam1.Entries={vs1,vs2,vs3};
    inputParam1.Value=inputParam1.Entries{1};

    vs1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationModeV1');
    vs2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationModeV2');
    vs3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationModeV3');

    inputParam2=ModelAdvisor.InputParameter;
    inputParam2.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationTimeButton');
    inputParam2.Type='enum';
    inputParam2.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationTimeTip');
    inputParam2.Entries={vs1,vs2,vs3};
    inputParam2.Value=inputParam2.Entries{1};


    inputParam3=ModelAdvisor.InputParameter;
    inputParam3.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationAccuracyButton');
    inputParam3.Type='enum';
    inputParam3.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationAccuracyTip');
    inputParam3.Entries={vs1,vs2,vs3};
    inputParam3.Value=inputParam3.Entries{1};


    vs=DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeoutEditbox');
    inputParam4=ModelAdvisor.InputParameter;
    inputParam4.Name=vs;
    inputParam4.Type='String';
    inputParam4.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeoutTip');
    inputParam4.Value='60';


    TAN.setInputParameters({inputParam1,inputParam2,inputParam3,inputParam4});

    nodes{end+1}=TAN;


    taskLvlOne=taskLvlOne+1;
    taskLvlTwo=0;



    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.Baseline');
    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;
    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Baseline'),taskLvlOne);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:BaselineDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline';













    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CreateBaseline'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlOne=taskLvlOne+1;
    taskLvlTwo=0;
    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.Simulation');
    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;
    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Simulation'),taskLvlOne);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.BeforeUpdate';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.UpdateDiagram';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.Runtime';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    taskLvlThree=0;

    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.BeforeUpdate');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:PreUpdate'),taskLvlOne,taskLvlTwo);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PreUpdateDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.IdentifyExpensiveDiagnostics';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.IdentifyApplicableOptimizations';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.InefficientLookupTableBlocks';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.DetectIntSysObjBlocks';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.DetectIntMATLABFcnBlocks';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckSimTargetEchoStatus';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefRebuildSetting';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.IdentifyScopes';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.IdentifyActiveMMO';
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.IdentifyExpensiveDiagnostics');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyExpensiveDiagnosticsTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.IdentifyExpensiveDiagnostics';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.IdentifyApplicableOptimizations');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyApplicableOptimizationsTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.IdentifyApplicableOptimizations';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.InefficientLookupTableBlocks');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableBlocksTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.InefficientLookupTableBlocks';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.DetectIntSysObjBlocks');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntSysObjBlocksTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.DetectIntSysObjBlocks';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.DetectIntMATLABFcnBlocks');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntMATLABFcnBlocksTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.DetectIntMATLABFcnBlocks';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckSimTargetEchoStatus');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimTargetEchoStatusTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckSimTargetEchoStatus';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefRebuildSetting');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckModelRefRebuildSettingTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefRebuildSetting';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.IdentifyScopes');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.IdentifyScopes';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.IdentifyActiveMMO');
    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyMMOCheckTask'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.IdentifyActiveMMO';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlTwo=taskLvlTwo+1;
    taskLvlThree=0;
    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.UpdateDiagram');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:UpdateDiagram'),taskLvlOne,taskLvlTwo);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UpdateDiagramDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefParallelBuild';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckDelayBlockCircularBufferSetting';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedDecoupleContDiscRates';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedOptimalSolverResetCausedByZc';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckDiscDriveContSignal';
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefParallelBuild');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckModelRefParallelBuildTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefParallelBuild';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckDelayBlockCircularBufferSetting');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckDelayBlockCircularBufferSetting';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedDecoupleContDiscRates');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedDecoupleContDiscRates';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedOptimalSolverResetCausedByZc');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedOptimalSolverResetCausedByZc';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckDiscDriveContSignal');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDiscDriveContSignal'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckDiscDriveContSignal';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlTwo=taskLvlTwo+1;
    taskLvlThree=0;
    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.Runtime');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:RunTime'),taskLvlOne,taskLvlTwo);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RunTimeDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.SolverTypeSelection';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckMultiThreadCoSimSetting';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckNumericCompensationCoSimSetting';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckDataflow';

    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.SolverTypeSelection');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverTypeSelectionTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.SolverTypeSelection';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckMultiThreadCoSimSetting');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckMultiThreadCoSimSetting';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckNumericCompensationCoSimSetting');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationCheckTask'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckNumericCompensationCoSimSetting';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckDataflow');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckDataflow';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlOne=taskLvlOne+1;
    taskLvlTwo=0;

    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.SimulationTargets');
    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;
    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationTargets'),taskLvlOne);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationTargetsDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.SimulationModesComparison';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.SimulationCompilerOptimization';
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.SimulationHardwareAcceleration';
    TAN.Value=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    taskLvlThree=0;
    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.SimulationModesComparison');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationModesComparisonTitle'),taskLvlOne,taskLvlTwo);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationModesComparisonDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationModesComparison';




    TAN.Value=true;
    nodes{end+1}=TAN;



    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationModesComparison');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimulationModesComparisonTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationModesComparison';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    taskLvlThree=0;
    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.SimulationCompilerOptimization');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationCompilerOptimizationTitle'),taskLvlOne,taskLvlTwo);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationCompilerOptimizationDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationCompilerOptimization';
    TAN.Value=true;
    nodes{end+1}=TAN;



    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationCompilerOptimization');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimulationCompilerOptimizationTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationCompilerOptimization';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlTwo=taskLvlTwo+1;
    taskLvlThree=0;
    TAN=ModelAdvisor.Group('com.mathworks.Simulink.PerformanceAdvisor.SimulationHardwareAcceleration');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorGroupDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTitle'),taskLvlOne,taskLvlTwo);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationHardwareAcceleration';
    TAN.Value=true;
    nodes{end+1}=TAN;




    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationHardwareAcceleration');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelCheckTitle'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationHardwareAcceleration';
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


























































































    taskLvlOne=taskLvlOne+1;

    TAN=ModelAdvisor.Task('com.mathworks.Simulink.PerformanceAdvisor.FinalValidation');

    TAN.CustomObject=createCustomObj;
    TAN.CustomDialogSchema=@performanceAdvisorTaskDialogSchema;

    TAN.DisplayName=utilTaskTitle(false,DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationTitle'),taskLvlOne);
    TAN.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationDesc');
    TAN.CSHParameters.MapKey='performancea';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.Simulink.PerformanceAdvisor.FinalValidation';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    function CustomObj=createCustomObj
        CustomObj=ModelAdvisor.Customization;
        CustomObj.GUITitle=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PerformanceAdvisor');
        CustomObj.GUICloseCallback={'performanceadvisor','string','%<System>','token','Cleanup','string'};
        CustomObj.MenuHelp.Text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PARootHelp');
        CustomObj.MenuHelp.Callback='helpview([docroot,''/toolbox/simulink/helptargets.map''],''using_performance_advisor'');';
        CustomObj.MenuAbout.Text=DAStudio.message('Simulink:tools:MAAboutSimulink');
        CustomObj.MenuAbout.Callback='daabout(''simulink'');';
        CustomObj.ShowAccordion=true;
        CustomObj.AccordionInfo.icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Toolbars','16px','PerformanceAdvisor_16.png');
        CustomObj.AccordionInfo.Description=DAStudio.message('ModelAdvisor:engine:PerformanceAdvisorAccordionDescription');
        CustomObj.LoadRestorePointCallback={'performanceadvisor','string','%<System>','token'};
        CustomObj.GUIReportTabName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Home');
        CustomObj.ReportPageTitleCallback={'DAStudio.message','string','ModelAdvisor:engine:PerformReportfor','string','''%<SystemName>''','token'};
        CustomObj.ReportTitle=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ReportTitle');
