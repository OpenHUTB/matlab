classdef(ConstructOnLoad)BrushButton<matlab.graphics.controls.ModeButton





    methods
        function obj=BrushButton()
            obj@matlab.graphics.controls.ModeButton();

            obj.ModeName='Exploration.Brushing';

            obj.Icon='brush';

            obj.Tag='Exploration.Brushing';

            obj.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
            .getString('TooltipString_Exploration_Brushing');
        end

        function doModeOn(obj)
            fig=ancestor(obj,'figure');
            brush(fig,'on');

            obj.doModeOn@matlab.graphics.controls.ModeButton();
        end

        function doModeOff(obj)
            fig=ancestor(obj,'figure');
            brush(fig,'off');

            obj.doModeOff@matlab.graphics.controls.ModeButton();
        end
    end
end
