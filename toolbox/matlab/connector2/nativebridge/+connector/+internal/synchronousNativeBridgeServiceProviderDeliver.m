function future=synchronousNativeBridgeServiceProviderDeliver(message,address)
    try
        jsonReq=mls.internal.toJSON(message);
        json=builtin('_connectorNativeBridgeSync',jsonReq,address);
        message=mls.internal.fromJSON(json);
        future=connector.internal.Future.makeReadyFuture(message);
    catch ex
        future=connector.internal.Future.makeFailedFuture(ex);
    end
end

