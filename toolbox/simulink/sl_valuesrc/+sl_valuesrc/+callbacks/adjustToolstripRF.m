function adjustToolstripRF(cbinfo,action)
    objContext=cbinfo.Context.Object;
    objValueSetMgr=objContext.getController();
    objValueSetMgr.adjustToolstripAction(action);
end

