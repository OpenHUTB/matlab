function setInMemoryCaching(httpPath,enableMemoryCache)
    if connector.isRunning

        httpPath=strtrim(httpPath);


        if isempty(httpPath)||isempty(enableMemoryCache)
            throw(MException('MATLAB:Connector:emptyInputNotAllowed','HTTP path cannot be empty.'));
        end


        if httpPath(1)~='/'
            throw(MException('MATLAB:Connector:InvalidHttpPath','HTTP path is invalid.'));
        end

        msg=struct('type','connector/http/SetInMemoryCaching','httpPath',httpPath,...
        'enableMemoryCache',enableMemoryCache);


        connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
        'connector/http/staticContentManager'}).get();
    else
        error(message('Connector:MissingConnector','The Connector is not loaded.'));
    end

end