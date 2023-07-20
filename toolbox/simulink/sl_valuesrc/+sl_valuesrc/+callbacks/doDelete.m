function doDelete(cbinfo)
    objContext=cbinfo.Context.Object;
    objValueSetMgr=objContext.getController();
    objValueSetMgr.doDelete();
end

