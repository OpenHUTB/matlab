

classdef db_0081_a<slcheck.subcheck
    methods
        function obj=db_0081_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0081_a';
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();


            if strcmp(get_param(obj,'Type'),'line')


                if isequal(get_param(obj,'SrcPortHandle'),-1)||...
                    isequal(get_param(obj,'DstBlockHandle'),-1)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'Signal',obj);
                    result=this.setResult(vObj);
                end
            end
        end
    end
end