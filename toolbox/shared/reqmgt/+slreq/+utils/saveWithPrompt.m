function result=saveWithPrompt(reqSetNames,dependentArtifact)



    if nargin<2
        promptTitle=getString(message('Slvnv:slreq:SavingRequirements'));
        promptList={getString(message('Slvnv:slreq:ModifiedReqSets'))};
    else
        promptTitle=getString(message('Slvnv:slreq:SavingArtifact',dependentArtifact));
        [~,artName,artExt]=fileparts(dependentArtifact);
        linkFile=rmimap.StorageMapper.defaultLinkPath('',artName,artExt);
        promptList={getString(message('Slvnv:slreq:LinkSetDependsOnModifiedReqSets',[artName,artExt],linkFile))};
    end

    for i=1:length(reqSetNames)
        [~,shortName]=fileparts(reqSetNames{i});
        promptList{end+1}=[shortName,'.slreqx'];%#ok<AGROW>
    end

    if nargin<2
        reply=questdlg(promptList,promptTitle,...
        getString(message('Slvnv:slreq:SaveAll')),...
        getString(message('Slvnv:slreq:Cancel')),...
        getString(message('Slvnv:slreq:SaveAll')));
    else
        promptList{end+1}=getString(message('Slvnv:slreq:RecommendedToSaveReqSets'));
        reply=questdlg(promptList,promptTitle,...
        getString(message('Slvnv:slreq:SaveAll')),...
        getString(message('Slvnv:slreq:SaveLinksOnly')),...
        getString(message('Slvnv:slreq:Cancel')),...
        getString(message('Slvnv:slreq:SaveAll')));
    end
    switch reply
    case getString(message('Slvnv:slreq:SaveAll'))
        for i=1:length(reqSetNames)
            reqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetNames{i});

            if~slreq.internal.LinkUtil.isEmbeddedReqSet(reqSet)
                reqSet.save();
            end
        end
        result=true;
    case getString(message('Slvnv:slreq:SaveLinksOnly'))
        result=true;
    otherwise
        result=false;
    end
end