






classdef FcnUnsupportedAstConstraint<slci.compatibility.Constraint

    properties(Access=protected)
        fUnsupportedAsts={};
    end

    methods

        function out=getDescription(aObj)
            out='For a fcn block, the expression cannot contain certain operations';
        end


        function obj=FcnUnsupportedAstConstraint()
            obj.setEnum('FcnUnsupportedAst');
            obj.setCompileNeeded(0);
        end


        function out=check(aObj)
            out={};

            ast=aObj.ParentBlock.getAsts();
            root=ast{1};
            failure=aObj.getUnsupportedAsts(root);

            if~isempty(failure)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'FcnUnsupportedAst',...
                aObj.ParentBlock().getName());
                aObj.fUnsupportedAsts=failure;
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end

            unsupportedAsts=strjoin(aObj.fUnsupportedAsts,' ');
            Information=DAStudio.message('Slci:compatibility:FcnUnsupportedAstConstraintInfo');
            SubTitle=DAStudio.message('Slci:compatibility:FcnUnsupportedAstConstraintSubTitle');
            RecAction=DAStudio.message('Slci:compatibility:FcnUnsupportedAstConstraintRecAction',unsupportedAsts);
            StatusText=DAStudio.message('Slci:compatibility:FcnUnsupportedAst',aObj.ParentBlock().getName());
        end


        function out=getUnsupportedAsts(aObj,root)
            out={};

            if(aObj.ParentBlock.getContainsFailedParse())
                out={'Unknown operation'};
                return
            end


            if(root.IsUnsupportedAst())
                out=horzcat(out,{root.getType});

            elseif isa(root,'slci.ast.SFAstMathBuiltin')
                if(strcmp(root.getMathType,'sqrt'))
                    out=horzcat(out,{'sqrt'});
                end
            elseif isa(root,'slci.ast.SFAstIdentifier')
                if(strcmp(root.getIdentifier,'sgn'))
                    out=horzcat(out,{root.getIdentifier});
                end
            end

            children=root.getChildren();

            if numel(children)>0
                for i=1:numel(children)
                    fail=aObj.getUnsupportedAsts(children{i});
                    out=horzcat(out,fail);
                end
            end
        end
    end
end

