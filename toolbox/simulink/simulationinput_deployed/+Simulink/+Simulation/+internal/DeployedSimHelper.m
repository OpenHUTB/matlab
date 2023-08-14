classdef DeployedSimHelper<Simulink.Simulation.internal.SimHelper
    methods(Static)
        function doPreSimulationChecks(~)

        end

        function simInput=doPreSimulationSetup(simInput)
        end

        function out=sim(simInput)
            out=builtin('sim',simInput);
        end

        function captureErrorInSimulationOutput(ME,modelName)%#ok<INUSD>






            assert(false,'Assertion failed in Simulink.Simulation.internal.SimHelper/captureErrorInSimulationOutput');
        end

        function executePostSimTasksOnSuccess(~)
        end

        function executePostSimTasksOnFailure(~)
        end

        function out=runUsingManager(in,varargin)
            out=arrayfun(@(simInput)sim(simInput),in);
        end

        function simInput=tuneParametersForRapidAccelerator(simInput,~)

        end
    end
end
