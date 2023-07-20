classdef AnalysisResult<handle






    properties(SetAccess=private)
        TotalCost{mustBeNonnegative}
OpCount
        ModelName char
BlockwiseCost
        Diagnostics struct
    end

    methods

        function obj=AnalysisResult(modelName)
            obj.TotalCost=0;
            obj.OpCount=table;
            obj.BlockwiseCost=table;
            obj.ModelName=modelName;
        end


        function setOperatorCount(obj,aOpCount)
            obj.OpCount=aOpCount;
        end


        function setTotalCost(obj,aTotalCost)
            obj.TotalCost=aTotalCost;
        end


        function setBlockwiseCost(obj,aBlockwiseCost)
            obj.BlockwiseCost=aBlockwiseCost;
        end


        function setDiagnostics(obj,Diagnostics)
            obj.Diagnostics=Diagnostics;
        end

    end
end
