function hideAngleMarkerDataDots(p,hide)


    m=[p.hCursorAngleMarkers;p.hPeakAngleMarkers];
    if~isempty(m)
        hideDataDot(m,hide);
    end
