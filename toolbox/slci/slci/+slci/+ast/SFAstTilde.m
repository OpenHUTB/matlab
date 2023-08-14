



classdef SFAstTilde<slci.ast.SFAst

    methods


        function aObj=SFAstTilde(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end

    end

end

