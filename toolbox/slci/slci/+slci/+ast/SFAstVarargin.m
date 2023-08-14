



classdef SFAstVarargin<slci.ast.SFAst

    methods


        function aObj=SFAstVarargin(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            assert(isa(aAstObj,'mtree'));
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end

    end

end

