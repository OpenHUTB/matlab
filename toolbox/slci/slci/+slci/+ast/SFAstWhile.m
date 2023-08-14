







classdef SFAstWhile<slci.ast.SFAst

    methods

        function aObj=SFAstWhile(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstWhile').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=getCondAST(aObj)
            objChildren=aObj.getChildren();
            assert(numel(objChildren)>=1);
            out=objChildren(1);
        end


        function out=getBodyAST(aObj)
            out={};
            objChildren=aObj.getChildren();
            if(numel(objChildren)>=2)
                out=objChildren(2:numel(objChildren));
            end
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
