function atomicChartContext=buildSubChartContext(atomicChartObj,context,chart)






    if isempty(context)
        atomicChartContext=[atomicChartObj.Path,'/',atomicChartObj.Name];
        if~isa(atomicChartObj.getParent,'Stateflow.Chart')




            atomicChartContext(length(chart.Path)+2:end)=...
            strrep(atomicChartContext(length(chart.Path)+2:end),'/','.');
        end
    else
        if strncmp(context,atomicChartObj.Path,length(context))
            atomicChartContext=[atomicChartObj.Path,'/',atomicChartObj.Name];
        else


            subpath=atomicChartObj.Path;
            subpath(1:length(chart.Path))=[];
            atomicChartContext=[context,subpath,'/',atomicChartObj.Name];
        end
        if~isa(atomicChartObj.getParent,'Stateflow.Chart')

            atomicChartContext(length(context)+2:end)=...
            strrep(atomicChartContext(length(context)+2:end),'/','.');
        end
    end
end

