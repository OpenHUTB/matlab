


classdef BaseTraceObject<handle
    properties(Access=protected)
        fModelToCodeTrace;
        fCodeToModelTrace;
    end


    methods

        function this=BaseTraceObject()
            this.fModelToCodeTrace=containers.Map('KeyType','char',...
            'ValueType','any');
            this.fCodeToModelTrace=containers.Map('KeyType','char',...
            'ValueType','any');
        end


        function codeTraceObj=getBlockToCodeTrace(this,aBlockSID)
            codeTraceObj={};
            if this.hasBlock(aBlockSID)
                codeTraceObj=this.fModelToCodeTrace(aBlockSID);
            end
        end


        function tf=hasBlock(this,aBlockSID)
            tf=this.fModelToCodeTrace.isKey(aBlockSID);
        end


        function blockTraceObj=getCodeToBlockTrace(this,aFilename,aLineNo)
            blockTraceObj={};
            aKey=[aFilename,':',aLineNo];
            if this.hasCode(aKey)
                blockTraceObj=this.fCodeToModelTrace(aKey);
            end
        end


        function tf=hasCode(this,aKey)
            tf=this.fCodeToModelTrace.isKey(aKey);
        end

    end


    methods(Abstract)

        populateTraces(this);
    end


    methods(Access=protected)

        function addModelToCodeTrace(this,aBlockSID,aCodeTraceObj)
        end


        function addCodeToModelTrace(this,aFilename,aLineNo,aBlockTraceObj)
        end

    end
end