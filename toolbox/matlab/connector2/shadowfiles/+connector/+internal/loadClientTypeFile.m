function loadClientTypeFile(filePath,shadowRootPath)

    message=struct('type','connector/v1/LoadClientTypeFile',...
    'filePath',filePath,'shadowRootPath',shadowRootPath);

    future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(message,{'connector/json/deserialize',...
    'connector/v1/shadowFiles'});
    try
        if~future.get().success
            warning('Unable to load client type file');
        end
    catch e
        warning('Error while loading client type. Unable to load client type file');
    end
end
