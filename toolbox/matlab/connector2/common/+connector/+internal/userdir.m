function result=userdir()

    result=userpath;

    if isempty(result)

        msg=struct('type','connector/v1/GetCurrentUserHomeDir');
        response=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,...
        {'connector/json/deserialize','connector/v1/worker'}).get();

        if strcmp(response.type,'connector/v1/GetCurrentUserHomeDirResponse')
            result=response.userHomeDir;
        end
    end

end
