classdef Action




    enumeration
Click
DoubleClick
Scroll
Drag
Pinch
Swipe
Hover
Exit
RectangleEnterExit
    end

    methods
        function output=toString(action)
            switch action
            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Click
                output="click";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Hover
                output="hover";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.DoubleClick
                output="doubleClick";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Scroll
                output="scroll";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag
                output="drag";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Pinch
                output="pinch";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Swipe
                output="swipe";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Exit
                output="mouseleave";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.RectangleEnterExit
                output="mouseleave";

            otherwise
                output="undefined";
            end
        end

        function actions=getActions(action)
            switch action
            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag
                actions=[matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragStart
                matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragProgress
                matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragEnd];
            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.RectangleEnterExit
                actions=[matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.RectangleEnter
                matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.RectangleExit];
            case matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Pinch
                actions=[matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.PinchStart
                matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.PinchProgress
                matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.PinchEnd];
            otherwise
                actions=action;
            end
        end
    end
end
