classdef RotateInteraction<matlab.graphics.interaction.interface.BaseInteraction




    methods(Hidden)
        function r=createInteraction(~,ax,fig)
            r=matlab.graphics.interaction.uiaxes.Rotate(ax,fig,'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
        end

        function r=createWebInteraction(~,can,ax)
            r=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RotateInteraction(can,ax);
            r.Object=ax;
        end
    end
end
