






classdef SFAstElseIf<slci.ast.SFAstBranch
    methods

        function aObj=SFAstElseIf(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstElseIf').getString);
            aObj=aObj@slci.ast.SFAstBranch(aAstObj,aParent);
        end
    end
end