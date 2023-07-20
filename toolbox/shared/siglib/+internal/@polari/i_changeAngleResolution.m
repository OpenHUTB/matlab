function i_changeAngleResolution(p,res)


    enableListeners(p,false);
    p.AngleResolution=res;
    enableListeners(p,true);

    cacheCoords_AngleTickLabels(p);
    drawRadialGridLines(p);
    drawGridRefinementLines(p);
    labelAngles(p);
    adjustAngleLabelsPos(p.hAngleText);
