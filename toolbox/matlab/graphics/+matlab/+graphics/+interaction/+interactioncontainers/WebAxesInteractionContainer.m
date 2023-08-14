classdef WebAxesInteractionContainer<matlab.graphics.interaction.interactioncontainers.AxesInteractionContainer




    methods
        function hObj=WebAxesInteractionContainer(ax)
            hObj=hObj@matlab.graphics.interaction.interactioncontainers.AxesInteractionContainer(ax);
        end

        function arr=getDefaultInteractionsArray(~)
            arr=matlab.graphics.interaction.interface.DefaultWebAxesInteractionSet;
        end

        function s=getDefaultStrategy(~)
            s=[];
        end

        function validateInteractions(~,ints)
            if any(isa(ints,'matlab.graphics.interaction.interface.RulerPanInteraction'))
                ME=MException('MATLAB:graphics:interactions','matlab.graphics.interaction.interface.RulerPanInteraction is not supported on Web Axes');
                throwAsCaller(ME);
            end
        end
    end
end
