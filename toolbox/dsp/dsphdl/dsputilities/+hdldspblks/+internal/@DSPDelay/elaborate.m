function hNewC=elaborate(this,hN,hC)





    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,hC,sysObjHandle);
    else
        blockInfo=getBlockInfo(this,hC);
    end

    desc=blockInfo.desc;

    numDelays=blockInfo.numDelays;

    if(isempty(numDelays))
        numDelays=1;
    end

    if(all(numDelays==numDelays(1)))
        numDelays=numDelays(1);
    end


    resetnone=false;
    rtype=this.getImplParams('ResetType');
    if~isempty(rtype)
        resetnone=strcmpi(rtype,'none');
    end

    [~,ht]=pirelab.getVectorTypeInfo(hC.PirInputSignals(1));


    initVal=blockInfo.initVal;

    if(length(numDelays)==1)
        if(numDelays(1)==0)
            icVal=0;
        else
            icVal=initVal;
        end
        dspComp=pirelab.getIntDelayComp(hN,hC.PirInputSignals,hC.PirOutputSignals,numDelays,...
        hC.Name,icVal,resetnone,false,'',blockInfo.rambased);%#ok<*NASGU>
        if hdlgetparameter('preserveDesignDelays')==1
            if(dspComp.isDelay)
                dspComp.setDoNotDistribute(1);
            end
        end
    else
        for ii=1:length(numDelays)
            hDelayIn(ii)=hN.addSignal(ht,sprintf('%s_in_%d',hC.Name,ii));%#ok<AGROW>
            hDelayOut(ii)=hN.addSignal(ht,sprintf('%s_out_%d',hC.Name,ii));%#ok<AGROW>
        end

        hDemux=pirelab.getDemuxComp(hN,hC.PirInputSignals(1),hDelayIn);

        currentIndex=1;
        for ii=1:length(numDelays)
            delayVal=numDelays(ii);
            if(delayVal==0)
                icVal=0;
            else

                icVal=initVal(currentIndex:currentIndex+delayVal-1);
                currentIndex=currentIndex+delayVal;
            end
            hDelay=pirelab.getIntDelayComp(hN,hDelayIn(ii),hDelayOut(ii),numDelays(ii),...
            sprintf('%s_%d',hC.Name,ii),icVal,resetnone,false,'',blockInfo.rambased,true,desc);
            if hdlgetparameter('preserveDesignDelays')==1
                if(hDelay.isDelay)
                    hDelay.setDoNotDistribute(1);
                end
            end
        end

        dspComp=pirelab.getMuxComp(hN,hDelayOut,hC.PirOutputSignals(1));
    end

    hNewC=dspComp;

end
