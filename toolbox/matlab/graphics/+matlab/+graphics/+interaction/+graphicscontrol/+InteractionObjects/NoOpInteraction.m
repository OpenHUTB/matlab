classdef NoOpInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase



    methods
        function this=NoOpInteraction()
            this.Type='noop';
        end

        function props=getPropertiesToSendToWeb(~)
            props={};
        end

        function response(obj,eventdata)%#ok<INUSD>

        end
    end
end
