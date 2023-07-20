function[Nthis,Nall]=numMarkersOnDataset(p,datasetIndex)


    Nthis=0;
    m=p.hPeakAngleMarkers;
    Nall=numel(m);
    if~isempty(m)
        Nthis=sum(getDataSetIndex(m)==datasetIndex);
    end
    m=p.hCursorAngleMarkers;
    Nall=Nall+numel(m);
    if~isempty(m)
        Nthis=Nthis+sum(getDataSetIndex(m)==datasetIndex);
    end
