function out=getSubsystemBuildSIDHelper(sid,sourceSubsystem,varargin)




    import Simulink.ID.internal.getSubsystemBuildSIDForwardHelper



    narginchk(2,3);

    colonsInTmpMdlSID=strfind(sid,':');

    if isempty(colonsInTmpMdlSID)
        out=sid;
        return;
    end

    h=get_param(sourceSubsystem,'Handle');
    sourceSID=get_param(h,'SIDFullString');
    colonsInSourceSID=strfind(sourceSID,':');


    if strcmp(extractBefore(sid,colonsInTmpMdlSID(1)),extractBefore(sourceSID,colonsInSourceSID(1)))



        flag=locIsImplicitLinkWithoutSIDSpace(h);
        out=getSubsystemBuildSIDForwardHelper(sid,sourceSID,flag);
        if out~=""&&nargin==3
            assert(ischar(varargin{1})||isStringScalar(varargin{1}));

            out=strcat(varargin{1},out);
        end
        if ischar(sid)
            out=convertStringsToChars(out);
        end
        return
    end

    if length(colonsInTmpMdlSID)>1&&...
        locIsImplicitLinkWithoutSIDSpace(h)



        out=strcat(extractBefore(sourceSID,colonsInSourceSID(end)),...
        extractAfter(sid,colonsInTmpMdlSID(2)-1));
    else

        sourceSIDSpace=extractBefore(sourceSID,colonsInSourceSID(end));

        if endsWith(sourceSIDSpace,':')

            watermark=get_param(extractBefore(sourceSIDSpace,strlength(sourceSIDSpace)),'SIDHighWatermark');
        else
            watermark=get_param(sourceSIDSpace,'SIDHighWatermark');
        end
        if str2double(strtok(extractAfter(sid,colonsInTmpMdlSID(1)),':'))>...
            str2double(watermark)
            out='';
        else
            out=strcat(sourceSIDSpace,extractAfter(sid,colonsInTmpMdlSID(1)-1));
        end
    end

    if nargin==3&&length(colonsInTmpMdlSID)==1
        assert(isa(varargin{1},'containers.Map'));
        Subsystem_Build_Mapping=varargin{1};


        tempSIDNum=extractAfter(sid,colonsInTmpMdlSID(1));




        if isKey(Subsystem_Build_Mapping,tempSIDNum)
            origSIDNum=Subsystem_Build_Mapping(tempSIDNum);
            out=strcat(extractBefore(sourceSID,colonsInSourceSID(1)+1),origSIDNum);
        end
    end
    if ischar(sid)
        out=convertStringsToChars(out);
    end

    function out=locIsImplicitLinkWithoutSIDSpace(h)
        out=get_param(h,'SIDHighWatermark')==""&&...
        strcmp(get_param(h,'LinkStatus'),'implicit');



