function SlreqImportDlg_TypeCombo_callback(this,dlg)




    this.clearStaleOptions();
    this.srcDoc='';
    this.setDestReqSet('');
    this.docObj=[];
    this.current={};
    this.errorText='';
    this.srcType=dlg.getWidgetValue('SlreqImportDlg_TypeCombo');
    try
        switch this.srcType
        case 0

        case 1


            try
                openDocs=rmidotnet.MSWord.getOpenDocuments();
            catch
                rmiut.warnNoBacktrace('Slvnv:rmiref:DocCheckWord:FailConnectWord');
                openDocs={};
            end

            for i=1:size(openDocs,1)

                fullName=fullfile(openDocs{i,2},openDocs{i,1});
                this.current{i}=fullName;
            end
        case 2


            try
                openDocs=rmidotnet.MSExcel.getOpenDocuments();
            catch
                rmiut.warnNoBacktrace('Slvnv:rmiref:DocCheckExcel:FailConnectExcelServer');
                openDocs={};
            end
            for i=1:size(openDocs,1)

                [name,~]=strtok(openDocs{i,1},'|');

                fullName=fullfile(openDocs{i,2},name);
                this.current{i}=fullName;
            end
        case 3



            allReqifFiles=slreq.import.findFilesInFolder(pwd,'.reqif');
            this.current=cell(size(allReqifFiles));
            for i=1:length(allReqifFiles)
                this.current{i}=fullfile(pwd,allReqifFiles{i});
            end
        case 4
            this.srcDoc=rmidoors.currentModuleInfo();
            if~isempty(this.srcDoc)
                modulesInfo=rmidoors.listFormalModulesInCurrentProject();



                this.current=strcat(modulesInfo(:,1),' (',modulesInfo(:,2),')');
            end
        case 5


            dlg.setEnabled('SlreqImportDlg_docEdit',false);
            dlg.setEnabled('SlreqImportDlg_docBrowse',false);

            rmiut.progressBarFcn('set',0.6,getString(message('Slvnv:oslc:GettingCatalog')));
            try
                [this.serverCatalog,loginInfo]=slreq.gui.getCatalogFromServer(this.serverName);
            catch ex
                this.serverCatalog=[];
                errorTitle=getString(message('Slvnv:reqmgt:linktype_rmi_excel:Error'));
                errorText=ex.message;
                errordlg(errorText,errorTitle,'modal');
            end
            rmiut.progressBarFcn('delete');
            if isempty(this.serverCatalog)

                this.srcType=0;
            else

                this.serverName=loginInfo.server;
                this.serverUser=loginInfo.username;
                this.serverPass=loginInfo.passcode;
            end
            dlg.setEnabled('SlreqImportDlg_docEdit',true);
            dlg.setEnabled('SlreqImportDlg_docBrowse',true);
        otherwise

            rmiut.warnNoBacktrace('unsupported doc type index: %d',this.docType);
        end
    catch ex



        this.errorText=ex.message;
    end
    this.refreshDlg(dlg);
end

