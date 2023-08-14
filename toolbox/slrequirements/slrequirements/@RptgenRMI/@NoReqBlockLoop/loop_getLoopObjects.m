function hList=loop_getLoopObjects(this)










    adSL=rptgen_sl.appdata_sl;
    adSL.Context='System';
    hList=getLoopBlocks(this);


    [~,idx]=setdiff(hList,adSL.ReportedSystemList);
    hList=hList(sort(idx));

    hList=hList(:);

    if reqmgt('rmiFeature','Experimental')
        objTypeFilters=rmi.settings_mgr('get','coverageSettings','objTypeFilters');
        if~isempty(objTypeFilters)
            hList=rmisl.filterByType(hList,objTypeFilters);
        end
    end


    filtIdx=true(length(hList),1);
    for idx=1:length(hList)
        reqs=rmi.getReqs(hList{idx});
        if~isempty(reqs)&&any([reqs.linked])
            filtIdx(idx)=false;
        end
    end
    hList=hList(filtIdx);
