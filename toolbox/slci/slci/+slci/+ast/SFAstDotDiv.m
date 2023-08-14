







classdef SFAstDotDiv<slci.ast.SFAst

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


            if~aObj.fComputedDataType
                aObj.fDataType=aObj.ResolveDataType();
            end
        end


        function ComputeDataDim(aObj)


            aObj.fDataDim=aObj.ResolveDataDim();
        end


        function aObj=SFAstDotDiv(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstDotDiv').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)

            newConstraints={...
            slci.compatibility.MatlabFunctionMathDatatypeConstraint,...
            slci.compatibility.MatlabFunctionScalarIntegerOperandsConstraint,...
            };
            aObj.setConstraints(newConstraints);

            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end
    end

end