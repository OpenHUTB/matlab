classdef subcheck_jc_0711<slcheck.subcheck
    properties(Access=private)
        Strict=true;
    end

    methods
        function obj=subcheck_jc_0711(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.Name;
            obj.Strict=InitParams.Strict;
        end

        function result=run(this)
            result=false;

            transitionObj=this.getEntity();

            if isempty(transitionObj)
                return;
            end

            if~isprop(transitionObj,'LabelString')
                return;
            end

            if strcmp(transitionObj.Chart.ActionLanguage,'MATLAB')
                hasViolation=checkViolationMatlab(transitionObj,this.Strict);
            else
                hasViolation=checkViolationC(transitionObj,this.Strict);
            end

            if hasViolation
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',transitionObj);
                result=this.setResult(vObj);
            end
        end
    end
end


function hasViolation=checkViolationMatlab(transitionObj,strict)
    hasViolation=false;

    label=strtrim(transitionObj.LabelString);
    if isempty(label)
        return;
    end


    tr=mtree(regexprep(label,'[\n\r]+|[{}]',''));

    if tr.isempty||~Advisor.Utils.isValidMtree(tr)
        return;
    end

    divOpsTree=mtfind(tr,'Kind','DIV');
    if divOpsTree.isempty||~Advisor.Utils.isValidMtree(divOpsTree)
        return;
    end


    rightTree=divOpsTree.Right;

    if rightTree.isempty||~Advisor.Utils.isValidMtree(rightTree)
        return;
    end

    divisor=str2double(rightTree.tree2str);

    if strict



        hasViolation=isnan(divisor)||0==divisor;
    else

        hasViolation=~isDivisionByZeroPrevented(rightTree.tree2str,...
        transitionObj,'MATLAB');
    end

end


function hasViolation=checkViolationC(obj,strict)
    hasViolation=false;
    roots=getAllRoots(obj);

    for j=1:numel(roots)
        if~isa(roots{j},'Stateflow.Ast.Divide')
            continue;
        end

        divisor=getDivisor(roots{j});
        if~isnumeric(divisor)
            hasViolation=true;
            if~strict

                hasViolation=~isDivisionByZeroPrevented(...
                divisor,obj,'C');
            end
        else
            hasViolation=(0==divisor);
        end
    end
end


function divisor=getDivisor(roots)
    node=roots.rhs;
    if isfield(node,'value')
        divisor=node.value;
    else
        divisor=node.sourceSnippet;
    end
end





function status=isDivisionByZeroPrevented(divisor,transitionObj,actionLanguage)
    status=false;

    if~isa(transitionObj.Source,'Stateflow.Junction')
        return;
    end

    transitions=transitionObj.Source.sourcedTransitions;

    if length(transitions)<2
        return;
    end

    for idx=1:numel(transitions)
        if transitionObj.Id==transitions(idx).Id
            continue;
        end

        if strcmp(actionLanguage,'MATLAB')

            tr=mtree(transitions(idx).LabelString);
            if tr.isempty||~Advisor.Utils.isValidMtree(tr)
                continue;
            end

            eqTree=mtfind(tr,'Kind','EQ');
            if eqTree.isempty||~Advisor.Utils.isValidMtree(eqTree)
                continue;
            end

            rightTree=eqTree.Right;
            leftTree=eqTree.Left;

            if rightTree.isempty||~Advisor.Utils.isValidMtree(rightTree)||...
                leftTree.isempty||~Advisor.Utils.isValidMtree(leftTree)
                continue;
            end

            status=(strcmp(rightTree.tree2str,divisor)||...
            strcmp(leftTree.tree2str,divisor))&&...
            (strcmp(rightTree.tree2str,'0')||...
            strcmp(leftTree.tree2str,'0'));

            if status



                status=transitionObj.ExecutionOrder>transitions(idx).ExecutionOrder;
                return;
            end

        else

            roots=getAllRoots(transitions(idx));
            for j=1:numel(roots)
                if~isa(roots{j},'Stateflow.Ast.IsEqual')
                    continue;
                end
                lhs=roots{j}.lhs;
                rhs=roots{j}.rhs;

                status=(strcmp(lhs.sourceSnippet,divisor)||...
                strcmp(rhs.sourceSnippet,divisor))&&...
                (strcmp(lhs.sourceSnippet,'0')||...
                strcmp(rhs.sourceSnippet,'0'));

                if status



                    status=transitionObj.ExecutionOrder>transitions(idx).ExecutionOrder;
                    return;
                end
            end

        end
    end
end


function roots=getAllRoots(uddObject)
    roots={};
    astObject=Stateflow.Ast.getContainer(uddObject);
    if isempty(astObject)
        return;
    end

    astSections=astObject.sections;
    if isempty(astSections)
        return;
    end

    roots=cellfun(@(x)x.roots,astSections,'UniformOutput',false);
    if isempty(roots)
        return;
    end
    roots=roots{:};

    children=cellfun(@(x)x.children,roots,'UniformOutput',false);
    if isempty(children)
        return;
    end
    children=children{:};

    roots=[roots,children];
end