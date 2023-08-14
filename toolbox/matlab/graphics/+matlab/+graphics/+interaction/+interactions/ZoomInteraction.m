classdef ZoomInteraction<matlab.graphics.interaction.interface.ConstrainableInteraction&matlab.graphics.interaction.interface.BaseInteraction




    methods(Hidden)
        function z=createInteraction(hObj,ax,fig)
            z=matlab.graphics.interaction.uiaxes.ScrollZoom(ax,fig,'WindowScrollWheel','WindowMouseMotion');
            z.Dimensions=hObj.Dimensions;
        end

        function ints=createWebInteraction(hObj,~,ax)
            scrollzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.ZoomInteraction(ax);
            scrollzoom.Dimensions=hObj.Dimensions;

            pinchpanzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.PinchPanZoomInteraction;
            pinchpanzoom.Dimensions=hObj.Dimensions;
            pinchpanzoom.Object=ax;

            ints=[scrollzoom;pinchpanzoom];
        end

        function z=createGeographicInteraction(hObj,ax,fig)
            z=matlab.graphics.interaction.uiaxes.ScrollZoom(ax,fig,'WindowScrollWheel','WindowMouseMotion');
            z.zoom_factor=2^(1/ax.StepsPerZoomLevelScrollWheel);
        end

        function ints=createGeographicWebInteraction(hObj,~,ax)
            scrollzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.GeographicZoomInteraction(ax);
            ints=scrollzoom;
        end
    end
end
