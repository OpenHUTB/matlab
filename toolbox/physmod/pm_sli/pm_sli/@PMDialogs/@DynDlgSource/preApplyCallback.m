function[isOK,errMsgStr]=preApplyCallback(hThis,varargin)













    isOK=true;
    errMsgStr='';
    s=warning('off','backtrace');
    C=onCleanup(@()warning(s));
    doNothing=pmsl_isblocklocked(hThis.BlockHandle);
    if~doNothing
        try



            [isOK,errMsgStr]=hThis.BuilderObj.PreApply();
            if~isOK
                return;
            end

            pmsl_cachedsetparam('purge');
            isOK=hThis.BuilderObj.Apply();
            pmsl_cachedsetparam('set');
        catch e
            errMsgStr=e.message;
            isOK=false;
        end
    end


