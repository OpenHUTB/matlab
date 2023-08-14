function notifyMessageEvent(modelName,sdName,messageUuidToSend,valid)




    if~isempty(modelName)&&~strcmp(modelName,sdName)
        mdlHandle=get_param(modelName,'handle');
        instanceParents=[];
        [~,mdlUri]=builtin('_get_sequence_diagram_uri_from_sl_object_instance_handle',mdlHandle,instanceParents);

        simTime=get_param(modelName,'SimulationTime');

        service=sequencediagram.internal.sl.kernel.getSimulinkApp().getExecutionListenerService();
        if nargin<4||valid
            service.observeVisitMessage(mdlUri,sdName,messageUuidToSend,simTime);
        else
            service.observeInvalidMessage(mdlUri,sdName,messageUuidToSend,simTime);
        end
    end
end


