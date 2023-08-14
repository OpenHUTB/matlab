classdef(Abstract)BaseClient<slreq.rest.AuthClient




    properties(SetAccess=protected)
        ServiceProvider char='';
        ConfigurationContext char='';
    end

    properties(Dependent)
ServiceRoot
CatalogUrl
    end

    properties(Access=protected)
ServiceProviderUrl
CatalogPath
ConfigurationQueryPath
    end

    properties(Hidden)
        ConfigurationUri char='';
        isTesting=false;
        testStruct;
    end


    methods
        function this=BaseClient()
            this=this@slreq.rest.AuthClient();
            this.server=rmipref('OslcServerAddress');
            this.user=rmipref('OslcServerUser');

            this.ConfigurationQueryPath='gc/oslc-query/configurations';


            slreq.datamodel.RequirementData.StaticMetaClass;
        end

        function success=login(this)
            this.isTesting=strcmp(this.user,'mw_automated_test');
            this.projCatalog=this.CatalogUrl;
            if~this.isTesting
                success=this.login@slreq.rest.AuthClient();
            else
                success=true;
            end
        end

        function setCatalogPath(this,path)
            this.CatalogPath=convertStringsToChars(path);
        end

        function setServiceRoot(this,rootName)
            this.serviceRoot=convertStringsToChars(rootName);
        end

        function setConfigurationQueryPath(this,queryPath)
            this.ConfigurationQueryPath=convertStringsToChars(queryPath);
        end

        function setHttpOptions(this,option)
            this.HttpOptions=option;
        end

        function setHttpHeader(this,header)
            this.HttpHeader=header;
        end

        function out=get.ServiceRoot(this)
            out=this.serviceRoot;
        end

        function out=get.CatalogUrl(this)

            out=appendPath(this.server,this.serviceRoot);
            out=appendPath(out,this.CatalogPath);

            function str=appendPath(str,in)


                if isempty(in)
                    return;
                end
                if startsWith(in,'/')
                    in=in(2:end);
                end
                if endsWith(str,'/')
                    str=str(1:end-1);
                end
                str=[str,'/',in];
            end
        end

        function setServiceProvider(this,providerName)
            providerName=convertStringsToChars(providerName);
            [names,url]=this.getServiceProviderNames();
            idx=strcmp(names,providerName);
            if~any(idx)
                error(message('Slvnv:oslc:ProjectNotFound',providerName));
            end
            this.ServiceProviderUrl=url{idx};
            this.ServiceProvider=providerName;
        end

        function[out,url]=getServiceProviderNames(this)
            rdf=this.get(this.CatalogUrl);
            try
                catalogs=slreq.internal.RdfResourceDataManager(rdf);
                catalogs.parse;
                oslcServiceProviders=catalogs.findNodesByTagName('oslc:ServiceProvider');
            catch ex

                me=MException(message('Slvnv:oslc:InvalidServiceCatalogUrl',this.CatalogUrl));


                mec=MException('Slvnv:oslc:CatalogError',slreq.cpputils.htmlToText(rdf));


                mec=mec.addCause(ex);
                me=me.addCause(mec);
                throw(me);
            end
            if isempty(oslcServiceProviders)

                typeNode=catalogs.findNodesByTagAttrNameValue('rdf:type','rdf:resource','http://open-services.net/ns/core#ServiceProvider');
                for n=1:length(typeNode)
                    srvcNode=typeNode(n).getParentNode;
                    if isempty(oslcServiceProviders)
                        oslcServiceProviders=srvcNode;
                    else
                        oslcServiceProviders(n)=srvcNode;
                    end
                end
            end
            numServiceProviders=length(oslcServiceProviders);
            out=cell(numServiceProviders,1);
            url=cell(numServiceProviders,1);
            for n=1:numServiceProviders
                titleNodeList=oslcServiceProviders(n).getElementsByTagName('dcterms:title');
                for m=1:titleNodeList.Length
                    titleNode=titleNodeList.node(m);
                    if~any(strcmpi(titleNode.getParentNode.getTagName,{'oslc:ServiceProvider','rdf:Description'}))

                        continue;
                    end
                    providerName=titleNode.TextContent;
                    srvcUrl=oslcServiceProviders(n).getAttribute('rdf:about');
                    if~isempty(srvcUrl)
                        out{n}=providerName;
                        url{n}=srvcUrl;
                    end
                end
            end
        end

        function out=getCreationFactory(this,resourceType)

            if isempty(this.ServiceProviderUrl)
                error(message('Slvnv:oslc:ServiceProviderIsNotSpecified'))
            end
            filterByResource=nargin>1;
            out=oslc.core.CreationFactory.empty();
            servicesRdf=this.get(this.ServiceProviderUrl);

            if filterByResource
                resourceType=convertStringsToChars(resourceType);
                resourceTypeUri=this.getResourceTypeUri(resourceType,'creation');
            end

            rdfMgr=slreq.internal.RdfResourceDataManager(servicesRdf);
            nodeList=rdfMgr.dom.getElementsByTagName('oslc:CreationFactory');
            for n=1:nodeList.Length
                node=nodeList.node(n);
                c=oslc.core.CreationFactory(node,this);
                if~filterByResource
                    out(n)=c;
                elseif any(strcmp(c.resourceType,resourceTypeUri))
                    out(end+1)=c;%#ok<AGROW>
                end
            end
        end

        function out=getQueryService(this,resourceType)

            if isempty(this.ServiceProviderUrl)
                error(message('Slvnv:oslc:ServiceProviderIsNotSpecified'));
            end
            filterByResource=nargin>1;
            out=oslc.core.QueryCapability.empty();
            if filterByResource
                resourceType=convertStringsToChars(resourceType);
                resourceTypeUri=this.getResourceTypeUri(resourceType,'query');
            end

            servicesRdf=this.get(this.ServiceProviderUrl);
            rdfMgr=slreq.internal.RdfResourceDataManager(servicesRdf);
            nodeList=rdfMgr.dom.getElementsByTagName('oslc:QueryCapability');
            for n=1:nodeList.Length
                node=nodeList.node(n);
                q=oslc.core.QueryCapability(node,this);
                if~filterByResource
                    out(n)=q;
                elseif any(strcmp(q.resourceType,resourceTypeUri))
                    out(end+1)=q;%#ok<AGROW>
                end
            end
        end

        function out=getDialog(this)
            if isempty(this.ServiceProviderUrl)
                error(message('Slvnv:oslc:ServiceProviderIsNotSpecified'))
            end
            out=oslc.core.Dialog.empty();
            servicesRdf=this.get(this.ServiceProviderUrl);
            rdfMgr=slreq.internal.RdfResourceDataManager(servicesRdf);
            nodeList=rdfMgr.dom.getElementsByTagName('oslc:Dialog');
            for n=1:nodeList.Length
                node=nodeList.node(n);
                out(n)=oslc.core.Dialog(node);
            end
        end

        function setConfigurationContext(this,configName)
            configName=convertStringsToChars(configName);
            if isempty(configName)

                this.ConfigurationContext='';
                this.ConfigurationUri='';
                this.AdditionalHttpHeader=[];
                return;
            end
            [names,url]=this.getConfigurationContextNames();
            idx=strcmp(names,configName);
            if~any(idx)
                error(message('Slvnv:oslc:InvalidConfigurationName',configName));
            end
            this.AdditionalHttpHeader=...
            matlab.net.http.HeaderField('Configuration-Context',url{idx});
            this.ConfigurationUri=url{idx};
            this.ConfigurationContext=configName;
        end

        function[out,url]=getConfigurationContextNames(this)
            url=[oslc.server,'/',this.ConfigurationQueryPath];
            rdf=this.get(url);
            rdfMgr=slreq.internal.RdfResourceDataManager(rdf);
            configNodes=rdfMgr.findNodesByTagAttrNameValue('rdf:type','rdf:resource','http://open-services.net/ns/config#Configuration');
            numConfigNodes=length(configNodes);
            out=cell(numConfigNodes,1);
            url=cell(numConfigNodes,1);
            for n=1:numConfigNodes
                topNode=configNodes(n).getParentNode;
                titleNode=topNode.getElementsByTagName('dcterms:title');
                out{n}=titleNode.node(1).TextContent;
                url{n}=topNode.getAttribute('rdf:about');
            end
        end

        function[content,eTag,responseStatusCode]=get(this,url)
            url=convertStringsToChars(url);
            if~this.isTesting
                [content,eTag,responseStatusCode]=get@slreq.rest.AuthClient(this,url);
                this.captureDataForTestingIfNeeded(content);
            else
                content=this.readFromCapturedTestData();
                eTag='';
                responseStatusCode=matlab.net.http.StatusCode.OK;
            end
        end

        function response=post(this,url,data,eTag)
            url=convertStringsToChars(url);
            if~this.isTesting
                response=post@slreq.rest.AuthClient(this,url,data,eTag);


                this.captureDataForTestingIfNeeded(response);
            else
                response=this.readFromCapturedTestData();
            end
        end

        function status=put(this,url,data,eTag)
            url=convertStringsToChars(url);
            if~this.isTesting
                status=put@slreq.rest.AuthClient(this,url,data,eTag);
                this.captureDataForTestingIfNeeded(status);
            else
                status=this.readFromCapturedTestData();
            end
        end

        function status=remove(this,url)
            url=convertStringsToChars(url);
            if~this.isTesting
                status=remove@slreq.rest.AuthClient(this,url);
                this.captureDataForTestingIfNeeded(status);
            else
                status=this.readFromCapturedTestData();
            end
        end
    end

    methods(Access=private)
        function out=getResourceTypeUri(~,in,type)
            pathTroughURIs={...
            oslc.rm.Requirement.typeUri,...
            oslc.rm.RequirementCollection.typeUri,...
            oslc.cm.ChangeRequest.typeUri...
            };

            qmURIs={...
            oslc.qm.TestCase.typeUri,...
            oslc.qm.TestScript.typeUri,...
            oslc.qm.TestPlan.typeUri,...
            oslc.qm.TestResult.typeUri,...
            oslc.qm.TestExecutionRecord.typeUri...
            };

            if any(strcmp(in,pathTroughURIs))
                out=in;
                return;
            elseif any(strcmp(in,qmURIs))
                if strcmpi(type,'query')

                    out=[in,'Query'];
                else
                    out=in;
                end
                return;
            end

            switch in
            case 'Requirement'
                out=oslc.rm.Requirement.typeUri;
            case 'RequirementCollection'
                out=oslc.rm.RequirementCollection.typeUri;
            case{'TestCase','TestScript','TestPlan','TestExecutionRecord','TestResult'}
                if strcmpi(type,'query')

                    out=[oslc.qm.(in).typeUri,'Query'];
                else
                    out=oslc.qm.(in).typeUri;
                end
            case 'ChangeRequest'
                out=oslc.cm.ChangeRequest.typeUri;
            otherwise
                error('%s is not a supported resource in OSLC client',in)
            end
        end

        function captureDataForTestingIfNeeded(this,in)


            if~isempty(this.testStruct)&&strcmp(this.testStruct.mode,'capture')
                this.testStruct.map(this.testStruct.count)=in;
                this.testStruct.count=this.testStruct.count+1;
            end
        end

        function out=readFromCapturedTestData(this)


            out=this.testStruct.map(this.testStruct.count);
            this.testStruct.count=this.testStruct.count+1;
        end
    end


    methods(Hidden)
        function initTestStruct(this,mode,mapData)
            if strcmp(mode,'capture')
                mapData=containers.Map('KeyType','double','ValueType','Any');
            else
                this.isTesting=true;
            end
            this.testStruct=struct('map',mapData,'count',1,'mode',mode);
        end
    end
end


