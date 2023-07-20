function deregisterPreviousBuildStatusReceiverCBs

    currentConnections=coder.internal.buildstatus.BuildStatusReceiver.getInstance;
    if~isempty(currentConnections.CallbackMap)


        k=currentConnections.CallbackMap.keys;
        for idx=1:length(k)
            coder.internal.buildstatus.BuildStatusReceiver.getInstance.deregisterCB(k{idx});
        end
    end

end