function bounds=getBounds(hAxes,disableIfLimitsOutsideAxes)


















    cLimits=[];
    if(disableIfLimitsOutsideAxes)
        cLimits=matlab.graphics.interaction.getDoubleAxesLimits(hAxes);
    end

    h=findobj(hAxes,'Type','image');
    if~isempty(h)
        image_bounds=getGraphicsExtents(hAxes);
        if~isempty(image_bounds)&&(~disableIfLimitsOutsideAxes||isAllAxesWithinLimits(cLimits,image_bounds,true))
            bounds=image_bounds;
            return;
        end
    end

    orig_bounds=getappdata(hAxes,'zoom_zoomOrigAxesLimits');
    extents=getGraphicsExtents(hAxes);
    if~isempty(orig_bounds)
        boundlimits=matlab.graphics.interaction.internal.getWiderLimits(orig_bounds,extents);
    else
        boundlimits=extents;
    end

    if~disableIfLimitsOutsideAxes||isAllAxesWithinLimits(cLimits,boundlimits,GetLayoutInformation(hAxes).is2D)
        bounds=boundlimits;
    else
        bounds=nan(1,6);
    end
end

function isWithinBounds=isAllAxesWithinLimits(limits,bounds,is2DAxes)
    if(is2DAxes)
        isWithinBounds=matlab.graphics.interaction.internal.isWithinLimits(limits(1:2),bounds(1:2))&&...
        matlab.graphics.interaction.internal.isWithinLimits(limits(3:4),bounds(3:4));
    else
        isWithinBounds=matlab.graphics.interaction.internal.isWithinLimits(limits(1:2),bounds(1:2))&&...
        matlab.graphics.interaction.internal.isWithinLimits(limits(3:4),bounds(3:4))&&...
        matlab.graphics.interaction.internal.isWithinLimits(limits(5:6),bounds(5:6));
    end
end
