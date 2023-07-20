

function clearHighlightForNonDiagramObject(handleOrId,domain)
    if strcmpi(domain,'stateflow')
        obj=sf('IdToHandle',handleOrId);
        if isa(obj,'Stateflow.Data')
            utils.toggleHighlightForSFData(handleOrId,false);
        end
    end
end