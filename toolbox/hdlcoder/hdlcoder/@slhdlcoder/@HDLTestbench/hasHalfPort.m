function isHalfPort=hasHalfPort(~,hPir)



    isHalfPort=false;
    topNtwk=hPir.getTopNetwork;

    isHalfPort=hasHalfIOTypes(topNtwk.PirInputSignals);
    if~isHalfPort
        isHalfPort=hasHalfIOTypes(topNtwk.PirOutputSignals);
    end
end

function isHalfTypeSignal=hasHalfIOTypes(IOSignals)
    isHalfTypeSignal=false;
    for ii=1:length(IOSignals)
        hT=IOSignals(ii).Type;
        if isHalfType(hT.getLeafType)
            isHalfTypeSignal=true;
            break;
        end
    end
end

