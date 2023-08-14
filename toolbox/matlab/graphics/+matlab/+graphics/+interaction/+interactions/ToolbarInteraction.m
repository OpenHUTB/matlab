classdef ToolbarInteraction<matlab.graphics.interaction.interface.BaseInteraction




    methods(Hidden)
        function ints=createInteraction(~,~,~)

            ints=[];
        end

        function ints=createWebInteraction(obj,can,ax)
            ints=obj.createToolbarInteraction(can,ax);
        end

        function ints=createGeographicInteraction(obj,ax,fig)
            ints=obj.createToolbarInteraction(fig.getCanvas(),ax);
        end

        function interaction=createToolbarInteraction(~,canvas,ax)
            interaction=matlab.graphics.controls.internal.AxesToolbarInteraction(canvas,ax);
        end
    end
end

