





classdef FcnWorkspaceVarConstraint<slci.compatibility.Constraint

    properties(Access=protected)
        fUnsupportedVars={};
    end

    methods

        function out=getDescription(aObj)
            out='For a fcn block, the expression cannot use variables other than u';
        end


        function obj=FcnWorkspaceVarConstraint()
            obj.setEnum('FcnWorkspaceVar');
            obj.setCompileNeeded(0);
        end


        function out=check(aObj)
            out={};

            ast=aObj.ParentBlock.getAsts();
            root=ast{1};

            if~aObj.ParentBlock.getContainsFailedParse()
                failure=aObj.getUnsupportedWorkspaceVars(root);

                if~isempty(failure)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'FcnWorkspaceVar',...
                    aObj.ParentBlock().getName());
                    aObj.fUnsupportedVars=failure;
                end
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end

            unsupportedVars=strjoin(aObj.fUnsupportedVars,' ');
            Information=DAStudio.message('Slci:compatibility:FcnWorkspaceVarConstraintInfo');
            SubTitle=DAStudio.message('Slci:compatibility:FcnWorkspaceVarConstraintSubTitle');
            RecAction=DAStudio.message('Slci:compatibility:FcnWorkspaceVarConstraintRecAction',unsupportedVars);
            StatusText=DAStudio.message('Slci:compatibility:FcnWorkspaceVar',aObj.ParentBlock().getName());
        end


        function out=getUnsupportedWorkspaceVars(aObj,root)
            out={};


            if isa(root,'slci.ast.SFAstIdentifier')
                if~(strcmp(root.getIdentifier,'u')||...
                    strcmp(root.getIdentifier,'sgn'))
                    out=horzcat(out,{root.getIdentifier});
                end
            end

            children=root.getChildren();

            if numel(children)>0
                for i=1:numel(children)
                    fail=aObj.getUnsupportedWorkspaceVars(children{i});
                    out=horzcat(out,fail);
                end
            end
        end
    end
end
