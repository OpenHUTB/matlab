function setReducedLayoutState(rootFolder,newState)
    newVal='true';

    if(~newState)
        newVal='false';
    end
    ps=alm.internal.ProjectService.get(rootFolder);
    adapter=ps.getAdapter();
    adapter.setMetaData('ReducedLayout',newVal);
end

