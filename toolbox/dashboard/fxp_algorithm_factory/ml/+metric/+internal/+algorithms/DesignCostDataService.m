classdef DesignCostDataService<metric.DataService




    methods
        function obj=DesignCostDataService()
            obj.AlgorithmID='DesignCostDataService';
            obj.Version=1;
        end

        function resources=collectData(this,collectionScopeUuid,queryResult)
            resources=metric.internal.algorithms.DesignCostDataServiceResource(...
            this.ID,collectionScopeUuid);
            queryArtifacts=queryResult.getSequences();
            this.runCostEstimation(queryArtifacts{1}{1},resources);
        end


        function runCostEstimation(~,queryArtifact,resources)
            if(string(queryArtifact.Type)~="sl_block_diagram")
                return;
            end
            modelName=queryArtifact.Label;
            artifactID=queryArtifact.Id;
            service=designcostestimation.internal.services.LifetimeManagement(modelName);
            objCleanup=onCleanup(@()restoreDesigns(service));
            [ProgramSizeEstimate,DataSegmentEstimate]=designcostestimation.internal.estimateSLMetricsCost(modelName);
            resources.EstimationData.ProgramSizeEstimate(artifactID)=ProgramSizeEstimate;
            resources.EstimationData.DataSegmentEstimate(artifactID)=DataSegmentEstimate;
        end
    end
end


