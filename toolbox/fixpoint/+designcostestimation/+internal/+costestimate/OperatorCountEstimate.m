classdef OperatorCountEstimate<designcostestimation.internal.costestimate.CostEstimate






    properties(SetAccess=private)
Design
ID
        TotalCost(1,1)double{mustBeNonnegative}=0
        CostTable table
    end

    properties(Hidden,SetAccess=private)
        CostGraph designcostestimation.internal.graphutil.CostGraph
        RawCostDetails table
    end

    methods

        function obj=OperatorCountEstimate(Model)
            obj.Design=Model;
            obj.ID="OperatorCount";
        end


        function SelfCost=componentSelfCost(obj,BlockName)
            SelfCost=obj.CostGraph.getCost(BlockName);
        end


        function TotalCost=componentTotalCost(obj,BlockName)
            TotalCost=obj.CostGraph.getTotalCost(BlockName);
        end


        function generateReport(obj)

            resource.ProgramSizeEstimate=containers.Map('KeyType','char','ValueType','any');
            resource.ProgramSizeEstimate(obj.Design)=obj;
            resource.DataSegmentEstimate=[];

            reportGenService=designcostestimation.internal.services.ReportGeneration(resource,[obj.Design,' Cost Estimation report'],'pdf',pwd);
            reportGenService.runService();
        end
    end

    methods(Hidden)
        function setCostGraph(obj,CostGraph)

            obj.CostGraph=CostGraph;
            obj.TotalCost=CostGraph.getTotalCost(obj.Design);
            obj.CostTable=obj.CostGraph.getCostTable();
        end


        function SetRawCostInformation(obj,rawInfo)
            obj.RawCostDetails=rawInfo;
        end



        function setDiagnostics(obj,Diagnostics)
            obj.Diagnostics=Diagnostics;
        end



        function visualizeCostOnCanvas(obj)

            open_system(obj.Design);
            allModels=find_mdlrefs(obj.Design);

            load_system(allModels);

            designcostestimation.internal.util.drawCostForAllBlocksOnCanvas(obj.CostTable);
        end

        function visualizeCostAsGraph(obj)

            designcostestimation.internal.graphutil.plotCostGraph(obj.CostGraph,"TotalCost");
        end

    end

end
