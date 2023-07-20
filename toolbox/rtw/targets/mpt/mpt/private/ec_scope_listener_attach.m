function listenerCleanupFcn=ec_scope_listener_attach(modelName)








    h=get_param(modelName,'Handle');
    listener=@ec_mpt_listener_cb;
    add_engine_event_listener(h,'EnginePostRTWCompFileNames',@ec_mpt_listener_cb);
    listenerCleanupFcn=@()coder.internal.removeListener(h,listener);


