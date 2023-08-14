

















classdef(Hidden=true)SimulationManagerEngine<handle
    properties(Dependent)
Options
    end

    properties(Access=private)
SimulationManager
    end

    methods(Access={?Simulink.SimulationManager})

        function obj=SimulationManagerEngine(simMgr)
            obj.SimulationManager=simMgr;
        end
    end

    methods
        function options=get.Options(obj)
            options=obj.SimulationManager.Options;
        end

        function set.Options(obj,newOptions)
            obj.SimulationManager.Options=newOptions;
        end

        function setup(obj)
            obj.SimulationManager.setup();
        end

        function out=executeSims(obj,fh,simInputs)
            obj.SimulationManager.SimulationInputs=simInputs;
            out=obj.SimulationManager.executeSims(fh);
        end

        function cancel(obj)
            obj.SimulationManager.cancel();
        end

        function cleanup(obj)
            obj.SimulationManager.cleanup();
        end
    end
end