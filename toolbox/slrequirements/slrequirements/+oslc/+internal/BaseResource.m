classdef(Abstract)BaseResource<matlab.mixin.Heterogeneous&handle

    properties(SetAccess=protected,GetAccess=public)
        ResourceUrl char;
        Dirty logical=false;
        IsFetched logical=false;
    end

    properties(Hidden)
        eTag char;
        rdfMgr slreq.internal.RdfResourceDataManager;
        authClient oslc.Client;
    end

    properties(Abstract,Constant)
        creationTemplate;
        typeUri;
        resourceTag;
    end

    properties(Dependent)
Title
    end

    properties(Dependent,SetAccess=private,GetAccess=public)
Identifier
    end

    methods
        function this=BaseResource()
            this.rdfMgr=slreq.internal.RdfResourceDataManager(this.creationTemplate);
            this.authClient=oslc.Client.empty;
        end

        function out=get.Title(this)
            if~this.IsFetched
                out='';
                return;
            end
            out=this.getProperty('dcterms:title');
        end

        function set.Title(this,title)
            title=convertStringsToChars(title);
            this.setProperty('dcterms:title',title);
        end

        function out=get.Identifier(this)
            if~this.IsFetched
                out='';
                return;
            end
            out=this.getProperty('dcterms:identifier');
        end

        function out=getRDF(this)
            out=this.rdfMgr.toString;


            out=strrep(out,'UTF-16','UTF-8');
        end

        function setRDF(this,rdf)
            rdf=convertStringsToChars(rdf);
            this.rdfMgr=slreq.internal.RdfResourceDataManager(rdf);
            this.IsFetched=true;
            this.Dirty=false;
        end

        function out=getProperty(this,propName)
            this.errorIfResourceNotFetched();
            propName=convertStringsToChars(propName);
            out=this.rdfMgr.getProperty(propName,this.typeUri,this.resourceTag);
        end

        function setProperty(this,propName,propValue)
            this.errorIfResourceNotFetched();
            propName=convertStringsToChars(propName);
            propValue=convertStringsToChars(propValue);
            this.rdfMgr.setProperty(propName,propValue,this.typeUri,this.resourceTag);
            this.Dirty=true;
        end

        function status=fetch(this,client)
            if nargin>1
                this.authClient=client;
            elseif isempty(this.authClient)
                error(message('Slvnv:oslc:OslcClientRequired'));
            end
            try
                [rdf,this.eTag,status]=this.authClient.get(this.ResourceUrl);
                this.rdfMgr=slreq.internal.RdfResourceDataManager(rdf);
                this.IsFetched=true;
                this.Dirty=false;
            catch ex
                this.IsFetched=false;
                if strcmp(ex.identifier,'slreq:oslc:GETMethodError')
                    this.authClient=oslc.Client.empty;
                    error(message('Slvnv:oslc:OslcClientRequired'));
                else
                    rethrow(ex);
                end
            end
        end

        function out=commit(this,client)

            if nargin>1
                this.authClient=client;
            elseif isempty(this.authClient)
                error(message('Slvnv:oslc:OslcClientRequired'));
            end
            this.errorIfResourceNotFetched();
            out=this.authClient.put(this.ResourceUrl,this.rdfMgr.toString,this.eTag);
            this.Dirty=false;
        end

        function out=remove(this,client)
            if nargin>1
                this.authClient=client;
            elseif isempty(this.authClient)
                error(message('Slvnv:oslc:OslcClientRequired'));
            end
            out=this.authClient.remove(this.ResourceUrl);
            delete(this);
        end

        function out=getResourceProperty(this,propName)
            this.errorIfResourceNotFetched();
            propName=convertStringsToChars(propName);
            out=this.rdfMgr.getResourceUrlsFromProperty(propName,this.typeUri);
        end

        function addTextProperty(this,propName,text,namespace)
            propName=convertStringsToChars(propName);
            text=convertStringsToChars(text);
            if nargin==3
                this.rdfMgr.addTextProperty(propName,this.resourceTag,this.typeUri,text);
            else
                namespace=convertStringsToChars(namespace);
                this.rdfMgr.addTextPropertyNS(propName,this.resourceTag,this.typeUri,text,namespace);
            end
            this.Dirty=true;
        end

        function addResourceProperty(this,propName,resourceUrl)
            propName=convertStringsToChars(propName);
            resourceUrl=convertStringsToChars(resourceUrl);
            if~this.IsFetched


                this.rdfMgr.addResourcePropertyByTag(this.resourceTag,propName,resourceUrl);
            else


                this.rdfMgr.addResourcePropertyByTypeUri(this.typeUri,propName,resourceUrl);
            end
            this.Dirty=true;
        end

        function setResourceUrl(this,resourceUrl)
            resourceUrl=convertStringsToChars(resourceUrl);
            this.ResourceUrl=resourceUrl;
            this.Dirty=true;
        end

        function removeResourceProperty(this,propName,resourceUrl)
            this.errorIfResourceNotFetched();
            propName=convertStringsToChars(propName);
            resourceUrl=convertStringsToChars(resourceUrl);


            tagNode=this.rdfMgr.findNodesByTagName(propName);
            if isempty(tagNode)
                ex=MException(message('Slvnv:oslc:NoSuchPropertyFound',propName));
                throwAsCaller(ex);
            end

            nodes=this.rdfMgr.findNodesByTagAttrNameValue(propName,'rdf:resource',resourceUrl);
            if isempty(nodes)
                ex=MException(message('Slvnv:oslc:NoSuchResourceFound',resourceUrl,propName));
                throwAsCaller(ex);
            end

            for n=length(nodes):-1:1
                thisNode=nodes(n);
                parentNode=thisNode.getParentNode;
                parentNode.removeChild(thisNode);
            end
            this.Dirty=true;
        end

        function show(this)


            if~isempty(this.authClient)
                contextUri=this.authClient.ConfigurationUri;
            else
                contextUri='';
            end
            if~isempty(contextUri)
                if any(this.ResourceUrl=='?')
                    querySep='&';
                else
                    querySep='?';
                end
                urlToOpen=sprintf('%s%soslc_config.context=%s',this.ResourceUrl,querySep,urlencode(contextUri));
            else
                urlToOpen=this.ResourceUrl;
            end
            web(urlToOpen);
        end
    end

    methods(Access=protected)
        function errorIfResourceNotFetched(this)
            if isempty(this.rdfMgr)
                error(message('Slvnv:oslc:UnfetchedError'));
            end
        end
    end

    methods(Hidden)
        function setClient(this,client)
            this.authClient=client;
        end
    end
end


