function DngModuleCombo_callback(this,dlg)



    selected=dlg.getWidgetValue('DngModuleCombo');
    if selected>0
        this.moduleName=this.allModuleNames{selected};
        this.moduleId=this.allModuleIds{selected};


        progressMessage=getString(message('Slvnv:oslc:GettingContentsOf',this.moduleName));
        progressTitle=getString(message('Slvnv:oslc:PleaseWait'));
        rmiut.progressBarFcn('set',0.2,progressMessage,progressTitle);
        client=oslc.connection();
        progressBarInfo=struct('text',progressMessage,'range',[0.3,0.5],'title',progressTitle);
        items=client.getRequirementsUrlsInCollection(this.moduleId,progressBarInfo);
        if~isempty(items)
            rmiut.progressBarFcn('set',0.5,progressMessage,progressTitle);
            project=oslc.Project.get(this.projName);
            progressBarInfo.range=[0.5,1.0];
            requirements=project.getRequirementsByURLs(items,progressBarInfo,client);%#ok<NASGU>
        end
        rmiut.progressBarFcn('delete');
    else
        this.moduleName='';
        this.moduleId='';
    end
    dlg.refresh();

end
