function addWebAddOnsPath(httpPath,fsPath,varargin)
    if connector.isRunning
        narginchk(2,inf);

        httpPath=strtrim(httpPath);
        fsPath=strtrim(fsPath);


        if isempty(httpPath)||isempty(fsPath)
            throw(MException('MATLAB:Connector:emptyInputNotAllowed',...
            'Argument httpPath or fsPath cannot be empty.'));
        end


        if any(~isstrprop(httpPath,'alphanum'))
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


        httpPath=strcat('/addons/',httpPath,'/');



        p=inputParser;
        p.addParameter('EnableCache',true,@islogical);
        p.addParameter('EnableMemoryCache',false,@islogical);
        p.addParameter('LocalizeContent',false,@islogical);
        p.parse(varargin{:});

        msg=struct('type','connector/http/AddStaticContentPath','httpPath',httpPath,'fsPath',fsPath,...
        'enableCache',p.Results.EnableCache,'enableMemoryCache',p.Results.EnableMemoryCache,'localizeContent',p.Results.LocalizeContent,'isDeprecated',true);


        connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
        'connector/http/staticContentManager'}).get();
    else
        error(message('Connector:MissingConnector','The Connector is not loaded.'));
    end

end