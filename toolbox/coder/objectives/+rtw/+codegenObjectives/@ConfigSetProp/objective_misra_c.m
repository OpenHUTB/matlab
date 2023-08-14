function objective=objective_misra_c(~)




    file.filename='objective__misrac.m';
    file.objectivename='MISRA C:2012 guidelines';
    file.order='7';

    paramsTable={

    'AssertControl','DisableAll',''
    'SystemTargetFile','ert.tlc',''
    'SupportContinuousTime','off',''
    'SupportNonInlinedSFcns','off',''
    'MatFileLogging','off',''
    'ParenthesesLevel','Maximum',''
    'ProdIntDivRoundTo','Zero',''
    'UseDivisionForNetSlopeComputation','on',''
    'EnableSignedLeftShifts','off',''
    'EnableSignedRightShifts','off',''
    'CastingMode','Standards',''
    'UtilityFuncGeneration','Shared location',''
    'GenerateSharedConstants','off',''
    'InternalIdentifier','Shortened',''
    'GenerateAllocFcn','off',''
    'IntegerOverflowMsg','error',''
    'SignalInfNanChecking','warning',''
    'MATLABDynamicMemAlloc','off',''
    'PreserveStaticInFcnDecls','on',''
    'ExtMode','off',''
    'SFUndirectedBroadcastEventsDiag','error',''
    'CompileTimeRecursionLimit','0',''
    'EnableRuntimeRecursion','off',''
    'GenerateComments','on',''
    'MATLABFcnDesc','on',''
    };

    params=cell2struct(paramsTable,{'name','setting','target'},2);

    if slfeature('ParenthesesLevelStandards')
        params(6).setting='Standards';
    end


    check={
'mathworks.codegen.CodeGenSanity'
'mathworks.misra.BlkSupport'
'mathworks.codegen.PCGSupport'
'mathworks.misra.BlockNames'
'mathworks.misra.AssignmentBlocks'
'mathworks.misra.CompliantCGIRConstructions'
'mathworks.misra.RecursionCompliance'
'mathworks.misra.CompareFloatEquality'
'mathworks.misra.SwitchDefault'
'mathworks.misra.ModelFunctionInterface'
'mathworks.misra.IntegerWordLengths'
'mathworks.misra.AutosarReceiverInterface'
'mathworks.misra.BusElementNames'
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


