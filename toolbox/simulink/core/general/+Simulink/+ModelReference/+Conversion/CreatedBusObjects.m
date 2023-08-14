classdef CreatedBusObjects<handle




    properties(SetAccess=private,GetAccess=public)
DataAccessor
BusNames
BusIds
BusObjects
    end

    methods(Access=public)
        function this=CreatedBusObjects(dataAccessor,busNames)
            this.DataAccessor=dataAccessor;
            this.BusNames=busNames;
            this.BusIds=cellfun(@(busName)dataAccessor.identifyByName(busName),...
            busNames,'UniformOutput',false);
            this.BusObjects=cellfun(@(busId)dataAccessor.getVariable(busId),...
            this.BusIds,'UniformOutput',false);


            this.clear;
        end
    end

    methods(Access=private)
        function clear(this)
            cellfun(@(busId)this.DataAccessor.deleteVariable(busId),...
            this.BusIds,'UniformOutput',false);
        end
    end
end
