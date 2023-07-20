



classdef SFAstTransOutOfState<slci.ast.SFAst

    properties
        fState=[];
        fCfgMode='';
    end

    methods

        function aObj=SFAstTransOutOfState(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

        function out=getStateId(aObj)
            out=aObj.fState.getSfId;
        end

        function setState(aObj,aState)
            aObj.fState=aState;
        end

        function out=getCfgMode(aObj)
            out=aObj.fCfgMode;
        end

        function setCfgMode(aObj,aMode)
            aObj.fCfgMode=aMode;
        end

    end

end
