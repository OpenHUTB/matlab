function i_changeAngleAtTop(p)


    i_updateAngleLabelRotation(p);



    cacheCoords_MagTickLabels(p);

    drawCircles(p,true);
    drawRadialGridLines(p);
    drawGridRefinementLines(p);







    i_updateAngleOfLabelMagnitudes(p);


    plot_data(p);

