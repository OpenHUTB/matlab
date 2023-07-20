function atomicSubchartCB(cbinfo)
    [state,~]=SFStudio.Utils.getRootStateAndModel(cbinfo);
    sfprivate('toggleIsAtomicSubchart',cbinfo.studio.App.getActiveEditor,state);
end