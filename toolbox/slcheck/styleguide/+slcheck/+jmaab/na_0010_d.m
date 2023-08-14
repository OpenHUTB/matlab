classdef na_0010_d<slcheck.subcheck
    methods
        function obj=na_0010_d()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='na_0010_d';
        end

        function result=run(this)
            result=false;
            entity=this.getEntity();

            ports=get_param(bdroot(entity),'BusInputIntoNonBusBlock');
            isMixedAttrib=logical([ports.MixedAttributes]');
            ports=ports(~isMixedAttrib);
            ports=unique({ports(:).BlockPath});


            if ismember(entity,ports)
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',entity);
                result=this.setResult(vObj);
            end
        end
    end
end
