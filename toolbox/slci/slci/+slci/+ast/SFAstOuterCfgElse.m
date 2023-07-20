



classdef SFAstOuterCfgElse<slci.ast.SFAst

    properties
        fSFObject=[];
        fSFObjIsAtomicSubchart=false;
    end

    methods


        function aObj=SFAstOuterCfgElse(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=getSFObjectId(aObj)
            if(aObj.isAtomicSubchartCfg)
                out=aObj.fSFObject.getParentAtomicSubchartSfId();
            else
                out=aObj.fSFObject.getSfId;
            end
        end


        function setSFObject(aObj,aState)
            aObj.fSFObject=aState;
        end


        function setSFObjIsAtomicSubchart(aObj,bool)
            aObj.fSFObjIsAtomicSubchart=bool;
        end


        function tf=isAtomicSubchartCfg(aObj)
            tf=aObj.fSFObjIsAtomicSubchart;
        end


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end

    end

end
