function unpopulate(h)





    if isempty(h.childNodes)
        return;
    end


    numChildren=h.childNodes.getCount();
    for idx=1:numChildren
        blk=h.childNodes.getDataByIndex(idx);
        if isempty(blk)||~ishandle(blk)
            continue;
        end
        locDeleteListeners(blk);
        unpopulate(blk);
        delete(blk);
    end


    h.childNodes.Clear;
    h.childNodes=[];


    h.clearSignalChildren;


    locDeleteListeners(h);

end


function locDeleteListeners(hBlk)

    for lIdx=1:numel(hBlk.listeners)
        if iscell(hBlk.listeners)
            delete(hBlk.listeners{lIdx});
        else
            delete(hBlk.listeners(lIdx));
        end
    end
    hBlk.listeners=[];

end
