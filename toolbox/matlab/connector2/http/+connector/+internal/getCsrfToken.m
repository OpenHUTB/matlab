function[csrfToken,validForMs]=getCsrfToken()

    if connector.isRunning

        msg=struct('type','connector/v1/CreateCsrfToken');


        message=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,...
        {'connector/json/deserialize','connector/v1/compute'}).get();


        csrfToken=message.csrfToken;

        validForMs=str2double(message.validForMs);

    else
        error(message('Connector:MissingConnector','The Connector is not loaded.'));
    end

end
