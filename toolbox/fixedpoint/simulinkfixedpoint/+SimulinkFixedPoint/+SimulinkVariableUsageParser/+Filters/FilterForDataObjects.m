classdef FilterForDataObjects<SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.UsersFilter






    methods(Access=protected)
        function registerInvalidUsers(this)
            this.InvalidUsers={...
            @(x)isa(x,'Simulink.ModelReference'),...
            @(x)isa(x,'Simulink.SubSystem')&&strcmpi(x.SFBlockType,'NONE')
            };
        end
    end
end


