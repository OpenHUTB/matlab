function doDuplicate(cbinfo)
    objContext=cbinfo.Context.Object;
    objValueSetMgr=objContext.getController();
    objValueSetMgr.doDuplicate();
end

