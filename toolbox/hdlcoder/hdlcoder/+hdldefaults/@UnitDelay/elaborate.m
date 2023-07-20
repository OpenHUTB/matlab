function udComp=elaborate(this,hN,hC)


    initval=getBlockInfo(hC);

    rtype=this.getImplParams('ResetType');
    if isempty(rtype)
        resetnone=false;
    else
        resetnone=strncmpi(rtype,'none',min(length(rtype),4));
    end

    udComp=pirelab.getUnitDelayComp(hN,hC.SLInputSignals,hC.SLOutputSignals,hC.Name,...
    initval,resetnone);

    if hdlgetparameter('preserveDesignDelays')==1
        if(udComp.isDelay)
            udComp.setDoNotDistribute(1);
        end
    end

end

function initval=getBlockInfo(hC)
    if hC.PirInputSignals(1).Type.isRecordType||hC.PirInputSignals(1).Type.isArrayOfRecords


        initval=[];
    else
        initval=0;
        rto=get_param(hC.SimulinkHandle,'RuntimeObject');
        np=get(rto,'NumRuntimePrms');
        for n=1:np
            if strcmp(rto.RuntimePrm(n).get.Name,'InitialCondition')
                initval=rto.RuntimePrm(n).Data;
                break;
            end
        end
    end
end