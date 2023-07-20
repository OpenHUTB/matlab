function out=getSubsystemBuildSIDForwardHelper(sid,sourceSID,aSplit)


























    narginchk(2,3);
    if nargin<3
        aSplit=false;
    end

    colonsInSourceSID=strfind(sourceSID,':');
    if isempty(colonsInSourceSID)

        out='';
    elseif~strncmp(sid,sourceSID,colonsInSourceSID(end))

        out='';
    else
        lastColon=colonsInSourceSID(end);


        out=extractAfter(sid,lastColon-1);
        if aSplit



            out=strcat(extractAfter(sourceSID,lastColon-1),out);
        end
    end
    if ischar(sid)
        out=convertStringsToChars(out);
    end

