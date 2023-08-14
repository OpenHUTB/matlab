classdef CostGraph<handle














    properties(SetAccess=private)
        Model char
        Graph digraph=digraph()
CostMap
    end

    properties(Access=private)
CostUtilContainer
    end

    methods

        function obj=CostGraph(aModel)
            obj.Model=aModel;
            obj.CostMap=containers.Map;
            obj.CostUtilContainer=designcostestimation.internal.graphutil.CostTopoUtilityContainer();
            obj.buildGraph();
        end




        function addCostEstimates(obj,aCostResult)
            obj.CostUtilContainer.addUtilitiesToTopo(aCostResult);
            obj.Graph=obj.CostUtilContainer.Graph;
            obj.buildCostMap(aCostResult);
        end




        function cost=getCost(obj,aPath)


            if obj.isValidPath(aPath)
                aBlockCost=obj.CostMap(aPath);
                cost=aBlockCost.getBlockCost();
            else
                cost=0;
            end
        end





        function cost=getTotalCost(obj,aPath)


            if obj.isValidPath(aPath)
                aBlockCost=obj.CostMap(aPath);
                cost=aBlockCost.getTotalCost();
            else
                cost=0;
            end
        end

    end

    methods(Hidden)




        function buildGraph(obj)
            obj.CostUtilContainer=obj.CostUtilContainer.buildGraph(obj.Model);
            obj.Graph=obj.CostUtilContainer.Graph;
        end




        function fIsValidPath=isValidPath(obj,aPath)
            if isKey(obj.CostMap,aPath)
                fIsValidPath=true;
            else
                fIsValidPath=false;
            end
        end


        function buildCostMap(obj,aResult)
            obj.addNodesToMap(aResult);
            obj.findTotalCostForBlocks(obj.Model);
        end


        function newCost=findTotalCostForBlocks(obj,aPath)
            if(~isKey(obj.CostMap,aPath))
                obj.addNodeToMap(aPath,0);
            end
            aPathStr=string(aPath);
            successorBlocks=designcostestimation.internal.graphutil.CostTopoContainer.findAllSuccessors(obj.Graph,aPathStr);
            successorCosts=arrayfun(@obj.findTotalCostForBlocks,successorBlocks);
            totalSuccessorCost=sum(successorCosts);
            aBlockCostObj=obj.CostMap(aPath);
            newCost=obj.getCost(aPath);
            newTotalCost=totalSuccessorCost+obj.getCost(aPath);
            aBlockCostObj.setTotalCost(newTotalCost);
        end


        function addNodesToMap(obj,aCostResult)
            BlocksCostTable=aCostResult.BlockwiseCost;

            func=@(BlockName,BlockCost)obj.addNodeToMap(BlockName,BlockCost);
            rowfun(func,BlocksCostTable,'NumOutputs',0);
        end


        function addNodeToMap(obj,aBlockName,aBlockCost)
            aBlockNameStr=string(aBlockName);
            obj.CostMap(aBlockNameStr)=designcostestimation.internal.graphutil.BlockCost(aBlockNameStr,aBlockCost);
        end


        function CostTable=getCostTable(obj)

            allBlockID=obj.Graph.Nodes.Handle>0;

            allBlocks=obj.Graph.Nodes(allBlockID,:).FullName;
            allCosts=cellfun(@(x)obj.getCost(x),allBlocks);
            allTotalCosts=cellfun(@(x)obj.getTotalCost(x),allBlocks);
            CostTable=table(allBlocks(:),allCosts(:),allTotalCosts(:),'VariableNames',...
            {'BlockName','BlockCost','TotalBlockCost'});
        end

    end
end


