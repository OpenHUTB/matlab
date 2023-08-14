classdef jc_0775_subCheck<slcheck.subcheck
    methods
        function obj=jc_0775_subCheck(inputParam)
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID=inputParam.Name;
        end

        function result=run(this)
            result=false;

            obj=this.getEntity();


            sfJ=obj.find('-isa','Stateflow.Junction','-depth',1);


            if isempty(sfJ)
                return;
            end



            flagArray=arrayfun(@(x)isempty(x.sourcedTransitions),sfJ);
            terminalJunction=sfJ(flagArray);


            terminalJunctionCnt=numel(terminalJunction);


            if isempty(terminalJunction)||terminalJunctionCnt<1
                return;
            end


            if strcmp(this.ID,'jc_0775_a1')&&terminalJunctionCnt==1




                return;

            elseif strcmp(this.ID,'jc_0775_a2')&&terminalJunctionCnt==1





                sfT=terminalJunction.sinkedTransitions;


                if isempty(sfT)
                    return;
                end

                if numel(sfT)==1




                    section=Advisor.Utils.Stateflow...
                    .getAbstractSyntaxTree(sfT);

                    if isempty(section.conditionSection)



                        return;
                    end

                end

            end



            rdObj=ModelAdvisor.ResultDetail;






            ModelAdvisor.ResultDetail.setData(rdObj,'Custom',...
            DAStudio.message('ModelAdvisor:jmaab:jc_0775_col1'),...
            obj,...
            DAStudio.message('ModelAdvisor:jmaab:jc_0775_col2'),...
            terminalJunction);

            result=this.setResult(rdObj);

        end
    end
end

