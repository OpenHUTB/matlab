function sysComp=elaborate(this,~,hC)



    [resetNone,retiming,constMultMode,ramMapping,guardIndex,simIndexCheck,...
    loopOptimization,variablePipeline,sharingFactor,compactSwitch]=this.getBlockInfo(hC);

    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    compName=hC.Name;

    inlineParams=false;
    [fcnName,fcnText,params,TunableParamStrs,TunableParamTypes]=...
    getMATLABScriptAndParams(this,hC,inlineParams);

    fiSettingParams=getFiParams(hC.SimulinkHandle);
    if~isempty(fiSettingParams)
        treatIntAsFi=strcmp(get_param(hC.SimulinkHandle,'TreatAsFi'),'Fixed-point & Integer');
        satOnIntOverflow=strcmp(get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'),'on');
    else
        treatIntAsFi=false;
        satOnIntOverflow=true;
    end
    sysComp=hC.Owner.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',fcnName,...
    'EMLFileBody',fcnText,...
    'EMLParams',params,...
    'EMLFlag_TreatInputIntsAsFixpt',treatIntAsFi,...
    'EMLFlag_TreatInputBoolsAsUFix1',false,...
    'EMLFlag_SaturateOnIntOverflow',satOnIntOverflow,...
    'RunPartitioning',true,...
    'Retiming',retiming,...
    'emlflag_constmultiplieroptimization',constMultMode,...
    'RamMapping',ramMapping,...
    'GuardIndexVariables',guardIndex,...
    'SimIndexCheck',simIndexCheck,...
    'VariablePipeline',variablePipeline,...
    'SharingFactor',sharingFactor,...
    'CompactSwitch',compactSwitch);

    sysComp.runConcurrencyMaximizer(0);

    sysComp.setEMLCDRCompType;
    sysComp.resetNone(resetNone);
    if~isempty(TunableParamStrs)
        sysComp.setTunableParamStrs(TunableParamStrs);
        sysComp.setTunableParamTypes(TunableParamTypes);
    end

    loopUnrolling=strcmpi(loopOptimization,'Unrolling');
    loopStreaming=strcmpi(loopOptimization,'Streaming');
    sysComp.runLoopUnrolling(loopUnrolling);
    sysComp.runLoopStreaming(loopStreaming);

    outPipes=hC.getOutputPipeline;
    if outPipes>0
        sysComp.setOutputPipeline(outPipes);
        hC.setOutputPipeline(0);
    end

    sysComp.SimulinkHandle=hC.SimulinkHandle;
end

function fiSettingParams=getFiParams(slbh)


    fiSettingParams={'SaturateOnIntegerOverflow','TreatAsFi',...
    'BlockDefaultFimath','InputFimath'};
    dialogParams=get_param(slbh,'DialogParameters');
    if~all(isfield(dialogParams,fiSettingParams))
        fiSettingParams={};
    end
end

