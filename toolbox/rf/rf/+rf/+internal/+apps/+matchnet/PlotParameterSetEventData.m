classdef PlotParameterSetEventData<event.EventData

    properties(Access=public)
PlotID
NewParameters
    end

    methods(Access=public)
        function this=PlotParameterSetEventData(id,params)
            this.PlotID=id;
            this.NewParameters=params;
        end
    end

end