function[chartId,machine,isSFChart,isInitOutput,...
    generateResetLogic,concurrencyMaximization,...
    retiming,constMultMode,ramMapping,guardIndex,...
    simIndexCheck,loopOptimization,emitPersistentWarning,...
    variablePipeline,sharingFactor,instantiateFcns,...
    matrixTypes,hasInputEvents,compactSwitch]=getBlockInfo(this,hC)













    chartId=sfprivate('block2chart',hC.simulinkHandle);
    machine=validateAndGetMachine(hC);

    phan=get_param(hC.SimulinkHandle,'PortHandles');


    hasInputEvents=~isempty(phan.Trigger);

    chartH=idToHandle(sfroot,chartId);
    isSFChart=this.isStateflowChart(chartH);
    isInitOutput=isSFChart&&chartH.initializeOutput;
    generateResetLogic=~strcmpi(getImplParams(this,'ResetType'),'None');

    concurrencyMaximization=sf('feature','Attempt fully concurrent code generation for sf/eML blocks');
    emitPersistentWarning=sf('feature','Emit warnings on improper use of persistent vars for HDL code generation');


    constMultiplierOptimMode=getImplParams(this,'ConstMultiplierOptimization');
    if~isempty(constMultiplierOptimMode)
        if strcmpi(constMultiplierOptimMode,'none')
            constMultMode=0;
        elseif strcmpi(constMultiplierOptimMode,'csd')
            constMultMode=1;
        elseif strcmpi(constMultiplierOptimMode,'fcsd')
            constMultMode=2;
        elseif strcmpi(constMultiplierOptimMode,'auto')
            constMultMode=3;
        else
            constMultMode=0;
        end
    else
        constMultMode=0;
    end


    retiming=getImplParams(this,'DistributedPipelining');
    retiming=strcmpi(retiming,'on');

    ramMapping=getImplParams(this,'MapPersistentVarsToRAM');
    ramMapping=strcmpi(ramMapping,'on');

    guardIndex=getImplParams(this,'GuardIndexVariables');
    guardIndex=strcmpi(guardIndex,'on');

    loopOptimization=getImplParams(this,'LoopOptimization');

    variablePipeline=getImplParams(this,'VariablesToPipeline');

    sharingFactor=getImplParams(this,'SharingFactor');

    instantiateFcns=getImplParams(this,'InstantiateFunctions');
    instantiateFcns=strcmpi(instantiateFcns,'on');

    matrixTypes=getImplParams(this,'UseMatrixTypesInHDL');
    matrixTypes=strcmpi(matrixTypes,'on');

    compactSwitch=hdlgetparameter('CompactSwitch');

    simIndexCheck=hdlgetparameter('SimIgnoreOutOfBounds');
end

function machine=validateAndGetMachine(hC)
    modelH=get_param(bdroot(hC.simulinkHandle),'handle');
    machine=sf('find','all','machine.simulinkModel',modelH);
    assert(length(machine)==1,'Failed to get machine from Stateflow block.');
end


