classdef DefaultAxesInteractionSet<matlab.graphics.interaction.interface.BaseInteractionSet




    methods(Hidden)
        function display(~)
            disp(getString(message('MATLAB:graphics:interaction:CartesianAxesInteractionsDisplay')));
        end

        function intarray=createInteractionArray(hObj,ax,is2dim)
            intarray=matlab.graphics.interaction.interface.BaseInteraction.empty;
            intarray(end+1)=zoomInteraction;
            intarray(end+1)=dataTipInteraction;
            if is2dim
                intarray(end+1)=panInteraction;
            else
                intarray(end+1)=rotateInteraction;
            end
            intarray(end+1)=rulerPanInteraction;

        end
    end

end

