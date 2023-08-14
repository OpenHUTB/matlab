function updateDeps=CodeHighlightOption(cs,~)


    updateDeps=false;
    hSrc=cs;

    model=hSrc.getModel;
    if~isempty(model)
        hTraceInfo=get_param(model,'RTWTraceInfo');
        if~isa(hTraceInfo,'RTW.TraceInfo')
            hTraceInfo=RTW.TraceInfo(getfullname(model));
        end
        browserDlg=get(hTraceInfo,'ViewWidget');
        if isempty(browserDlg)||~isa(browserDlg,'DAStudio.Dialog')
            browserDlg=DAStudio.Dialog(hTraceInfo);
            set(hTraceInfo,'ViewWidget',browserDlg);
        end
        browserDlg.show;
    end

