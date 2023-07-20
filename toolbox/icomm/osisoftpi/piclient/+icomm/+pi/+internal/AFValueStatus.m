classdef AFValueStatus



    enumeration
Good
Questionable
Substituted
Annotated
Bad
    end

    methods(Static,Access=public)

        function statuses=fromPiSdk(netStatuses)
            if isa(netStatuses,'OSIsoft.AF.Asset.AFValueStatus')
                statuses=icomm.pi.internal.AFValueStatus(string(netStatuses));
            else
                numStatus=netStatuses.Length;
                statusString=strings(numStatus,1);
                for statusIndex=1:numStatus
                    statusString(statusIndex)=string(netStatuses.Get(statusIndex-1));
                end
                statuses=icomm.pi.internal.AFValueStatus(statusString);
            end
        end
    end
end