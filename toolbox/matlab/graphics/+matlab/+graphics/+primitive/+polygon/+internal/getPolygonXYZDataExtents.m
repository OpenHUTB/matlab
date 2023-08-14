function ex=getPolygonXYZDataExtents(polygon)


    shape=polygon.Shape;
    xmin=0;
    xmax=1;
    ymin=0;
    ymax=1;
    if(numel(shape)~=0&&~isempty(shape)&&~(numboundaries(shape)==0))
        [xLim,yLim]=boundingbox(shape);


        xmargin=diff(xLim)*0.1;
        ymargin=diff(yLim)*0.1;
        xmin=xLim(1)-xmargin;
        xmax=xLim(2)+xmargin;
        ymin=yLim(1)-ymargin;
        ymax=yLim(2)+ymargin;
    end

    x=matlab.graphics.chart.primitive.utilities.arraytolimits(...
    [xmin,xmax]);
    y=matlab.graphics.chart.primitive.utilities.arraytolimits(...
    [ymin,ymax]);
    z=[0,NaN,NaN,0];
    ex=[x;y;z];
end
