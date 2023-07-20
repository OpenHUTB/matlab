function doIncrPriority(cbinfo)
    objContext=cbinfo.Context.Object;
    objValueSetMgr=objContext.getController();
    objValueSetMgr.doIncrPriority();
end

