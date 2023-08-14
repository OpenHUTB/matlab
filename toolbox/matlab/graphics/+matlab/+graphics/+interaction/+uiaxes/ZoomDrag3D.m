classdef ZoomDrag3D<matlab.graphics.interaction.uiaxes.Drag&matlab.graphics.interaction.uiaxes.InteractionBase


    properties(Access=private)
        Damping=300;
    end

    methods
        function hObj=ZoomDrag3D(ax,obj,down,move,up)
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
            import matlab.graphics.interaction.*


            hObj.Axes.CameraTargetMode='auto';
            hObj.Axes.CameraPositionMode='auto';

            dataspace=hObj.Axes.ActiveDataSpace;
            pt=e.IntersectionPoint;
            custom.MousePoint=e.PointInPixels;
            custom.TransformedPoint=internal.TransformPoint(dataspace,pt);
            custom.DataSpaceCopy=internal.copyDataSpace(dataspace);
            custom.DataPoint=pt;
        end

        function move(hObj,~,e,c)
            import matlab.graphics.interaction.*

            starting_pt=c.MousePoint;
            curr_pixels=e.PointInPixels;

            xy=sum(curr_pixels-starting_pt);
            zoom_factor=2.^(xy/hObj.Damping);

            orig_limits=[0,1,0,1,0,1];
            trans_limits=internal.zoom.zoomAroundPoint3D(orig_limits,c.TransformedPoint,zoom_factor);
            [new_xlim,new_ylim,new_zlim]=internal.UntransformLimits(c.DataSpaceCopy,trans_limits(1:2),trans_limits(3:4),trans_limits(5:6));
            hObj.strategy.setZoomLimitsInternal(hObj.Axes,new_xlim,new_ylim,new_zlim);
        end

        function stop(~,~,~,~),end
        function cancel(~,~,~,~),end
    end
end
