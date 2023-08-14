classdef CostEstimator<handle






    properties(SetAccess=private)
ModelsUnderSUDandAssociatedCostsMap
CostEstimatorConfig
    end

    properties(SetAccess=private)

Diagnostics
DiagArr
OpWeights
    end


    methods

        function obj=CostEstimator(aModelsUnderSUDandAssociatedCostsMap,aCostOption)
            obj.ModelsUnderSUDandAssociatedCostsMap=aModelsUnderSUDandAssociatedCostsMap;
            obj.CostEstimatorConfig=aCostOption;
            obj.setupDiagnostics();
        end


        function generateCost(obj)
            costStructs=values(obj.ModelsUnderSUDandAssociatedCostsMap);
            for i=1:obj.ModelsUnderSUDandAssociatedCostsMap.Count
                obj.generateCostFor(costStructs{i});
            end
        end


        function generateCostFor(obj,aCostStruct)
            OperatorCounts=aCostStruct.OpCount;
            if(isempty(OperatorCounts))
                return;
            end
            numOfOperations=size(OperatorCounts(:,1));
            Totalcost=0;
            blockName=cell(numOfOperations);
            blockCost=zeros(numOfOperations);
            OperatorWeightObj=obj.CostEstimatorConfig.OperatorWeights;

            for a=1:numOfOperations
                currentOperationDataType=OperatorCounts{a,4};
                currentOperation=char(OperatorCounts{a,3});
                currentOperationWeight=OperatorWeightObj.getWeight(currentOperation,currentOperationDataType);
                if(obj.CostEstimatorConfig.EnableDiagnostics)
                    obj.updateDiagnostics(currentOperation,currentOperationDataType);
                end

                currentCost=(OperatorCounts{a,2}*currentOperationWeight);
                blockName{a}=char(OperatorCounts{a,1});
                blockCost(a)=currentCost;
                Totalcost=Totalcost+currentCost;
            end

            aCostStruct.setTotalCost(Totalcost);
            aCostStruct.setBlockwiseCost(obj.getBlockWiseCost(blockName,blockCost,numOfOperations));
            if(obj.CostEstimatorConfig.EnableDiagnostics)

                obj.finalizeDiagnostics();

                aCostStruct.setDiagnostics(obj.Diagnostics);
            end
        end
    end


    methods(Hidden)

        function setupDiagnostics(obj)
            obj.OpWeights=designcostestimation.internal.OperatorsWeight2d();

            numRows=numel(obj.OpWeights.SupportedOperators);
            numCols=numel(obj.OpWeights.SupportedDatatypes);
            obj.DiagArr=zeros(numRows,numCols);
        end


        function updateDiagnostics(obj,currentOp,currentOpDatatype)
            rowNum=find(strcmp(obj.OpWeights.SupportedOperators,currentOp));
            colNum=find(strcmp(obj.OpWeights.SupportedDatatypes,currentOpDatatype));
            obj.DiagArr(rowNum,colNum)=obj.DiagArr(rowNum,colNum)+1;
        end


        function finalizeDiagnostics(obj)
            t=array2table(obj.DiagArr,'VariableNames',obj.OpWeights.SupportedDatatypes,...
            "RowNames",obj.OpWeights.SupportedOperators);
            obj.Diagnostics=setfield(obj.Diagnostics,'HistTable',t);
        end
    end


    methods(Static,Hidden)



        function blockwiseCostTable=getBlockWiseCost(blockNameCellArr,blockCostArr,numOfOperations)
            aBlockCostMap=containers.Map;
            for a=1:numOfOperations
                currBlockName=blockNameCellArr{a};
                currBlockCost=blockCostArr(a);
                if(isKey(aBlockCostMap,currBlockName))
                    currCost=aBlockCostMap(currBlockName);
                    aBlockCostMap(currBlockName)=currCost+currBlockCost;
                else
                    aBlockCostMap(currBlockName)=currBlockCost;
                end
            end
            BlockName=keys(aBlockCostMap);
            BlockCost=cell2mat(values(aBlockCostMap));
            blockwiseCostTable=table(BlockName',BlockCost','VariableNames',{'BlockName','BlockCost'});
        end
    end

end
