function address=server(varargin)














    persistent doPrompt
    if isempty(doPrompt)
        doPrompt=true;
    end

    if nargin<1
        address=rmipref('OslcServerAddress');

    elseif isempty(varargin{1})
        doPrompt=true;
        if nargout==0
            return;
        else
            address=rmipref('OslcServerAddress');
        end

    else
        address=varargin{1};
        if~startsWith(address,'https://')
            address=['https://',address];
        end
        doPrompt=(nargin==2&&strcmp(varargin{2},'prompt'));
    end

    serviceRoot='';
    if doPrompt||isempty(address)
        [address,serviceRoot]=uiPromptAndValidate(address);
        if isempty(address)
            return;
        else
            doPrompt=false;
        end
    end


    rmipref('OslcServerAddress',address);
    if~isempty(serviceRoot)
        rmipref('OslcServerRMRoot',serviceRoot);
    end
end

function[address,serviceRoot]=uiPromptAndValidate(address)

    serverUrl='';
    serverPort='9443';
    if~isempty(address)
        matched=regexp(address,'https://(\S+):(\d+)','tokens');
        if~isempty(matched)
            serverUrl=matched{1}{1};
            serverPort=matched{1}{2};
        end
    end
    serviceRoot=rmipref('OslcServerRMRoot');

    prompt={...
    getString(message('Slvnv:oslc:DngServerAddress')),...
    getString(message('Slvnv:oslc:DngServerPort')),...
    getString(message('Slvnv:oslc:DngServerSection'))};
    name=getString(message('Slvnv:oslc:DngServer'));

    while true
        result=inputdlg(prompt,name,1,{serverUrl,serverPort,serviceRoot});
        if isempty(result)

            address='';
            serviceRoot='';
            return;
        end
        serverUrl=strtrim(result{1});
        if~looksLikeValidServerUrl(serverUrl)
            serverUrl=[serverUrl,' <- INVALID'];%#ok<AGROW>
            continue;
        end
        serverPort=strtrim(result{2});
        if isempty(regexp(serverPort,'^\d+$','once'))
            serverPort=[serverPort,' <- INVALID'];%#ok<AGROW>
            continue;
        end
        serviceRoot=strtrim(result{3});
        if isempty(regexp(serviceRoot,'^\w\w+$','once'))
            serviceRoot=[serviceRoot,' <- INVALID'];%#ok<AGROW>
            continue;
        end

        if~startsWith(serverUrl,'https://')
            serverUrl=['https://',serverUrl];%#ok<AGROW>
        end
        break;
    end
    address=[serverUrl,':',serverPort];
end

function tf=looksLikeValidServerUrl(in)

    tf=~isempty(regexp(in,'^\w[\w\/\.\-]+\w\w$','once'))||...
    ~isempty(regexp(in,'^https\://\w[\w\/\.\-]+\w\w$','once'));
end

