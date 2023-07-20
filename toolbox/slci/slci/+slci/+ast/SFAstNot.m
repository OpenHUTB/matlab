



classdef SFAstNot<slci.ast.SFAst

    methods

        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            aObj.fDataType='boolean';
        end

        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);

            aObj.fDataDim=aObj.ResolveDataDim();
        end

        function aObj=SFAstNot(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
