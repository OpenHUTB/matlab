classdef jc_0630_b<slcheck.subcheck

    methods
        function obj=jc_0630_b()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='jc_0630_b';
        end

        function result=run(this)
            result=false;
            inps=this.getEntity();
            CompData=get_param(inps,'CompiledPortDataTypes');

            if~contains(CompData.Inport{1},'uint')
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'SID',inps);
                result=this.setResult(vObj);
            end

        end
    end
end
