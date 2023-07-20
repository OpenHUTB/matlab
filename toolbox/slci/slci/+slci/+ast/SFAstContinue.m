





classdef SFAstContinue<slci.ast.SFAst

    methods

        function aObj=SFAstContinue(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstContinue').getString);
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
