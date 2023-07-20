







classdef SFAstDotLDiv<slci.ast.SFAst

    methods(Access=protected)




        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end


        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end

    end

    methods


        function ComputeDataType(aObj)%#ok


        end


        function ComputeDataDim(aObj)%#ok


        end


        function aObj=SFAstDotLDiv(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstDotLDiv').getString);

            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)

            newConstraints={...
            slci.compatibility.MatlabFunctionMathDatatypeConstraint,...
            slci.compatibility.MatlabFunctionScalarOperandsConstraint,...
            };
            aObj.setConstraints(newConstraints);

            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end
    end

end