
classdef CanvasPlugin
    properties
Factory
    end

    methods
        function hObj=CanvasPlugin(factory)
            hObj.Factory=factory;
        end


        function can=createCanvas(hObj)
            can=hObj.Factory.createCanvas();
            tbController=matlab.graphics.controls.internal.ToolbarFactory.getInstance.getToolbar(can);
            matlab.graphics.controls.internal.PostUpdatePlugin(can,tbController);
        end
    end

    methods(Static)



        function instance=getInstance()


            persistent canvasPlug;
            if isempty(canvasPlug)
                canvasPlug=matlab.graphics.controls.CanvasPlugin(...
                matlab.graphics.primitive.canvas.JavaCanvasFactory());
            end
            instance=canvasPlug;
        end
    end
end