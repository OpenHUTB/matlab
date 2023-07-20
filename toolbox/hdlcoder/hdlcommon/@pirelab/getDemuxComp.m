function demuxComp=getDemuxComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='demux';
    end

    demuxComp=pircore.getDemuxComp(hN,hInSignals,hOutSignals,compName);