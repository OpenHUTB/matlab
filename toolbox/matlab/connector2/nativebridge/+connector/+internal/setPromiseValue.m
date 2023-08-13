function setPromiseValue(promiseId,json)
    if connector.isRunning
        service=connector.internal.ConnectorManager.Impl.NativeBridgeServiceProvider;

        promise=service.getPromise(promiseId);
        promise.setValue(struct('type','OpaqueMessage','content',json));
    else
        error('Connector:MissingNativeBridgeService','The native bridge service is not loaded.');
    end
end
