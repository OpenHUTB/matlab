function demuxComp=getHardwareDemuxComp(hN,hInSignal,hOutSignal,compName)




    if(nargin<4)
        compName='hwdemux';
    end

    demuxComp=pircore.getHardwareDemuxComp(hN,hInSignal,hOutSignal,compName);

end


