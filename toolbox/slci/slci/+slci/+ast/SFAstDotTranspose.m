






classdef SFAstDotTranspose<slci.ast.SFAst
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

            childDim=aObj.ResolveDataDim();

            if(childDim~=-1)
                assert(numel(childDim)==2);
                aObj.fDataDim=[childDim(2),childDim(1)];
            end
        end


        function aObj=SFAstDotTranspose(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstDotTranspose').getString);

            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionRollThresholdConstraint,...
            };
            aObj.setConstraints(newConstraints);

            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end
    end
end
