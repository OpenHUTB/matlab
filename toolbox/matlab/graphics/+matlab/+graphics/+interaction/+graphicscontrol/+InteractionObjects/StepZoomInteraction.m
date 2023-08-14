classdef StepZoomInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitInteractionBase




    properties
        DirectionOut=false;
    end

    methods
        function this=StepZoomInteraction
            this.Type='stepzoom';
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Click;
        end

        function props=getPropertiesToSendToWeb(~)
            props={'DirectionOut'};
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
