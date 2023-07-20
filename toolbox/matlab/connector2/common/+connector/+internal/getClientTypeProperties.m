function properties=getClientTypeProperties




    try
        msg=struct('type','connector/v1/GetCurrentClientProperties');


        message=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
        'connector/v1/information'}).get();

        properties=message.properties;

    catch ex
        properties='';
    end