classdef UpdateDetectionStatus





    enumeration
Unknown
Disabled
UpToDate
Detected
UnableToAccess
    end

    methods
        function str=toString(this)

            switch this
            case slreq.dataexchange.UpdateDetectionStatus.Unknown
                str=getString(message('Slvnv:slreq:UpdateDetectionStatusUnknown'));
            case slreq.dataexchange.UpdateDetectionStatus.Disabled
                str=getString(message('Slvnv:slreq:UpdateDetectionStatusDisabled'));
            case slreq.dataexchange.UpdateDetectionStatus.UpToDate
                str=getString(message('Slvnv:slreq:UpdateDetectionStatusUpToDate'));
            case slreq.dataexchange.UpdateDetectionStatus.Detected
                str=getString(message('Slvnv:slreq:UpdateDetectionStatusDetected'));
            case slreq.dataexchange.UpdateDetectionStatus.UnableToAccess
                str=getString(message('Slvnv:slreq:UpdateDetectionStatusUnableToAccess'));
            otherwise
            end
        end


    end
end

