






classdef SFAstBranch<slci.ast.SFAst
    properties
        fCondEmpty=false;
        fBodyEmpty=false;
    end

    methods

        function aObj=SFAstBranch(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstBranch').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);


            if isempty(aAstObj.Left)
                aObj.fCondEmpty=true;
            end


            if isempty(aAstObj.Body)
                aObj.fBodyEmpty=true;
            end
        end


        function out=getCondAST(aObj)
            out={};
            if~aObj.fCondEmpty
                objChildren=aObj.getChildren();
                assert(numel(objChildren)>=1,...
                'SFAstBranch has at least one children');
                out=objChildren(1);
            end
        end


        function out=getBodyAST(aObj)
            out={};
            if~aObj.fBodyEmpty
                objChildren=aObj.getChildren();
                bodyIndex=2;
                if aObj.fCondEmpty
                    bodyIndex=1;
                end
                out=objChildren(bodyIndex:end);
            end
        end
    end

end