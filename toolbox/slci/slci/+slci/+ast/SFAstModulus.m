



classdef SFAstModulus<slci.ast.SFAst

    methods(Access=protected)

        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end

        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end

    end

    methods

        function ComputeDataType(aObj)

            aObj.fDataType=aObj.ResolveDataType();
            if strcmp(aObj.fDataType,'boolean')||...
                strcmp(aObj.fDataType,'single')||...
                strcmp(aObj.fDataType,'double')
                aObj.fDataType='int32';
            end
        end

        function ComputeDataDim(aObj)

            aObj.fDataDim=aObj.ResolveDataDim();
        end

        function aObj=SFAstModulus(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
