function mfReq=findRequirement(~,mfReqSet,id)








    if isempty(id)
        error(message('Slvnv:slreq:PleaseProvideValidID'));
    end
    if ischar(id)
        sid=str2double(erase(id,'#'));
        if isempty(sid)||isnan(sid)
            mfReq=slreq.datamodel.RequirementItem.empty();
            rmiut.warnNoBacktrace(['Bad argument ',id,' in a call to ReqData.findRequirement().',newline...
            ,'         Did you mean to call searchRequirementByCustomId()?']);
            return;
        end
    else
        sid=id;
    end

    mfReq=mfReqSet.items{int32(sid)};
end
