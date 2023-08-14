classdef jc_0627_a<slcheck.subcheck
    methods
        function obj=jc_0627_a(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.CheckName;
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();
            dtiObj=get_param(obj,'Object');

            if strcmp(dtiObj.LimitOutput,'off')
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Block',obj,'Parameter','LimitOutput',...
                'CurrentValue',dtiObj.LimitOutput,'RecommendedValue','on');
                result=this.setResult(vObj);
            end
        end
    end
end