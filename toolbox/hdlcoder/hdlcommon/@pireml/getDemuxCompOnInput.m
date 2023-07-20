function demuxComp=getDemuxCompOnInput(hN,hInSignal)
















    demuxComp=pircore.getDemuxCompOnInput(hN,hInSignal);
    if targetmapping.isValidDataType(hInSignal.Type)
        demuxComp.setSupportTargetCodGenWithoutMapping(true);
    end
end
