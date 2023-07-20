classdef PanInteraction<matlab.graphics.interaction.interface.ConstrainableInteraction&matlab.graphics.interaction.interface.BaseInteraction




    methods(Hidden)
        function p=createInteraction(hObj,ax,fig)
            p=matlab.graphics.interaction.uiaxes.Pan3D(ax,fig,'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
            p.Dimensions=hObj.Dimensions;
        end

        function p=createWebInteraction(hObj,~,ax)
            p=matlab.graphics.interaction.graphicscontrol.InteractionObjects.PanInteraction(ax);
            p.Dimensions=hObj.Dimensions;
        end

        function p=createGeographicInteraction(hObj,ax,fig)
            p=matlab.graphics.interaction.uiaxes.Pan(ax,fig,...
            'WindowMousePress','WindowMouseMotion','WindowMouseRelease');

        end

        function p=createGeographicWebInteraction(hObj,~,ax)
            p=matlab.graphics.interaction.graphicscontrol.InteractionObjects.GeographicPanInteraction(ax);

        end
    end
end
