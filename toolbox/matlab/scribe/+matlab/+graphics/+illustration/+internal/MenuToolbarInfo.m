classdef MenuToolbarInfo<handle




    properties
        Figure matlab.ui.Figure;

        CurrentAxesListener event.proplistener;

        LegendMenu;

        LegendToggle;

        ColorbarMenu;

        ColorbarToggle;
    end

    methods
        function hObj=MenuToolbarInfo(fig)
            hObj.CurrentAxesListener=addlistener(fig,'CurrentAxes','PostSet',@(h,e)matlab.graphics.illustration.internal.updateLegendMenuToolbar(h,e,[]));
        end
    end
end
