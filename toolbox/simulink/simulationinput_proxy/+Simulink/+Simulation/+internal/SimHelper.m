classdef(Abstract)SimHelper
    methods(Abstract,Static)
        doPreSimulationChecks(simInputs)
        doPreSimulationSetup(simInput)
        sim(simInput)
        captureErrorInSimulationOutput(ME,simInput)
        executePostSimTasksOnSuccess(simInput)
        executePostSimTasksOnFailure(simInput)
        runUsingManager(simInputs,varargin)
        tuneParametersForRapidAccelerator(simInput,rtp)
    end
end