function doAddSource(cbinfo)
    objContext=cbinfo.Context.Object;
    objValueSetMgr=objContext.getController();
    objValueSetMgr.doAddSource();
end

