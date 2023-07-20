



classdef SFAstNegEqual<slci.ast.SFAst

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
            children=aObj.getChildren();

            aObj.fDataDim=children{1}.getDataDim();
        end

        function aObj=SFAstNegEqual(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
