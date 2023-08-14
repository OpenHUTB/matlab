classdef(Sealed)jc_0121_a<slcheck.subcheck
%#ok<*AGROW>
    methods
        function obj=jc_0121_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0121_a';
        end

        function result=run(this)
            result=false;
            blockHandle=this.getEntity();

            if isempty(blockHandle)
                return;
            end

            sumBlock=get(blockHandle);
            if strcmp(sumBlock.IconShape,'rectangular')
                return;
            end

            svc=slcheck.services.GraphService.getInstance();
            data=svc.getData(get_param(sumBlock.Parent,'handle'));
            if data.in_loop(data.handles==blockHandle)
                return;
            end

            vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
            ModelAdvisor.ResultDetail.setData(vObj,'SID',blockHandle);
            result=this.setResult(vObj);
        end
    end
end