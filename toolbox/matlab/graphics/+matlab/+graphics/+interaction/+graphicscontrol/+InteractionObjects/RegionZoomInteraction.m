classdef RegionZoomInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitInteractionBase




    methods
        function this=RegionZoomInteraction
            this.Type='regionzoom';

            this.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom;
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function props=getPropertiesToSendToWeb(~)
            props={'DimX','DimY','DimZ'};
        end

        function preresponse(this,~)
            this.captureOldLimits(this.Object);
        end

        function response(obj,eventdata)%#ok<INUSD>
        end

        function postresponse(this,~)
            this.addToUndoStack(this.Object,'Zoom');
            this.generateCode(this.Object);
        end

    end
end
