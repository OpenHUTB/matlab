function msg=rtw_run_tfl_mcb(modelName)




    msg='';
    try
        hRtwFcnLib=get_param(modelName,'TargetFcnLibHandle');
        if isempty(hRtwFcnLib)
            DAStudio.error('RTW:buildProcess:loadObjectHandleError',...
            'TargetFcnLibhandle');
        end
        genDirForTFL=rtwprivate('rtwattic','AtticData','genDirForTFL');
        runFcnImpCallbacks(hRtwFcnLib,genDirForTFL);
    catch me



        numError=length(me.cause);
        msg=[];
        for i=1:numError
            msg=[msg,me.cause{i}.message,newline];%#ok<AGROW>
        end
    end




