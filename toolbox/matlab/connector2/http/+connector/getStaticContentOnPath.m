function contentUrlPath=getStaticContentOnPath(path)
    if connector.isRunning
        fsPath=strtrim(path);


        if isempty(fsPath)
            throw(MException('MATLAB:Connector:emptyInputNotAllowed',...
            'Argument fsPath cannot be empty.'));
        end


        if fsPath(end)~=filesep
            fsPath=strcat(fsPath,filesep);
        end

        msg=struct('type','connector/http/GetStaticContentPath','fsPath',fsPath);

        try

            message=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize','connector/http/staticContentManager'}).get();
        catch
            throw(MException('MATLAB:Connector:GetError','There was a problem getting data from Connector'));
        end


        contentUrlPath=message.httpPath;

    else
        error(message('Connector:MissingConnector','The Connector is not loaded.'));
    end

end
