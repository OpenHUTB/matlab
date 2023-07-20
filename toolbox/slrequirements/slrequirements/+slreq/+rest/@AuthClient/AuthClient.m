classdef AuthClient<handle





    properties(Access=protected)


server
serviceRoot
user
passcode
passmanager
passwrapper


headers
cookies
history
status
authOK
authInProgress
loginExec


catalogUrl
projCatalog
projectName
projectQuery

    end

    properties(Access=protected)
HttpOptions
HttpHeader
AdditionalHttpHeader
    end

    properties(Access=private,Hidden=true)
optionsWithCred
    end

    methods(Static)
        function instance=getInstance()%#ok<STOUT>
            error('Cannot create an instance of AuthClient. Please use one of supported subclasses (oslc.matlab.DngClient,..)');
        end
    end

    methods(Access=protected)

        function obj=AuthClient()
            obj.server='';
            obj.serviceRoot='rm';
            obj.user='';
            obj.passmanager=[];
            obj.passwrapper=@(a,~)a;
            obj.loginExec='';
            obj.optionsWithCred=[];
            obj.authInProgress=false;
            obj.authOK=false;
        end

    end

    methods(Access=private)


        function options=getOptionsWithCredentials(this)
            if~isempty(this.HttpOptions)

                options=this.HttpOptions;
            else

                if isempty(this.optionsWithCred)
                    this.optionsWithCred=this.makeOptionsWithCredentials();
                end
                options=this.optionsWithCred;
            end
        end

        function options=makeOptionsWithCredentials(this)

            this.passcode=this.promptForPassword();
            if isempty(this.passcode)
                error(message('Slvnv:oslc:PasswordNotSupplied'));
            end
            creds=matlab.net.http.Credentials(...
            'Username',this.user,...
            'Password',this.passwrapper(this.passcode,this.user),...
            'Scheme',matlab.net.http.AuthenticationScheme.Basic);
            options=matlab.net.http.HTTPOptions(...
            'Credentials',creds,...
            'VerifyServerName',false,...
            'CertificateFilename','');
        end

        function password=promptForPassword(this)
            if isempty(this.passmanager)
                prompt=getString(message('Slvnv:oslc:PasswordQ'));
                password=input([prompt,' '],'s');
            else
                password=this.passmanager(this.user);
            end
        end

        function server=getHostUrl(~,url)

            matched=regexp(url,'(https://[^/]+)','tokens');
            if isempty(matched)
                server='';
            else
                server=matched{1}{1};
            end
        end


        success=loginUsingFormAuth(this)
        success=loginUsingBasicAuth(this)

        function reconnect(this)
            this.resetAuth();
            this.login();
        end

        function out=loginInProgress(this,value)
            out=this.authInProgress;
            if nargin>1
                this.authInProgress=value;
            end
        end

        function resetCredentials(this)
            this.user='';
            this.passcode='';
            this.optionsWithCred=[];
        end

        function out=formEncode(~,in)


            out='';
            if~isempty(in)
                out=urlencode(in);
            end
        end

    end

    methods

        function setCustomLoginProvider(this,loginFcnName)
            this.loginExec=loginFcnName;
        end

        function fcnName=getCustomLoginProvider(this)
            fcnName=this.loginExec;
        end

        function success=login(this)


            this.loginInProgress(true);clp=onCleanup(@()this.loginInProgress(false));
            if isempty(this.server)
                this.server=oslc.server();
            end
            if isempty(this.user)
                this.user=oslc.user();
            end
            this.optionsWithCred=this.getOptionsWithCredentials();

            if isempty(this.loginExec)

                success=this.loginUsingFormAuth();
                if~success
                    success=this.loginUsingBasicAuth();
                end
            else

                [success,receivedCookies]=feval(this.loginExec,this.server,this.optionsWithCred);
                if success
                    this.cookies=receivedCookies;
                end
            end

            this.authOK=success;

            this.projCatalog=[];
            if~success
                this.resetCredentials();
                throwAsCaller(MException(message('Slvnv:oslc:FailedToAuthenticate',...
                this.user,this.server,char(this.status))));
            end
        end

        function showHistory(this)
            show(this.history);
        end

        function resetAuth(this)
            this.authOK=false;
        end

        function out=getServer(this)
            out=this.server;
        end

        function setServer(this,serverUrlAndPortNumber)
            serverUrlAndPortNumber=convertStringsToChars(serverUrlAndPortNumber);
            this.server=slreq.rest.AuthClient.sanitizeServerName(serverUrlAndPortNumber);
            oslc.server(serverUrlAndPortNumber);
        end

        function setUser(this,userName)
            userName=convertStringsToChars(userName);
            if~strcmp(this.user,userName)
                this.resetCredentials();
                this.user=userName;
                oslc.user(userName);
            end
        end

        function result=getUser(this)
            result=this.user;
        end


        [content,eTag,responseStatusCode]=get(this,url)
        result=put(this,url,content,eTag)
        response=post(this,url,data,eTag)
        result=remove(this,url)
    end

    methods(Static)
        function serverAndPort=sanitizeServerName(serverAndPort)
            while endsWith(serverAndPort,'/')
                serverAndPort(end)=[];
            end
            if isempty(serverAndPort)
                serverAndPort='localhost';
            end
            if startsWith(serverAndPort,'https://')
                if sum(serverAndPort==':')<2
                    serverAndPort=[serverAndPort,':443'];
                end
            elseif startsWith(serverAndPort,'http://')
                if sum(serverAndPort==':')<2
                    serverAndPort=[serverAndPort,':80'];
                end
            else
                serverAndPort=['https://',serverAndPort];
                if sum(serverAndPort==':')<2
                    serverAndPort=[serverAndPort,':443'];
                end
            end
        end
    end
end

