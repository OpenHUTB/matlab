



classdef SFAstAndAssignment<slci.ast.SFAst

    properties(Access=private)
        fTmpDataType='';
    end

    methods(Access=protected)

        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end

        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end

    end

    methods

        function out=getTmpDataType(aObj)
            if~aObj.fComputedDataType
                aObj.ComputeDataType;
            end
            out=aObj.fTmpDataType;
        end

        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType)
            children=aObj.getChildren();

            aObj.fDataType=children{1}.getDataType();
            if strcmp(aObj.fDataType,'boolean')
                aObj.fDataType='uint32';
            end
            if strcmp(aObj.fDataType,'single')||...
                strcmp(aObj.fDataType,'double')
                aObj.fDataType='int32';
            end

            aObj.fTmpDataType=aObj.ResolveDataType();
            if strcmp(aObj.fTmpDataType,'boolean')
                aObj.fTmpDataType='uint32';
            end
            if strcmp(aObj.fTmpDataType,'single')||...
                strcmp(aObj.fTmpDataType,'double')
                aObj.fTmpDataType='int32';
            end
        end

        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            children=aObj.getChildren();

            aObj.fDataDim=children{1}.getDataDim();
        end

        function aObj=SFAstAndAssignment(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end


