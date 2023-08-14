function covIdDfsMap=buildCovIdDfsMap(cvd)

    allDecCondIds=[];

    if isa(cvd,'cv.cvdatagroup')
        cvdata=cvd.getAll();
        cvdata=[cvdata{:}];
    else
        cvdata=cvd;
    end

    for i=1:length(cvdata)
        rootId=cvdata(i).rootId;
        cvId=cv('get',rootId,'.topSlsf');
        [elemIds,~]=cv('DfsOrder',cvId);

        mdlDecCondIds=arrayfun(@(id)getDecCond(id),elemIds,'UniformOutput',false);
        allDecCondIds=[allDecCondIds,mdlDecCondIds];%#ok<AGROW>
    end

    allDecCondIds=[allDecCondIds{:}];

    if isempty(allDecCondIds)
        covIdDfsMap=[];
        return;
    end

    covIdDfsMap=containers.Map(uint32(allDecCondIds),uint32(1:length(allDecCondIds)));

    function DecCondId=getDecCond(cvid)
        decid=cv('MetricGet',cvid,...
        cvi.MetricRegistry.getEnum('decision'),'.baseObjs');
        condid=cv('MetricGet',cvid,...
        cvi.MetricRegistry.getEnum('condition'),'.baseObjs');

        DecCondId=[decid,condid];
    end
end

