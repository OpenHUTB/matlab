classdef na_0001_c<slcheck.subcheck


    methods
        function obj=na_0001_c()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='na_0001_c';
        end

        function result=run(this)

            result=false;
            chartObj=this.getEntity();
            if Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                return;
            end
            vObjArray=[];
            StatesTransitions=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');

            for jj=1:length(StatesTransitions)
                obj=StatesTransitions(jj);
                objSID=Simulink.ID.getSID(obj);
                asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
                if isempty(asts)
                    return;
                end
                sections=asts.sections;
                for kk=1:length(sections)
                    for mm=1:length(sections{kk}.roots)
                        transitionObj=sections{kk}.roots{mm};
                        if isempty(transitionObj)
                            return;
                        end


                        idx=regexp(transitionObj.sourceSnippet,'~[^=]','once');
                        if~isempty(idx)
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'SID',objSID,'Expression',transitionObj.sourceSnippet,'TextStart',idx,'TextEnd',idx+1);
                            vObjArray=[vObjArray;vObj];
                        end
                    end
                end
            end
            if~isempty(vObjArray)
                result=this.setResult(vObjArray);
            end
        end
    end
end