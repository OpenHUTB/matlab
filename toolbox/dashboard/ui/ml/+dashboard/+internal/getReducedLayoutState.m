function state=getReducedLayoutState(rootFolder)




    state=[];
    ps=alm.internal.ProjectService.get(rootFolder);
    adapter=ps.getAdapter();
    currentSetting=adapter.getMetaData("ReducedLayout");
    if~isempty(currentSetting)
        state=strcmp(currentSetting,'true');
    end
end

