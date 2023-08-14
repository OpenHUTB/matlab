classdef SourceTypeFilterForDataTypingServices<SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.SourceTypeFilter






    methods(Access=protected)
        function registerInvalidValues(this)
            this.InvalidValues={...
            'mask workspace'};
        end
    end
end