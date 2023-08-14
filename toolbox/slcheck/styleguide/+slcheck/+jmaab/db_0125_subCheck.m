classdef db_0125_subCheck<slcheck.subcheck
    methods
        function obj=db_0125_subCheck(InitParams)
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};

            obj.ID=InitParams.Name;
        end

        function result=run(this)
            result=false;

            sfDataObj=this.getEntity();

            if isa(sfDataObj,'Stateflow.Chart')||isa(sfDataObj,'Stateflow.StateTransitionTableChart')
                return;
            end


            if~isa(sfDataObj.getParent,'Simulink.BlockDiagram')
                return;
            end



            if strcmp(this.ID,'db_0125_a')&&...
                strcmp('Local',sfDataObj.Scope)

                flag=true;


            elseif strcmp(this.ID,'db_0125_b')&&...
                strcmp('Constant',sfDataObj.Scope)

                flag=true;


            elseif strcmp(this.ID,'db_0125_c')&&...
                strcmp('Parameter',sfDataObj.Scope)

                flag=true;

            else
                return;
            end



            if~flag
                return;
            end


            rdObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(rdObj,'SID',sfDataObj);
            result=this.setResult(rdObj);


        end
    end
end

