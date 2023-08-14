function objective=objective_safetyprecaution(~)



    file.filename='objective_safetyprecaution';
    file.objectivename='Safety precaution';
    file.order='5';

    paramsTable={

    'MatFileLogging','off',''
    'LifeSpan','inf',''
    'BooleanDataType','on',''
    'MultiTaskDSMMsg','error',''
    'MultiTaskCondExecSysMsg','error',''
    'IntegerOverflowMsg','error',''
    'IntegerSaturationMsg','error',''
    'MultiTaskRateTransMsg','error',''
    'WriteAfterReadMsg','EnableAllAsError',''
    'WriteAfterWriteMsg','EnableAllAsError',''
    'ReadBeforeWriteMsg','EnableAllAsError',''
    'NonBusSignalsTreatedAsBus','error',''
    'BusNameAdapt','WarnAndRepair',''
    'SFInvalidInputDataAccessInChartInitDiag','error',''
    'SFNoUnconditionalDefaultTransitionDiag','error',''
    'SFTransitionOutsideNaturalParentDiag','error',''
    'SFUnexpectedBacktrackingDiag','error',''
    'SFUnusedDataAndEventsDiag','warning',''
    'MergeDetectMultiDrivingBlocksExec','error',''
    'UnderspecifiedInitializationDetection','Simplified',''
    'SFUnreachableExecutionPathDiag','error',''
    'SFTransitionActionBeforeConditionDiag','warning',''
    'SFUndirectedBroadcastEventsDiag','error',''
    'NoFixptDivByZeroProtection','off',''
    'MATLABDynamicMemAlloc','off',''
    };
    params=cell2struct(paramsTable,{'name','setting','target'},2);


    check={
'mathworks.codegen.CodeGenSanity'
'mathworks.design.UnconnectedLinesPorts'
'mathworks.design.DataStoreMemoryBlkIssue'
'mathworks.design.OutputSignalSampleTime'
'mathworks.codegen.ConstraintsTunableParam'
'mathworks.design.DiagnosticDataStoreBlk'
'mathworks.design.MismatchedBusParams'
'mathworks.design.DataStoreBlkSampleTime'
'mathworks.design.OrderingDataStoreAccess'
    };

    checkToExclude={
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


