classdef DefaultGeographicAxesInteractionSet<matlab.graphics.interaction.interface.BaseInteractionSet




    methods(Hidden)
        function display(hObj)
            disp(getString(message('MATLAB:graphics:interaction:GeographicAxesInteractionsDisplay')));
        end

        function intarray=createInteractionArray(hObj,ax,is2dim)
            intarray(1)=zoomInteraction;
            intarray(2)=dataTipInteraction;
            intarray(3)=panInteraction;
        end
    end
end

