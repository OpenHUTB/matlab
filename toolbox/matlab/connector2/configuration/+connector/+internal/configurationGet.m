function future=configurationGet(key)
    msg=struct('type','connector/configuration/ConfigurationGet','key',key);
    future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
    'connector/configuration'});

    future=future.then(@(f)unwrapValue(f));
end

function value=unwrapValue(future)
    response=future.get();
    if isfield(response,'value')
        value=response.value;
    else

        warning('No value found for requested key');
        value=[];
    end
end