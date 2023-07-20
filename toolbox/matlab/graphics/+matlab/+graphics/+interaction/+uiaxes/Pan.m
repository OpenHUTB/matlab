classdef Pan<matlab.graphics.interaction.uiaxes.Drag&matlab.graphics.interaction.uiaxes.InteractionBase


    properties(Access=private)
        dataSpaceCopy=[];
        startPointPixels=[0,0];
        zoomMidDragListener;
        resetOrigLimitsAndPixelPointFlag=false;
    end

    methods
        function hObj=Pan(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.InteractionBase;
            hObj=hObj@matlab.graphics.interaction.uiaxes.Drag(obj,down,move,up);
            hObj.Axes=ax;
            hObj.Figure=ancestor(ax,'figure');
        end
    end

    methods(Access=protected,Sealed)
        function ret=validate(hObj,o,e)
            isvalid=hObj.strategy.isValidMouseEvent(hObj,o,e);
            ishit=hObj.strategy.isObjectHit(hObj,o,e);
            ret=isvalid&&ishit;
        end

        function custom=start(hObj,~,e)
            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(hObj.Figure,hObj.Axes,false);
            end

            custom.ruler_lengths=hObj.Axes.GetLayoutInformation.PlotBox(3:4);
            hObj.dataSpaceCopy=matlab.graphics.interaction.internal.copyDataSpace(hObj.Axes.DataSpace);
            hObj.startPointPixels=e.PointInPixels;
            hObj.zoomMidDragListener=event.listener(hObj.strategy,'PostZoom',@(~,~)hObj.resetOrigLimitsAndPixelPoint);
        end

        function move(hObj,~,e,c)
            if hObj.resetOrigLimitsAndPixelPointFlag
                hObj.dataSpaceCopy=matlab.graphics.interaction.internal.copyDataSpace(hObj.Axes.DataSpace);
                hObj.startPointPixels=e.PointInPixels;
                hObj.resetOrigLimitsAndPixelPointFlag=false;
            end

            orig_limits=[0,1,0,1,0,1];
            pixeldiff=e.PointInPixels-hObj.startPointPixels;
            norm_limits=matlab.graphics.interaction.internal.pan.panFromPixelToPixel2D(orig_limits,pixeldiff,c.ruler_lengths);
            hObj.strategy.setUntransformedPanLimitsInternal(hObj.Axes,hObj.dataSpaceCopy,norm_limits(1:2),norm_limits(3:4));
        end

        function stop(hObj,~,~,~)
            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(hObj.Figure,hObj.Axes,true);
            end
            hObj.zoomMidDragListener=[];
        end

        function cancel(hObj,~,~,~)
            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(hObj.Figure,hObj.Axes,true);
            end
            hObj.zoomMidDragListener=[];
        end
    end

    methods(Access=private)
        function resetOrigLimitsAndPixelPoint(hObj)
            hObj.resetOrigLimitsAndPixelPointFlag=true;
        end
    end
end
