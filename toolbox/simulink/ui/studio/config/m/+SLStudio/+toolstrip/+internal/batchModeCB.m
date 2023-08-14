



function batchModeCB(cbinfo)
    model=cbinfo.model;
    val=cbinfo.EventData;
    set_param(model.Handle,'ExtModeBatchMode',slprivate('onoff',val));
end
