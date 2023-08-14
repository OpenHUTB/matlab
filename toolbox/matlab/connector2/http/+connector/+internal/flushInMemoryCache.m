function flushInMemoryCache(httpPath)
    if connector.isRunning

        httpPath=strtrim(httpPath);


        if isempty(httpPath)
            throw(MException('MATLAB:Connector:emptyInputNotAllowed','HTTP path cannot be empty.'));
        end


        if httpPath(1)~='/'
            throw(MException('MATLAB:Connector:InvalidHttpPath','HTTP path is invalid.'));
        end

        msg=struct('type','connector/http/FlushInMemoryCache','httpPath',httpPath);


        connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
        'connector/http/staticContentManager'}).get();
    else
        error(message('Connector:MissingConnector','The Connector is not loaded.'));
    end

end