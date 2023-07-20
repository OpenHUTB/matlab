




function descrTable=setMetricEnums(descrTable)
    s=size(descrTable);
    for idx=1:s(1)
        mn=descrTable{idx,2};
        metricedataId=cv('find','all','metricdescr.name',mn);
        descrTable{idx,4}=cv('get',metricedataId,'.enumVal');
    end

