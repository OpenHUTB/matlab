classdef(ConstructOnLoad)PanButton<matlab.graphics.controls.ModeButton





    methods
        function obj=PanButton()
            obj@matlab.graphics.controls.ModeButton();

            obj.ModeName='Exploration.Pan';

            obj.Icon='pan';

            obj.Tag='Exploration.Pan';
            obj.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
            .getString('TooltipString_Exploration_Pan');
        end

        function doModeOn(obj)
            fig=ancestor(obj,'figure');
            pan(fig,'on');

            obj.doModeOn@matlab.graphics.controls.ModeButton();
        end

        function doModeOff(obj)
            fig=ancestor(obj,'figure');
            pan(fig,'off');

            obj.doModeOff@matlab.graphics.controls.ModeButton();
        end
    end
end
