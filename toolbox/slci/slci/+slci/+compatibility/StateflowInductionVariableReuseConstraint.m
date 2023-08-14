

classdef StateflowInductionVariableReuseConstraint<slci.compatibility.Constraint



    methods

        function out=getDescription(aObj)%#ok
            out=['A supported stateflow non-loop transition must not'...
            ,'reuse loop induction variables.'];

        end


        function obj=StateflowInductionVariableReuseConstraint
            obj.setEnum('StateflowInductionVariableReuse');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            classnames=aObj.getOwner.getClassNames;
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction'],classnames);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status],classnames);
        end


        function out=check(aObj)
            out=[];
            t=aObj.getOwner();
            asts=t.getASTs();
            for i=1:numel(asts)
                ast=asts{i};
                isLoopTransition=t.isLoopInitTransition()...
                ||t.isLoopCondTransition()...
                ||t.isLoopBodyTransition()...
                ||t.isLoopAfterTransition();
                if~isLoopTransition...
                    &&aObj.hasInductionReuse(ast)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowInductionVariableReuse',...
                    aObj.ParentBlock().getName(),...
                    aObj.getOwner().getClassNames());
                end
            end
        end


        function out=hasInductionReuse(aObj,rootAst)
            out=false;
            if isa(rootAst,'slci.ast.SFAstIdentifier')
listOfInductionVariables...
                =aObj.ParentChart().getInductionVariablesList();
                varName=rootAst.getQualifiedName();
isInductionVar...
                =any(cellfun(@(x)(strcmpi(x,varName)),...
                listOfInductionVariables));
                if isInductionVar
                    out=true;
                    return;
                end
            end


            children=rootAst.getChildren();
            for i=1:numel(children)
                child=children{i};
                if aObj.hasInductionReuse(child)
                    out=true;
                    return;
                end
            end
        end
    end
end