classdef subcheck_db_0127<slcheck.subcheck


    properties
        Strict=1;
    end
    methods
        function obj=subcheck_db_0127(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.Name;
            obj.Strict=InitParams.Strict;
        end
        function result=run(this)
            result=false;
            violations=[];
            sfObj=this.getEntity();
            if isempty(sfObj)
                return;
            end

            asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfObj);
            if isempty(asts)
                return;
            end
            treeStart=[];

            checkMatFun=this.Strict;
            for i=1:numel(asts.sections)
                sec=asts.sections{i};
                for j=1:numel(sec.roots)
                    root=sec.roots{j};


                    if ismember(root.treeStart,treeStart)
                        continue;
                    else
                        treeStart=[treeStart;root.treeStart];%#ok<AGROW>

                        if Advisor.Utils.Stateflow.isActionLanguageC(sfObj)
                            violations=[violations;iCheckMatlabExprInChart(sfObj,root,checkMatFun)];%#ok<AGROW>
                        end
                    end
                end
            end

            if~isempty(violations)
                result=this.setResult(violations);
            end
        end
    end
end

function violations=iCheckMatlabExprInChart(sfObj,root,checkMatFun)





    indices=[];
    violations=[];


    if isa(root,'Stateflow.Ast.UserFunction')&&...
        (iCheckMatlabFunctionCall(root)&&checkMatFun)
        userFunName=strtok(root.sourceSnippet,'(');
        highlightText=Advisor.Utils.Stateflow.highlightSFLabelByIndex(root.sourceSnippet,[1,numel(userFunName)]);
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',sfObj,'Expression',highlightText.emitHTML);
        violations=[violations;vObj];
    end

    if((isa(root,'Stateflow.Ast.UserFunction')||...
        isa(root,'Stateflow.Ast.Identifier'))&&...
...
        (~isempty(strfind(root.sourceSnippet,'ml.'))))||...
...
        (isa(root,'Stateflow.Ast.MatlabFunction'))


        if isa(root,'Stateflow.Ast.MatlabFunction')
            indices=[indices;[root.treeStart,root.treeStart+2]];
            mlStr=strfind(root.children{1}.sourceSnippet,'ml.');
            if~isempty(mlStr)
                for j=1:length(mlStr)
                    indices=[indices;[root.children{1}.treeStart+mlStr(j)-1,root.children{1}.treeStart+mlStr(j)+3]];%#ok<AGROW>
                end
            end
        else
            indices=[indices;[root.treeStart,root.treeEnd]];
        end

        highlightText=Advisor.Utils.Stateflow.highlightSFLabelByIndex(sfObj.LabelString,indices);
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',sfObj,'Expression',highlightText.emitHTML);
        violations=[violations;vObj];
    end

    children=root.children;
    for k=1:length(children)
        violations=[violations;iCheckMatlabExprInChart(sfObj,children{k},checkMatFun)];%#ok<AGROW>
    end
end
function flag=iCheckMatlabFunctionCall(root)


    rt=sfroot;

    emMatlabFunList=rt.find('-isa','Stateflow.EMFunction');
    emMatlabFunNames=arrayfun(@(x)x.LabelString,emMatlabFunList,'UniformOutput',false);
    userFunName=strtok(root.sourceSnippet,'(');

    flag=any(contains(emMatlabFunNames,[userFunName,'(']));
end