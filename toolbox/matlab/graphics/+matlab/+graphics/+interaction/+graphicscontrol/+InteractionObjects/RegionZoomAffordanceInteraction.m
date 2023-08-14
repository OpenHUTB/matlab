classdef RegionZoomAffordanceInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitInteractionBase



    properties
        ShowConstrainedROI(1,1)logical=true;
    end

    methods
        function this=RegionZoomAffordanceInteraction
            this.Type='regionzoomaffordance';
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function props=getPropertiesToSendToWeb(~)
            props={'DimX','DimY','DimZ','ShowConstrainedROI'};
        end

        function response(obj,eventdata)%#ok<INUSD>
        end
    end
end
