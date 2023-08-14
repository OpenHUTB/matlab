


classdef StateflowArrayIndexTypeConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Array type should use index of type int32 or uint64';
        end

        function obj=StateflowArrayIndexTypeConstraint
            obj.setEnum('StateflowArrayIndexType');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];


            if~strcmpi(aObj.getOwner.ParentChart.getActionLanguage,'MATLAB')
                asts=aObj.getOwner().getASTs();
                for i=1:numel(asts)
                    ast=asts{i};
                    if aObj.containsInvalidArrayIndexType(ast)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'StateflowArrayIndexType',...
                        aObj.ParentBlock().getName(),...
                        aObj.getOwner().getClassNames(),...
                        'int32 or uint64');
                        return;
                    end
                end
            end
        end


        function out=containsInvalidArrayIndexType(aObj,node)
            out=false;
            if isa(node,'slci.ast.SFAstArray')...
                &&~(node.isIndexInt32()||node.isIndexUInt64())
                out=true;
                return;
            end
            childs=node.getChildren();
            for i=1:numel(childs)
                out=aObj.containsInvalidArrayIndexType(childs{i});
                if out
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

    end
end
