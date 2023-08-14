function removeStaticContentOnPath(route)
    SLASH='/';
    if connector.isRunning


        httpPath=strtrim(route);


        if isempty(httpPath)
            throw(MException('MATLAB:Connector:emptyInputNotAllowed',...
            'Argument httpPath cannot be empty.'));
        end



        sanitizedString=replace(httpPath,[" ","/","-"],'');
        if any(~isstrprop(sanitizedString,'alphanum'))
            throw(MException('MATLAB:Connector:WebPathAlphaNumeric',...
            'Argument httpPath can only be alphanumeric.'));
        end


        httpPath=strcat(SLASH,httpPath);

        msg=struct('type','connector/http/RemoveStaticContentPath','httpPath',httpPath);


        connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
        'connector/http/staticContentManager'}).get();
    else
        error(message('Connector:MissingConnector','The Connector is not loaded.'));
    end

end
