



classdef SFAstGreaterThan<slci.ast.SFAst

    methods(Access=protected)


        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end

        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end

    end

    methods


        function ComputeDataType(aObj)
            aObj.fDataType='boolean';
            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end

        function aObj=SFAstGreaterThan(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
