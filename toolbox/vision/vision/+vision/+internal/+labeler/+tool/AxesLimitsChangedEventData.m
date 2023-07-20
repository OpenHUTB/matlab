
classdef(ConstructOnLoad)AxesLimitsChangedEventData<event.EventData

    properties

XLim
YLim

    end

    methods

        function this=AxesLimitsChangedEventData(xLim,yLim)

            this.XLim=xLim;
            this.YLim=yLim;

        end

    end

end