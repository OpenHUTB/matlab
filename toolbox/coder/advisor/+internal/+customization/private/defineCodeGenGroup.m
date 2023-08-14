function nodes=defineCodeGenGroup
    nodes={};

    TAN=CodeGenAdvisor.Group('com.mathworks.cgo.group');





    TAN.DisplayName=DAStudio.message('RTW:configSet:CGAName');
    TAN.Description=DAStudio.message('Simulink:tools:CodeGenObjectiveCheckGroupDescr');

    TAN.CSHParameters.MapKey='ma.rtw';
    TAN.CSHParameters.TopicID='com.mathworks.cgo.group';
    TAN.Children{end+1}='com.mathworks.cgo.1';
    TAN.Children{end+1}='com.mathworks.cgo.2';
    TAN.Children{end+1}='com.mathworks.cgo.3';
    TAN.Children{end+1}='com.mathworks.cgo.4';
    TAN.Children{end+1}='com.mathworks.cgo.5';
    TAN.Children{end+1}='com.mathworks.cgo.6';
    TAN.Children{end+1}='com.mathworks.cgo.7';
    TAN.Children{end+1}='com.mathworks.cgo.8';
    TAN.Children{end+1}='com.mathworks.cgo.9';
    TAN.Children{end+1}='com.mathworks.cgo.10';
    TAN.Children{end+1}='com.mathworks.cgo.11';
    TAN.Children{end+1}='com.mathworks.cgo.12';
    TAN.Children{end+1}='com.mathworks.cgo.13';
    TAN.Children{end+1}='com.mathworks.cgo.14';
    TAN.Children{end+1}='com.mathworks.cgo.15';
    TAN.Children{end+1}='com.mathworks.cgo.16';
    TAN.Children{end+1}='com.mathworks.cgo.17';
    TAN.Children{end+1}='com.mathworks.cgo.18';
    TAN.Children{end+1}='com.mathworks.cgo.19';
    TAN.Children{end+1}='com.mathworks.cgo.20';
    TAN.Children{end+1}='com.mathworks.cgo.21';

    if license('test','Fixed_Point_Toolbox')
        TAN.Children{end+1}='com.mathworks.cgo.22';

        if slfeature('UseCGIRAdvisorChecks')
            TAN.Children{end+1}='com.mathworks.cgo.31';
        end
    end

    TAN.Children{end+1}='com.mathworks.cgo.23';

    if exist(fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','misra'),'dir')>0
        TAN.Children{end+1}='com.mathworks.cgo.24';
        TAN.Children{end+1}='com.mathworks.cgo.33';
        TAN.Children{end+1}='com.mathworks.cgo.34';
        TAN.Children{end+1}='com.mathworks.cgo.35';
        TAN.Children{end+1}='com.mathworks.cgo.36';
        TAN.Children{end+1}='com.mathworks.cgo.37';
        TAN.Children{end+1}='com.mathworks.cgo.38';
        TAN.Children{end+1}='com.mathworks.cgo.39';
        TAN.Children{end+1}='com.mathworks.cgo.40';
        TAN.Children{end+1}='com.mathworks.cgo.41';
        TAN.Children{end+1}='com.mathworks.cgo.42';
    end

    TAN.Children{end+1}='com.mathworks.cgo.25';
    TAN.Children{end+1}='com.mathworks.cgo.26';
    TAN.Children{end+1}='com.mathworks.cgo.27';
    TAN.Children{end+1}='com.mathworks.cgo.28';
    TAN.Children{end+1}='com.mathworks.cgo.29';
    TAN.Children{end+1}='com.mathworks.cgo.30';

    TAN.Children{end+1}='com.mathworks.cgo.32';



    TAN.Children{end+1}='com.mathworks.cgo.43';

    if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
        fixedChkLen=length(TAN.Children);

        cm=DAStudio.CustomizationManager;
        addChkLen=length(cm.ObjectiveCustomizer.additionalCheck);

        for i=1:addChkLen
            TAN.Children{end+1}=['com.mathworks.cgo.',num2str(fixedChkLen+i)];
        end
    end

    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.1');
    TAN.MAC='mathworks.codegen.CodeGenSanity';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.2');
    TAN.MAC='mathworks.design.UnconnectedLinesPorts';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.3');
    TAN.MAC='mathworks.design.RootInportSpec';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.4');
    TAN.MAC='mathworks.design.ImplicitSignalResolution';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.5');
    TAN.MAC='mathworks.design.OptBusVirtuality';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.6');
    TAN.MAC='mathworks.design.DiscreteTimeIntegratorInitCondition';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.7');
    TAN.MAC='mathworks.design.DisabledLibLinks';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.8');
    TAN.MAC='mathworks.design.ParameterizedLibLinks';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.9');
    TAN.MAC='mathworks.design.DataStoreMemoryBlkIssue';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.10');
    TAN.MAC='mathworks.design.OutputSignalSampleTime';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.11');
    TAN.MAC='mathworks.design.MergeBlkUsage';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.12');
    TAN.MAC='mathworks.design.InitParamOutportMergeBlk';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.13');
    TAN.MAC='mathworks.codegen.SolverCodeGen';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.14');
    TAN.MAC='mathworks.codegen.QuestionableBlks';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.15');
    TAN.MAC='mathworks.codegen.HWImplementation';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.16');
    TAN.MAC='mathworks.codegen.SWEnvironmentSpec';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.17');
    TAN.MAC='mathworks.codegen.CodeInstrumentation';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.18');
    TAN.MAC='mathworks.codegen.ConstraintsTunableParam';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.19');
    TAN.MAC='mathworks.codegen.QuestionableSubsysSetting';
    nodes{end+1}=TAN;


    TAN=ModelAdvisor.Task('com.mathworks.cgo.20');
    TAN.MAC='mathworks.codegen.ExpensiveSaturationRoundingCode';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.21');
    TAN.MAC='mathworks.codegen.SampleTimesTaskingMode';
    nodes{end+1}=TAN;

    if license('test','Fixed_Point_Toolbox')

        TAN=ModelAdvisor.Task('com.mathworks.cgo.22');
        TAN.MAC='mathworks.codegen.QuestionableFxptOperations';
        nodes{end+1}=TAN;

        if slfeature('UseCGIRAdvisorChecks')

            TAN=ModelAdvisor.Task('com.mathworks.cgo.31');
            TAN.MAC=('mathworks.codegen.BlockSpecificQuestionableFxptOperations');
            nodes{end+1}=TAN;
        end

    end

    TAN=ModelAdvisor.Task('com.mathworks.cgo.23');
    TAN.MAC='mathworks.codegen.cgsl_0101';
    nodes{end+1}=TAN;

    if exist(fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','misra'),'dir')>0
        TAN=ModelAdvisor.Task('com.mathworks.cgo.24');
        TAN.MAC='mathworks.misra.BlkSupport';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.33');
        TAN.MAC='mathworks.misra.BlockNames';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.34');
        TAN.MAC='mathworks.misra.AssignmentBlocks';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.35');
        TAN.MAC='mathworks.misra.CompliantCGIRConstructions';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.36');
        TAN.MAC='mathworks.misra.RecursionCompliance';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.37');
        TAN.MAC='mathworks.misra.CompareFloatEquality';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.38');
        TAN.MAC='mathworks.misra.SwitchDefault';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.39');
        TAN.MAC='mathworks.misra.ModelFunctionInterface';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.40');
        TAN.MAC='mathworks.misra.IntegerWordLengths';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.41');
        TAN.MAC='mathworks.misra.AutosarReceiverInterface';
        nodes{end+1}=TAN;

        TAN=ModelAdvisor.Task('com.mathworks.cgo.42');
        TAN.MAC='mathworks.misra.BusElementNames';
        nodes{end+1}=TAN;

    end

    TAN=ModelAdvisor.Task('com.mathworks.cgo.25');
    TAN.MAC='mathworks.codegen.LUTRangeCheckCode';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.26');
    TAN.MAC='mathworks.codegen.LogicBlockUseNonBooleanOutput';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.27');
    TAN.MAC='mathworks.design.DiagnosticDataStoreBlk';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.28');
    TAN.MAC='mathworks.design.MismatchedBusParams';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.29');
    TAN.MAC='mathworks.design.DataStoreBlkSampleTime';
    nodes{end+1}=TAN;

    TAN=ModelAdvisor.Task('com.mathworks.cgo.30');
    TAN.MAC='mathworks.design.OrderingDataStoreAccess';
    nodes{end+1}=TAN;



    TAN=ModelAdvisor.Task('com.mathworks.cgo.32');
    TAN.MAC='mathworks.codegen.PCGSupport';
    nodes{end+1}=TAN;



    TAN=ModelAdvisor.Task('com.mathworks.cgo.43');

    TAN.MAC='mathworks.codegen.EnableLongLong';
    nodes{end+1}=TAN;


    if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
        for i=1:addChkLen
            TAN=ModelAdvisor.Task(['com.mathworks.cgo.',num2str(fixedChkLen+i)]);
            TAN.MAC=cm.ObjectiveCustomizer.additionalCheck{i};
            nodes{end+1}=TAN;
        end
    end


