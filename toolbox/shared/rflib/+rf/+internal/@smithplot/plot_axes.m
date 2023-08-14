function plot_axes(p,wasDirty)


    if wasDirty
        getParentFig(p);
        getPolarAxes(p,false);

        cacheColorValues(p);
        updateGridView(p);


        p.pFontSize=getFontSize(p);

        drawCircles(p,false);



        labelAngles(p);
        labelResistances(p);
        adjustAngleLabelsPos(p.hAngleText);
    end

    if wasDirty
        updateTitleFont(p);
    end
