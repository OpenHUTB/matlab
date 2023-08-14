function defineSLCIModelAdvisorTasks







    if~ismac()
        mdladvRoot=ModelAdvisor.Root;
        rec=ModelAdvisor.FactoryGroup('com.slci.SLCIGroup');
        rec.DisplayName=DAStudio.message('Slci:compatibility:MASLCITaskGroupName');
        rec.Description='Simulink compatibility checks';
        rec.addCheck('mathworks.slci.SDPWorkflow');
        rec.addCheck('mathworks.slci.CodeGenerationSettings');
        rec.addCheck('mathworks.slci.DataImportSettings');
        rec.addCheck('mathworks.slci.DiagnosticsSettings');
        rec.addCheck('mathworks.slci.HardwareImplementationSettings');
        rec.addCheck('mathworks.slci.MathandDataTypesSettings');
        rec.addCheck('mathworks.slci.SolverSettings');
        rec.addCheck('mathworks.slci.UnconnectedObjects');
        rec.addCheck('mathworks.slci.SystemTargetFileSettings');
        rec.addCheck('mathworks.slci.FcnSpecSettings');
        rec.addCheck('mathworks.slci.MinMaxLogging');
        rec.addCheck('mathworks.slci.UnsupportedBlocks');
        rec.addCheck('mathworks.slci.WorkspaceVarUsage');
        rec.addCheck('mathworks.slci.GetSetVarUsage');
        rec.addCheck('mathworks.slci.SampleTimesUsage');
        rec.addCheck('mathworks.slci.SourcesBlocksUsage');
        rec.addCheck('mathworks.slci.SignalRoutingBlocksUsage');
        rec.addCheck('mathworks.slci.MathOperationsBlocksUsage');
        rec.addCheck('mathworks.slci.SignalAttributesBlocksUsage');
        rec.addCheck('mathworks.slci.LogicalandBitOperationsBlocksUsage');
        rec.addCheck('mathworks.slci.LookupTablesBlocksUsage');
        rec.addCheck('mathworks.slci.UserDefinedFunctionBlocksUsage');
        rec.addCheck('mathworks.slci.PortsandSubsystemsBlocksUsage');
        rec.addCheck('mathworks.slci.DiscontinuitiesBlocksUsage');
        rec.addCheck('mathworks.slci.SinksBlocksUsage');
        rec.addCheck('mathworks.slci.DiscreteBlocksUsage');
        rec.addCheck('mathworks.slci.RootOutportBlocksUsage');
        rec.addCheck('mathworks.slci.HiddenBufferBlock');
        rec.addCheck('mathworks.slci.BusUsage');
        rec.addCheck('mathworks.slci.SynthLocalDSM');
        rec.addCheck('mathworks.slci.GlobalDSM');
        rec.addCheck('mathworks.slci.GlobalDSMShadow');
        rec.addCheck('mathworks.slci.ConditionallyExecuteInputs');
        rec.addCheck('mathworks.slci.StateflowBlocksUsage');
        rec.addCheck('mathworks.slci.StateflowMachineData');
        rec.addCheck('mathworks.slci.StateflowMachineEvents');
        rec.addCheck('mathworks.slci.chartsSFObjsUsage');
        rec.addCheck('mathworks.slci.dataSFObjsUsage');
        rec.addCheck('mathworks.slci.eventsSFObjsUsage');
        rec.addCheck('mathworks.slci.statesSFObjsUsage');
        rec.addCheck('mathworks.slci.junctionsSFObjsUsage');
        rec.addCheck('mathworks.slci.transitionsSFObjsUsage');
        rec.addCheck('mathworks.slci.graphicalfunctionsSFObjsUsage');
        rec.addCheck('mathworks.slci.truthtablesSFObjsUsage');
        rec.addCheck('mathworks.slci.RollThreshold');
        rec.addCheck('mathworks.slci.SeparateOutputAndUpdate');
        rec.addCheck('mathworks.slci.PassReuseOutputArgsAs');
        rec.addCheck('mathworks.slci.OutportTerminator');
        rec.addCheck('mathworks.slci.FirstInitICPropagation');
        rec.addCheck('mathworks.slci.DataTypeReplacementName');
        rec.addCheck('mathworks.slci.MATLABFunctionBlocksUsage');
        rec.addCheck('mathworks.slci.MATLABFunctionDataUsage');
        rec.addCheck('mathworks.slci.MATLABFunctionCodeUsage');
        rec.addCheck('mathworks.slci.MATLABCodeAnalyzer');
        rec.addCheck('mathworks.slci.RefModelMultirate');
        rec.addCheck('mathworks.slci.EnableMultiTasking');
        rec.addCheck('mathworks.slci.CommentedBlocks');
        rec.addCheck('mathworks.slci.VVSubSystemName');
        rec.addCheck('mathworks.slci.LookupndBreakpointsDataType');
        rec.addCheck('mathworks.slci.ReuseSubSystemLibrary');
        rec.addCheck('mathworks.slci.SharedSynthLocalDSM');
        rec.addCheck('mathworks.slci.CodeGenFolderStructure');
        rec.addCheck('mathworks.slci.CodeMappingDefaults');
        rec.addCheck('mathworks.slci.BlockSortedOrder');
        rec.addCheck('mathworks.slci.StringBlocksUsage');
        rec.addCheck('mathworks.slci.SharedUtilsUsage');
        rec.addCheck('mathworks.slci.StructureStorageClass');
        rec.addCheck('mathworks.slci.MATLABactionlanguageSFObjsUsage');
        rec.addCheck('mathworks.slci.SampleERTMain');


        mdladvRoot.publish(rec);
    end
