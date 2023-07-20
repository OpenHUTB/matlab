classdef SimulationRunnerParallelMJSConfig<MultiSim.internal.SimulationRunnerParallelBaseConfig




    properties
        FunctionDependencyAnalysisHandler(1,1)function_handle=@MultiSim.internal.functionDependencyAnalysis
        AttachFilesToPoolHandler(1,1)function_handle=@MultiSim.internal.attachFilesToPool
    end
end