





classdef SFAstTransIntoState<slci.ast.SFAst

    properties
        fState=[];
        fIsEntryInternal=false;
        fIsEntryInternalFromSubstate=false;
        fNeedsProtectionCode=false;
    end

    methods


        function aObj=SFAstTransIntoState(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=getStateId(aObj)
            out=aObj.fState.getSfId;
        end


        function setState(aObj,aState)
            aObj.fState=aState;
        end


        function setIsEntryInternal(aObj,isEntryInternal)
            aObj.fIsEntryInternal=isEntryInternal;
        end


        function out=isEntryInternal(aObj)
            out=aObj.fIsEntryInternal;
        end


        function setIsEntryInternalFromSubstate(aObj,isEntryInternal)
            aObj.fIsEntryInternalFromSubstate=isEntryInternal;
        end


        function out=isEntryInternalFromSubstate(aObj)
            out=aObj.fIsEntryInternalFromSubstate;
        end


        function setNeedsProtectionCode(aObj,needsProtection)
            aObj.fNeedsProtectionCode=needsProtection;
        end


        function out=needsProtectionCode(aObj)
            out=aObj.fNeedsProtectionCode;
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end

    end

end
