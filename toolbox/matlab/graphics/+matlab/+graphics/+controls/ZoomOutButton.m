classdef(ConstructOnLoad)ZoomOutButton<matlab.graphics.controls.ModeButton





    methods
        function obj=ZoomOutButton()
            obj@matlab.graphics.controls.ModeButton();

            obj.ModeName='Exploration.Zoom';

            obj.Icon='zoomout';

            obj.Tag='Exploration.ZoomOut';

            obj.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
            .getString('TooltipString_Exploration_ZoomOut');
        end

        function setModeState(obj,state)
            if isfield(state,'Direction')
                if strcmp(state.Direction,'out')
                    obj.setModeState@matlab.graphics.controls.ModeButton(state);
                else
                    obj.Value=false;
                end
            end
        end

        function doModeOn(obj)
            fig=ancestor(obj,'figure');
            zoom(fig,['out','mode']);

            obj.doModeOn@matlab.graphics.controls.ModeButton();
        end

        function doModeOff(obj)
            fig=ancestor(obj,'figure');
            zoom(fig,'off');

            obj.doModeOff@matlab.graphics.controls.ModeButton();
        end

    end
end
