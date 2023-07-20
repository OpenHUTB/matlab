classdef DisplayEventData<event.EventData
    properties
        DisplayFig;
        IsAppClosing;
    end
    methods
        function this=DisplayEventData(fig,isAppClosing)
            this.DisplayFig=fig;
            this.IsAppClosing=isAppClosing;
        end
    end
end