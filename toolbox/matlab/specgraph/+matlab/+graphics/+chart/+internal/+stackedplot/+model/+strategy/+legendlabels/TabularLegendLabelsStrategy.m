classdef TabularLegendLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.LegendLabelsStrategy




    methods
        function labels=getLegendLabels(~,chartData,axesIndex)
            tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
            t=tabularIndex.getSubTableForAxes(axesIndex);
            if width(t)==1
                labels=t.Properties.VariableNames;
                v=t.(1);
                if istabular(v)

                    innerLabels=v.Properties.VariableNames{1};
                    labels=strcat(labels,'.',innerLabels);
                    v=v.(1);
                end

                v=v(:,:);
                width_v=size(v,2);
                if width_v>1
                    labels=labels+" "+(1:width_v);
                    labels=cellstr(labels);
                end
            else
                rawlabels=t.Properties.VariableNames;
                widths=varfun(@(v)size(v(:,:),2),t,"OutputFormat","uniform");
                cumwidths=[0,cumsum(widths)];

                labels=strings(1,cumwidths(end));
                for j=1:length(rawlabels)
                    if widths(j)>1
                        labels(cumwidths(j)+1:cumwidths(j+1))=rawlabels{j}+" "+(1:widths(j));
                    else
                        labels(cumwidths(j)+1:cumwidths(j+1))=string(rawlabels{j});
                    end
                end
                labels=cellstr(labels);
            end
        end
    end
end
