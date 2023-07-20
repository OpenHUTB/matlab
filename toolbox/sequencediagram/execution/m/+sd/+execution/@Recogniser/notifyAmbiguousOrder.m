function notifyAmbiguousOrder(modelName,sdName,currentmessageUuid,previousMessageUUID)






    if~isempty(modelName)&&~strcmp(modelName,sdName)
        mdlHandle=get_param(modelName,'handle');
        instanceParents=[];
        [~,mdlUri]=builtin('_get_sequence_diagram_uri_from_sl_object_instance_handle',mdlHandle,instanceParents);
        service=sequencediagram.internal.sl.kernel.getSimulinkApp().getExecutionListenerService();
        service.observeAmbiguousMessageOrder(mdlUri,sdName,{currentmessageUuid,char(previousMessageUUID.extractBefore("_"))});
    end

end
