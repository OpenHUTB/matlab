classdef(ConstructOnLoad)DataCursorButton<matlab.graphics.controls.ModeButton





    methods
        function obj=DataCursorButton()
            obj@matlab.graphics.controls.ModeButton();

            obj.ModeName='Exploration.Datacursor';

            obj.Icon='datacursor';
            obj.Tag='Exploration.DataCursor';

            obj.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
            .getString('TooltipString_Exploration_DataCursor');
        end

        function doModeOn(obj)
            fig=ancestor(obj,'figure');
            datacursormode(fig,'on');

            obj.doModeOn@matlab.graphics.controls.ModeButton();
        end

        function doModeOff(obj)
            fig=ancestor(obj,'figure');
            datacursormode(fig,'off');

            obj.doModeOff@matlab.graphics.controls.ModeButton();
        end
    end
end
