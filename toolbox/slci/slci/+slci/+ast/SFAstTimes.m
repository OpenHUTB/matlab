



classdef SFAstTimes<slci.ast.SFAst

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
            assert(~aObj.fComputedDataType);

            aObj.fDataType=aObj.ResolveDataType();
            if strcmp(aObj.fDataType,'boolean')
                aObj.fDataType='int32';
            end
        end

        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim)

            aObj.fDataDim=aObj.ResolveDataDim();
        end

        function aObj=SFAstTimes(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionMathDatatypeConstraint,...
            };
            aObj.setConstraints(newConstraints);
            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end
    end

end
