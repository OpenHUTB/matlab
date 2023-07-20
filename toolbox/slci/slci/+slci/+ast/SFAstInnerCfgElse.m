


classdef SFAstInnerCfgElse<slci.ast.SFAst

    properties
        fState=[];
    end

    methods

        function aObj=SFAstInnerCfgElse(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

        function out=getStateId(aObj)
            out=aObj.fState.getSfId;
        end

        function setState(aObj,aState)
            aObj.fState=aState;
        end


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end

    end

end
