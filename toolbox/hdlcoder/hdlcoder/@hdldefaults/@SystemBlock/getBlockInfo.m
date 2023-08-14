function[resetNone,retiming,constMultMode,ramMapping,guardIndex,simIndexCheck,...
    loopOptimization,variablePipeline,sharingFactor,compactSwitch]=getBlockInfo(this,hC)











    resetNone=strcmpi(getImplParams(this,'ResetType'),'None');


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

    compactSwitch=hdlgetparameter('CompactSwitch');

    simIndexCheck=hdlgetparameter('SimIndexCheck');
