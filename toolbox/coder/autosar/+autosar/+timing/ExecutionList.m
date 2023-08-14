classdef(Hidden,Abstract)ExecutionList<handle







    properties(Transient,SetAccess=protected)
        ModelName;
    end

    methods
        function this=ExecutionList(modelName)
            this.ModelName=modelName;
        end
    end

    methods(Abstract)
        setExecutionOrder(this,rootSlEntryPointFunctions,swcNames)




        getExecutionOrder(this)




    end
end


