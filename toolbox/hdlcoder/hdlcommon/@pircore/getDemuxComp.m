function demuxComp=getDemuxComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='demux';
    end

    demuxComp=pirelab.getDemuxCompOnInput(hN,hInSignals(1));
    hDemuxOutSigs=demuxComp.PirOutputSignals;

    numOuts=length(hOutSignals);
    currIndex=1;
    for ii=1:numOuts
        [dimlen,~]=pirelab.getVectorTypeInfo(hOutSignals(ii));
        if dimlen>1
            hMux=pirelab.getMuxComp(hN,hDemuxOutSigs(currIndex:(currIndex+dimlen-1)),hOutSignals(ii),sprintf('%s_mux_%d',compName,ii));
        else
            hWire=pirelab.getWireComp(hN,hDemuxOutSigs(currIndex),hOutSignals(ii));
        end
        currIndex=currIndex+dimlen;
    end

end


