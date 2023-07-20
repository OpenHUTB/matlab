function onVivadoElabOptionChange(this,dlg,val,tag)


    dlgPrec=dlg.getWidgetValue('edaHDLTimePrec');
    dlgDbg=dlg.getComboBoxText('edaDebugOptions');

    try
        hdlRes=this.UserData.precStrToExp(dlgPrec);
    catch ME
        k=this.UserData.precStrToExp.keys();
        error('Bad precision argument.  Valid values include: %s',sprintf('%s ',k{:}));
    end

    this.ElabOptions=this.UserData.createElabOptions(...
    this.UserData.TclQueryInfo.TopLanguage,...
    dlgDbg,dlgPrec);


    this.UserData.HdlResolution=hdlRes;
    this.UserData.HdlDebug=dlgDbg;

end

