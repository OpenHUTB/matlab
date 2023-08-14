function reason=getReason(model,sid,rtwname)


    reason='';

    try
        if coder.internal.slcoderReport('existTraceInfo',model)
            traceInfo=RTW.TraceInfo.instance(model);
            if isempty(traceInfo.BuildDir)
                traceInfo.setBuildDir('');
            end

            reg=[];
            reg.sid=sid;
            reg.rtwname=rtwname;
            reg.pathname=Simulink.ID.getFullName(sid);

            reason=traceInfo.getReason('',reg);
        end
    catch
    end



