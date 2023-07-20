function taskCellArray=defineModelAdvisorTasks











































    taskCellArray={};
    mdladvRoot=ModelAdvisor.Root;


    task=Simulink.MdlAdvisorTask;
    task.TitleID='Model Referencing';
    task.Title=DAStudio.message('Simulink:tools:MAMdlRefTaskTitle');
    task.TitleTips=DAStudio.message('Simulink:tools:MAMdlRefTaskTitleTips');
    task.CheckTitleIDs={...
    'mathworks.codegen.MdlrefConfigMismatch',...
    'mathworks.design.ModelRefSIMConfigCompliance',...
    'mathworks.codegen.ModelRefRTWConfigCompliance',...
    'mathworks.design.ParamTunabilityIgnored',...
    'mathworks.design.ImplicitSignalResolution',...
    'mathworks.design.BusTreatedAsVector',...
    'mathworks.design.RootInportSpec',...
    'mathworks.design.CheckVirtualBusAcrossModelReferenceArgs',...
    };
    taskCellArray{end+1}=task;


    task=Simulink.MdlAdvisorTask;
    task.TitleID='Managing Library Links and Variants';
    task.Title=DAStudio.message('Simulink:tools:MALibLinksTaskTitle');
    task.TitleTips=DAStudio.message('Simulink:tools:MALibLinksTaskTitleTips');
    task.CheckTitleIDs={...
    'mathworks.design.DisabledLibLinks',...
    'mathworks.design.ParameterizedLibLinks',...
    'mathworks.design.UnresolvedLibLinks',...
    'mathworks.design.CSStoVSSConvert',...
    };

    taskCellArray{end+1}=task;


    task=Simulink.MdlAdvisorTask;
    task.TitleID='Data Transfer Efficiency';
    task.Title=DAStudio.message('Simulink:tools:MADataTransferTaskTitle');
    task.TitleTips=DAStudio.message('Simulink:tools:MADataTransferTaskTitleTips');
    task.CheckTitleIDs={...
    'mathworks.design.ReplaceZOHDelayByRTB',...
    };

    taskCellArray{end+1}=task;



    rec=ModelAdvisor.FactoryGroup('ModelingUsingBuses');
    rec.DisplayName=DAStudio.message('ModelAdvisor:engine:ModelingUsingBuses');
    rec.Description=DAStudio.message('ModelAdvisor:engine:ModelingUsingBuses');
    rec.addCheck('mathworks.design.OptBusVirtuality');
    rec.addCheck('mathworks.design.MismatchedBusParams');
    rec.addCheck('mathworks.design.BusTreatedAsVector');
    mdladvRoot.publish(rec);

    rec1=ModelAdvisor.FactoryGroup('Code_generation_efficiency');
    rec1.DisplayName=DAStudio.message('ModelAdvisor:engine:CodeGenEfficiency');
    rec1.Description=DAStudio.message('ModelAdvisor:engine:CodeGenEfficiency');
    rec1.addCheck('mathworks.design.OptimizationSettings');
    rec1.addCheck('mathworks.codegen.cgsl_0101');
    rec1.addCheck('mathworks.codegen.SWEnvironmentSpec');
    rec1.addCheck('mathworks.codegen.LUTRangeCheckCode');
    rec1.addCheck('mathworks.codegen.CodeInstrumentation');
    rec1.addCheck('mathworks.codegen.LogicBlockUseNonBooleanOutput');
    rec1.addCheck('mathworks.codegen.EfficientTunableParamExpr');
    rec1.addCheck('mathworks.codegen.ExpensiveSaturationRoundingCode');
    rec1.addCheck('mathworks.codegen.QuestionableFxptOperations');
    rec1.addCheck('mathworks.codegen.EnableLongLong');
    if slfeature('UseCGIRAdvisorChecks')
        rec1.addCheck('mathworks.codegen.BlockSpecificQuestionableFxptOperations');
    end
    rec1.addCheck('mathworks.codegen.UseRowMajorAlgorithm');
    mdladvRoot.publish(rec1);

    rec=ModelAdvisor.FactoryGroup('ModelingSinglePrecision');
    rec.DisplayName=DAStudio.message('ModelAdvisor:engine:ModelingSinglePrecision');
    rec.Description=DAStudio.message('ModelAdvisor:engine:ModelingSinglePrecision');
    rec.addCheck('mathworks.design.StowawayDoubles');
    mdladvRoot.publish(rec);


    rec=ModelAdvisor.FactoryGroup('SimplifiedInit');
    rec.DisplayName=DAStudio.message('Simulink:tools:MATitleMigrateToSimplifiedMode');
    rec.Description=DAStudio.message('Simulink:tools:MATitletipMigrateToSimplifiedMode');
    rec.addCheck('mathworks.design.MergeBlkUsage');
    rec.addCheck('mathworks.design.InitParamOutportMergeBlk');
    rec.addCheck('mathworks.design.DiscreteBlock');
    rec.addCheck('mathworks.design.ModelLevelMessages');
    mdladvRoot.publish(rec);

    rec=ModelAdvisor.FactoryGroup('RowMajor');
    rec.DisplayName=DAStudio.message('ModelAdvisor:engine:RowMajor');
    rec.Description=DAStudio.message('ModelAdvisor:engine:RowMajorDescription');
    rec.addCheck('mathworks.codegen.UseRowMajorAlgorithm');
    rec.addCheck('mathworks.codegen.RowMajorCodeGenSupport');
    rec.addCheck('mathworks.codegen.RowMajorUnsetSFunction');
    mdladvRoot.publish(rec);


end




