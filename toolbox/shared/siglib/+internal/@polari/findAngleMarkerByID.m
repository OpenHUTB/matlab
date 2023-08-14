function[m,is_peak]=findAngleMarkerByID(p,ID)



    is_peak=false;
    if isempty(ID)
        m=[];
        return
    end
    switch lower(ID(1))
    case 'p'

        is_peak=true;
        m=p.hPeakAngleMarkers;
    case 'c'

        m=p.hCursorAngleMarkers;
    case 'a'

        m=p.hAngleLimCursors;
    otherwise
        m=[];
    end
    if~isempty(m)
        m=m(strcmpi(ID,{m.ID}));
    end


    assert(numel(m)<=1,'Duplicate marker IDs exist (%s, count=%d)',ID,numel(m))
