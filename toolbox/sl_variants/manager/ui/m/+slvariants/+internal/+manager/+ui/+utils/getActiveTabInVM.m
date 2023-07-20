function activeTab=getActiveTabInVM(modelHandle)




    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);

    vMgrToolStrip=vmStudioHandle.getToolStrip;
    activeTab=vMgrToolStrip.ActiveTab;
end
