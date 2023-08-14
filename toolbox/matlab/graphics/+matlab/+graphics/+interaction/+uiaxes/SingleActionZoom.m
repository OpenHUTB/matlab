classdef SingleActionZoom<matlab.graphics.interaction.uiaxes.InteractionBase&...
    matlab.graphics.interaction.uiaxes.LimitInteractionBase


    properties
        zoom_factor=1.1;
    end

    methods
        function hObj=SingleActionZoom(ax)
            hObj.Axes=ax;
            hObj.Figure=ancestor(ax,'figure','node');
        end
    end

    methods(Access=protected)
        function invert=invertzoomfactor(~,~)
            invert=false;
        end

        function pt=getzoompoint(~,e)
            pt=e.IntersectionPoint;
        end
    end

    methods
        function apply(hObj,o,e,invert)
            import matlab.graphics.interaction.*
            if~hObj.strategy.isValidMouseEvent(hObj,o,e)||...
                ~hObj.strategy.isObjectHit(hObj,o,e)
                return;
            end

            pt=uiaxes.SingleActionZoom.getIntPt(hObj.Axes,e);
            if any(isnan(pt))
                return
            end

            if invert
                zf=1/hObj.zoom_factor;
            else
                zf=hObj.zoom_factor;
            end
            zoomcallback(hObj,zf,pt);
        end
    end

    methods(Access=private)
        function zoomcallback(hObj,zf,pt)
            import matlab.graphics.interaction.*

            [new_xlim,new_ylim,new_zlim]=uiaxes.SingleActionZoom.calculateSingleShotZoom(hObj.Axes,pt,zf);
            normalized_limits=[new_xlim,new_ylim,new_zlim];
            constrained_limits=matlab.graphics.interaction.internal.constrainNormalizedLimitsToDimensions(normalized_limits,hObj.Dimensions);
            if is2D(hObj.Axes)
                hObj.strategy.setUntransformedZoomLimitsInternal(hObj.Axes,hObj.Axes.ActiveDataSpace,constrained_limits(1:2),constrained_limits(3:4));
            else


                hObj.strategy.setUntransformedZoomLimitsInternal(hObj.Axes,hObj.Axes.ActiveDataSpace,constrained_limits(1:2),constrained_limits(3:4),constrained_limits(5:6));
            end
        end
    end

    methods(Static)
        function[norm_xlim,norm_ylim,norm_zlim]=calculateSingleShotZoom(ax,point,zf)
            import matlab.graphics.interaction.*
            lims=[0,1,0,1,0,1];

            trans_point=internal.TransformPoint(ax.ActiveDataSpace,point(:));
            norm_xlim=internal.zoom.zoomAxisAroundPoint(lims(1:2),trans_point(1),zf);
            norm_ylim=internal.zoom.zoomAxisAroundPoint(lims(3:4),trans_point(2),zf);
            norm_zlim=internal.zoom.zoomAxisAroundPoint(lims(5:6),trans_point(3),zf);
        end






        function intpt=getIntPt(ax,e)
            import matlab.graphics.interaction.*

            if is2D(ax)
                intpt=e.IntersectionPoint;
                if any(isnan(intpt))
                    hFig=ancestor(ax,'figure');
                    pixelpt=internal.getPointInPixels(hFig,e.Point);
                    intpt=internal.calculateIntersectionPoint(pixelpt,ax);
                end
            else
                OrigLimits=getDoubleAxesLimits(ax);
                intpt=internal.zoom.chooseLimitZoom3DPoint(OrigLimits,e,ax);
            end
        end
    end
end
