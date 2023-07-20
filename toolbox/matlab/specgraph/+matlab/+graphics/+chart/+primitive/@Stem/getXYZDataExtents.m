function varargout=getXYZDataExtents(hObj,~,constraints)



    xTmp=hObj.XDataCache(:);
    yTmp=hObj.YDataCache(:);
    zTmp=hObj.ZDataCache(:);

    [xdata,ydata,zdata]=matlab.graphics.chart.primitive.utilities.preprocessextents(xTmp,yTmp,zTmp);

    if isempty(xdata)
        varargout{1}=[];
        return;
    end

    if strcmp(hObj.XLimInclude,'off')
        xdata=[];
    end
    if strcmp(hObj.YLimInclude,'off')
        ydata=[];
    end
    if~isempty(constraints)
        if isfield(constraints,'XConstraints')&&~isempty(xdata)
            mask=(xdata>=constraints.XConstraints(1))&(xdata<=constraints.XConstraints(2));
            if numel(xdata)==numel(ydata)
                xdata=xdata(mask);
                ydata=ydata(mask);
            end
        end
    end


    xlim=matlab.graphics.chart.primitive.utilities.arraytolimits(xdata);
    ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(ydata);
    zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(zdata);

    varargout{1}=[xlim;ylim;zlim];
end
