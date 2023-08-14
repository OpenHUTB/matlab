classdef DataSegmentEstimate<designcostestimation.internal.costestimate.CostEstimate





    properties(SetAccess=private)
Design
ID
        TotalMemoryConsumption(1,1)double{mustBeNonnegative}=0;
        CostTable table
    end

    methods

        function obj=DataSegmentEstimate(model)
            obj.Design=model;
            obj.ID="DataSegmentEstimate";
        end
    end

    methods(Hidden)

        function setCostInformation(obj,totalCost,costTable)
            obj.TotalMemoryConsumption=totalCost;
            obj.CostTable=costTable;
        end


        function setDiagnostics(obj,diagnostics)
            obj.Diagnostics=diagnostics;
        end

    end

end


