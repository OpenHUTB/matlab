function linkSetFile=getLinkSetForReqSet(reqSetFilePath)
    linkSetFile=rmimap.StorageMapper.getInstance.getStorageFor(reqSetFilePath);

end