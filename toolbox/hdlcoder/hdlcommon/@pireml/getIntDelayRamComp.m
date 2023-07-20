function delayComp=getIntDelayRamComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,resetnone,desc)




    if(nargin<7)
        desc='';
    end

    if(nargin<6)
        resetnone=false;
    end

    if(nargin<5)
        compName='intdelay';
    end


    [dimlen,ht]=pirelab.getVectorTypeInfo(hSignalsIn(1));

    if(dimlen>1)
        delayComp=getVectorRam(hN,hSignalsIn,hSignalsOut,delayNumber,compName,dimlen,ht,resetnone,desc);
    else
        delayComp=makeRam(hN,hSignalsIn,hSignalsOut,delayNumber,compName,resetnone,desc);
    end

end


function intcomp=getVectorRam(hN,hSignalsIn,hSignalsOut,delayNumber,compName,numDims,hInType,resetnone,desc)
    for ii=1:numDims
        hDelayInSignals(ii)=hN.addSignal(hInType,sprintf('%s_in_%d',compName,ii));%#ok<AGROW>
        hDelayOutSignals(ii)=hN.addSignal(hInType,sprintf('%s_out_%d',compName,ii));%#ok<AGROW>
    end

    intcomp=pirelab.getDemuxComp(hN,hSignalsIn(1),hDelayInSignals);

    delayComps=hdlhandles(numDims,1);
    for ii=numDims:-1:1
        delayComps(ii)=makeRam(hN,hDelayInSignals(ii),hDelayOutSignals(ii),delayNumber,sprintf('%s_%d',compName,ii),resetnone,desc);
    end

    hMux=pirelab.getMuxComp(hN,hDelayOutSignals,hSignalsOut(1));%#ok<*NASGU>
end


function delayComp=makeRam(hN,hSignalsIn,hSignalsOut,delayNumber,compName,resetnone,desc)

    [~,delayComp]=pireml.getRAMBasedShiftRegisterComp(hN,hSignalsIn,hSignalsOut,...
    delayNumber,delayNumber,compName,resetnone);

end