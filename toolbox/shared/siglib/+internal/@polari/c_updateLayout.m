function c_updateLayout(p)





    if~isempty(p.hAxes)
        adjustFontSize(p);
        adjustAngleLabelsPos(p.hAngleText);
        updateMarkers(p);
    end
