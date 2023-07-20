


function[blkH,sfId]=convertToHdlOrSfId(obj,blockSID,sfObjSID)

    [blkH,obj.mSID_2_Blk_Hdl_ID]=getHdl(blockSID,obj.mSID_2_Blk_Hdl_ID);


    [sfId,obj.mSID_2_Blk_Hdl_ID]=getSfId(sfObjSID,obj.mSID_2_Blk_Hdl_ID);
end

function[sfId,sid2sfId]=getSfId(sid,sid2sfId)
    if isempty(sid)
        sfId=0;
        return;
    end

    if isKey(sid2sfId,sid)
        sfId=sid2sfId(sid);
    else
        if isSidOfType(sid,'$ExternalFcn$')
            sfId=getExternalFcnSfId(sid);
        elseif isSidOfType(sid,'$Artificial$')
            sfId=getArtificialSID(sid);
        elseif isSidOfType(sid,'$SFChart$')
            sfId=getSFChartSfId(sid);
        else
            sfId=sldvprivate('util_get_hdl',sid);
        end
        sid2sfId(sid)=sfId;
    end
end

function[hdl,sid2hdl]=getHdl(sid,sid2hdl)
    if isKey(sid2hdl,sid)
        hdl=sid2hdl(sid);
    else
        if strcmp('-1',sid)
            hdl=-1;
        elseif strcmp('DefaultBlockDiagram',sid)
            hdl=0;
        else
            hdl=Simulink.ID.getHandle(sid);
            sid2hdl(sid)=hdl;
        end
    end
end

function check=isSidOfType(sid,type)
    check=~isempty(sid)&&ischar(sid);
    if check
        tmp=strfind(sid,type);
        check=~isempty(tmp)&&(1==tmp);
    end
end

function sfId=getArtificialSID(sid)
    id='$Artificial$';
    sfId=str2double(sid(numel(id)+1:end));
    assert(~isnan(sfId),'Invalid Artificial SID');
end

function sfId=getExternalFcnSfId(sid)
    try
        id='$ExternalFcn$';
        sid=sid(numel(id)+1:end);
        sfId=sf('find','all','.isa',sf('get','default','script.isa'),'script.name',sid);
    catch
        sfId='';
    end
end

function sfId=getSFChartSfId(sid)
    id='$SFChart$';
    sid=sid(numel(id)+1:end);
    sfId=sfprivate('block2chart',Simulink.ID.getHandle(sid));
end
