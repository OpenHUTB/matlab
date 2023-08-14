classdef jc_0792_b<slcheck.subcheck
    methods
        function obj=jc_0792_b()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='jc_0792_b';
        end

        function result=run(this)
            result=false;

            obj=this.getEntity();

            if isa(obj,'Simulink.VariableUsage')&&isempty(obj.Users)&&strcmp(obj.SourceType,'model workspace')
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SimulinkVariableUsage',obj);
                result=this.setResult(vObj);
            end
        end
    end
end