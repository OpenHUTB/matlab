classdef CanvasSetup<handle




    methods(Static)
        function createScribeLayers(canvas)
            cM=canvas.StackManager;
            if isempty(cM)
                cM=matlab.graphics.shape.internal.ScribeStackManager.getInstance;
                canvas.StackManager=cM;
            end

            cM.getLayer(canvas,'overlay');
            cM.getLayer(canvas,'middle');
            cM.getLayer(canvas,'underlay');
        end
    end
end
