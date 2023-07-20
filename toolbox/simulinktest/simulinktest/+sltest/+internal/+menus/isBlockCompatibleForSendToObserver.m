function bool=isBlockCompatibleForSendToObserver(portHandles,blockType)
    bool=true;
    ph=portHandles;
    prtArrayIn=[ph.Inport,ph.Enable,ph.Trigger,ph.Ifaction,ph.Reset];
    prtArrayOut=[ph.Outport,ph.State];
    prtArrayConn=[ph.LConn,ph.RConn];
    if isempty(prtArrayIn)||~isempty(prtArrayOut)||~isempty(prtArrayConn)||...
        ismember(blockType,["Outport","Goto","DataStoreWrite","ArgOut","StateWriter"])
        bool=false;
    end
end
