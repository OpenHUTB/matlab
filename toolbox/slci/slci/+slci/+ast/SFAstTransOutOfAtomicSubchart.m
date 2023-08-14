



classdef SFAstTransOutOfAtomicSubchart<slci.ast.SFAst

    properties
        fAtomicSubchart=[];
        fCfgMode='';
    end

    methods


        function aObj=SFAstTransOutOfAtomicSubchart(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=getAtomicSubchartId(aObj)
            out=aObj.fAtomicSubchart.getParentAtomicSubchartSfId;
        end


        function setAtomicSubchart(aObj,aAtomicSubchart)
            aObj.fAtomicSubchart=aAtomicSubchart;
        end



        function out=getAtomicSubchartSID(aObj)
            aAtomicSubchartObj=aObj.fAtomicSubchart;
            out=aAtomicSubchartObj.getSID;
        end


        function out=getCfgMode(aObj)
            out=aObj.fCfgMode;
        end


        function setCfgMode(aObj,aMode)
            aObj.fCfgMode=aMode;
        end

    end

end
