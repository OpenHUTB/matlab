






classdef SFAstOtherwise<slci.ast.SFAstBranch
    methods

        function aObj=SFAstOtherwise(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstOtherwise').getString);
            aObj=aObj@slci.ast.SFAstBranch(aAstObj,aParent);

        end
    end
end