function stfTargetActivateCB(hTarget)




    if~hTarget.isActive
        return;
    end

    model=hTarget.getModel;
    hConfigSet=hTarget.getConfigSet;
    callback=hTarget.ActivateCallback;
    hDlg=[];

    if~isempty(callback)
        try
            loc_eval(hTarget,hDlg,callback);
        catch exc
            warnmsg=(['Error executing the ActivateCallback of the target "',...
            get_param(hConfigSet,'SystemTargetFile'),'":',sprintf('\n'),...
            exc.message]);

            MSLDiagnostic('SL_SERVICES:utils:GENERAL_USAGE',warnmsg,'COMPONENT','RTW','CATEGORY','SYSTLC').reportAsWarning;
        end
    end

    function loc_eval(hSrc,hDlg,evalstr)%#ok<INUSL>
        model=hSrc.getModel;%#ok<NASGU>
        hConfigSet=hSrc.getConfigSet;%#ok<NASGU>
        eval(evalstr);

