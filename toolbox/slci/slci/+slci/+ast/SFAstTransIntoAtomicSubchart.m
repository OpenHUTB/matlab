




classdef SFAstTransIntoAtomicSubchart<slci.ast.SFAst

    properties
        fAtomicSubchart=[];
    end

    methods


        function aObj=SFAstTransIntoAtomicSubchart(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=getAtomicSubchartId(aObj)
            out=aObj.fAtomicSubchart.getParentAtomicSubchartSfId;
        end


        function out=getAtomicSubchartSID(aObj)
            aAtomicSubchartObj=aObj.fAtomicSubchart;
            out=aAtomicSubchartObj.getSID;
        end


        function setAtomicSubchart(aObj,aAtomicSubchart)
            aObj.fAtomicSubchart=aAtomicSubchart;
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end

    end

end
