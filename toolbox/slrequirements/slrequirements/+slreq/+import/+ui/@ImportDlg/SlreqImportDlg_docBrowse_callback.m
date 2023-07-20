function SlreqImportDlg_docBrowse_callback(this,dlg)



    resolveType=false;
    switch this.srcType
    case 1
        filetypes={...
        '*.docx;*.doc',getString(message('Slvnv:slreq_import:AllWordFiles','(*.docx,*.doc)'));...
        '*.docx',getString(message('Slvnv:slreq_import:AllWord2007','(*.docx)'));...
        '*.doc',getString(message('Slvnv:slreq_import:MSWord2003','(*.doc)'))};
    case 2
        filetypes={...
        '*.xlsx;*.xls',getString(message('Slvnv:slreq_import:AllExcelFiles','(*.xlsx,*.xls)'));...
        '*.xlsx',getString(message('Slvnv:slreq_import:AllExcel2007','(*.xlsx)'));...
        '*.xls',getString(message('Slvnv:slreq_import:MSExcel2003','(*.xls)'))};
    case 3
        filetypes={...
        '*.reqif;*.reqifz',getString(message('Slvnv:slreq_import:AllReqifFiles','(*.reqif,*.reqifz)'));...
        '*.reqif',getString(message('Slvnv:slreq_import:ReqifFiles','(*.reqif)'));...
        '*.reqifz',getString(message('Slvnv:slreq_import:ReqifzFiles','(*.reqifz)'))};

    case 4
        doorsApi=rmi.linktype_mgr('resolveByRegName','linktype_rmi_doors');
        if~isempty(doorsApi)
            modIdStr=strtrim(doorsApi.BrowseFcn());
            if~isempty(modIdStr)

                rmi.navigate('linktype_rmi_doors',strtok(modIdStr),'');
                this.srcDoc=modIdStr;
                this.subDoc='';
                this.docObj=[];
                this.refreshDlg(dlg);
            end
        end
        return;

    otherwise
        filetypes={...
        '*.docx;*.doc;*.xlsx;*.xls;*.reqif;*.reqifz',getString(message('Slvnv:slreq_import:AllSupportedFiles'));...
        '*.docx;*.doc',getString(message('Slvnv:slreq_import:AllWordFiles','(*.docx,*.doc)'));...
        '*.xlsx;*.xls',getString(message('Slvnv:slreq_import:AllExcelFiles','(*.xlsx,*.xls)'));...
        '*.reqif;*.reqifz',getString(message('Slvnv:slreq_import:AllReqifFiles','(*.reqif,*.reqifz)'))};
        resolveType=true;
    end


    if isempty(this.srcDoc)
        defaultFile=pwd;
    else
        defaultFile=this.srcDoc;
    end

    [fileName,pathName]=uigetfile(filetypes,getString(message('Slvnv:slreq_import:SelectDocToImport')),defaultFile);

    if~isempty(fileName)&&ischar(fileName)
        this.srcDoc=fullfile(pathName,fileName);
        if resolveType
            [~,~,fExt]=fileparts(fileName);

            switch lower(fExt)
            case{'.reqif','.reqifz'}
                this.srcType=3;
            case{'.xls','.xlsx'}
                this.srcType=2;
            case{'.doc','.docx'}
                this.srcType=1;
            otherwise
            end
        end

        this.setDestReqSet('');
        this.subDoc='';
        this.docObj=[];
        this.refreshDlg(dlg);
    end
end
