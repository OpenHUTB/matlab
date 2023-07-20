function resetPath()




    request=struct('type','connector/v1/ContainerRequest','messages',struct('ResetToolboxes',{{struct()}}));
    future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(request,{'connector/json/deserialize',...
    'connector/v1/container'});
    response=future.get();

    if responseHasFault(response)
        warning('SEVERE: Error setting default path.');
    end

    function hasFault=responseHasFault(response)

        hasFault=isfield(response,'fault')||(isfield(response,'messages')&&isfield(response.messages,'ResetToolboxesResponse')...
        &&isfield(response.messages.ResetToolboxesResponse,'messageFaults')...
        &&~isempty(response.messages.ResetToolboxesResponse.messageFaults));
    end
end
