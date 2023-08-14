



classdef SFAstEventBroadcastAction<slci.ast.SFAst

    methods

        function aObj=SFAstEventBroadcastAction(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end
    end

end
