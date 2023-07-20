function[labels,depths,locations]=listCollections(this,allCollectionsIds)
    oslc.Project.currentProject(this.name,this.queryBase);
    if nargin==2

        if~iscell(allCollectionsIds)
            allCollectionsIds=split(strtrim(allCollectionsIds));
        end
        if numel(this.collectionIds)~=numel(allCollectionsIds)||...
            ~all(strcmp(sort(this.collectionIds),sort(allCollectionsIds)))


            this.refreshCollectionsList();
        end

    elseif this.contentsList.isUpdated

        this.contentsList.isUpdated=false;

    end
    [labels,depths,locations]=this.getContentsList();
end
