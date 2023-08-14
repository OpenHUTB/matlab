



function result=CGOFixedCheck()

    persistent checkID;

    if isempty(checkID)
        checkID{1}='mathworks.codegen.CodeGenSanity';
        checkID{2}='mathworks.design.UnconnectedLinesPorts';
        checkID{3}='mathworks.design.RootInportSpec';
        checkID{4}='mathworks.design.ImplicitSignalResolution';
        checkID{5}='mathworks.design.OptBusVirtuality';
        checkID{6}='mathworks.design.DiscreteTimeIntegratorInitCondition';
        checkID{7}='mathworks.design.DisabledLibLinks';
        checkID{8}='mathworks.design.ParameterizedLibLinks';
        checkID{9}='mathworks.design.DataStoreMemoryBlkIssue';
        checkID{10}='mathworks.design.OutputSignalSampleTime';
        checkID{11}='mathworks.design.MergeBlkUsage';
        checkID{12}='mathworks.design.InitParamOutportMergeBlk';
        checkID{13}='mathworks.codegen.SolverCodeGen';
        checkID{14}='mathworks.codegen.QuestionableBlks';
        checkID{15}='mathworks.codegen.HWImplementation';
        checkID{16}='mathworks.codegen.SWEnvironmentSpec';
        checkID{17}='mathworks.codegen.CodeInstrumentation';
        checkID{18}='mathworks.codegen.ConstraintsTunableParam';
        checkID{19}='mathworks.codegen.QuestionableSubsysSetting';
        checkID{20}='mathworks.codegen.ExpensiveSaturationRoundingCode';
        checkID{21}='mathworks.codegen.SampleTimesTaskingMode';
        checkID{22}='mathworks.codegen.QuestionableFxptOperations';
        checkID{23}='mathworks.codegen.cgsl_0101';
        checkID{24}='mathworks.misra.BlkSupport';
        checkID{25}='mathworks.codegen.LUTRangeCheckCode';
        checkID{26}='mathworks.codegen.LogicBlockUseNonBooleanOutput';
        checkID{27}='mathworks.design.DiagnosticDataStoreBlk';
        checkID{28}='mathworks.design.MismatchedBusParams';
        checkID{29}='mathworks.design.DataStoreBlkSampleTime';
        checkID{30}='mathworks.design.OrderingDataStoreAccess';
        checkID{31}='mathworks.codegen.BlockSpecificQuestionableFxptOperations';
        checkID{32}='mathworks.codegen.PCGSupport';
        checkID{33}='mathworks.misra.BlockNames';
        checkID{34}='mathworks.misra.AssignmentBlocks';
        checkID{35}='mathworks.misra.CompliantCGIRConstructions';
        checkID{36}='mathworks.misra.RecursionCompliance';
        checkID{37}='mathworks.misra.CompareFloatEquality';
        checkID{38}='mathworks.misra.SwitchDefault';
        checkID{39}='mathworks.misra.ModelFunctionInterface';
        checkID{40}='mathworks.misra.IntegerWordLengths';
        checkID{41}='mathworks.misra.AutosarReceiverInterface';
        checkID{42}='mathworks.misra.BusElementNames';
        checkID{43}='mathworks.codegen.EnableLongLong';
    end

    checkHash=coder.advisor.internal.HashMap();

    for i=1:length(checkID)
        checkHash.put(checkID{i},i);
    end

    result.checkID=checkID;
    result.checkHash=checkHash;

    return;
end


