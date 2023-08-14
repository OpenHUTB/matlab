function plot_axes(p,wasDirty)





    if wasDirty
        getParentFig(p);
        getPolarAxes(p,false);

        cacheColorValues(p);
        updateGridView(p);


        p.pFontSize=getFontSize(p);

        drawCircles(p,false);
        drawRadialGridLines(p);
        drawGridRefinementLines(p);



        labelAngles(p);
        adjustAngleLabelsPos(p.hAngleText);
        updateAngleTickLabelFormat(p);
    end




    labelMagnitudes(p);

    if wasDirty

        updateTitleFont(p);
    end
