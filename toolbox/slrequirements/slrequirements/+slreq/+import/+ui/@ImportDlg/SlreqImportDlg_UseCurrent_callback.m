function SlreqImportDlg_UseCurrent_callback(this,dlg)





    this.srcType=dlg.getWidgetValue('SlreqImportDlg_TypeCombo');
    currentDoc='';%#ok<NASGU>
    errorDlgText='';
    switch this.srcType
    case 1
        currentDoc=rmidotnet.MSWord.currentDocPath();
        if isempty(currentDoc)
            errorDlgText=getString(message('Slvnv:slreq_import:UseCurrentErrorMsg','Microsoft Word'));
        end
    case 2
        currentDoc=rmidotnet.MSExcel.currentDocPath();
        if isempty(currentDoc)
            errorDlgText=getString(message('Slvnv:slreq_import:UseCurrentErrorMsg','Microsoft Excel'));
        end
    case 4
        [currentDoc,errorDlgText]=rmidoors.currentModuleInfo();
    otherwise


        return;
    end
    if isempty(currentDoc)
        errorDlgTitle=getString(message('Slvnv:slreq_import:UseCurrentError'));
        errordlg(errorDlgText,errorDlgTitle);
    else


        if this.srcType==1||this.srcType==2
            slreq.internal.errorIfWebDoc(currentDoc);
        end

        this.srcDoc=currentDoc;


        this.setDestReqSet('');
        this.subDoc='';
        this.docObj=[];
        this.refreshDlg(dlg)
    end
end

