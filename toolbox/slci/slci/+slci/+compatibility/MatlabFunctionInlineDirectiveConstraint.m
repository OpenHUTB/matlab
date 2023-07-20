


classdef MatlabFunctionInlineDirectiveConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Non root function must have coder.inline(''always'') '...
            ,'Root function may have unspecified coder.inline or coder.inline(''always'')'];
        end


        function obj=MatlabFunctionInlineDirectiveConstraint()
            obj.setEnum('MatlabFunctionInlineDirective');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            ast=aObj.getOwner();
            assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));
            if slci.matlab.astProcessor.MatlabFunctionUtils.isRootFunction(ast)
                supportedValues=[slci.compatibility.CoderInlineEnum.Always...
                ,slci.compatibility.CoderInlineEnum.Unknown];
            else
                supportedValues=[slci.compatibility.CoderInlineEnum.Always...
                ,slci.compatibility.CoderInlineEnum.Never];
            end
            if~any(ast.getInline()==supportedValues)
                out=slci.compatibility.Incompatibility(aObj,...
                aObj.getEnum());
            end
        end

    end

end
