function setViewBlocksMode(cbinfo)



    cbinfo.Context.Object.setBlocksViewInfo(cbinfo.EventData);
    slvariants.internal.manager.core.setCurrentBVFilterMode(cbinfo.Context.Object.getModelHandle(),cbinfo.EventData);
end
