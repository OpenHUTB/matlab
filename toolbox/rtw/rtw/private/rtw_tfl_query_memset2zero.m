function isRegistered=rtw_tfl_query_memset2zero(model)







    libH=get_param(model,'TargetFcnLibHandle');
    if isempty(libH)
        isRegistered=0;
    else
        isRegistered=libH.keyNameIsRegistered('memset2zero');
    end
