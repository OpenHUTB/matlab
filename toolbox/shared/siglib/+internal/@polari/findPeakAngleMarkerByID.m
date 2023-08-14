function m=findPeakAngleMarkerByID(p,ID)

    m=p.hPeakAngleMarkers;
    if~isempty(m)
        m=m(strcmpi(ID,{m.ID}));
    end

