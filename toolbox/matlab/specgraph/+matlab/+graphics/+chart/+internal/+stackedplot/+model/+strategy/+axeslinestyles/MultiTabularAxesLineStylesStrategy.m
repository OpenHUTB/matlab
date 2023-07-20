classdef MultiTabularAxesLineStylesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesLineStylesStrategy




    methods
        function s=getAxesLineStyles(~,chartData,axesIndex)


            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            tbls=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);






            s=[];
            plotName2LineStyleMap=dictionary(cell.empty,double.empty);
            for i=1:numel(tbls)
                t=tbls{i};
                var=t.(1);
                outerVarName=t.Properties.VariableNames{1};
                if istabular(var)
                    for j=1:width(var)
                        varInner=var.(j);
                        innerVarName=var.Properties.VariableNames{j};
                        for columnNum=1:width(varInner(:,:))
                            plotName={{outerVarName,innerVarName,columnNum}};
                            plotName2LineStyleMap=updateLineStyleMapping(plotName2LineStyleMap,plotName);
                            s=[s,plotName2LineStyleMap(plotName)];%#ok<AGROW> 
                        end
                    end
                else
                    innerVarName={};
                    for columnNum=1:width(var(:,:))
                        plotName={{outerVarName,innerVarName,columnNum}};
                        plotName2LineStyleMap=updateLineStyleMapping(plotName2LineStyleMap,plotName);
                        s=[s,plotName2LineStyleMap(plotName)];%#ok<AGROW> 
                    end
                end
            end
        end
    end
end

function plotName2LineStyleMap=updateLineStyleMapping(plotName2LineStyleMap,plotName)

    if~isKey(plotName2LineStyleMap,plotName)
        plotName2LineStyleMap(plotName)=numEntries(plotName2LineStyleMap)+1;
    end
end