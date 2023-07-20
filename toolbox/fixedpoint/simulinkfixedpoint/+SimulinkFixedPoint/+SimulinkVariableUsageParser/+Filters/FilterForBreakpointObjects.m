classdef FilterForBreakpointObjects<SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.FilterForDataObjects






    methods(Access=protected)
        function registerInvalidUsers(this)
            registerInvalidUsers@SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.FilterForDataObjects(this)
            this.InvalidUsers=[this.InvalidUsers,{@(x)isa(x,'Simulink.Interpolation_nD')}];
        end
    end
end