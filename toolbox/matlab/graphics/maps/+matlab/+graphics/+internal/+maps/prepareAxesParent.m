function parent=prepareAxesParent(parent,pvpairs)







    if nargin>1
        parent=matlab.graphics.chart.internal.inputparsingutils.getParent(parent,pvpairs);
    end
    currentFigure=get(groot,"CurrentFigure");
    currentAxes=get(currentFigure,"CurrentAxes");
    currentAxesIsMapAxes=isa(currentAxes,"map.graphics.axis.MapAxes");
    if isa(parent,"map.graphics.axis.MapAxes")||(isempty(parent)&&currentAxesIsMapAxes)
        parent=matlab.graphics.internal.prepareCoordinateSystem(...
        'map.graphics.axis.MapAxes',parent,@mapaxes);
    else
        parent=matlab.graphics.internal.prepareCoordinateSystem(...
        'matlab.graphics.axis.GeographicAxes',parent,@geoaxes);
    end
    parent=matlab.graphics.chart.internal.inputparsingutils.prepareAxes(parent,true);
end