classdef MultiTableAxesXDataStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesXDataStrategy




    methods
        function x=getAxesXData(~,chartData,axesIndex)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            [tbls,tblIdx]=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);
            xVariable=chartData.XVariable;
            if isempty(xVariable)
                x=cellfun(@(t)(1:height(t))',tbls,"UniformOutput",false);
            else
                xVariable=string(xVariable);
                sourceTables=chartData.SourceTable;
                if isscalar(xVariable)
                    x=arrayfun(@(i)sourceTables{i}.(xVariable),tblIdx,"UniformOutput",false);
                else
                    x=arrayfun(@(i)sourceTables{i}.(xVariable(i)),tblIdx,"UniformOutput",false);
                end
            end
        end
    end
end
