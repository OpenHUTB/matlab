classdef(Sealed)jc_0121_c<slcheck.subcheck
%#ok<*AGROW>
    methods
        function obj=jc_0121_c()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0121_c';
        end

        function result=run(this)
            result=false;
            blockHandle=this.getEntity();

            if isempty(blockHandle)
                return;
            end

            sumBlock=get_param(blockHandle,'object');

            if sumBlock.Ports(1)>2
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'SID',blockHandle);
                result=this.setResult(vObj);
            end
        end
    end
end