classdef na_0010_c<slcheck.subcheck
    methods
        function obj=na_0010_c()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='na_0010_c';
        end

        function result=run(this)
            result=false;
            entity=this.getEntity();

            mdlAdvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();

            if~strcmp(mdlAdvObj.system,entity)
                return;
            end

            if~strcmp(get_param(bdroot(entity),'StrictBusMsg'),'ErrorOnBusTreatedAsVector')
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Model',bdroot(entity),'Parameter','StrictBusMsg','CurrentValue',get_param(bdroot(entity),'StrictBusMsg'),'RecommendedValue','ErrorOnBusTreatedAsVector');
                result=this.setResult(vObj);
            end
        end

        function bSuccess=fixit(this)
            bSuccess=false;
            entity=this.getEntity();

            mdlAdvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();

            if~strcmp(mdlAdvObj.system,entity)
                return;
            end

            set_param(bdroot(entity),'StrictBusMsg','ErrorOnBusTreatedAsVector');
            bSuccess=true;
        end
    end
end

