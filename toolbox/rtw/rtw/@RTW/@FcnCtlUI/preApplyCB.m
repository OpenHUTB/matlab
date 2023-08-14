function[status,errMsg]=preApplyCB(hObj,hDlg)





    [status,errMsg]=hObj.fcnclass.preApplyCB();

    codeResult=hObj.fcnclass.codeConstruction();
    hObj.fcnclass.ArgSpecData=codeResult.ArgSpec;

    if hObj.fcnclass.RightClickBuild
        savedFcnClass=get_param(hObj.fcnclass.SubsysBlockHdl,'SSRTWFcnClass');
    else
        savedFcnClass=get_param(hObj.fcnclass.ModelHandle,'RTWFcnClass');
    end

    if~strcmp(class(savedFcnClass),class(hObj.fcnclass))
        hDlg.enableApplyButton(1);
    end

    if status==1&&isempty(errMsg)&&...
        hDlg.hasUnappliedChanges()
        set_param(hObj.fcnclass.ModelHandle,'RTWFcnClass',hObj.fcnclass);
    end

    if hObj.fcnclass.RightClickBuild&&...
        hDlg.hasUnappliedChanges()

        set_param(hObj.fcnclass.SubsysBlockHdl,'SSRTWFcnClass',hObj.fcnclass);
        originalMdl=bdroot(hObj.fcnclass.SubsysBlockHdl);
        set_param(originalMdl,'Dirty','on');
    end
















    if~isempty(hObj.dialogHndl)
        hObj.dialogHndl.refresh;
    end


    hDlg.enableApplyButton(0);


