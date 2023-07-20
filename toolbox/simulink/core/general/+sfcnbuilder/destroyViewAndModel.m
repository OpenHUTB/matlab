function destroyViewAndModel(blockHandle)
    sfunctionbuilderMgr=sfunctionbuilder.internal.sfunctionbuilderMgr.getInstance();
    sfunctionbuilderMgr.destroyUI(blockHandle);
    sfunctionbuilderMgr.destroyModel(blockHandle);
end
