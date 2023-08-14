function updateDeps=InlineParamsConfigure(cs,msg)


    updateDeps=false;
    hDlg=msg.dialog;
    hSrc=cs;
    if~isempty(cs.getConfigSet)



        hSrc=cs.getConfigSet;
    end
    config_dlg_configure_param('Show',hDlg,hSrc);

