function extents=getXYZDataExtents(hObj,~,constraints)







    x=hObj.XDataCache(:);
    y=hObj.YDataCache(:);

    if~isequaln(x,hObj.OldXDataCache)||~isequaln(y,hObj.OldYDataCache)
        [xD,yD]=matlab.graphics.chart.primitive.utilities.preprocessextents(x,y);
        if strcmp(hObj.XLimInclude,'off')
            xD=[];
        end
        if strcmp(hObj.YLimInclude,'off')
            yD=[];
        end

        if~isempty(constraints)
            inmask=[];
            if isfield(constraints,'XConstraints')&&~isempty(xD)
                xmask=(constraints.XConstraints(1)<=xD)&(xD<=constraints.XConstraints(2));
                if numel(inmask)==numel(xmask)
                    inmask=inmask&xmask;
                else
                    inmask=xmask;
                end
            end
            if isfield(constraints,'YConstraints')&&~isempty(yD)
                ymask=(constraints.YConstraints(1)<=yD)&(yD<=constraints.YConstraints(2));
                if numel(inmask)==numel(ymask)
                    inmask=inmask&ymask;
                else
                    inmask=ymask;
                end
            end

            if(numel(inmask)==numel(xD))
                xD=xD(inmask);
            end
            if(numel(inmask)==numel(yD))
                yD=yD(inmask);
            end
        end

        [xlim,ylim]=matlab.graphics.chart.primitive.utilities.arraytolimits(xD,yD);
        extents=[xlim;ylim;NaN(1,4)];
        hObj.XYZExtentsCache=extents;
    else
        extents=hObj.XYZExtentsCache;
    end

end