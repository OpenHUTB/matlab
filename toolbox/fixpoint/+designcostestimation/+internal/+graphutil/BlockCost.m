classdef BlockCost<handle





    properties(SetAccess=private)
        ThisBlockCost(1,1)double{mustBeNonnegative}=0
        TotalCost(1,1)double{mustBeNonnegative}=0
OpCount
        BlockName(1,1)string
    end

    methods

        function obj=BlockCost(aBlockName,aThisBlockCost)
            obj.OpCount=table;
            obj.BlockName=aBlockName;
            obj.ThisBlockCost=aThisBlockCost;
        end


        function cost=getBlockCost(obj)
            cost=obj.ThisBlockCost;
        end


        function cost=getTotalCost(obj)
            cost=obj.TotalCost;
        end
    end

    methods(Hidden)

        function setTotalCost(obj,aTotalCost)
            obj.TotalCost=aTotalCost;
        end


        function setOperatorCount(obj,aOpCountTable)
            obj.OpCount=aOpCountTable;
        end
    end
end
