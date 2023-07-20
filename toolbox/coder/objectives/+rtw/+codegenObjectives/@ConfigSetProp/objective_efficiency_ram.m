function objective=objective_efficiency_ram(~)






    file.filename='objective_efficiency_ram.m';
    file.objectivename='RAM efficiency';
    file.order='3';

    paramsTable={

    'SupportNonInlinedSFcns','off',''
    'SuppressErrorStatus','on',''
    'MatFileLogging','off',''
    'EnhancedBackFolding','on',''
    'CombineOutputUpdateFcns','on',''
    'OptimizeBlockIOStorage','on',''
    'ConditionallyExecuteInputs','on',''
    'DefaultParameterBehavior','Inlined',''
    'BooleanDataType','on',''
    'BlockReduction','on',''
    'ExpressionFolding','on',''
    'InlinedPrmAccess','Literals',''
    'LocalBlockOutputs','on',''
    'InlineInvariantSignals','on',''
    'BufferReuse','on',''
    'PassReuseOutputArgsAs','Individual arguments',''
    'DataBitsets','on',''
    'StateBitsets','on',''
    'BooleansAsBitfields','on',''
    'CombineSignalStateStructs','on',''
    'UseSpecifiedMinMax','on',''
    'GlobalBufferReuse','on',''
    'GlobalVariableUsage','Use global to hold temporary results',''
    'BusAssignmentInplaceUpdate','on',''
    'OptimizeDataStoreBuffers','on',''
    'DifferentSizesBufferReuse','on',''
    'UseRowMajorAlgorithm','off',''
    'GainParamInheritBuiltInType','on',''
    'InheritOutputTypeSmallerThanSingle','off',''
    };
    params=cell2struct(paramsTable,{'name','setting','target'},2);


    check={
'mathworks.codegen.CodeGenSanity'
'mathworks.design.OptBusVirtuality'
'mathworks.codegen.QuestionableBlks'
'mathworks.codegen.CodeInstrumentation'
'mathworks.codegen.QuestionableSubsysSetting'
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


