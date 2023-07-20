function objective=objective_efficiency_speed(~)









    file.filename='objective_efficiency_speed.m';
    file.objectivename='Execution efficiency';
    file.order='1';

    paramsTable={

    'SupportNonInlinedSFcns','off',''
    'SuppressErrorStatus','on',''
    'MatFileLogging','off','grt'
    'GRTInterface','off','grt'
    'SupportContinuousTime','off',''
    'SupportNonFinite','off','grt'
    'CombineOutputUpdateFcns','on','grt'
    'OptimizeBlockIOStorage','on','grt'
    'ConditionallyExecuteInputs','on','grt'
    'DefaultParameterBehavior','Inlined','grt'
    'BooleanDataType','on','grt'
    'BlockReduction','on','grt'
    'ExpressionFolding','on','grt'
    'InlinedPrmAccess','Literals',''
    'LocalBlockOutputs','on','grt'
    'EfficientFloat2IntCast','on','grt'
    'InlineInvariantSignals','on','grt'
    'ZeroExternalMemoryAtStartup','off',''
    'ZeroInternalMemoryAtStartup','off',''
    'InitFltsAndDblsToZero','off','grt'
    'OptimizeModelRefInitCode','on',''
    'DataBitsets','off','grt'
    'StateBitsets','off','grt'
    'ConvertIfToSwitch','on',''
    'BooleansAsBitfields','off',''
    'BufferReuse','on','grt'
    'GlobalBufferReuse','on',''
    'PassReuseOutputArgsAs','Individual arguments',''
    'CombineSignalStateStructs','on',''
    'UseSpecifiedMinMax','on',''
    'UseFloatMulNetSlope','on','grt'
    'EnableMemcpy','on','grt'
    'CodeExecutionProfiling','off',''
    'CodeProfilingInstrumentation','off',''
    'SuppressUnreachableDefaultCases','on',''
    'BuildConfiguration','Faster Runs','grt'
    'GlobalVariableUsage','None',''
    'NoFixptDivByZeroProtection','on',''
    'ProdLongLongMode','on',''
    'BusAssignmentInplaceUpdate','on',''
    'OptimizeBlockOrder','speed',''
    'OptimizeDataStoreBuffers','on',''
    'MATLABDynamicMemAlloc','off',''
    'RateTransitionBlockCode','Inline',''
    'UseRowMajorAlgorithm','off','grt'
    'GainParamInheritBuiltInType','on','grt'
    'EfficientTunableParamExpr','on',''
    'EfficientMapNaN2IntZero','on',''
    'InheritOutputTypeSmallerThanSingle','off','grt'
    'PreserveIfCondition','off',''
    };
    params=cell2struct(paramsTable,{'name','setting','target'},2);


    check={
'mathworks.codegen.CodeGenSanity'
'mathworks.design.OptBusVirtuality'
'mathworks.codegen.QuestionableBlks'
'mathworks.codegen.HWImplementation'
'mathworks.codegen.SWEnvironmentSpec'
'mathworks.codegen.CodeInstrumentation'
'mathworks.codegen.ExpensiveSaturationRoundingCode'
'mathworks.codegen.QuestionableFxptOperations'
'mathworks.codegen.EnableLongLong'
'mathworks.codegen.cgsl_0101'
'mathworks.codegen.LUTRangeCheckCode'
'mathworks.codegen.LogicBlockUseNonBooleanOutput'
'mathworks.codegen.BlockSpecificQuestionableFxptOperations'
    };







    allChecks=coder.advisor.internal.CGOFixedCheck;
    value=double(ismember(allChecks.checkID,check));

    checklist=struct('id',num2cell(1:length(value)),'value',num2cell(value));


    objective.params=arrayfun(@(x)x,transpose(params),'UniformOutput',false);
    objective.checklist=arrayfun(@(x)x,checklist,'UniformOutput',false);
    objective.len=length(params);
    objective.checklen=length(checklist);
    objective.file=file;
    objective.error=0;

end


