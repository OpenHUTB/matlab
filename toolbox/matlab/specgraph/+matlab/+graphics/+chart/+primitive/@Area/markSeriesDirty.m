function markSeriesDirty(hObj)




    hPeers=hObj.AreaPeers;
    for p=1:numel(hPeers)
        hPeers(p).MarkDirty('limits');
    end
