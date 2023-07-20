function[msgId,comment]=getReason(h,reasonMap,reg)




    msgId='';
    comment='';

    if~isempty(reasonMap)
        if reasonMap.isKey(reg.sid)
            v=reasonMap(reg.sid);
            msgId=v.msgId;
            comment=v.comment;
        end
    else
        reason=h.getReasonHelper(reg);
        msgId=reason.msgId;
        comment=reason.comment;
    end