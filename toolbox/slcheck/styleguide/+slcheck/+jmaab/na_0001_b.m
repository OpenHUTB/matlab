classdef na_0001_b<slcheck.subcheck





    properties
        inequalityOp;
    end
    methods
        function obj=na_0001_b(InitParams)
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID=InitParams.Name;
            obj.inequalityOp={InitParams.operator};
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

                        idx=cell2mat(regexp(transitionObj.sourceSnippet,this.inequalityOp,'once'));

                        if contains(transitionObj.sourceSnippet,this.inequalityOp)
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
