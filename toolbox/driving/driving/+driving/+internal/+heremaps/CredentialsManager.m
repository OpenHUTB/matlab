classdef CredentialsManager<handle

    properties(Dependent,Access=protected)
DataService
Settings
    end

    properties(Access=private)
DataServiceManager
TestingAuthority
    end

    methods

        function s=get.Settings(this)
            s=this.DataServiceManager.ServiceSettings.credentials;
        end

        function service=get.DataService(this)
            service=this.DataServiceManager.DataService;
        end

    end

    methods

        function[isValid,errorMessage]=setTemporaryCredentials(this,credentials)
            [isValid,errorMessage]=this.setCredentials(credentials,'temporary');
        end

        function[isValid,errorMessage]=setPersistentCredentials(this,credentials)
            [isValid,errorMessage]=this.setCredentials(credentials,'personal');
        end

        function deleteTemporaryCredentials(this)
            this.deleteCredentials('temporary');
            this.DataService.deleteCredentials();
        end

        function deletePersistentCredentials(this)
            this.deleteCredentials('personal');
            this.DataService.deleteCredentials();
        end

        function[url,options]=computeRequest(this,url,options)
            creds=this.getCredentials('active');

            [url,options]=this.DataService.attachCredentials(url,options,creds);
        end

        function data=webread(this,url,options)
            if isempty(this.TestingAuthority)

                if~this.credentialsExist()
                    error(message('driving:heremaps:NoAppCredentials'));
                end

                [urlWithCredentials,options]=this.computeRequest(url,options);

                try
                    data=webread(urlWithCredentials,options);
                catch ME

                    errMsg=strrep(ME.message,urlWithCredentials.EncodedURI,...
                    url.EncodedURI);


                    throw(MException(ME.identifier,errMsg));
                end

            else




                data=this.DataService.testReplaceUrl(this.TestingAuthority,url,options);
            end
        end

        function flag=credentialsExist(this)
            flag=~isequal(this.getCredentials('active'),this.getCredentials('factory'));
        end

        function flag=hasInternetAccess(this)



            [~,err]=this.validate();
            flag=~(isfield(err,'identifier')&&...
            strcmp(err.identifier,'MATLAB:webservices:UnknownHost'));
        end

    end

    methods(Static,Hidden)

        function mgr=getInstance()

            persistent manager

            if isempty(manager)
                manager=driving.internal.heremaps.CredentialsManager();
            end

            mgr=manager;
        end

        function out=encode(in)



            out=matlab.net.base64encode(char(in));
        end

        function out=decode(in)



            out=char(matlab.net.base64decode(in));
        end

    end

    methods(Access=protected)

        function this=CredentialsManager()
            this.DataServiceManager=driving.internal.heremaps.DataServiceManager.getInstance();
        end

        function[isValid,errorMessage]=validate(this)
            isValid=true;
            errorMessage='';
            try
                url=matlab.net.URI(this.DataService.ValidationURL);
                this.webread(url,weboptions);
            catch ME
                isValid=false;
                errorMessage=ME;
            end
        end

    end

    methods(Access=private)

        function[isValid,errorMessage]=setCredentials(this,credentials,type)

            type=capitalize(type);

            fields=fieldnames(credentials);
            for idx=1:numel(fields)
                f=fields{idx};
                this.Settings.(f).([type,'Value'])=this.encode(credentials.(f));
            end


            [isValid,errorMessage]=validate(this);


            if~isValid
                this.deleteCredentials(type);
            end
        end

        function deleteCredentials(this,type)

            type=capitalize(type);

            fields=this.DataService.CredentialsTokens;
            for idx=1:numel(fields)
                setting=this.Settings.(fields{idx});
                if setting.(['has',type,'Value'])
                    setting.(['clear',type,'Value']);
                end
            end

        end

        function creds=getCredentials(this,type)


            type=capitalize(type);


            fields=this.DataService.CredentialsTokens;


            creds=struct;
            for idx=1:numel(fields)
                val='';
                setting=this.Settings.(fields{idx});
                if strcmpi(type,'active')||setting.(['has',type,'Value'])
                    val=this.decode(setting.([type,'Value']));
                end
                creds.(fields{idx})=val;
            end
        end

    end

    methods(Access=?hereHDLMTestHelper)

        function enableTesting(this,authority)
            this.TestingAuthority=authority;
        end

    end

end

function str=capitalize(str)
    str=[upper(str(1)),str(2:end)];
end