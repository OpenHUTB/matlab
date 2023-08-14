

















classdef SFAstBitSet<slci.ast.SFAstBitOp

    methods

        function ComputeDataType(aObj)

            children=aObj.getChildren();
            assert(numel(children)>=2);

            aObj.fDataType=children{1}.getDataType();
        end


        function ComputeDataDim(aObj)

            aObj.fDataDim=aObj.ResolveDataDim();
        end


        function aObj=SFAstBitSet(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAstBitOp(aAstObj,aParent);
        end

    end

end