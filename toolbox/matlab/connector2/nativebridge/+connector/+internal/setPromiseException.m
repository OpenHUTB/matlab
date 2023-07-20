



function setPromiseException(promiseId,msg)
    if connector.isRunning
        service=connector.internal.ConnectorManager.Impl.NativeBridgeServiceProvider;

        promise=service.getPromise(promiseId);
        promise.setException(MException('Connector:NativeBridge:ResponseType',msg));
    else
        error('Connector:MissingNativeBridgeService','The native bridge service is not loaded.');
    end
end
