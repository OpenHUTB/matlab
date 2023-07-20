classdef DefaultPolarAxesInteractionSet<matlab.graphics.interaction.interface.BaseInteractionSet




    methods(Hidden)
        function display(~)
            disp(getString(message('MATLAB:graphics:interaction:PolarAxesInteractionsDisplay')));
        end

        function intarray=createInteractionArray(hObj,ax,is2dim)
            intarray=dataTipInteraction;
        end
    end
end

