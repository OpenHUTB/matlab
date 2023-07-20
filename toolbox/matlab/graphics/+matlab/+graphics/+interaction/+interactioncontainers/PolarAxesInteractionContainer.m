classdef PolarAxesInteractionContainer<matlab.graphics.interaction.interactioncontainers.StandardAxesInteractionContainer




    methods

        function hObj=PolarAxesInteractionContainer(ax)
            hObj=hObj@matlab.graphics.interaction.interactioncontainers.StandardAxesInteractionContainer(ax);
        end

        function arr=getDefaultInteractionsArray(~)
            arr=matlab.graphics.interaction.interface.DefaultPolarAxesInteractionSet;
        end

        function s=getDefaultStrategy(~)
            s=matlab.graphics.interaction.uiaxes.DefaultAxesInteractionStrategy();
        end

        function validateInteractions(~,ints)
            for i=1:numel(ints)
                isInteractionAndNotDataTip=isa(ints(i),'matlab.graphics.interaction.interface.BaseInteraction')&&...
                ~isa(ints(i),'matlab.graphics.interaction.interactions.DataTipInteraction');

                isInteractionSetAndNotPolar=isa(ints(i),'matlab.graphics.interaction.interface.BaseInteractionSet')&&...
                ~isa(ints(i),'matlab.graphics.interaction.interface.PolarAxesInteractionSet');

                if isInteractionAndNotDataTip||isInteractionSetAndNotPolar
                    ME=MException(message('MATLAB:graphics:interaction:PolarAxesInteractionsProperty',class(ints(i))));
                    throwAsCaller(ME);
                end
            end
        end
    end
end

