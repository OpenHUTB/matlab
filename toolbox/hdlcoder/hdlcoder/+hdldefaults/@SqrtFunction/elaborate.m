function hNewC=elaborate(this,hN,blockComp)





    hInSignals=blockComp.PirInputSignals;
    hOutSignals=blockComp.PirOutputSignals;
    fname=get_param(blockComp.SimulinkHandle,'Function');
    nfpOptions=getNFPBlockInfo(this);
    bfp=blockComp.SimulinkHandle;
    Fname=get_param(bfp,'Function');

    latencyParam=this.getImplParams('LatencyStrategy');
    if strcmpi(latencyParam,'Custom')
        customLatency=getImplParams(this,'NFPCustomLatency');
        if~isempty(customLatency)
            nfpOptions.CustomLatency=int8(customLatency);
        else
            if~isempty(this.getImplParams('CustomLatency'))
                nfpOptions.CustomLatency=int8(this.getImplParams('CustomLatency'));
            else
                nfpOptions.CustomLatency=int8(0);
            end
        end
    end
    if targetmapping.mode(hInSignals)
        hNewC=pirelab.getSqrtComp(hN,hInSignals,hOutSignals,...
        blockComp.Name,blockComp.SimulinkHandle,fname,nfpOptions);
    else


        if(strcmpi(Fname,'Sqrt')&&(~targetmapping.hasFloatingPointPort(blockComp)))

            hNewC=SqrtBitsetWrapper(this,hN,blockComp);
        else
            impl=getFunctionImpl(this,blockComp);
            hNewC=impl.elaborate(hN,blockComp);
        end
    end
end
