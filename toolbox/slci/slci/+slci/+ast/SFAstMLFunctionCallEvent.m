


classdef SFAstMLFunctionCallEvent<slci.ast.SFAst

    properties
        fPortNum=-1;
    end

    methods

        function aObj=SFAstMLFunctionCallEvent(aAstObj,aParent,aPortNum)
            assert(isa(aAstObj,'mtree'))
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            aObj.fPortNum=aPortNum;
        end


        function out=getPortNum(aObj)
            out=aObj.fPortNum;
        end


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(~,~)


        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionFunctionCallOutputConstraint,...
            };

            aObj.setConstraints(newConstraints);
        end
    end

end