classdef Status





    enumeration
Unknown
Stale
Pass
Fail
    end

    methods(Hidden)
        function internalStatus=getInternalStatus(this)
            switch this
            case 'Unknown'
                internalStatus=slreq.verification.ResultStatus.Unknown;
            case 'Stale'
                internalStatus=slreq.verification.ResultStatus.Stale;
            case 'Pass'
                internalStatus=slreq.verification.ResultStatus.Pass;
            case 'Fail'
                internalStatus=slreq.verification.ResultStatus.Fail;
            end
        end
    end
end
