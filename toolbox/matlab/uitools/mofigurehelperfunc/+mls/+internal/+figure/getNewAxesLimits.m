function[newXLim,newYLim]=getNewAxesLimits(hAxes,origin,endPt)

    originData=convertNormalizedPointToDataSpace(hAxes,origin);
    endPtData=convertNormalizedPointToDataSpace(hAxes,endPt);

    newXLim=getNewXLim(hAxes,originData,endPtData);
    newYLim=getNewYLim(hAxes,originData,endPtData);

end

function newPoint=convertNormalizedPointToDataSpace(hAxes,point)

    oldXLim=ruler2num(get(hAxes,'XLim'),get(hAxes,'XAxis'));
    oldYLim=ruler2num(get(hAxes,'YLim'),get(hAxes,'YAxis'));

    if strcmpi(get(hAxes,'XDir'),'reverse')
        oldXLim=oldXLim([2,1]);
    end

    if strcmpi(get(hAxes,'YDir'),'reverse')
        oldYLim=oldYLim([2,1]);
    end

    newPoint=point;
    if strcmpi(get(hAxes,'XScale'),'log')
        logXLim=log10(oldXLim);
        newPoint(1)=10^(point(1)*diff(logXLim)+logXLim(1));
    else
        newPoint(1)=point(1)*diff(oldXLim)+oldXLim(1);
    end

    if strcmpi(get(hAxes,'YScale'),'log')
        logYLim=log10(oldYLim);
        newPoint(2)=10^(point(2)*diff(logYLim)+logYLim(1));
    else
        newPoint(2)=point(2)*diff(oldYLim)+oldYLim(1);
    end

end



function[newXLim]=getNewXLim(hAxes,origin,endPt)



    x_lim=[origin(1),endPt(1)];
    if x_lim(1)>x_lim(2),
        x_lim=x_lim([2,1]);
    end





    if abs(x_lim(1)-x_lim(2))>1e-10*(abs(x_lim(1))+abs(x_lim(2)))
        newXLim=x_lim;
    else
        newXLim=ruler2num(xlim(hAxes),get(hAxes,'XAxis'));
    end

end



function[newYLim]=getNewYLim(hAxes,origin,endPt)



    y_lim=[origin(2),endPt(2)];
    if y_lim(1)>y_lim(2),
        y_lim=y_lim([2,1]);
    end





    if abs(y_lim(1)-y_lim(2))>1e-10*(abs(y_lim(1))+abs(y_lim(2)))
        newYLim=y_lim;
    else
        newYLim=ruler2num(ylim(hAxes),get(hAxes,'YAxis'));
    end

end