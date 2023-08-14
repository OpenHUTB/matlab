function future=editorServiceOpenOrCreate(filePath)
    message=struct('type','connector/v1/OpenOrCreateInEditor','path',filePath);
    future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(message,{'connector/json/deserialize',...
    'connector/v1/editor'});
end