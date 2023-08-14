function extents=getXYZDataExtents(hObj,~,~)



    xData=[];
    yData=[];
    zData=[];

    if strcmp(hObj.XLimInclude,'on')
        xData=filterInfiniteValues(hObj.XData);
    end
    if strcmp(hObj.YLimInclude,'on')
        yData=filterInfiniteValues(hObj.YData);
    end
    if strcmp(hObj.ZLimInclude,'on')
        if strcmp(hObj.Is3D,'on')
            zData=filterInfiniteValues(hObj.ZData);
        elseif strcmp(hObj.ContourZLevelMode,'manual')


            zData=hObj.ContourZLevel;
        elseif isnumeric(hObj.ZLocation_I)
            if strcmp(hObj.ZLocationMode,'auto')

                zData=0;
            else
                zData=hObj.ZLocation_I;
            end
        end
    end

    [xlimits,ylimits,zlimits]=...
    matlab.graphics.chart.primitive.utilities.arraytolimits(...
    xData,yData,zData);

    extents=[xlimits;ylimits;zlimits];
end

function x=filterInfiniteValues(x)
    x=x(:);
    xInf=isinf(x);
    if any(xInf)
        x(xInf)=[];
    end
end
