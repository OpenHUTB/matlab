classdef QueryCapability<oslc.internal.BaseService

    properties(GetAccess=public,SetAccess=private)
        queryParameter='';
        client;
    end

    properties(Dependent)
        queryBase;
        resourceShape;
    end

    methods
        function this=QueryCapability(dom,client)
            this.dom=dom;
            this.client=client;
        end

        function out=get.queryBase(this)
            node=this.dom.getElementsByTagName('oslc:queryBase');
            out=node.node(1).getAttribute('rdf:resource');
        end

        function out=get.resourceShape(this)
            out={};
            nodeList=this.dom.getElementsByTagName('oslc:resourceShape');
            for n=1:nodeList.Length
                out{n}=node.node(n).getAttribute('rdf:resource');%#ok<AGROW>
            end
            out=unique(out);
        end

        function setQueryParameter(this,param)
            param=this.sanitizeOptionalParams(param);
            this.queryParameter=param;
        end

        function out=queryTestCases(this)
            out=this.queryResource(@oslc.qm.TestCase,'rdf:resource','oslc_qm:testCase','oslc.select=oslc_qm:testCase');
        end

        function out=queryTestScripts(this)
            out=this.queryResource(@oslc.qm.TestScript,'rdf:resource','oslc_qm:testScript','oslc.select=oslc_qm:testScript');
        end

        function out=queryTestPlans(this)
            out=this.queryResource(@oslc.qm.TestPlan,'rdf:resource','oslc_qm:testPlan','oslc.select=oslc_qm:testPlan');
        end

        function out=queryTestExecutionRecords(this)
            out=this.queryResource(@oslc.qm.TestExecutionRecord,'rdf:resource','oslc_qm:testExecutionRecord','oslc.select=oslc_qm:testExecutionRecord');
        end

        function out=queryTestResults(this)
            out=this.queryResource(@oslc.qm.TestResult,'rdf:resource','oslc_qm:testResult','oslc.select=oslc_qm:testResult');
        end

        function out=queryRequirements(this)
            out=this.queryResource(@oslc.rm.Requirement,'rdf:about','oslc_rm:Requirement','');
            if numel(out)==0&&contains(this.queryParameter,'oslc.where')

                rmiut.warnNoBacktrace('Slvnv:oslc:NoMatchesFor',this.queryParameter);
            end
        end

        function out=queryRequirementCollections(this)
            out=this.queryResource(@oslc.rm.RequirementCollection,'rdf:about','oslc_rm:RequirementCollection','');
            if numel(out)==0&&contains(this.queryParameter,'oslc.where')

                rmiut.warnNoBacktrace('Slvnv:oslc:NoMatchesFor',this.queryParameter);
            end
        end

        function out=queryChangeRequests(this)


            out=this.queryResource(@oslc.cm.ChangeRequest,'rdf:resource','rdfs:member','');
        end
    end

    methods(Hidden)

        function rdfMgr=runQuery(this,queryUrl)
            rdf=this.client.get(queryUrl);
            rdfMgr=slreq.internal.RdfResourceDataManager(rdf);
        end

        function queryUrl=getQueryUrl(this,queryParameters)
            queryUrl=this.queryBase;

            if~isempty(this.queryParameter)
                queryUrl=this.appendToQueryUrl(queryUrl,this.queryParameter);
            end

            if~isempty(queryParameters)
                queryUrl=this.appendToQueryUrl(queryUrl,queryParameters);
            end
            queryUrl=this.ensureNamespaces(queryUrl);
        end

        function out=queryResource(this,classHandle,resouceAttributeName,resourceTagName,queryParameters)

            out=classHandle().empty;
            queryUrl=this.getQueryUrl(queryParameters);
            queryResult=this.runQuery(queryUrl);
            nodeList=queryResult.dom.getElementsByTagName(resourceTagName);
            for n=1:nodeList.Length
                thisNodeObj=classHandle();
                thisNodeObj.setResourceUrl(nodeList.node(n).getAttribute(resouceAttributeName));
                thisNodeObj.setClient(this.client);
                out(n)=thisNodeObj;
            end
        end

    end

    methods(Access=private)

        function url=appendToQueryUrl(~,url,param)
            if startsWith(param,'oslc.select=')&&contains(url,'oslc.select=')

                url=regexprep(url,'oslc\.select=[^\&]+',param);
            elseif startsWith(param,'oslc.where=')&&contains(url,'oslc.where=')

                url=regexprep(url,'oslc\.where=[^\&]+',param);
            elseif any(url=='?')

                url=[url,'&',param];
            else

                url=[url,'?',param];
            end
        end

        function params=sanitizeOptionalParams(~,varargin)
            if isempty(varargin)
                params='';
            else
                params=convertStringsToChars(varargin{1});



                if~isempty(params)&&(params(1)=='?'||params(1)=='&')
                    params(1)=[];
                end
            end
        end

        function queryStr=ensureNamespaces(~,queryStr)
            if contains(queryStr,'dcterms:')&&~contains(queryStr,'dcterms=')
                dcterms=oslc.matlab.Constants.DC;
                namespace=['oslc.prefix=dcterms=',urlencode(['<',dcterms,'>'])];
                queryStr=strrep(queryStr,'oslc.where',[namespace,'&oslc.where']);
            end
            if contains(queryStr,'oslc_rm:')&&~contains(queryStr,'oslc_rm=')
                oslc_rm=oslc.matlab.Constants.OSLC_RM_V2;
                namespace=['oslc.prefix=oslc_rm=',urlencode(['<',oslc_rm,'>'])];
                queryStr=strrep(queryStr,'oslc.select',[namespace,'&oslc.select']);
            end
        end
    end
end


