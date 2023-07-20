

function highlightNonDiagramObject(handleOrId,domain)
    if strcmpi(domain,'stateflow')
        obj=sf('IdToHandle',handleOrId);
        if isa(obj,'Stateflow.Data')
            utils.toggleHighlightForSFData(handleOrId,true);
        end
    end
end