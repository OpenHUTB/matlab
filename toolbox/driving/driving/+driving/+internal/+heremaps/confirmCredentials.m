function confirmCredentials

    manager=driving.internal.heremaps.CredentialsManager.getInstance();
    if~manager.credentialsExist()
        hereHDLMCredentials('setup');
        if~manager.credentialsExist()
            error(message('driving:heremaps:NoAppCredentials'));
        end
    end
    if~manager.hasInternetAccess()
        error(message('driving:heremaps:NoInternetAccess'));
    end

end