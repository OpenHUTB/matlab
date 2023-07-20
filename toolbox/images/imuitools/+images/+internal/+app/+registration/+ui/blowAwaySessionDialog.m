function TF=blowAwaySessionDialog(fig)





    TF=false;

    warnstring=getString(message('images:imageRegistration:blowAwaySessionDlgString'));
    dlgname=getString(message('images:imageRegistration:blowAwaySessionDlgName'));
    yesbtn=getString(message('images:commonUIString:yes'));
    cancelbtn=getString(message('images:commonUIString:cancel'));

    dlg=uiconfirm(fig,warnstring,dlgname,...
    'Options',{yesbtn,cancelbtn},...
    'DefaultOption',2,'CancelOption',2);

    switch dlg
    case yesbtn
        TF=true;
    case cancelbtn
        TF=false;
    end
end
