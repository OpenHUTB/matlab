function evaled_obj=safeEvalinGlobalScope(system,evalString)





    try
        evaled_obj=evalinGlobalScope(bdroot(system),evalString);
    catch
        evaled_obj=[];
    end
end
