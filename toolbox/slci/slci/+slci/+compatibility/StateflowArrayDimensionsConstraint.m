


classdef StateflowArrayDimensionsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Arrays should be one dimensional';
        end

        function obj=StateflowArrayDimensionsConstraint
            obj.setEnum('StateflowArrayDimensions');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];



            if~strcmpi(aObj.getOwner.ParentChart.getActionLanguage,'MATLAB')
                asts=aObj.getOwner().getASTs();
                for i=1:numel(asts)
                    ast=asts{i};
                    if aObj.containsInvalidArrayDimensions(ast)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'StateflowArrayDimensions',...
                        aObj.ParentBlock().getName(),...
                        aObj.getOwner().getClassNames());
                        return;
                    end
                end
            end
        end


        function out=containsInvalidArrayDimensions(aObj,node)
            out=false;
            if isa(node,'slci.ast.SFAstArray')...
                &&~node.isOneDimensional()
                out=true;
                return;
            end
            childs=node.getChildren();
            for i=1:numel(childs)
                out=aObj.containsInvalidArrayDimensions(childs{i});
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
