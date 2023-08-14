classdef jc_0763_a1<slcheck.subcheck
    methods
        function obj=jc_0763_a1()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0763_a1';
        end

        function result=run(this)
            result=false;

            obj=this.getEntity();

            txns=obj.find('-isa','Stateflow.Transition','-depth',1);

            txns=txns(arrayfun(@(x)~isempty(x.Source)&&~isempty(x.Destination),txns));

            numInternalTxn=sum(arrayfun(@(x)x.Source==obj,txns));

            if numInternalTxn>1
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                result=this.setResult(vObj);
            end

        end
    end
end
