classdef(Sealed)jc_0702_a<slcheck.subcheck
%#ok<*AGROW>
    properties
        castsToBeIgnored={};
        alreadyProcessedUMinus={};
    end
    methods
        function obj=jc_0702_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0702_a';
        end

        function result=run(this)

            sfObj=this.getEntity();

            violations=[];
            asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfObj);
            for i=1:numel(asts.sections)
                sec=asts.sections{i};
                for j=1:numel(sec.roots)
                    root=sec.roots{j};

                    if Advisor.Utils.Stateflow.isActionLanguageC(sfObj)
                        violations=[violations;this.checkCObj(sfObj,root)];
                    else
                        violations=[violations;checkMObj(sfObj,root)];
                    end
                end
            end
            if~isempty(violations)
                [~,ia]=unique({violations(:).Data});
                violations=violations(ia);
                result=this.setResult(violations);
            else
                result=false;
            end

            this.clear();
        end
        function clear(this)
            this.castsToBeIgnored={};
            this.alreadyProcessedUMinus={};
        end
        function violations=checkCObj(this,sfObj,root)
            violations=[];
            if isa(root,'Stateflow.Ast.EqualAssignment')
                for i=1:numel(root.children)
                    if isFloatOrInt(root.children{i})&&root.children{i}.value~=0
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',sfObj,'Expression',root.sourceSnippet);
                        violations=[violations;vObj];
                    end
                end
            elseif isa(root,'Stateflow.Ast.PlusAssignment')||isa(root,'Stateflow.Ast.MinusAssignment')||isa(root,'Stateflow.Ast.Plus')||isa(root,'Stateflow.Ast.Minus')
                for i=1:numel(root.children)
                    if isFloatOrInt(root.children{i})&&root.children{i}.value~=1
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',sfObj,'Expression',root.sourceSnippet);
                        violations=[violations;vObj];
                    end


                    if isa(root.children{i},'Stateflow.Ast.Uminus')
                        this.alreadyProcessedUMinus{end+1}=root.children{i};
                        if numel(root.children{i}.children)==1&&isFloatOrInt(root.children{i}.children{1})...
                            &&root.children{i}.children{1}.value~=1
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'SID',sfObj,'Expression',root.sourceSnippet);
                            violations=[violations;vObj];
                        end
                    end



                    if isa(root.children{i},'Stateflow.Ast.ExplicitTypeCast')&&numel(root.children{i}.children)==1
                        if isFloatOrInt(root.children{i}.children{1})&&root.children{i}.children{1}.value==1

                            this.castsToBeIgnored{end+1}=root.children{i};
                        end
                    end
                end
            else

                if~any(cellfun(@(x)isequal(x,root),this.castsToBeIgnored))&&...
                    ~any(cellfun(@(x)isequal(x,root),this.alreadyProcessedUMinus))
                    for i=1:numel(root.children)
                        if isFloatOrInt(root.children{i})
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'SID',sfObj,'Expression',root.sourceSnippet);
                            violations=[violations;vObj];
                        end
                    end
                end
            end

            children=root.children;
            for i=1:numel(children)
                violations=[violations;this.checkCObj(sfObj,children{i})];
            end
        end
    end
end

function floatOrInt=isFloatOrInt(node)
    floatOrInt=isa(node,'Stateflow.Ast.FloatNum')||isa(node,'Stateflow.Ast.IntegerNum');
end
function violations=checkMObj(sfObj,root)
    violations=[];

    mt=mtree(regexprep(root.sourceSnippet,'\s',''));

    nodes=mt.mtfind('Kind',{'DOUBLE','INT'});
    for idx=nodes.indices
        thisnode=nodes.select(idx);
        typecastfcn={'single','double','int8','int16','int32','int64',...
        'uint8','uint16','unit32','uint32','typecast','cast'};
        parent=thisnode.Parent;

        if strcmp(parent.kind,'EQUALS')&&(str2double(thisnode.string)==0)
            continue;
        elseif any(strcmp(parent.kind,{'PLUS','MINUS'}))&&(str2double(thisnode.string)==1)
            continue;



        elseif strcmp(parent.kind,'CALL')&&any(strcmp(parent.Parent.kind,{'PLUS','MINUS'}))&&...
            (any(strcmp(parent.Left.string,typecastfcn)))
            continue;
        else
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',sfObj,'Expression',root.sourceSnippet);
            violations=[violations;vObj];
        end
    end
end