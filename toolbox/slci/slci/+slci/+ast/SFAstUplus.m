




classdef SFAstUplus<slci.ast.SFAst
    methods(Access=protected)

        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end
    end

    methods

        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));

            aObj.fDataType=aObj.ResolveDataType();
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim,...
            message('Slci:slci:ReComputeDataDim',class(aObj)));

            aObj.fDataDim=aObj.ResolveDataDim();
        end


        function aObj=SFAstUplus(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstUplus').getString);

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
