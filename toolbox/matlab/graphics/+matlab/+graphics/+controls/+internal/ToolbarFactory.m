classdef ToolbarFactory<handle




    methods(Static)

        function obj=getInstance()
            persistent factoryInstance;
            mlock;
            if isempty(factoryInstance)
                factoryInstance=matlab.graphics.controls.internal.ToolbarFactory;
            end
            obj=factoryInstance;
        end
    end

    methods(Access=private)
        function obj=ToolbarFactory
        end
    end

    methods(Access=public)
        function controller=getToolbar(~,canvas)
            canvasType=class(canvas);

            switch(canvasType)
            case 'matlab.graphics.primitive.canvas.HTMLCanvas'
                controller=matlab.graphics.controls.WebToolbarController.getInstance(canvas);
                return;
            case 'matlab.graphics.primitive.canvas.JavaCanvas'
                controller=matlab.graphics.controls.DesktopToolbarController.getInstance(canvas);
                return;
            end
        end
    end
end

