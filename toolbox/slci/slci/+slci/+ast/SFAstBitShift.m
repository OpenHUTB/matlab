














classdef SFAstBitShift<slci.ast.SFAstBitOp

    methods

        function ComputeDataType(aObj)
            assert(aObj.hasMtree());

            children=aObj.getChildren();
            assert(numel(children)==2);

            aObj.fDataType=children{1}.getDataType();
        end


        function ComputeDataDim(aObj)

            aObj.fDataDim=aObj.ResolveDataDim();
        end


        function aObj=SFAstBitShift(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAstBitOp(aAstObj,aParent);
        end

    end

end