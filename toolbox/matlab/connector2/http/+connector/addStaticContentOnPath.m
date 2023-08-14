function contentUrlPath=addStaticContentOnPath(route,path,varargin)
    SLASH='/';
    if connector.isRunning
        narginchk(2,inf);

        httpPath=strtrim(route);
        fsPath=strtrim(path);


        if isempty(httpPath)||isempty(fsPath)
            throw(MException('MATLAB:Connector:emptyInputNotAllowed',...
            'Argument httpPath or fsPath cannot be empty.'));
        end



        sanitizedString=replace(httpPath,[" ","/","-"],'');
        if any(~isstrprop(sanitizedString,'alphanum'))
            throw(MException('MATLAB:Connector:WebPathAlphaNumeric',...
            'Argument httpPath can only be alphanumeric.'));
        end


        if~exist(fsPath,'dir')
            throw(MException('MATLAB:Connector:FolderNotFound',...
            'Directory does not exist.'));
        end


        if fsPath(end)~=filesep
            fsPath=strcat(fsPath,filesep);
        end


        httpPath=strcat(SLASH,httpPath);



        p=inputParser;
        p.addParameter('EnableCache',true,@islogical);
        p.addParameter('EnableMemoryCache',false,@islogical);

        p.addParameter('LocalizeContent',false,@islogical);
        p.addParameter('EnableUniqueIdentifier',true,@islogical);
        p.addParameter('SkipCompatibilityList',false,@islogical);
        p.parse(varargin{:});

        msg=struct('type','connector/http/AddStaticContentPath','httpPath',httpPath,'fsPath',fsPath,...
        'enableCache',p.Results.EnableCache,'enableMemoryCache',p.Results.EnableMemoryCache,...
        'localizeContent',p.Results.LocalizeContent,'enableUniqueIdentifier',p.Results.EnableUniqueIdentifier,'skipCompatibilityList',p.Results.SkipCompatibilityList);


        message=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
        'connector/http/staticContentManager'}).get();

        contentUrlPath=message.httpPath;
    else
        error(message('Connector:MissingConnector','The Connector is not loaded.'));
    end

end
