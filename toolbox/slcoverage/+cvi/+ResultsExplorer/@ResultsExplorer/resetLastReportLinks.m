function resetLastReportLinks(obj)




    allData=obj.maps.uniqueIdMap.values;
    for idx=1:numel(allData)
        d=allData{idx};
        d.resetLastReport;
    end
    d=obj.root.activeTree.root.data;
    if~isempty(d)
        d.resetLastReport;
    end
end