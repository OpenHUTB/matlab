classdef(ConstructOnLoad)RotateButton<matlab.graphics.controls.ModeButton




    properties(Hidden)


        Was3d=false;
    end

    methods
        function obj=RotateButton()
            obj@matlab.graphics.controls.ModeButton();

            obj.ModeName='Exploration.Rotate3d';

            obj.Icon='rotate';

            obj.Tag='Exploration.Rotate';

            obj.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
            .getString('TooltipString_Exploration_Rotate');
        end

        function doModeOn(obj)
            fig=ancestor(obj,'figure');
            rotate3d(fig,'on','-orbit');

            obj.doModeOn@matlab.graphics.controls.ModeButton();
        end

        function doModeOff(obj)
            fig=ancestor(obj,'figure');
            rotate3d(fig,'off');

            obj.doModeOff@matlab.graphics.controls.ModeButton();
        end
    end
end
