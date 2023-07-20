classdef MultiTabularAxesSeriesIndicesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesSeriesIndicesStrategy




    methods
        function s=getAxesSeriesIndices(~,chartData,axesIndex)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            [tbls,tblIdx]=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);




            s=[];
            for i=1:numel(tbls)
                t=tbls{i};
                var=t.(1);
                if istabular(var)
                    for j=1:width(var)
                        varInner=var.(j);
                        indices=repmat(tblIdx(i),1,width(varInner(:,:)));
                        s=[s,indices];%#ok<AGROW> 
                    end
                else
                    indices=repmat(tblIdx(i),1,width(var(:,:)));
                    s=[s,indices];%#ok<AGROW> 
                end
            end
        end
    end
end