function items=dngModuleSelector(this)

    subLabel.Type='text';
    subLabel.Name=getString(message('Slvnv:slreq_import:DngModuleName'));
    subLabel.RowSpan=[3,3];
    subLabel.ColSpan=[2,2];
    subLabel.Enabled=~isempty(this.srcDoc);

    subDocCombo.Type='combobox';
    subDocCombo.Tag='SlreqImportDlg_subDocCombo';
    topItemInCombo=getString(message('Slvnv:slreq_import:DngSelectModuleComboDefault'));
    subDocCombo.Entries={topItemInCombo};
    subDocCombo.Values=0;
    subDocCombo.Value=0;
    subDocCombo.Enabled=(this.connectionMode==0);
    this.subDocs={};





    if~isempty(this.srcDoc)&&this.connectionMode==0

        catalog=this.serverCatalog;
        idx=find(strcmp(catalog.projectNames,this.srcDoc));
        if~isempty(idx)
            try
                rmiut.progressBarFcn('set',0.3,getString(message('Slvnv:slreq_import:DngGettingModules',this.srcDoc)));
                if isempty(this.modulesInfo)

                    projectInfo=struct('name',this.srcDoc,'uri',catalog.projectURIs{idx});
                    reqData=slreq.data.ReqData.getInstance();
                    this.modulesInfo=reqData.fetchOSLCModules(projectInfo);
                end
                rmiut.progressBarFcn('set',0.8,getString(message('Slvnv:slreq_import:DngGettingModules',this.srcDoc)));
                if~isempty(this.modulesInfo)
                    this.subDocs=this.modulesInfo.title;
                    subDocCombo.Entries=[{topItemInCombo};this.subDocs];
                    subDocCombo.Values=[0;(1:length(this.subDocs))'];
                    subDocCombo.Enabled=true;
                    if~isempty(this.subDoc)
                        modIdx=find(strcmp(this.modulesInfo.title,this.subDoc));
                        if~isempty(modIdx)
                            subDocCombo.Value=modIdx(1);
                        end
                    end
                else
                    subDocCombo.Entries={getString(message('Slvnv:slreq_import:DngNoModules'))};
                end
                rmiut.progressBarFcn('set',0.9,getString(message('Slvnv:slreq_import:DngGettingModules',this.srcDoc)));
                rmiut.progressBarFcn('delete');
            catch






                rmiut.progressBarFcn('set',1.0,'ERROR getting modules list for OSLC Project');
            end

        else
            errordlg(sprintf('ERROR: project %s not found on server',this.srcDoc));
        end

    end

    subDocCombo.RowSpan=[3,3];
    subDocCombo.ColSpan=[3,4];
    subDocCombo.ObjectMethod='SlreqImportDlg_subDocCombo_callback';
    subDocCombo.MethodArgs={'%dialog'};
    subDocCombo.ArgDataTypes={'handle'};

    items={subLabel,subDocCombo};

end


