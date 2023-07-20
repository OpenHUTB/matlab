function cb_SDIMsgBoxResponse(this,evt)
    cb=this.MsgBoxResponseCb.getDataByKey(evt.UserData);
    this.MsgBoxResponseCb.deleteDataByKey(evt.UserData);
    if~isempty(cb)
        cb(evt.Choice);
    end
end
