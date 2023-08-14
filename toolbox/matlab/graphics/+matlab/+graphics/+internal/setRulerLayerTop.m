function setRulerLayerTop(obj)




    if isa(obj,'matlab.graphics.axis.PolarAxes')
        rulers=[obj.RAxis;obj.ThetaAxis];
    else
        rulers=[obj.XAxis;obj.YAxis];
    end
    set(rulers,'AxesLayer','top')
