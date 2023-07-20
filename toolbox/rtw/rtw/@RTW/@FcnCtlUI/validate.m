function validate(hSrc,hDlg)




    [status,msg]=hSrc.fcnclass.validate(hDlg,'',false,'interactive');

    if~strcmp(msg,'Canceled')
        hSrc.validationResult=msg;
        hSrc.validationStatus=status;
    end

