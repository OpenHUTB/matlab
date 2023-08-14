classdef EditInteraction<matlab.graphics.interaction.interface.BaseInteraction




    methods(Hidden)
        function e=createInteraction(~,text)

            e=matlab.graphics.interaction.uiaxes.EditInteraction(text);
        end

        function e=createWebInteraction(~,text)

            e=matlab.graphics.interaction.graphicscontrol.InteractionObjects.TextInteraction.EditInteraction(text);
        end
    end

end
