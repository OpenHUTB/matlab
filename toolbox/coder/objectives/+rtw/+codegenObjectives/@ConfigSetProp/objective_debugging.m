function objective=objective_debugging(~)







    file.filename='objective_debugging.m';
    file.objectivename='Debugging';
    file.order='6';

    paramsTable={
    'SuppressErrorStatus','off',''
    'MultiInstanceErrorCode','Warning','grt'
    'MatFileLogging','on','grt'
    'OptimizeBlockIOStorage','off','grt'
    'ReuseModelBlockBuffer','off',''
    'EfficientFloat2IntCast','off','grt'
    'InlineInvariantSignals','off','grt'
    'UseSpecifiedMinMax','off',''
    'CreateSILPILBlock','None',''
    'GenerateComments','on','grt'
    'MATLABFcnDesc','on',''
    'MATLABSourceComments','on','grt'
    'SimulinkBlockComments','on','grt'
    'EnableCustomComments','on',''
    'ForceParamTrailComments','on','grt'
    'ReqsInCode','on',''
    'ShowEliminatedStatement','on','grt'
    'InsertBlockDesc','on',''
    'SimulinkDataObjDesc','on',''
    'SFDataObjDesc','on',''
    'SFInvalidInputDataAccessInChartInitDiag','warning','grt'
    'SFNoUnconditionalDefaultTransitionDiag','warning','grt'
    'SFTransitionOutsideNaturalParentDiag','warning','grt'
    'SFUnexpectedBacktrackingDiag','warning','grt'
    'SFUnusedDataAndEventsDiag','warning','grt'
    'MergeDetectMultiDrivingBlocksExec','error','grt'
    'SFUnreachableExecutionPathDiag','warning','grt'
    'SFTransitionActionBeforeConditionDiag','warning','grt'
    'SFUndirectedBroadcastEventsDiag','warning','grt'
    'BuildConfiguration','Debug','grt'
    'BusAssignmentInplaceUpdate','off',''
    'OptimizeBlockOrder','off',''
    'OptimizeDataStoreBuffers','off',''
    'DifferentSizesBufferReuse','off',''
    'PreserveIfCondition','on',''
    };
    params=cell2struct(paramsTable,{'name','setting','target'},2);


    check={
'mathworks.codegen.CodeGenSanity'
    };

    checkToExclude={
'mathworks.codegen.CodeInstrumentation'
'mathworks.codegen.ExpensiveSaturationRoundingCode'
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


