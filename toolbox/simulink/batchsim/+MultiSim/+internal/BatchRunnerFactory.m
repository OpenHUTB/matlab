classdef BatchRunnerFactory<handle






    properties(Constant,Access=private)
        objInstance=MultiSim.internal.BatchRunnerFactory
    end

    properties
        Policy=@MultiSim.internal.BatchRunnerFactory.defaultPolicy
    end

    methods(Static)
        function instance=getInstance()
            instance=MultiSim.internal.BatchRunnerFactory.objInstance;
        end

        function resetPolicy()
            instance=MultiSim.internal.BatchRunnerFactory.getInstance();
            instance.Policy=@MultiSim.internal.BatchRunnerFactory.defaultPolicy;
        end
    end

    methods(Access=private)
        function obj=BatchRunnerFactory
        end
    end

    methods(Static,Access=private)
        function runner=defaultPolicy(cluster,simIns,parsimOptions,batchOptions)
            if isa(cluster,'parallel.cluster.Local')
                runner=MultiSim.internal.BatchRunnerLocal(cluster,simIns,parsimOptions,batchOptions);
            else
                runner=MultiSim.internal.BatchRunnerNonLocal(cluster,simIns,parsimOptions,batchOptions);
            end
        end
    end

    methods
        function runner=create(obj,varargin)
            runner=obj.Policy(varargin{:});
        end
    end
end