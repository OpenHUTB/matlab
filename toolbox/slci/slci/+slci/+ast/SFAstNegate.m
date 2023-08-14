



classdef SFAstNegate<slci.ast.SFAst

    methods(Access=protected)


        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end

    end

    methods

        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            aObj.fDataType=aObj.ResolveDataType();
            if strcmp(aObj.fDataType,'boolean')||...
                strcmp(aObj.fDataType,'single')||...
                strcmp(aObj.fDataType,'double')
                aObj.fDataType='int32';
            end
        end

        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);

            aObj.fDataDim=aObj.ResolveDataDim();
        end

        function aObj=SFAstNegate(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
