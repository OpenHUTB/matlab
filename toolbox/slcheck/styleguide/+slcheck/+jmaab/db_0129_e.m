classdef db_0129_e<slcheck.subcheck
    methods
        function obj=db_0129_e()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0129_e';
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();
            if isa(obj,'Stateflow.Junction')&&isequal(obj.Type,'CONNECTIVE')
                if~isa(getParent(obj),'Stateflow.TruthTable')

                    if Advisor.Utils.Stateflow.isUnnecessaryJunction(obj)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                        result=this.setResult(vObj);
                    end
                end
            end
        end
    end
end