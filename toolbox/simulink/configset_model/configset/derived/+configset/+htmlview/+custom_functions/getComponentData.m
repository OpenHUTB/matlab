
function FC=getComponentData(cc,cid)

    if isempty(cc)
        FC=ismember(cid,{'Simulink.ConfigSet','Simulink.SolverCC','Simulink.DataIOCC','Simulink.OptimizationCC','Simulink.DebuggingCC','Simulink.HardwareCC','Simulink.ModelReferenceCC','Simulink.SFSimCC','Simulink.RTWCC','Simulink.CodeAppCC','Simulink.TargetCC','AUTOSAR.AUTOSARAdaptiveTargetCC','MDX.MDXTargetCC','RTW.RSimTargetCC','RTW.TornadoTargetCC','Simulink.CPPComponent','SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC','SimulinkDesktopRealTime.SimulinkDesktopRealTimeERTCC','SimulinkRealTime.SimulinkRealTimeCC','SimulinkRealTime.SimulinkRealTimeERTCC','dpigen.DPIERTTargetCC','dpigen.DPIGRTTargetCC','Simulink.ERTTargetCC','Simulink.GRTTargetCC','pjtgeneratorpkg.ERTFactory','pjtgeneratorpkg.GRTFactory','Simulink.RaccelTargetCC','slrealtime.SimulinkRealTimeTargetCC','slrtlinux.slrtlinuxTargetCC','tlmg.TLMERTTargetCC','tlmg.TLMGRTTargetCC','CCSTargetConfig.HostTargetConfig','CCSTargetConfig.RtdxConfig','ModelAdvisor.ConfigsetCC','PLCCoder.ConfigComp','SSC.SimscapeCC','SlCovCC.ConfigComp','Sldv.ConfigComp','hdlcoderui.hdlcc','pslink.ConfigComp','simmechanics.ConfigurationSet','simmechanics.DiagnosticsConfigSet','simmechanics.ExplorerConfigSet','CoderTarget.SettingsController','MECH.SimMechanicsCC','RealTime.SettingsController','pjtgeneratorpkg.TargetHardwareResources'});
        return;
    end

    if isempty(cid)
        cid=class(cc);
    end
    cs=cc.getConfigSet;
    switch cid
    case 'Simulink.ConfigSet'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'Simulink.SolverCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.AbsoluteTime=slfeature('AbsoluteTime');
        FC.feature.AdaptiveSolverUI=slfeature('AdaptiveSolverUI');
        FC.feature.EnableODEN=slfeature('EnableODEN');
        FC.feature.FixedStepZeroCrossing=slfeature('FixedStepZeroCrossing');
        FC.feature.MultiCoreDeterRTB=slfeature('MultiCoreDeterRTB');
        FC.feature.MultiRateBranchedIO=slfeature('MultiRateBranchedIO');
        FC.feature.SampleTimeParameterization=slfeature('SampleTimeParameterization');
        FC.status=0;
    case 'Simulink.DataIOCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'Simulink.OptimizationCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.DisableZeroInitForCppEncap=slfeature('DisableZeroInitForCppEncap');
        FC.feature.InlinePrmsAsCodeGenOnlyOption=slfeature('InlinePrmsAsCodeGenOnlyOption');
        FC.license.Simulink_PLC_Coder=dig.isProductInstalled('Simulink PLC Coder');
        FC.license.Stateflow=dig.isProductInstalled('Stateflow');
        FC.status=0;
    case 'Simulink.DebuggingCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.ExportPeriodicFcnCallRTB=slfeature('ExportPeriodicFcnCallRTB');
        FC.feature.InheritVAT=slfeature('InheritVAT');
        FC.feature.ModelArgumentDefaultVal=slfeature('ModelArgumentDefaultVal');
        FC.feature.VMgrCompBrowser=slfeature('VMgrCompBrowser');
        FC.license.Stateflow=dig.isProductInstalled('Stateflow');
        FC.status=0;
    case 'Simulink.HardwareCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'Simulink.ModelReferenceCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.MultiSolverSimulationSupport=slfeature('MultiSolverSimulationSupport');
        FC.status=0;
    case 'Simulink.SFSimCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.EnableSimHardwareAcceleration=slfeature('EnableSimHardwareAcceleration');
        FC.feature.OutOfProcessExecution=slfeature('OutOfProcessExecution');
        FC.feature.SLCCFcnMutipleExecInstances=slfeature('SLCCFcnMutipleExecInstances');
        FC.license.GPU_Coder=dig.isProductInstalled('GPU Coder');
        FC.status=0;
    case 'Simulink.RTWCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.BoolAndFixedWidthDataTypes=slfeature('BoolAndFixedWidthDataTypes');
        FC.feature.DecoupleCodeMetrics=slfeature('DecoupleCodeMetrics');
        FC.feature.EnableCodeStackProfiling=slfeature('EnableCodeStackProfiling');
        FC.feature.EnableGPUUseSimSettings=slfeature('EnableGPUUseSimSettings');
        FC.feature.FCPlatform=slfeature('FCPlatform');
        FC.license.rtw_embedded_coder=dig.isProductInstalled('Embedded Coder');
        FC.license.GPU_Coder=dig.isProductInstalled('GPU Coder');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'Simulink.CodeAppCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'Simulink.TargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'AUTOSAR.AUTOSARAdaptiveTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.RTWCGStdArraySupport=slfeature('RTWCGStdArraySupport');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.feature.SLDataDictionarySetCSCSource=slfeature('SLDataDictionarySetCSCSource');
        FC.feature.SLDataDictionarySetUserData=slfeature('SLDataDictionarySetUserData');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'MDX.MDXTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.MDXHideCoderGroupParams=slfeature('MDXHideCoderGroupParams');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.RTWCGStdArraySupport=slfeature('RTWCGStdArraySupport');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.feature.SLDataDictionarySetCSCSource=slfeature('SLDataDictionarySetCSCSource');
        FC.feature.SLDataDictionarySetUserData=slfeature('SLDataDictionarySetUserData');
        FC.status=0;
    case 'RTW.RSimTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'RTW.TornadoTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=0;
    case 'Simulink.CPPComponent'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.status=max([~(ismember(cs.getProp('ShowRTWWidgets'),{'on'}))*3,~(ismember(cs.getProp('IsERTTarget'),{'on'}))*3]);
    case 'SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'SimulinkDesktopRealTime.SimulinkDesktopRealTimeERTCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.RTWCGStdArraySupport=slfeature('RTWCGStdArraySupport');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.feature.SLDataDictionarySetCSCSource=slfeature('SLDataDictionarySetCSCSource');
        FC.feature.SLDataDictionarySetUserData=slfeature('SLDataDictionarySetUserData');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'SimulinkRealTime.SimulinkRealTimeCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'SimulinkRealTime.SimulinkRealTimeERTCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.RTWCGStdArraySupport=slfeature('RTWCGStdArraySupport');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.feature.SLDataDictionarySetCSCSource=slfeature('SLDataDictionarySetCSCSource');
        FC.feature.SLDataDictionarySetUserData=slfeature('SLDataDictionarySetUserData');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'dpigen.DPIERTTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.RTWCGStdArraySupport=slfeature('RTWCGStdArraySupport');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.feature.SLDataDictionarySetCSCSource=slfeature('SLDataDictionarySetCSCSource');
        FC.feature.SLDataDictionarySetUserData=slfeature('SLDataDictionarySetUserData');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'dpigen.DPIGRTTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'Simulink.ERTTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.RTWCGStdArraySupport=slfeature('RTWCGStdArraySupport');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.feature.SLDataDictionarySetCSCSource=slfeature('SLDataDictionarySetCSCSource');
        FC.feature.SLDataDictionarySetUserData=slfeature('SLDataDictionarySetUserData');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'Simulink.GRTTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ExtModeXCPMemoryConfiguration=slfeature('ExtModeXCPMemoryConfiguration');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'pjtgeneratorpkg.ERTFactory'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.RTWCGStdArraySupport=slfeature('RTWCGStdArraySupport');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.feature.SLDataDictionarySetCSCSource=slfeature('SLDataDictionarySetCSCSource');
        FC.feature.SLDataDictionarySetUserData=slfeature('SLDataDictionarySetUserData');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'pjtgeneratorpkg.GRTFactory'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ExtModeXCPMemoryConfiguration=slfeature('ExtModeXCPMemoryConfiguration');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'Simulink.RaccelTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=0;
    case 'slrealtime.SimulinkRealTimeTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ExtModeXCPMemoryConfiguration=slfeature('ExtModeXCPMemoryConfiguration');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'slrtlinux.slrtlinuxTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ExtModeXCPMemoryConfiguration=slfeature('ExtModeXCPMemoryConfiguration');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'tlmg.TLMERTTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.RTWCGStdArraySupport=slfeature('RTWCGStdArraySupport');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.feature.SLDataDictionarySetCSCSource=slfeature('SLDataDictionarySetCSCSource');
        FC.feature.SLDataDictionarySetUserData=slfeature('SLDataDictionarySetUserData');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'tlmg.TLMGRTTargetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.CSClassInterfaceOptions=slfeature('CSClassInterfaceOptions');
        FC.feature.ParenthesesLevelStandards=slfeature('ParenthesesLevelStandards');
        FC.feature.ReductionsWithSimdParam=slfeature('ReductionsWithSimdParam');
        FC.status=~(~ismember(cs.getProp('ShowRTWWidgets'),{'off'}))*3;
    case 'CCSTargetConfig.HostTargetConfig'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'CCSTargetConfig.RtdxConfig'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'ModelAdvisor.ConfigsetCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'PLCCoder.ConfigComp'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.PLCExternallyDefinedBlocks=slfeature('PLCExternallyDefinedBlocks');
        FC.feature.PLCExternallyDefinedBlocks2=slfeature('PLCExternallyDefinedBlocks2');
        FC.status=0;
    case 'SSC.SimscapeCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'SlCovCC.ConfigComp'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.SlCovAccelSimSupport=slfeature('SlCovAccelSimSupport');
        FC.feature.SlCovConsistentReportingOfVariants=slfeature('SlCovConsistentReportingOfVariants');
        FC.status=~(dig.isProductInstalled('Simulink Coverage'))*3;
    case 'Sldv.ConfigComp'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.DVCodeAwareParameterTuning=slfeature('DVCodeAwareParameterTuning');
        FC.feature.ExportTestcasesInSLTest=slfeature('ExportTestcasesInSLTest');
        FC.feature.ExportTestcasesInSLTestUseSB=slfeature('ExportTestcasesInSLTestUseSB');
        FC.feature.SLDVCombinedDLRTE=slfeature('SLDVCombinedDLRTE');
        FC.feature.SLDVCombinedDLRTEAndDSMChecks=slfeature('SLDVCombinedDLRTEAndDSMChecks');
        FC.feature.SLDVUserFilterForDED=slfeature('SLDVUserFilterForDED');
        FC.feature.SldvCombinedDlRteAndBlockInputBoundaryViolations=slfeature('SldvCombinedDlRteAndBlockInputBoundaryViolations');
        FC.feature.SldvDeprecateDisplayUnsatisfiableObjectives=slfeature('SldvDeprecateDisplayUnsatisfiableObjectives');
        FC.feature.SldvForceActiveLogicOn=slfeature('SldvForceActiveLogicOn');
        FC.feature.SldvMcdcInDeadLogic=slfeature('SldvMcdcInDeadLogic');
        FC.feature.SldvValidateActiveLogic=slfeature('SldvValidateActiveLogic');
        FC.license.MATLAB_Report_Gen=dig.isProductInstalled('MATLAB Report Generator');
        FC.status=~(dig.isProductInstalled('Simulink Design Verifier'))*3;
    case 'hdlcoderui.hdlcc'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.feature.StreamingMatrixWorkflow=slfeature('StreamingMatrixWorkflow');
        FC.license.Simulink_Requirements=dig.isProductInstalled('Requirements Toolbox');
        FC.status=configset.internal.custom.HDL_status(cs);
    case 'pslink.ConfigComp'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'simmechanics.ConfigurationSet'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'simmechanics.DiagnosticsConfigSet'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'simmechanics.ExplorerConfigSet'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'CoderTarget.SettingsController'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'MECH.SimMechanicsCC'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'RealTime.SettingsController'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    case 'pjtgeneratorpkg.TargetHardwareResources'
        FC=struct('feature',[],'license',[],'status',[]);
        FC.status=0;
    otherwise
        FC=[];
    end