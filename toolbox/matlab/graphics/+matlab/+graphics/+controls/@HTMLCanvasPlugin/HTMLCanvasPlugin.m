
classdef HTMLCanvasPlugin
    properties
        Factory;
    end

    methods
        function hObj=HTMLCanvasPlugin(factory)
            hObj.Factory=factory;
        end


        function can=createCanvas(hObj)
            can=hObj.Factory.createCanvas();
            matlab.graphics.controls.internal.ToolbarFactory.getInstance.getToolbar(can);
        end
    end

    methods(Static)



        function instance=getInstance()


            persistent htmlcanvasPlug;
            if isempty(htmlcanvasPlug)
                htmlcanvasPlug=matlab.graphics.controls.HTMLCanvasPlugin(...
                matlab.graphics.primitive.canvas.HTMLCanvasFactory());
            end
            instance=htmlcanvasPlug;
        end
    end
end