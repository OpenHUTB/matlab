function recordCellArray=definePerformanceAdvisorChecks




    recordCellArray={};



    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:TitleCreateBaseline');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@BaselineGeneration;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Enable=true;
    rec.Value=true;
    rec.InputParametersLayoutGrid=[1,4];


    baselineInputParam{1}=ModelAdvisor.InputParameter;
    baselineInputParam{end}.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:StopTime');
    baselineInputParam{end}.Type='String';
    baselineInputParam{end}.Value=DAStudio.message('SimulinkPerformanceAdvisor:advisor:auto');
    baselineInputParam{end}.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:StopTimeTip');
    baselineInputParam{end}.setRowSpan([1,1]);
    baselineInputParam{end}.setColSpan([1,2]);


    baselineInputParam{end+1}=ModelAdvisor.InputParameter;
    baselineInputParam{end}.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SetupTolerance');
    baselineInputParam{end}.Type='bool';
    baselineInputParam{end}.Enable=true;
    baselineInputParam{end}.Value=false;
    baselineInputParam{end}.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SetupToleranceTip');
    baselineInputParam{end}.setRowSpan([1,1]);
    baselineInputParam{end}.setColSpan([4,4]);



















    rec.setInputParameters(baselineInputParam);
    recordCellArray{end+1}=rec;




    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.IdentifyExpensiveDiagnostics');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyExpensiveDiagnosticsDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@IdentifyExpensiveDiagnostics;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;


    rec=utilSetDefaultActionParameters(rec,2,false,false,@IdentifyExpensiveDiagnosticsFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.IdentifyApplicableOptimizations');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyApplicableOptimizationsDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@IdentifyApplicableOptimizations;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,2,false,false,@IdentifyApplicableOptimizationsFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.InefficientLookupTableBlocks');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableBlocksDesc');
    rec.TitleTips=rec.Title;
    rec.setCallbackFcn(@InefficientLookupTableBlocks,'None','StyleThree');


    rec=utilSetDefaultActionParameters(rec,2,true,true,@InefficientLookupTableBlocksFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.DetectIntSysObjBlocks');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntSysObjBlocksDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@DetectIntSysObjBlocks;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;


    rec=utilSetDefaultActionParameters(rec,1,true,false,@DetectIntSysObjBlocksFix,[1,1,0]);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.DetectIntMATLABFcnBlocks');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntMATLABFcnBlocksDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@DetectIntMATLABFcnBlocks;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;


    rec=utilSetDefaultActionParameters(rec,1,false,true,@DetectIntMATLABFcnBlocksFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckSimTargetEchoStatus');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimTargetEchoStatusDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckSimTargetEchoStatus;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;


    rec=utilSetDefaultActionParameters(rec,2,false,false,@CheckSimTargetEchoStatusFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefRebuildSetting');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckModelRefRebuildSettingDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckModelRefRebuildSetting;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;


    rec=utilSetDefaultActionParameters(rec,2,false,false,@CheckModelRefRebuildSettingFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.IdentifyScopes');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesDescription');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@IdentifyScopes;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;


    rec=utilSetDefaultActionParameters(rec,2,false,false,@IdentifyScopesFix);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.IdentifyActiveMMO');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyMMOCheckTitle');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@IdentifyActiveMMO;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;

    rec=utilSetDefaultActionParameters(rec,2,false,false,@IdentifyActiveMMOFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefParallelBuild');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelRefParallelBuildDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckModelRefParallelBuild;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;
    rec.InputParametersLayoutGrid=[1,6];


    parallelBuildInputParam{1}=ModelAdvisor.InputParameter;
    parallelBuildInputParam{end}.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:QuickEstimation');
    parallelBuildInputParam{end}.Type='bool';
    parallelBuildInputParam{end}.Value=true;
    parallelBuildInputParam{end}.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:QuickEstimationTip');
    parallelBuildInputParam{end}.setRowSpan([1,1]);
    parallelBuildInputParam{end}.setColSpan([1,1]);

    parallelBuildInputParam{end+1}=ModelAdvisor.InputParameter;
    parallelBuildInputParam{end}.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Overhead');
    parallelBuildInputParam{end}.Type='string';
    parallelBuildInputParam{end}.Value='0.5';
    parallelBuildInputParam{end}.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:OverheadTip');
    parallelBuildInputParam{end}.setRowSpan([1,1]);
    parallelBuildInputParam{end}.setColSpan([3,6]);

    rec.setInputParameters(parallelBuildInputParam);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckDelayBlockCircularBufferSetting');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckDelayBlockCircularBufferSetting;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,2,false,false,@CheckDelayBlockCircularBufferSettingFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedDecoupleContDiscRates');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckIfNeedDecoupleContDiscRates;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,2,false,false,@CheckIfNeedDecoupleContDiscRatesFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedOptimalSolverResetCausedByZc');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckIfNeedOptimalSolverResetCausedByZc;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,2,false,false,@CheckIfNeedOptimalSolverResetCausedByZcFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckDiscDriveContSignal');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDiscDriveContSignal');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckDiscDriveContSignal;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec.setInputParameters([]);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.SolverTypeSelection');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverTypeSelectionDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@SolverTypeSelection;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,2,true,true,@SolverTypeSelectionFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckMultiThreadCoSimSetting');
    rec.Title=DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckMultiThreadCoSimSetting;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=false;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,1,false,false,@CheckMultiThreadCoSimSettingFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckNumericCompensationCoSimSetting');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationCheckTitle');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckNumericCompensationCoSimSetting;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=false;
    rec.Enable=true;


    rec=cosimSetActionParameters(rec,@CheckNumericCompensationCoSimSettingFix);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckDataflow');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckDataflow;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,1,false,false,@CheckDataflowFix,[1,1,0]);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationModesComparison');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimulationModesComparisonDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckSimulationModesComparison;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,1,false,false,@CheckSimulationModesComparisonFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationCompilerOptimization');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimulationCompilerOptimizationDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckSimulationCompilerOptimization;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,1,false,false,@CheckSimulationCompilerOptimizationFix);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationHardwareAcceleration');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckSimulationHardwareAcceleration;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,1,false,false,@CheckSimulationHardwareAccelerationFix);
    recordCellArray{end+1}=rec;


























































    rec=ModelAdvisor.Check('com.mathworks.Simulink.PerformanceAdvisor.FinalValidation');
    rec.Title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationDesc');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@CheckFinalValidation;


    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;


    rec=utilSetDefaultActionParameters(rec,2,true,true,@CheckFinalValidationFix);
    recordCellArray{end+1}=rec;


