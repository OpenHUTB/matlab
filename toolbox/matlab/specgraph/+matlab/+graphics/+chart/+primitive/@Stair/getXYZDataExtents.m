function varargout=getXYZDataExtents(hObj,~,constraints)



    [xdata,ydata]=matlab.graphics.chart.primitive.utilities.preprocessextents(hObj.XDataCache(:),hObj.YDataCache(:));
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
    zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(0);

    varargout{1}=[xlim;ylim;zlim];
end
