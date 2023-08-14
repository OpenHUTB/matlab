

function toggleHighlightForSFData(backendId,enable)
    chartId=sfprivate('getChartOf',backendId);
    chartHandle=sfprivate('chart2block',chartId);
    model=bdroot(chartHandle);
    modelHandle=get_param(model,'Handle');
    studioApps=SLM3I.SLDomain.getAllStudioAppsFor(modelHandle);
    for studioIdx=1:numel(studioApps)
        studio=studioApps(studioIdx).getStudio();
        studioTag=studio.getStudioTag();
        symbolManager=Stateflow.internal.SymbolManager.GetSymbolManagerForStudio(studioTag);
        if~isempty(symbolManager)&&symbolManager~=0&&isvalid(symbolManager)
            if enable
                symbolManager.highlightRowsForIds(backendId,[]);
            else
                symbolManager.removeStyle('CONTAINS_USE');
            end
        end
    end
end