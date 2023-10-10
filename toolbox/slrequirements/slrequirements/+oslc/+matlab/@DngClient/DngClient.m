classdef(Sealed)DngClient<slreq.rest.AuthClient

    properties(Access=private)


isTesting
testMap

    end

    methods(Static)
        function instance=getInstance()
            persistent client
            doLogin=false;
            if isempty(client)||~isvalid(client)

                client=oslc.matlab.DngClient();
                if client.isTesting

                    client.authOK=true;
                else
                    doLogin=true;
                end
            elseif~client.authOK

                client.server=oslc.server();
                client.serviceRoot=rmipref('OslcServerRMRoot');
                client.catalogUrl=[client.server,'/',client.serviceRoot,'/oslc_rm/catalog'];
                client.user=oslc.user();
                doLogin=true;
            end
            if doLogin
                client.login();
            end
            instance=client;
        end


        url=appendContextParam(url)
    end


    methods(Access=private)

        function obj=DngClient()
            obj=obj@slreq.rest.AuthClient();
            obj.passmanager=@oslc.passcode;
            obj.passwrapper=@oslc.matlab.DngClient.unconfusePasscode;
            obj.server=oslc.server();
            obj.serviceRoot=rmipref('OslcServerRMRoot');
            obj.user=oslc.user();
            obj.isTesting=strcmp(obj.user,'mw_automated_test');
            if~obj.isTesting
                obj.setServer(rmipref('OslcServerAddress'));
                obj.setUser(rmipref('OslcServerUser'));
                obj.passcode=oslc.passcode(obj.user,false);
            end
            obj.catalogUrl=[obj.server,'/',obj.serviceRoot,'/oslc_rm/catalog'];
            dngLoginHelper=rmipref('LoginProvider');
            if~isempty(dngLoginHelper)
                obj.setCustomLoginProvider(dngLoginHelper);
            end
        end

    end

    methods(Static,Access=private)
        function out=unconfusePasscode(in,key)
            cl=clock();
            day=cl(3);
            out=in;
            for i=1:length(in)
                j=mod(i,length(key))+1;
                diff=int32(key(j))-day;
                out(i)=char(int32(in(i))-diff);
            end
        end
    end


    methods

        function out=isAuthOK(this)
            out=this.authOK;
        end

        function url=getReqQueryCapability(this)
            url=strrep(this.projectQuery,'&amp;','&');
        end
        function url=getCollectionQueryCapability(this)
            url=strrep(this.projectQuery,'&amp;','&');
        end

        function updateContexts(this)
            proj=oslc.Project.get(this.projectName,this);
            if~isempty(proj)
                proj.updateRecentContexts(this);
            end
        end

        function[result,eTag]=get(this,url)
            if strcmp(this.user,'mw_automated_test')


                if this.hasCachedFile(url)
                    filename=this.getCachedFile(url);
                    result=oslc.matlab.DngClient.loadFromFile(filename);
                    eTag='';
                else
                    error(message('Slvnv:reqmgt:NotFoundIn',url,'this.testMap'));
                end
            else
                [result,eTag]=get@slreq.rest.AuthClient(this,url);
            end
        end

        function url=getCatalogURL(this)
            url=this.catalogUrl;
        end

        function rdf=getCatalogRDF(this)
            rdf=this.get(this.getCatalogURL());
        end

        function storeCatalog(this,catalogInfo)
            this.projCatalog=catalogInfo;
        end

        function name=getProject(this)
            name=this.projectName;
        end

        function updateQueryBase(this,queryBase)
            this.projectQuery=queryBase;
        end



        rdf=getItemRdfById(this,id)
        allIds=getCollectionsIds(this,doRefresh,optionalProgressBarInfo)
        urls=getRequirementsUrlsInCollection(this,collectionId,optionalProgressBarInfo)
        result=addLink(this,resourceURL,linkUrl,linkLabel,linkType)
        serviceUrl=setProject(this,projName)
        updateProjectQueryUrl(this)
    end


    methods(Hidden)
        function setTestMap(this,mapData)
            this.testMap=mapData;
        end
        function tf=hasCachedFile(this,url)
            tf=isKey(this.testMap,url);
        end
        function filename=getCachedFile(this,url)
            filename=this.testMap(url);
        end
    end
    methods(Static,Hidden)
        function data=loadFromFile(filename)
            if exist(filename,'file')~=2
                error(message('Slvnv:slreq:NeedFullPathToFile',filename,'preloaded file'));
            end
            [~,~,fExt]=fileparts(filename);
            if strcmp(fExt,'.mat')
                loaded=load(filename);
                data=loaded.result;
            else
                fid=fopen(filename,'r');
                data=fread(fid,'*char')';
                fclose(fid);
            end
        end

        function[globalConfigNames,globalConfigUrls]=getGlobalConfigs(doReset)










            persistent rmClient
            if isempty(rmClient)||(nargin>0&&doReset)
                rmClient=oslc.Client;
                isNew=true;
                rmClient.setServer(oslc.server);
                rmClient.setUser(oslc.user);
                rmClient.setServiceRoot(rmipref('OslcServerRMRoot'));
            else
                isNew=false;
            end
            if isNew||~rmClient.authOK
                rmClient.login();
            end
            [globalConfigNames,globalConfigUrls]=rmClient.getConfigurationContextNames();
        end

        function configStruct=resolveGlobalConfig(url)
            [globalNames,globalUrls]=oslc.matlab.DngClient.getGlobalConfigs();
            isMatch=strcmp(globalUrls,url);
            if any(isMatch)
                configStruct=struct('name',globalNames{isMatch},'url',url);
            else
                configStruct=[];
            end
        end
    end
end
