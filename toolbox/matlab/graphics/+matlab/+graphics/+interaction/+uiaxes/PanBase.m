classdef PanBase<matlab.graphics.interaction.uiaxes.Drag&matlab.graphics.interaction.uiaxes.InteractionBase&matlab.graphics.interaction.uiaxes.LimitInteractionBase



    methods
        function hObj=PanBase(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.InteractionBase;
            hObj=hObj@matlab.graphics.interaction.uiaxes.Drag(obj,down,move,up);
            hObj.Axes=ax;
            hObj.Figure=ancestor(ax,'figure','node');
        end
    end

    methods(Access=protected)
        function ret=validate(hObj,o,e)
            isvalid=hObj.strategy.isValidMouseEvent(hObj,o,e);
            ishit=hObj.strategy.isObjectHit(hObj,o,e);
            ret=isvalid&&ishit;
        end
    end

    methods(Access=protected,Sealed)
        function custom=start(hObj,~,e)
            import matlab.graphics.interaction.*


            if isprop(hObj.Axes,'CameraTargetMode')
                hObj.Axes.CameraTargetMode='auto';
            end
            if isprop(hObj.Axes,'CameraPositionMode')
                hObj.Axes.CameraPositionMode='auto';
            end


            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(hObj.Figure,hObj.Axes,false);
            end

            custom=matlab.graphics.interaction.uiaxes.PanBase.getPanStartdata(hObj.Axes,e.PointInPixels);
            custom.is2D=is2D(hObj.Axes);
            custom.addeddata=hObj.addeventdata(custom);
        end

        function move(hObj,~,e,c)

            curr_ray=matlab.graphics.interaction.internal.pan.transformPixelsToPoint(c.transform,e.PointInPixels);

            norm_limits=hObj.performpan(e,c,curr_ray);

            if c.is2D
                clamped_limits=matlab.graphics.interaction.internal.constrainNormalizedLimitsToDimensions(norm_limits,hObj.Dimensions);
                hObj.strategy.setUntransformedPanLimitsInternal(hObj.Axes,c.dataSpaceCopy,clamped_limits(1:2),clamped_limits(3:4));
            else
                hObj.strategy.setUntransformedPanLimitsInternal(hObj.Axes,c.dataSpaceCopy,norm_limits(1:2),norm_limits(3:4),norm_limits(5:6));
            end
        end

        function stop(hObj,~,~,~)
            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(hObj.Figure,hObj.Axes,true);
            end
            matlab.graphics.interaction.internal.setInteractiveDDUXData(hObj.Axes,hObj.getdduxinteractionname,'default');
        end

        function cancel(hObj,~,~,~)
            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(hObj.Figure,hObj.Axes,true);
            end
        end
    end

    methods(Abstract,Access=protected)
        c=addeventdata(~,~)
        norm_limits=performpan(hObj,e,c,curr_ray)
        i=getdduxinteractionname(hObj);
    end

    methods(Static)
        function startdata=getPanStartdata(axes,point)
            import matlab.graphics.interaction.*
            startdata.Point=point;
            startdata.dataSpaceCopy=internal.copyDataSpace(axes.ActiveDataSpace);


            startdata.orig_axlim=[0,1,0,1,0,1];

            startdata.transform=internal.pan.getMVP(axes);
            startdata.orig_ray=internal.pan.transformPixelsToPoint(startdata.transform,startdata.Point);
        end
    end
end