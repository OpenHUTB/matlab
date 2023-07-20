classdef DefaultValues



    methods(Static)

        function out=getNaT()
            persistent defaultNaT
            if isempty(defaultNaT)
                defaultNaT=NaT;
            end
            out=defaultNaT;
        end


        function out=getRevision()
            persistent defaultRevision
            if isempty(defaultRevision)
                defaultRevision=getString(message('Slvnv:slreq:NoVersionAvaiable'));
            end
            out=defaultRevision;
        end


        function out=getRevisionInfo()
            persistent defaultRevision
            if isempty(defaultRevision)
                defaultRevision=struct('revision',slreq.utils.DefaultValues.getRevision,...
                'timestamp',0,...
                'uuid','');
            end
            out=defaultRevision;
        end


        function out=getTimeZoneOffsetString
            persistent currentTimeZone
            if isempty(currentTimeZone)
                currenttime=datetime;
                currenttime.TimeZone='Local';
                currentTimeZone=['UTC',char(tzoffset(currenttime))];
            end
            out=currentTimeZone;
        end
    end
end