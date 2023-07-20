



classdef SimulationCompletedEvent<event.EventData
    properties
        ResultSet sltest.testmanager.ResultSet;
    end

    methods
        function this=SimulationCompletedEvent(rs)
            this.ResultSet=rs;
        end
    end
end
