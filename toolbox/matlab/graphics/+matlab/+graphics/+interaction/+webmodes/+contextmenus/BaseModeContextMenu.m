classdef BaseModeContextMenu<handle




    properties
        contextMenu;
    end

    methods(Hidden)
        function ModeResetPlotView(~,hAxes)
            resetplotview(hAxes,'ApplyStoredView');
        end
    end
end
