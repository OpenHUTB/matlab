function fctInfo=rtw_get_tfl_used_fcns_info(modelName,idx)






    try
        hRtwFcnLib=get_param(modelName,'TargetFcnLibHandle');

        if isempty(hRtwFcnLib)
            DAStudio.error('RTW:buildProcess:loadObjectHandleError',...
            'TargetFcnLibhandle');
        end

        if idx==-1


            fctInfo=length(hRtwFcnLib.HitCache);
        else
            implH=hRtwFcnLib.HitCache(idx);
            if isprop(implH,'Implementation')&&~isempty(implH.Implementation)
                fctInfo=struct('genCallback',implH.GenCallback,...
                'FcnName',implH.Implementation.Name,...
                'FileName',implH.GenFileName,...
                'FcnType',implH.Implementation.Return.toString(),...
                'HdrFile',implH.Implementation.HeaderFile,...
                'NumInputs',implH.Implementation.NumInputs,...
                'NonFiniteSupportNeeded',implH.NonFiniteSupportNeeded);
            else
                fctInfo=struct('genCallback','',...
                'FcnName',implH.Key,...
                'FileName','',...
                'FcnType','',...
                'HdrFile','',...
                'NumInputs',0,...
                'NonFiniteSupportNeeded',0);
            end
        end
    catch myException
        rethrow(myException);
    end


