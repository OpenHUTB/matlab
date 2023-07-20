classdef LimitZoom3D<matlab.graphics.interaction.uiaxes.Drag&matlab.graphics.interaction.uiaxes.InteractionBase


    properties(Access=private)
        ZoomFactor=1.5;
        Damping=300;
    end

    methods
        function hObj=LimitZoom3D(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.InteractionBase;
            hObj=hObj@matlab.graphics.interaction.uiaxes.Drag(obj,down,move,up);
            hObj.Axes=ax;
            hObj.Figure=obj;
        end
    end

    methods(Access=protected,Sealed)
        function ret=validate(hObj,o,e)
            isvalid=hObj.strategy.isValidMouseEvent(hObj,o,e);
            ishit=hObj.strategy.isObjectHit(hObj,o,e);
            ret=isvalid&&ishit;
        end

        function custom=start(hObj,~,e)
            origlimits=matlab.graphics.interaction.getDoubleAxesLimits(hObj.Axes);
            datapoint=matlab.graphics.interaction.internal.zoom.chooseLimitZoom3DPoint(origlimits,e,hObj.Axes);
            pixelpoint=e.PointInPixels;
            custom=matlab.graphics.interaction.uiaxes.LimitZoom3D.startImpl(hObj.Axes,pixelpoint,datapoint);
        end

        function move(hObj,~,e,c)
            currpixels=e.PointInPixels;
            [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.uiaxes.LimitZoom3D.moveImpl(hObj.Damping,currpixels,c);
            hObj.strategy.setZoomLimitsInternal(hObj.Axes,new_xlim,new_ylim,new_zlim);
        end

        function stop(hObj,~,e,c)
            import matlab.graphics.interaction.*
            if e.PointInPixels==c.MousePoint
                orig_limits=[0,1,0,1,0,1];
                xlim=internal.zoom.zoomAxisAroundPoint(orig_limits(1:2),c.TransformedPoint(1),hObj.ZoomFactor);
                ylim=internal.zoom.zoomAxisAroundPoint(orig_limits(3:4),c.TransformedPoint(2),hObj.ZoomFactor);
                zlim=internal.zoom.zoomAxisAroundPoint(orig_limits(5:6),c.TransformedPoint(3),hObj.ZoomFactor);
                [new_xlim,new_ylim,new_zlim]=internal.UntransformLimits(c.DataSpaceCopy,xlim,ylim,zlim);
                hObj.strategy.setZoomLimitsInternal(hObj.Axes,new_xlim,new_ylim,new_zlim);
            end
        end

        function cancel(~,~,~),end
    end

    methods(Static)
        function custom=startImpl(hAxes,pixelPoint,dataPoint)

            hAxes.CameraTargetMode='auto';
            hAxes.CameraPositionMode='auto';

            dataspace=hAxes.ActiveDataSpace;

            custom.TransformedPoint=matlab.graphics.interaction.internal.TransformPoint(dataspace,dataPoint);
            custom.MousePoint=pixelPoint;
            custom.DataSpaceCopy=matlab.graphics.interaction.internal.copyDataSpace(dataspace);
        end

        function[new_xlim,new_ylim,new_zlim]=moveImpl(damping,pixelPoint,startData)
            import matlab.graphics.interaction.*

            starting_pt=startData.MousePoint;

            xy=sum(pixelPoint-starting_pt);
            zoom_factor=2.^(xy/damping);

            orig_limits=[0,1,0,1,0,1];
            trans_limits=internal.zoom.zoomAroundPoint3D(orig_limits,startData.TransformedPoint,zoom_factor);
            [new_xlim,new_ylim,new_zlim]=internal.UntransformLimits(startData.DataSpaceCopy,trans_limits(1:2),trans_limits(3:4),trans_limits(5:6));

        end
    end
end
