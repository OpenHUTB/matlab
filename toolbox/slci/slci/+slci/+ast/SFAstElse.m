






classdef SFAstElse<slci.ast.SFAstBranch
    methods

        function aObj=SFAstElse(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstElse').getString);
            aObj=aObj@slci.ast.SFAstBranch(aAstObj,aParent);

        end
    end
end