function upgrade(hObj)






    if hObj.versionCompare('21.0.0')<0
        set_param(hObj,'UseGCCFastMath','on');
    end


    if hObj.versionCompare('22.0.0')<0
        set_param(hObj,'IsSLRTTarget','on');
    end
end
