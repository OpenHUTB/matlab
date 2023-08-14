classdef jc_0763_a2<slcheck.subcheck
    methods
        function obj=jc_0763_a2()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0763_a2';
        end

        function result=run(this)
            result=false;

            obj=this.getEntity();

            txns=obj.find('-isa','Stateflow.Transition','-depth',1);

            innerTx=txns(arrayfun(@(x)Advisor.Utils.Stateflow.isInnerTransition(x),txns));

            if isempty(innerTx)
                return;
            end

            art=cell2mat(arrayfun(@(x)[x.SourceEndpoint(2),x.ExecutionOrder],innerTx,'UniformOutput',false));

            art=sortrows(art);

            if~issorted(art(:,2))
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                result=this.setResult(vObj);
            end

        end
    end
end
