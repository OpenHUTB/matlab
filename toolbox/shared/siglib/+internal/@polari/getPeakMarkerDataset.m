function ds=getPeakMarkerDataset(p)


    m=p.hPeakAngleMarkers;
    ds=zeros(size(m));
    for i=1:numel(m)
        ds(i)=getDataSetIndex(m(i));
    end
