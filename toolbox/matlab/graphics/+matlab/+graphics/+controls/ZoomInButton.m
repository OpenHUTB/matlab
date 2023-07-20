classdef(ConstructOnLoad)ZoomInButton<matlab.graphics.controls.ModeButton





    methods
        function obj=ZoomInButton()
            obj@matlab.graphics.controls.ModeButton();

            obj.ModeName='Exploration.Zoom';

            obj.Icon='zoomin';

            obj.Tag='Exploration.ZoomIn';

            obj.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
            .getString('TooltipString_Exploration_ZoomIn');
        end

        function setModeState(obj,state)
            if isfield(state,'Direction')
                if strcmp(state.Direction,'in')
                    obj.setModeState@matlab.graphics.controls.ModeButton(state);
                else
                    obj.Value=false;
                end
            end
        end

        function doModeOn(obj)
            fig=ancestor(obj,'figure');
            zoom(fig,['in','mode']);

            obj.doModeOn@matlab.graphics.controls.ModeButton();
        end

        function doModeOff(obj)
            fig=ancestor(obj,'figure');
            zoom(fig,'off');

            obj.doModeOff@matlab.graphics.controls.ModeButton();
        end
    end
end
