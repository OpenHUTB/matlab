function pt=chooseLimitZoom3DPoint(OrigLimits,evd,hAxes)
    import matlab.graphics.interaction.isPointWithinLimits;


    pt=mean(reshape(OrigLimits,2,3));
    if~isempty(evd)
        hitObjectAvailable=isprop(evd,'HitObject')&&~isempty(evd.HitObject);
        hitAxesOrNoHitObjectProp=~hitObjectAvailable||(hitObjectAvailable&&~ishghandle(evd.HitObject,'axes'));
        validIntersectionPoint=(isprop(evd,'IntersectionPoint')||isfield(evd,'IntersectionPoint'))&&~any(isnan(evd.IntersectionPoint));
        if hitAxesOrNoHitObjectProp&&validIntersectionPoint
            pt=evd.IntersectionPoint;
        elseif hitObjectAvailable
            gObj=evd.HitObject;
            if~isempty(gObj)&&isa(gObj,'matlab.graphics.chart.interaction.DataAnnotatable')
                gObj=evd.HitObject;
                pointInPixels=matlab.graphics.interaction.internal.getPointInPixels(ancestor(gObj,'figure'),evd.Point);
                pt=localPixelToDataSpaceConverter(gObj,pointInPixels);
            else
                pt=mean(hAxes.CurrentPoint);
            end
        else
            pt=mean(hAxes.CurrentPoint);
        end
    end



    if any(~isfinite(pt))||~isPointWithinLimits(pt,OrigLimits)
        pt=mean(hAxes.CurrentPoint);
        if~isPointWithinLimits(mean(hAxes.CurrentPoint),OrigLimits)
            pt=mean(reshape(OrigLimits,2,3));
        end
    end


    function pt=localPixelToDataSpaceConverter(gObj,pixelpoint)





        gObj=gObj(1);
        closestIndex=gObj.getNearestPoint(pixelpoint);
        pos=gObj.getReportedPosition(closestIndex);
        pt=pos.getLocation(gObj);



        if numel(pt)==2
            pt(3)=0;
        end
        pt(:);
