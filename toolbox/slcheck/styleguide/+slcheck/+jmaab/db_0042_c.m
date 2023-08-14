classdef db_0042_c<slcheck.subcheck
    methods
        function obj=db_0042_c()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0042_c';
        end

        function result=run(this)
            result=false;

            portObj=this.getEntity();


            if strcmp(get_param(portObj,'BlockType'),'InportShadow')
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',portObj);
                result=this.setResult(vObj);
            end
        end
    end
end

