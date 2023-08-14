function objective=objective_traceability(~)



    file.filename='objective_traceability';
    file.objectivename='Traceability';
    file.order='4';

    paramsTable={

    'ConditionallyExecuteInputs','on',''
    'BlockReduction','off',''
    'GenerateTraceReport','on',''
    'SimulinkDataObjDesc','on',''
    'InsertBlockDesc','on',''
    'ForceParamTrailComments','on',''
    'GenerateTraceReportEml','on',''
    'GenerateTraceInfo','on',''
    'IncludeHyperlinkInReport','on',''
    'LaunchReport','on',''
    'GenerateReport','on',''
    'SimulinkBlockComments','on',''
    'StateflowObjectComments','on',''
    'MangleLength','1',''
    'ExpressionFolding','off',''
    'SFDataObjDesc','on',''
    'ReqsInCode','on',''
    'InlinedPrmAccess','Macros',''
    'GenerateComments','on',''
    'InlineInvariantSignals','off',''
    'ShowEliminatedStatement','on',''
    'OperatorAnnotations','on',''
    'IncludeHyperlinkInReport','on',''
    'GenerateTraceInfo','on',''
    'IncludeHyperlinkInReport','on',''
    'GenerateTraceReportSl','on',''
    'GenerateTraceReportSf','on',''
    'GenerateTraceReportEml','on',''
    'ConvertIfToSwitch','off',''
    'UseSpecifiedMinMax','off',''
    'MATLABFcnDesc','on',''
    'MATLABSourceComments','on',''
    'MergeDetectMultiDrivingBlocksExec','error',''
    'SuppressUnreachableDefaultCases','on',''
    'EnableCustomComments','on',''
    'RateTransitionBlockCode','Function',''
    'PreserveIfCondition','on',''
    'ReuseModelBlockBuffer','off',''
    };
    params=cell2struct(paramsTable,{'name','setting','target'},2);


    check={
'mathworks.codegen.CodeGenSanity'
    };

    checkToExclude={
'mathworks.codegen.SWEnvironmentSpec'
'mathworks.codegen.CodeInstrumentation'
    };
    allChecks=coder.advisor.internal.CGOFixedCheck;
    value=double(ismember(allChecks.checkID,check));
    value(ismember(allChecks.checkID,checkToExclude))=-1;
    checklist=struct('id',num2cell(1:length(value)),'value',num2cell(value));

    objective.params=arrayfun(@(x)x,transpose(params),'UniformOutput',false);
    objective.checklist=arrayfun(@(x)x,checklist,'UniformOutput',false);
    objective.len=length(params);
    objective.checklen=length(checklist);
    objective.file=file;
    objective.error=0;

end
