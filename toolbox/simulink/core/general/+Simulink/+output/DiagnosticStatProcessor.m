classdef DiagnosticStatProcessor<handle




    properties(Access='private')
        mErrorCount=0;
    end

    methods

        function result=process(this,aMsgRecord)
            if isequal(lower(aMsgRecord.Severity),'error')
                this.mErrorCount=this.mErrorCount+1;
            end
            result=aMsgRecord;
        end


        function returnErrorCount=getErrorCount(this)
            returnErrorCount=this.mErrorCount;
        end

        function resetErrorCount(this)
            this.mErrorCount=0;
        end
    end

end

