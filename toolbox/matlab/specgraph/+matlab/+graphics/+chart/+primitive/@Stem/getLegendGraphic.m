function graphic=getLegendGraphic(hObj)



    edgeVD=single([0,.7;.5,.5;0,0]);
    markerVD=single([.7;.5;0]);
    graphic=matlab.graphics.chart.primitive.utilities.getIconForLinePlots(hObj,edgeVD,markerVD);
