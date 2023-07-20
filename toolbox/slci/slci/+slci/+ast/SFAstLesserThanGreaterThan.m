



classdef SFAstLesserThanGreaterThan<slci.ast.SFAst

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
            assert(~aObj.fComputedDataType);
            aObj.fDataType='boolean';
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end

        function aObj=SFAstLesserThanGreaterThan(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
