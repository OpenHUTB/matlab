function demuxComp=getDemuxComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='demux';
    end






    for i=1:length(hOutSignals)
        dimLen=double(max(hOutSignals(i).Type.getDimensions));
        outLen(i)=dimLen;%#ok<AGROW>
    end

    ipf='hdleml_demux';
    bmp={outLen};




    demuxComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',bmp,...
    'EMLFlag_RunLoopUnrolling',false);

    if targetmapping.isValidDataType(hInSignals(1).Type)
        demuxComp.setSupportTargetCodGenWithoutMapping(true);
    end

end


