function SlreqImportDlg_docEdit_callback(this,dlg)



    docName=dlg.getWidgetValue('SlreqImportDlg_docEdit');

    if isempty(docName)
        this.srcDoc='';
        this.subDoc='';
        this.docObj=[];
        this.clearStaleOptions();

    elseif this.srcType>3

        if strcmp(docName,this.srcDoc)
            return;
        end
        this.srcDoc=docName;
        this.clearStaleOptions();

    else
        newSrcDoc='';



        if exist(docName,'file')~=2
            errordlg(getString(message('Slvnv:slreq_import:FileNotFound',docName)),...
            getString(message('Slvnv:slreq:Error')));
        elseif rmiut.isCompletePath(docName)
            newSrcDoc=docName;
        elseif~isempty(this.current)
            for i=1:length(this.current)
                comboDoc=slreq.uri.getShortNameExt(this.current{i});
                if strcmp(comboDoc,docName)
                    newSrcDoc=fullfile(pwd,comboDoc);
                    break;
                end
            end
        end
        if isempty(newSrcDoc)
            newSrcDoc=which(docName);
        end
        if~isempty(newSrcDoc)&&this.srcType<4

            [~,~,fExt]=fileparts(newSrcDoc);

            fExt=lower(fExt);
            switch this.srcType
            case 0



                if any(strcmpi(fExt,{'.doc','.docx'}))
                    this.srcType=1;
                elseif any(strcmpi(fExt,{'.xls','.xlsx'}))
                    this.srcType=2;
                elseif any(strcmpi(fExt,{'.reqif','.reqifz'}))
                    this.srcType=3;
                end
            case 1

                if~any(strcmpi(fExt,{'.doc','.docx'}))
                    errordlg(getString(message('Slvnv:slreq_import:ImportInvalidFileType',fExt,'Microsoft Word')));
                    newSrcDoc='';
                end
            case 2

                if~any(strcmpi(fExt,{'.xls','.xlsx'}))
                    errordlg(getString(message('Slvnv:slreq_import:ImportInvalidFileType',fExt,'Microsoft Excel')));
                    newSrcDoc='';
                end
            case 3

                if~any(strcmpi(fExt,{'.reqif','.reqifz'}))
                    errordlg(getString(message('Slvnv:slreq_import:ImportInvalidFileType',fExt,'ReqIF')));
                    newSrcDoc='';
                end
            otherwise

            end
        end
        if~strcmp(newSrcDoc,this.srcDoc)
            this.setDestReqSet('');
            this.srcDoc=newSrcDoc;
            this.clearStaleOptions();
        end
    end
    this.refreshDlg(dlg);
end

