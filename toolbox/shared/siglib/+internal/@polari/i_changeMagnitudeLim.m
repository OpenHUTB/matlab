function i_changeMagnitudeLim(p,labelVis)


    updateAxesMagLimits(p);
    cacheCoords_MagTickLabels(p);


    drawCircles(p,false);
    drawRadialGridLines(p);
    drawGridRefinementLines(p);
    labelMagnitudes(p);




    if nargin<2
        labelVis='on';
    end
    overrideMagnitudeTickLabelVis(p,labelVis);

    plot_data(p);



    notify(p,'MagnitudeLimChanged');
