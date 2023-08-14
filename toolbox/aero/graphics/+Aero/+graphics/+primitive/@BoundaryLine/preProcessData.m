function[x,y,z]=preProcessData(hObj,xscale,yscale,xlim,ylim)




    x=hObj.XData;
    y=hObj.YData;
    z=zeros(size(x));

    if isempty(xlim)
        xlim=[min(x),max(x)];
    end
    if isempty(ylim)
        ylim=[min(y),max(y)];
    end


    invalid_x=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(xscale,xlim,x);
    invalid_y=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(yscale,ylim,y);
    x(invalid_x)=NaN;
    y(invalid_y)=NaN;

    if isvector(x)
        x=x(:);
        y=y(:);
        z=z(:);
    end


    nani=isfinite(x)&isfinite(y)&isfinite(z);
    x=x(nani);
    y=y(nani);
    z=z(nani);

end

