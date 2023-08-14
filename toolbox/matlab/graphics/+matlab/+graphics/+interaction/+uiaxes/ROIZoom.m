classdef ROIZoom<matlab.graphics.interaction.uiaxes.Drag&matlab.graphics.interaction.uiaxes.InteractionBase&matlab.graphics.interaction.uiaxes.LimitInteractionBase



    properties
        zoom_factor=1.5;
        invert_on_shift=true;
    end

    properties(Access=private)
shiftkeylist
    end

    methods
        function hObj=ROIZoom(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.Drag(obj,down,move,up);
            hObj=hObj@matlab.graphics.interaction.uiaxes.InteractionBase;
            hObj.shiftkeylist=matlab.graphics.interaction.uiaxes.ModifierKeyListener(obj,'shift');
            hObj.Axes=ax;
            hObj.Figure=ancestor(ax,'figure');
        end
    end

    methods
        function enable(hObj)
            enable@matlab.graphics.interaction.uiaxes.Drag(hObj)
            if hObj.invert_on_shift
                hObj.shiftkeylist.enable();
            end
        end

        function disable(hObj)
            disable@matlab.graphics.interaction.uiaxes.Drag(hObj)
            if hObj.invert_on_shift
                hObj.shiftkeylist.disable();
            end
        end
    end


    methods(Access=protected)
        function ret=validate(hObj,o,e)
            isvalid=hObj.strategy.isValidMouseEvent(hObj,o,e);
            ishit=hObj.strategy.isObjectHit(hObj,o,e);
            is2d=is2D(hObj.Axes);
            ret=isvalid&&ishit&&is2d;
        end

        function custom=start(hObj,~,e)
            import matlab.graphics.interaction.*

            custom.start_point_pixels=e.PointInPixels;
            custom.start_point_normalized=internal.TransformPoint(hObj.Axes.ActiveDataSpace,e.IntersectionPoint(:));
        end

        function stop(hObj,~,e,c)
            import matlab.graphics.interaction.*

            orig_limits=[0,1,0,1,0,1];
            zf=hObj.getzoomfactor(e);
            intpt=e.IntersectionPoint(:);
            if any(isnan(intpt))||any(isnan(c.start_point_normalized))
                return;
            end

            trans_point=internal.TransformPoint(hObj.Axes.ActiveDataSpace,intpt);
            normalized_limits=uiaxes.ROIZoom.calculateZoomedLimits(zf,orig_limits,c.start_point_pixels,e.PointInPixels,...
            c.start_point_normalized,trans_point);

            normalized_limits_with_z=[normalized_limits,0,1];
            constrained_limits=matlab.graphics.interaction.internal.constrainNormalizedLimitsToDimensions(normalized_limits_with_z,hObj.Dimensions);
            [new_xlim,new_ylim,~]=internal.UntransformLimits(hObj.Axes.ActiveDataSpace,constrained_limits(1:2),constrained_limits(3:4),[0,1]);
            hObj.strategy.setZoomLimitsInternal(hObj.Axes,new_xlim,new_ylim);
            matlab.graphics.interaction.internal.setInteractiveDDUXData(hObj.Axes,'regionzoom','default');
        end

        function move(~,~,~,~),end
        function cancel(~,~,~,~),end
    end


    methods(Access=protected)
        function zf=getzoomfactor(hObj,e)
            zf=hObj.zoom_factor;
            if hObj.invertzoomfactor(e)
                zf=1/hObj.zoom_factor;
            end
        end

        function invert=invertzoomfactor(hObj,e)
            if hObj.invert_on_shift
                invert=hObj.shiftkeylist.iskeypressed(e);
            end
        end
    end

    methods(Static)
        function zoom_limits=calculateZoomedLimits(zf,orig_limits,start_point_pixels,end_point_pixels,...
            start_point_data,end_point_data)
            import matlab.graphics.interaction.internal.zoom.zoomAxisAroundPoint
            dist_in_x=abs(start_point_pixels(1)-end_point_pixels(1));
            dist_in_y=abs(start_point_pixels(2)-end_point_pixels(2));
            x_not_far_enough=dist_in_x<15;
            y_not_far_enough=dist_in_y<15;

            if(dist_in_x==0)&&(dist_in_y==0)
                zoom_limits=orig_limits;
                return;
            end


            if(x_not_far_enough&&y_not_far_enough)
                xlim=zoomAxisAroundPoint(orig_limits(1:2),end_point_data(1),zf);
                ylim=zoomAxisAroundPoint(orig_limits(3:4),end_point_data(2),zf);
            else

                if(x_not_far_enough)
                    start_point_data(1)=orig_limits(1);
                    end_point_data(1)=orig_limits(2);

                elseif(y_not_far_enough)
                    start_point_data(2)=orig_limits(3);
                    end_point_data(2)=orig_limits(4);
                end

                xlim=sort([start_point_data(1),end_point_data(1)]);
                ylim=sort([start_point_data(2),end_point_data(2)]);
            end
            zoom_limits=[xlim(1),xlim(2),ylim(1),ylim(2)];
        end
    end
end
