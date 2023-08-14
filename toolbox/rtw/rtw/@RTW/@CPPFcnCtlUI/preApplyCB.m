function[status,errMsg]=preApplyCB(hObj,hDlg)





    status=1;
    errMsg='';
    [status,errMsg]=hObj.fcnclass.preApplyCB();

    codeResult=hObj.fcnclass.codeConstruction();
    hObj.fcnclass.ArgSpecData=codeResult.ArgSpecData;

    if status==1&&isempty(errMsg)&&...
        hDlg.hasUnappliedChanges()
        set_param(hObj.fcnclass.ModelHandle,'RTWCPPFcnClass',hObj.fcnclass);
    end

    if hObj.fcnclass.RightClickBuild&&...
        hDlg.hasUnappliedChanges()

        set_param(hObj.fcnclass.SubsysBlockHdl,'SSRTWCPPFcnClass',hObj.fcnclass);
        originalMdl=bdroot(hObj.fcnclass.SubsysBlockHdl);
        set_param(originalMdl,'Dirty','on');
    end

    hDlg.resetSize(false);
    hDlg.refresh();
    hDlg.resetSize(false);