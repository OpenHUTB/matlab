






classdef SFAstCase<slci.ast.SFAstBranch
    methods

        function aObj=SFAstCase(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstCase').getString);
            aObj=aObj@slci.ast.SFAstBranch(aAstObj,aParent);

        end
    end
end