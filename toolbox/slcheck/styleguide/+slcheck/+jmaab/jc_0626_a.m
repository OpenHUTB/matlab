classdef jc_0626_a<slcheck.subcheck

    methods
        function obj=jc_0626_a(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.CheckName;
        end
        function result=run(this)

            result=false;
            obj=this.getEntity();


            if(strcmp(get_param(obj,'BlockType'),'S-Function')&&...
                strcmp(get_param(obj,'MaskType'),'Lookup Table Dynamic'))


                ReferenceBlock=get_param(obj,'ReferenceBlock');
                libIndex=regexp(ReferenceBlock,'simulink/');
                if isempty(libIndex)
                    return;
                else
                    if~libIndex==1
                        return;
                    end
                end

                LookUpMeth=get_param(obj,'LookUpMeth');


                if~strcmp(LookUpMeth,'Interpolation-Use End Values')
                    currentValue=LookUpMeth;
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,...
                    'Block',obj,...
                    'Parameter','LookUpMeth',...
                    'CurrentValue',currentValue,...
                    'RecommendedValue','Interpolation-Use End Values');
                    result=this.setResult(vObj);

                end
            end
        end
        function bSuccess=fixit(this)
            bSuccess=true;

            obj=this.getEntity();

            set_param(obj,'LookUpMeth','Interpolation-Use End Values');
        end
    end
end