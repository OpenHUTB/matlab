







classdef SFAstDotPow<slci.ast.SFAst

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


            aObj.setDataType(aObj.ResolveDataType());
        end


        function ComputeDataDim(aObj)%#ok


        end

        function aObj=SFAstDotPow(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstDotPow').getString);

            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint,...
            slci.compatibility.MatlabFunctionFloatDatatypeConstraint,...
            slci.compatibility.MatlabFunctionDimConstraint(...
            {'Scalar','Vector','Matrix'})...
            };
            aObj.setConstraints(newConstraints);

            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end
    end

end