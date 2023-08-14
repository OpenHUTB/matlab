function demuxComp=getDemuxCompOnInput(hN,hInSignal)
















    [dimlen,~]=pirelab.getVectorTypeInfo(hInSignal);
    if dimlen==1
        hT=hInSignal.Type;
        hOutSignal=hN.addSignal(hT,sprintf('%s_wireout',hInSignal.Name));
        demuxComp=pirelab.getWireComp(hN,hInSignal,hOutSignal);
    else
        demuxComp=hInSignal.split;
    end

end
