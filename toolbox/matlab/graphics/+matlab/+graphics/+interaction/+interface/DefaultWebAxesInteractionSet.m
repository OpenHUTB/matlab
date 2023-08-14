classdef DefaultWebAxesInteractionSet<matlab.graphics.interaction.interface.BaseInteractionSet




    methods(Hidden)
        function display(hObj)
            fprintf(['\nWebAxesInteractionsSet includes the following interactions\n\n'...
            ,'\tPanInteraction (2D Axes)\n'...
            ,'\tZoomInteraction\n'...
            ,'\tDataTipInteraction\n'...
            ,'\tRotateInteraction (3D Axes)\n\n']);
        end

        function intarray=createInteractionArray(~,~,is2dim)
            intarray(1)=zoomInteraction;
            intarray(2)=dataTipInteraction;
            if is2dim
                intarray(end+1)=panInteraction;
            else
                intarray(end+1)=rotateInteraction;
            end
        end
    end
end

