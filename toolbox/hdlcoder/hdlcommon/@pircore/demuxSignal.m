function demuxOutputs=demuxSignal(hN,hInSignal)





    if hInSignal.Type.isArrayType
        demuxComp=pirelab.getDemuxCompOnInput(hN,hInSignal);
        demuxOutputs=demuxComp.PirOutputSignals;
    else
        demuxOutputs=hInSignal;
    end

end
