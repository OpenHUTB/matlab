











classdef SFAstBitCmp<slci.ast.SFAstBitOp

    methods

        function ComputeDataType(aObj)
            assert(aObj.hasMtree());

            children=aObj.getChildren();
            assert(numel(children)==1);

            aObj.fDataType=children{1}.getDataType();
        end


        function ComputeDataDim(aObj)

            aObj.fDataDim=aObj.ResolveDataDim();
        end


        function aObj=SFAstBitCmp(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAstBitOp(aAstObj,aParent);
        end

    end

end