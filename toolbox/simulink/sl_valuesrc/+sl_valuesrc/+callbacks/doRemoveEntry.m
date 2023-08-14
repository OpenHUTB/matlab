function doRemoveEntry(cbinfo)
    objContext=cbinfo.Context.Object;
    objValueSetMgr=objContext.getController();
    objValueSetMgr.doRemoveEntry();
end

