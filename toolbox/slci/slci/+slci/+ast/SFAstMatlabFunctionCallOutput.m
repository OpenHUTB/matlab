




classdef SFAstMatlabFunctionCallOutput<slci.ast.SFAst


    methods


        function aObj=SFAstMatlabFunctionCallOutput(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            assert(isa(aAstObj,'mtree'));
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end

    end


    methods(Access=protected)


        function addMatlabFunctionConstraints(aObj)
            newConstraints={};
            aObj.setConstraints(newConstraints);
        end

    end


end
