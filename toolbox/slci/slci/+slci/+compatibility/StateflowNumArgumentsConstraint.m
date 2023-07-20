

classdef StateflowNumArgumentsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Number of arguments of a function should not be greater than 2';
        end

        function obj=StateflowNumArgumentsConstraint
            obj.setEnum('StateflowNumArguments');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            asts=aObj.getOwner().getASTs();
            for i=1:numel(asts)
                ast=asts{i};
                if aObj.containsInvalidNumArguments(ast)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowNumArguments',...
                    aObj.ParentBlock().getName(),...
                    aObj.getOwner().getClassNames());
                    return;
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
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


        function out=containsInvalidNumArguments(aObj,node)
            out=false;
            if isa(node,'slci.ast.SFAstUserFunction')...
                &&~(node.isSFSLFunction()...
                ||node.IsGraphicalFunction()...
                ||node.IsTruthTable())
                children=node.getChildren();


                if numel(children)>2
                    out=true;
                    return
                end
            end
            childs=node.getChildren();
            for i=1:numel(childs)
                out=aObj.containsInvalidNumArguments(childs{i});
                if out
                    return;
                end
            end

        end

    end
end
