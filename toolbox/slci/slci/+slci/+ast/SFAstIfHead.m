






classdef SFAstIfHead<slci.ast.SFAstBranch
    methods

        function aObj=SFAstIfHead(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstIfHead').getString);
            aObj=aObj@slci.ast.SFAstBranch(aAstObj,aParent);
        end
    end
end