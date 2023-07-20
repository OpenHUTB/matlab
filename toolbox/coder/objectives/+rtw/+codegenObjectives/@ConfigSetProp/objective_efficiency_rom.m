function objective=objective_efficiency_rom(~)







    file.filename='objective_efficiency_rom.m';
    file.objectivename='ROM efficiency';
    file.order='2';

    paramsTable={

    'SupportNonInlinedSFcns','off',''
    'SuppressErrorStatus','on',''
    'MatFileLogging','off',''
    'GRTInterface','off',''
    'SupportContinuousTime','off',''
    'SupportNonFinite','off',''
    'UtilityFuncGeneration','Shared location',''
    'EnhancedBackFolding','on',''
    'CombineOutputUpdateFcns','on',''
    'OptimizeBlockIOStorage','on',''
    'DefaultParameterBehavior','Inlined',''
    'BooleanDataType','on',''
    'BlockReduction','on',''
    'ExpressionFolding','on',''
    'BitwiseOrLogicalOp','Bitwise operator',''
    'InlinedPrmAccess','Literals',''
    'LocalBlockOutputs','on',''
    'EfficientFloat2IntCast','on',''
    'InlineInvariantSignals','on',''
    'ZeroExternalMemoryAtStartup','off',''
    'ZeroInternalMemoryAtStartup','off',''
    'InitFltsAndDblsToZero','off',''
    'OptimizeModelRefInitCode','on',''
    'PassReuseOutputArgsAs','Structure reference',''
    'DataBitsets','off',''
    'StateBitsets','off',''
    'ConvertIfToSwitch','on',''
    'BooleansAsBitfields','off',''
    'BufferReuse','on',''
    'CombineSignalStateStructs','on',''
    'UseSpecifiedMinMax','on',''
    'EnableMemcpy','on',''
    'CodeExecutionProfiling','off',''
    'CodeProfilingInstrumentation','off',''
    'SuppressUnreachableDefaultCases','on',''
    'GlobalVariableUsage','Minimize global data access',''
    'BusAssignmentInplaceUpdate','on',''
    'OptimizeDataStoreBuffers','on',''
    'NoFixptDivByZeroProtection','on',''
    'ProdLongLongMode','on',''
    'DifferentSizesBufferReuse','on',''
    'RateTransitionBlockCode','Inline',''
    'GainParamInheritBuiltInType','on',''
    'EfficientTunableParamExpr','on',''
    'EfficientMapNaN2IntZero','on',''
    'InheritOutputTypeSmallerThanSingle','on',''
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
'mathworks.codegen.QuestionableSubsysSetting'
'mathworks.codegen.ExpensiveSaturationRoundingCode'
'mathworks.codegen.QuestionableFxptOperations'
'mathworks.codegen.EnableLongLong'
'mathworks.codegen.cgsl_0101'
'mathworks.codegen.LUTRangeCheckCode'
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


