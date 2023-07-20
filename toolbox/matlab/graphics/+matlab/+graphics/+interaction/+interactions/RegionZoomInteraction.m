classdef RegionZoomInteraction<matlab.graphics.interaction.interface.ConstrainableInteraction&matlab.graphics.interaction.interface.BaseInteraction




    methods(Hidden)
        function p=createInteraction(hObj,ax,fig)
            p1=matlab.graphics.interaction.uiaxes.ROIZoom(ax,fig,'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
            p1.Dimensions=hObj.Dimensions;

            p2=matlab.graphics.interaction.uiaxes.ROIZoomAffordance(ax,fig,'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
            p2.Dimensions=hObj.Dimensions;

            p=[p1,p2];
        end

        function p=createWebInteraction(hObj,can,ax)
            p1=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RegionZoomInteraction;
            p1.Dimensions=hObj.Dimensions;
            p1.Object=ax;

            p2=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RegionZoomAffordanceInteraction;
            p2.Dimensions=hObj.Dimensions;
            p2.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pointer;
            p2.Object=ax;

            p=[p1,p2];
        end
    end
end
