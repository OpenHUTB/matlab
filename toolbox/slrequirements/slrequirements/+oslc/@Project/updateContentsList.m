function updateContentsList(this,collectionId)

    idx=find(strcmp(this.contentsList.locations,collectionId));
    if idx==length(this.contentsList.locations)||oslc.isCollectionItem(this.contentsList.labels{idx+1})

        progressMessage=getString(message('Slvnv:oslc:GettingContentsOf',this.contentsList.labels{idx}));
        progressTitle=getString(message('Slvnv:oslc:PleaseWait'));
        rmiut.progressBarFcn('set',0.5,progressMessage,progressTitle);
        myConnection=oslc.connection();
        items=myConnection.getRequirementsUrlsInCollection(collectionId);


        if(iscell(items)&&~isempty(items))||(~iscell(items)&&~items.isempty)
            progressBarInfo=struct('text',progressMessage,'range',[0.5,1.0],'title',progressTitle);
            requirements=this.getRequirementsByURLs(items,progressBarInfo,myConnection);

            [lbls,dpths,lctns]=oslc.Project.listRequirements(requirements(:),this.contentsList.labels{idx},1);

            this.contentsList.labels=[this.contentsList.labels(1:idx);lbls;this.contentsList.labels(idx+1:end)];
            this.contentsList.depths=[this.contentsList.depths(1:idx);dpths;this.contentsList.depths(idx+1:end)];
            this.contentsList.locations=[this.contentsList.locations(1:idx);lctns;this.contentsList.locations(idx+1:end)];

            this.contentsList.isUpdated=true;
        end
        rmiut.progressBarFcn('delete');
    else

        nextIdx=idx+1;
        while nextIdx<=length(this.contentsList.labels)
            if oslc.isCollectionItem(this.contentsList.labels{nextIdx})
                break;
            end
            nextIdx=nextIdx+1;
        end
        if nextIdx==idx+1

            return;
        elseif nextIdx>length(this.contentsList.labels)

            this.contentsList.labels=this.contentsList.labels(1:idx);
            this.contentsList.depths=this.contentsList.depths(1:idx);
            this.contentsList.locations=this.contentsList.locations(1:idx);
            this.contentsList.isUpdated=true;
        else
            this.contentsList.labels=[this.contentsList.labels(1:idx);this.contentsList.labels(nextIdx:end)];
            this.contentsList.depths=[this.contentsList.depths(1:idx);this.contentsList.depths(nextIdx:end)];
            this.contentsList.locations=[this.contentsList.locations(1:idx);this.contentsList.locations(nextIdx:end)];
            this.contentsList.isUpdated=true;
        end
    end
end
