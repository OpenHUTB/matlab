function future=configurationKeys()
    msg=struct('type','connector/configuration/Keys');
    future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
    'connector/configuration'});

    future=future.then(@(f)f.get().keys);
end
