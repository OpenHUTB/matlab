






classdef SFAstFor<slci.ast.SFAst

    methods

        function aObj=SFAstFor(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstFor').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=getIndexAST(aObj)
            objChildren=aObj.getChildren();
            assert(numel(objChildren)>=2);
            out=objChildren(1);
        end


        function out=getIndexRangeAST(aObj)
            objChildren=aObj.getChildren();
            assert(numel(objChildren)>=2);
            out=objChildren(2);
        end


        function out=getBodyAST(aObj)
            out={};
            objChildren=aObj.getChildren();
            if(numel(objChildren)>=3)
                out=objChildren(3:numel(objChildren));
            end
        end
    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionScalarForIndexConstraint,...
            slci.compatibility.MatlabFunctionForIndexRangeConstConstraint,...
            slci.compatibility.MatlabFunctionForIndexMonoIncrRangeConstraint};
            aObj.setConstraints(newConstraints);
        end
    end
end