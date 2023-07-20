function status=getContextMenuStatus(obj)




    objectId=obj.objectId;
    status={};

    s=[];
    s.id='c_trace_action_id';
    st=sfprivate('traceabilityManager','getRTWMenuStatus',objectId);
    s.visible=st(1);
    s.enabled=st(2);
    status{end+1}=s;

    s=[];
    s.id='plc_trace_action_id';
    st=sfprivate('traceabilityManager','getPLCMenuStatus',objectId);
    s.visible=st(1);
    s.enabled=st(2);
    status{end+1}=s;

    s=[];
    s.id='hdl_trace_action_id';
    st=sfprivate('traceabilityManager','getHDLMenuStatus',objectId);
    s.visible=st(1);
    s.enabled=st(2);
    status{end+1}=s;