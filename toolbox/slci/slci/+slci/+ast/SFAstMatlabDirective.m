



classdef SFAstMatlabDirective<slci.ast.SFAst

    methods

        function aObj=SFAstMatlabDirective(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            assert(isa(aAstObj,'mtree'));
        end
    end

end
