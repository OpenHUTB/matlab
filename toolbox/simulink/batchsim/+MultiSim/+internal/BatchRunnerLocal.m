classdef BatchRunnerLocal<MultiSim.internal.BatchRunner




    methods
        function obj=BatchRunnerLocal(cluster,simIns,parsimOptions,batchOptions)
            obj=obj@MultiSim.internal.BatchRunner(cluster,simIns,parsimOptions,batchOptions);
        end
    end

    methods(Access=protected)
        function prepareHeadNodeForSimulinkProject(obj)
            simulinkproject(obj.SimulinkProjectLocation);
        end

        function makeModelDependenciesAccessible(obj)





            obj.SimulinkProjectLocation=obj.getProjectRoot();




            obj.SlxcArchive=MultiSim.internal.getSlxcArchiveForModel(obj.ModelName);





            modelFile=which(obj.ModelName);
            modelPath=fileparts(modelFile);
            additionalPaths=[{modelPath},fileparts(obj.SlxcArchive)];
            obj.BatchOptions.AdditionalPaths=[obj.BatchOptions.AdditionalPaths,additionalPaths];
        end
    end
end