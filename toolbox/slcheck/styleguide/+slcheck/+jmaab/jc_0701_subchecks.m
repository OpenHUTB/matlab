classdef jc_0701_subchecks<slcheck.subcheck
    properties(Access=private)
        Index=1;
    end

    methods
        function obj=jc_0701_subchecks(initParams)
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID=initParams.Name;
            obj.Index=initParams.Index;
        end

        function result=run(this)
            result=false;

            dataObj=this.getEntity();


            if~isa(dataObj,'Stateflow.Data')
                return
            end


            if~Advisor.Utils.Stateflow.isActionLanguageC(dataObj.getParent)
                return;
            end


            firstIndex=dataObj.Props.Array.FirstIndex;



            if isempty(firstIndex)
                firstIndex='0';
            end


            if~strcmp(firstIndex,this.Index)

                rdObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(rdObj,'SID',dataObj);
                result=this.setResult(rdObj);

            end

        end
    end
end


