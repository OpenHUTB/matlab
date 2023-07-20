function str=getFormatterText(msgId,insertTxt)




    fullMsgId=['Slvnv:simcoverage:make_formatters:',msgId];
    fullInsertTxt=[];
    if~isempty(insertTxt)

        insertTxt=strrep(insertTxt,newline,'');
        if contains(msgId,'MSG_SL_TESTINTERVAL')||...
            contains(msgId,'MSG_SL_TESTPOINT')||...
            contains(msgId,'MSG_OUT_GENERIC_TXT')||...
            contains(msgId,'MSG_CUSTOM_TXT')

            tmpInsertTxt=['''',strrep(insertTxt(2:end-1),'''',''''''),''''];
        elseif contains(msgId,'MSG_SF_STATE_ON_DECISION')||contains(msgId,'MSG_SF_TRANS_PRED')


            cIdx=min(strfind(insertTxt,''''));
            if~isempty(cIdx)
                tmpInsertTxt=[insertTxt(1:cIdx),strrep(insertTxt(cIdx+1:end-1),'''',''''''),insertTxt(end)];
            else
                tmpInsertTxt=insertTxt;
            end

        else
            tmpInsertTxt=insertTxt;
        end
        fullInsertTxt=[',',tmpInsertTxt];
    end
    try
        evalTxt=['getString(message(''',fullMsgId,'''',fullInsertTxt,'))'];
        str=eval(evalTxt);
    catch MEx
        rethrow(MEx);
    end

