classdef na_0001_a<slcheck.subcheck


    methods
        function obj=na_0001_a()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='na_0001_a';
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
                treeStart=[];
                for kk=1:length(sections)

                    roots=sections{kk}.roots;
                    if ismember(roots{1}.treeStart,treeStart)
                        continue;
                    else
                        treeStart=[treeStart;roots{1}.treeStart];%#ok<AGROW>
                        for mm=1:length(sections{kk}.roots)
                            transitionObj=sections{kk}.roots{mm};
                            if isempty(transitionObj)
                                return;
                            end
                            hasViolation=false;



                            if~(chartObj.EnableBitOps)&&~isempty(regexp(transitionObj.sourceSnippet,'(?<!\&)(\&)(?!\&)|(?<!\|)(\|)(?!\|)|\^|(\~)(?!\=)','once'))
                                hasViolation=true;
                            elseif(chartObj.EnableBitOps)&&~isempty(regexp(transitionObj.sourceSnippet,'(?<!\&)(\&)(?!\&)|(?<!\|)(\|)(?!\|)|\^|(\~)(?!\=)','once'))


                                hasViolation=verifyBitOps(transitionObj,chartObj);


                            end

                            if hasViolation
                                idx=regexp(transitionObj.sourceSnippet,'[|&^~]');
                                vObj=ModelAdvisor.ResultDetail;
                                ModelAdvisor.ResultDetail.setData(vObj,'SID',objSID,'Expression',transitionObj.sourceSnippet,'TextStart',idx,'TextEnd',idx+1);
                                vObjArray=[vObjArray;vObj];
                            end
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

function present=verifyBitOps(node,chartObj)
    present=false;







    if isa(node,'Stateflow.Ast.BitAnd')||isa(node,'Stateflow.Ast.BitOr')||isa(node,'Stateflow.Ast.BitXor')
        [ltype,~]=Advisor.Utils.Stateflow.getAstDataType(bdroot(chartObj.Path),node.lhs,chartObj);
        [rtype,~]=Advisor.Utils.Stateflow.getAstDataType(bdroot(chartObj.Path),node.rhs,chartObj);

        if(strcmp(ltype,'boolean')&&strcmp(rtype,'boolean'))
            present=true;
        end

    elseif isa(node,'Stateflow.Ast.EqualAssignment')
        [ltype,~]=Advisor.Utils.Stateflow.getAstDataType(bdroot(chartObj.Path),node.lhs,chartObj);
        if strcmp(ltype,'boolean')
            present=true;
        end
    end
    if true==present
        return;
    end

    for ii=1:length(node.children)
        childNode=node.children{ii};
        if~isempty(childNode.children)
            present=verifyBitOps(childNode,chartObj);
        end

    end
end