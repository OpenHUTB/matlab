

function out=getBlockFullPath(model,sidName)
    out='';
    sid=extractBetween(sidName,'(''',''')');
    if sid~=""
        sid=strcat(model,sid{1});
        out=Simulink.ID.getFullName(sid);
    end
