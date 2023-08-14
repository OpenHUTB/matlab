function hNewC=elaborate(this,hN,hC)




    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    usePipelines=this.getUsePipelines(isSysObj);
    if(isempty(this.getImplParams('CustomLatency')))
        customLatency=0;
    else
        customLatency=this.getImplParams('CustomLatency');
    end

    if(isempty(this.getImplParams('LatencyStrategy')))
        latencyStrategy='MAX';
    else
        latencyStrategy=this.getImplParams('LatencyStrategy');
    end

    if isSysObj
        sysObjHandle=hC.getSysObjImpl;
        cordicInfo=getSysObjInfo(this,hC,sysObjHandle);
        fName=sysObjHandle.FunctionName;
        hC_Name=[fName,'_iter_',int2str(cordicInfo.iterNum)];
    else
        slbh=hC.SimulinkHandle;
        cordicInfo=getBlockInfo(this,slbh);
        fName=get_param(slbh,'Operator');
        hC_Name=hC.Name;
    end


    hN.renderCodegenPir(true);
    if(strcmp(fName,'atan2'))
        hNewC=pirelab.getAtan2CordicComp(hN,hInSignals,hOutSignals,cordicInfo,fName,usePipelines,customLatency,latencyStrategy,hC_Name);
    else
        hNewC=pirelab.getSinCosCordicComp(hN,hInSignals,hOutSignals,cordicInfo,fName,usePipelines,customLatency,latencyStrategy,hC_Name);
    end


