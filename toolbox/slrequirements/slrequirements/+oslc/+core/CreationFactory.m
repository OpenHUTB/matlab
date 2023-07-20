














































































classdef CreationFactory<oslc.internal.BaseService



    properties
client
    end

    properties(Dependent)
        creation;
        resourceShape;
    end

    methods
        function this=CreationFactory(dom,client)
            this.dom=dom;
            this.client=client;
        end

        function out=get.creation(this)
            node=this.dom.getElementsByTagName('oslc:creation');
            out=node.node(1).getAttribute('rdf:resource');
        end

        function out=get.resourceShape(this)
            out={};
            nodeList=this.dom.getElementsByTagName('oslc:resourceShape');
            for n=1:nodeList.Length
                out{n}=nodeList.node(n).getAttribute('rdf:resource');%#ok<AGROW>
            end
            out=unique(out);
        end

        function obj=create(this,obj)
            if~isa(obj,'oslc.internal.BaseResource')
                error(message('Slvnv:oslc:InvalidResourceObject'))
            end
            obj=this.createResource(obj);
        end

        function obj=createTestCase(this,title)
            obj=oslc.qm.TestCase();
            obj.addTextProperty('dcterms:title',title);
            obj=this.createResource(obj);
        end

        function obj=createTestScript(this,title)
            obj=oslc.qm.TestScript();
            obj.addTextProperty('dcterms:title',title);
            obj=this.createResource(obj);
        end

        function obj=createTestPlan(this,title)
            obj=oslc.qm.TestPlan();
            obj.addTextProperty('dcterms:title',title);
            obj=this.createResource(obj);
        end

        function obj=createTestExecutionRecord(this,title,testCaseUrl)
            obj=oslc.qm.TestExecutionRecord();
            obj.addTextProperty('dcterms:title',title);
            obj.addResourceProperty('oslc_qm:runsTestCase',testCaseUrl);
            obj=this.createResource(obj);
        end

        function obj=createTestResult(this,title,testCaseUrl,testExecutionRecordUrl,status)
            obj=oslc.qm.TestResult();
            obj.addTextProperty('dcterms:title',title);
            obj.addResourceProperty('oslc_qm:reportsOnTestCase',testCaseUrl);
            obj.addResourceProperty('oslc_qm:producedByTestExecutionRecord',testExecutionRecordUrl);
            obj.addTextProperty('oslc_qm:status',status);
            obj=this.createResource(obj);
        end

        function obj=createRequirement(this,title)
            obj=oslc.rm.Requirement();
            obj.addTextProperty('dcterms:title',title);
            obj.addResourceProperty('oslc:instanceShape',this.resourceShape{1});
            obj=this.createResource(obj);
        end

        function obj=createRequirementCollection(this,title)
            obj=oslc.rm.RequirementCollection();
            obj.addTextProperty('dcterms:title',title);
            obj.addResourceProperty('oslc:instanceShape',this.resourceShape{1});
            obj=this.createResource(obj);
        end

        function obj=createChangeRequest(this,title)
            obj=oslc.cm.ChangeRequest();
            obj.addTextProperty('dcterms:title',title);
            obj=this.createResource(obj);
        end
    end

    methods(Access=private)
        function obj=createResource(this,obj)


            response=this.client.post(this.creation,obj.getRDF(),'');
            resourceUrl=char(response.getFields('Location').Value);
            obj.setResourceUrl(resourceUrl);
            obj.setClient(this.client);
            data=char(response.Body.Data)';
            if~isempty(data)

                obj.setRDF(data);
            end
        end
    end
end


