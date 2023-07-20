classdef PlotFormatSetEventData<event.EventData

    properties(Access=public)
PlotID
NewFormat
    end

    methods(Access=public)
        function this=PlotFormatSetEventData(id,format)
            this.PlotID=id;
            this.NewFormat=format;
        end
    end

end