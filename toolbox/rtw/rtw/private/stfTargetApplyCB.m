function[ok,errmsg]=stfTargetApplyCB(hDlg,hTarget)%#ok<INUSL>



    model=hTarget.getModel;
    hConfigSet=hTarget.getConfigSet;
    callback=hTarget.PostApplyCallback;
    hDlg=[];
    ok=true;
    errmsg='';

    if~isempty(callback)
        try
            loc_eval(hTarget,hDlg,callback);
        catch exc
            warnmsg=(['Error executing the PostApplyCallback of the target "',...
            get_param(hConfigSet,'SystemTargetFile'),'":',sprintf('\n'),...
            exc.message]);

            MSLDiagnostic('SL_SERVICES:utils:GENERAL_USAGE',warnmsg,'COMPONENT','RTW','CATEGORY','SYSTLC').reportAsWarning;
            ok=false;
            errmsg=warnmsg;
        end
    end

    function loc_eval(hSrc,hDlg,evalstr)%#ok<INUSL>
        model=hSrc.getModel;%#ok<NASGU>
        hConfigSet=hSrc.getConfigSet;%#ok<NASGU>
        isActive=hSrc.isActive;%#ok<NASGU>
        eval(evalstr);

