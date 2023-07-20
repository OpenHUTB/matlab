function applyFilter(obj)




    data=obj.data;
    appliedFilterIds=obj.getAppliedFilterIds;
    filterFileNames='';
    if~isempty(appliedFilterIds)
        filterFileNames=obj.parentTree.resultsExplorer.filterExplorer.getFilterFileName(appliedFilterIds);
    end

    data.applyFilterOnCvData(filterFileNames);
end