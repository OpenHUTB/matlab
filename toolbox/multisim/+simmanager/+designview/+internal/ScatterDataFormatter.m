classdef ScatterDataFormatter<simmanager.designview.internal.FigureObjectDataFormatter
    methods


        function obj=ScatterDataFormatter(figureData)
            obj=obj@simmanager.designview.internal.FigureObjectDataFormatter(figureData);
        end

        function[newXData]=formatXData(obj,paramId)
            if strcmp(paramId.Id,'')
                newXData=nan(obj.FigureData.NumSims,1);
                return;
            end

            newXData=obj.FigureData.getParamVals(paramId);
        end

        function newYData=formatYData(obj,paramId)
            if strcmp(paramId.Id,'')
                newYData=nan(obj.FigureData.NumSims,1);
                return;
            end

            newYData=obj.FigureData.getParamVals(paramId);
        end

        function[newCData,newNanIds]=formatCData(obj,paramId)
            if strcmp(paramId.Id,'')
                newCData=nan(obj.FigureData.NumSims,1);
                newNanIds=[];
                return;
            end

            newCData=obj.FigureData.getParamVals(paramId);
            newNanIds=find(arrayfun(@(x)any(isnan(newCData(x,:))),1:size(newCData,1)));
        end

        function paramVal=getSingleParamVal(obj,paramId,runId)
            if strcmp(paramId.Id,'')
                paramVal=NaN;
                return;
            end


            paramVal=obj.FigureData.getSingleParamVal(paramId,runId);
        end



        function[newXData,newYData,newCData,newNaNIds]=...
            formatAllData(obj,xDataId,yDataId,cDataId)
            newXData=obj.formatXData(xDataId);
            newYData=obj.formatYData(yDataId);
            [newCData,newNaNIds]=obj.formatCData(cDataId);
        end




    end
end