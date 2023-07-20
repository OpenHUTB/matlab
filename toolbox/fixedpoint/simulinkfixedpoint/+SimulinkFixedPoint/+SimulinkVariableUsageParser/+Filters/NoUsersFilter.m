classdef NoUsersFilter<SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.UsersFilter





    methods(Access=protected)
        function registerInvalidUsers(this)

            this.InvalidUsers={@(x)false};
        end
    end
end