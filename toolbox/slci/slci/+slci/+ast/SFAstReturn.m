





classdef SFAstReturn<slci.ast.SFAst

    methods

        function aObj=SFAstReturn(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstReturn').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end