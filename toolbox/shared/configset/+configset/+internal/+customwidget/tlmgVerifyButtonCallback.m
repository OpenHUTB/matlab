function updateDeps=tlmgVerifyButtonCallback(cs,msg)



    updateDeps=false;
    hDlg=msg.dialog;

    if isa(cs,'Simulink.ConfigSet')
        hSrc=cs.getComponent('Code Generation').getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        hSrc=cs.getComponent('Target');
    else
        hSrc=cs;
    end

    try
        hSrc.verifyTlmComp(hDlg);
    catch ME

        dlg=errordlg(ME.message);

        set(dlg,'tag','tlmg error dialog');
    end






