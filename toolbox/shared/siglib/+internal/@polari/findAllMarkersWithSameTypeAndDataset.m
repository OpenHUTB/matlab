function m=findAllMarkersWithSameTypeAndDataset(p,ID)



    switch lower(ID(1))
    case 'p'
        mAll=p.hPeakAngleMarkers;
    case 'c'
        mAll=p.hCursorAngleMarkers;
    case 'a'


        m=p.hAngleLimCursors;
        return
    otherwise
        mAll=[];
    end
    sel=strcmpi(ID,{mAll.ID});
    assert(sum(sel)==1);
    m=mAll(getDataSetIndex(mAll)==getDataSetIndex(mAll(sel)));
