function[m,sel]=findCursorAngleMarkerByID(p,ID)

    m=p.hCursorAngleMarkers;
    if~isempty(m)
        sel=strcmpi(ID,{m.ID});
        m=m(sel);
    end

