




classdef SFAstBreak<slci.ast.SFAst

    methods

        function aObj=SFAstBreak(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstBreak').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end
    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionUnsupportedAstConstraint};
            aObj.setConstraints(newConstraints);
        end
    end
end