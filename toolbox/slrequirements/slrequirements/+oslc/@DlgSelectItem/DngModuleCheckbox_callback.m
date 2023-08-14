function DngModuleCheckbox_callback(this,dlg)

    this.useModule=dlg.getWidgetValue('DngModuleCheckbox');

    if this.useModule
        if isempty(this.allModuleNames)

            statusMessage=getString(message('Slvnv:oslc:GettingModules',this.projName));
            statusTitle=getString(message('Slvnv:oslc:PleaseWait'));
            rmiut.progressBarFcn('set',0.1,statusMessage,statusTitle);

            project=oslc.Project.get(this.projName);
            if isempty(project)
                return;
            end
            client=oslc.connection();
            progressBarInfo=struct('text',statusMessage,'range',[0.3,0.7],'title',getString(message('Slvnv:oslc:PleaseWait')));
            allCollectionsIds=client.getCollectionsIds(true,progressBarInfo);
            if~isempty(allCollectionsIds)
                rmiut.progressBarFcn('set',0.7,statusMessage,statusTitle);
                [labels,~,locations]=project.listCollections(allCollectionsIds);
                rmiut.progressBarFcn('set',0.9,statusMessage,statusTitle);
                isModule=false(size(labels));
                for i=1:numel(labels)
                    oneLabel=labels{i};
                    prefix=strtok(oneLabel,':');
                    if strcmp(prefix,'Module')
                        isModule(i)=true;
                        labels{i}=oneLabel(length('Module: ')+1:end);
                    end
                end
                this.allModuleNames=labels(isModule);
                this.allModuleIds=locations(isModule);
                rmiut.progressBarFcn('delete');
            end
        end
        dlg.refresh();
    else
        dlg.setEnabled('DngModuleCombo',false);
    end

end
