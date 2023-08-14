classdef Actions




    enumeration
Click
DoubleClick
Scroll
DragStart
DragEnd
DragProgress
PinchStart
PinchEnd
PinchProgress
Swipe
Hover
Exit
RectangleEnter
RectangleExit
    end

    methods
        function output=toString(action)
            switch action
            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Click
                output="click";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Hover
                output="hover";
            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DoubleClick
                output="doubleClick";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Scroll
                output="scroll";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragStart
                output="dragstart";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragEnd
                output="dragend";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragProgress
                output="dragprogress";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.PinchStart
                output="pinchstart";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.PinchEnd
                output="pinchend";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.PinchProgress
                output="pinchprogress";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Swipe
                output="swipe";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Exit
                output="mouseleave";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.RectangleEnter
                output="RectangleEnter";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.RectangleExit
                output="RectangleExit";

            otherwise
                output="undefined";
            end
        end
    end
end
