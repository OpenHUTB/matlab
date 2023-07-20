function showError(h)

    try
        delete(h.ErrDlg)
    catch %#ok
    end

    title=DAStudio.message('configset:util:ErrorMessageWindowTitle',h.Name);
    msg=configset.util.message(h.ErrMessage);
    h.ErrDlg=helpdlg(msg,title);
