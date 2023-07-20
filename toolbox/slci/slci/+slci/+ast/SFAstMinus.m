



classdef SFAstMinus<slci.ast.SFAst

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
            if strcmp(aObj.fDataType,'boolean')
                aObj.fDataType='int32';
            end
        end

        function ComputeDataDim(aObj)

            aObj.fDataDim=aObj.ResolveDataDim();
        end

        function aObj=SFAstMinus(aAstObj,aParent)
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
