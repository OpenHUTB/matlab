function tdc=elaborate(this,hN,hC)



    [initVal,numDelays,delayorder,includecurrent]=getBlockInfo(this,hC);

    initVal=uint8(initVal);

    resetnone=false;
    rtype=this.getImplParams('ResetType');
    if~isempty(rtype)
        resetnone=contains(string(rtype),'none','IgnoreCase',true);
    end

    if isa(hC,'hdlcoder.sysobj_comp')
        inputs=hC.PirInputSignals;
        outputs=hC.PirOutputSignals;
    else
        inputs=hC.SLInputSignals;
        outputs=hC.SLOutputSignals;
    end

    tdc=pirelab.getTapDelayComp(hN,inputs,outputs,numDelays,...
    hC.Name,initVal,delayorder,includecurrent,resetnone,'');

end
