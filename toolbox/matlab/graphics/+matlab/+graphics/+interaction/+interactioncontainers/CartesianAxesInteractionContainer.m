classdef CartesianAxesInteractionContainer<matlab.graphics.interaction.interactioncontainers.StandardAxesInteractionContainer




    properties(Hidden)




PanDisabled
ZoomDisabled

PanConstraint2D
PanConstraint3D
ZoomConstraint2D
ZoomConstraint3D
    end

    methods
        function hObj=CartesianAxesInteractionContainer(ax)
            hObj=hObj@matlab.graphics.interaction.interactioncontainers.StandardAxesInteractionContainer(ax);
        end

        function arr=getDefaultInteractionsArray(~)
            arr=matlab.graphics.interaction.interface.DefaultAxesInteractionSet;
        end

        function s=getDefaultStrategy(hObj)
            s=matlab.graphics.interaction.uiaxes.DefaultAxesInteractionStrategy();
        end

        function validateInteractions(~,interactions)
            for i=1:numel(interactions)
                interaction=interactions(i);

                isValidInteraction=~isa(interaction,...
                'matlab.graphics.interaction.interactions.EditInteraction');

                if(~isValidInteraction)
                    ME=MException(message('MATLAB:graphics:interaction:CartesianAxesInteractionsProperty',class(interaction)));
                    throwAsCaller(ME);
                end
            end
        end
    end
end
