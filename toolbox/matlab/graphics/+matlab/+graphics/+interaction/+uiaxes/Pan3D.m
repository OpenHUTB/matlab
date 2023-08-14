classdef Pan3D<matlab.graphics.interaction.uiaxes.InteractionBase&matlab.graphics.interaction.uiaxes.LimitInteractionBase


    properties
        PanHandle matlab.graphics.interaction.uiaxes.InteractionBase

Down
Move
Up
    end

    methods
        function hObj=Pan3D(ax,obj,down,move,up)
            hObj.Axes=ax;
            hObj.Figure=obj;
            hObj.Down=down;
            hObj.Move=move;
            hObj.Up=up;
        end

        function enable(hObj)
            switch(hObj.Dimensions)
            case{"x","y","z"}
                hObj.PanHandle=matlab.graphics.interaction.uiaxes.AxisPan(hObj.Axes,hObj.Figure,hObj.Down,hObj.Move,hObj.Up);
            case{"xy","yz","xz"}
                hObj.PanHandle=matlab.graphics.interaction.uiaxes.PlanePan(hObj.Axes,hObj.Figure,hObj.Down,hObj.Move,hObj.Up);
            otherwise
                hObj.PanHandle=matlab.graphics.interaction.uiaxes.UnconstrainedPan(hObj.Axes,hObj.Figure,hObj.Down,hObj.Move,hObj.Up);
            end
            hObj.PanHandle.Dimensions=hObj.Dimensions;
            hObj.PanHandle.strategy=hObj.strategy;
            hObj.PanHandle.enable();
        end

        function disable(hObj)
            hObj.PanHandle.disable();
            hObj.PanHandle.abort();
        end

        function abort(hObj)
            hObj.PanHandle.abort();
        end

    end
end
