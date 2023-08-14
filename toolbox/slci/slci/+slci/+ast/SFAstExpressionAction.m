



classdef SFAstExpressionAction<slci.ast.SFAst

    methods

        function aObj=SFAstExpressionAction(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end

    end

end