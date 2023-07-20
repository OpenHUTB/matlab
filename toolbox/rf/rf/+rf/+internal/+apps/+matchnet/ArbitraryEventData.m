classdef ArbitraryEventData<event.EventData
    properties(Access=public)
data
    end

    methods(Access=public)
        function this=ArbitraryEventData(datain)
            this.data=datain;
        end
    end
end