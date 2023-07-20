function[success,cutObjs,cutReqs]=exportMatchedItems(parentName,filterPrefix,exportedPath,reqFilePath)



    success=false;
    cutObjs={};
    cutReqs={};

    if strncmp(filterPrefix,'urn:uuid:',length('urn:uuid:'))
        domain='linktype_rmi_simulink';
    else

        error('slreq.exportMatchedItems() can only be called for Simulink harness export.');
    end
    artifactPath=slreq.resolveArtifactPath(parentName,domain);
    reqData=slreq.data.ReqData.getInstance();
    linkSet=reqData.getLinkSet(artifactPath);
    if isempty(linkSet)
        return;
    end


    newLinkSet=reqData.getLinkSet(exportedPath);
    if~isempty(newLinkSet)
        error('slreq.exportMatchedItems() cannot export to existing LinkSet.');
    end

    srcStruct.artifact=exportedPath;
    srcStruct.domain=domain;


    allLinkedItems=linkSet.getLinkedItems();





    if filterPrefix(1)~=':'
        filterPrefix=[':',filterPrefix];
    end
    filterPrefixLength=length(filterPrefix);
    [~,exportedName,exportedExt]=fileparts(exportedPath);



    isNonCutOutgoingLinks=false(size(allLinkedItems));




    harnessOwner=getHarnessOwnerPath(parentName,filterPrefix);

    doSaveParent=false;
    doSaveNew=false;

    for i=1:numel(allLinkedItems)

        links=allLinkedItems(i).getLinks();

        if isempty(links)
            continue;
        end

        linkedItemID=allLinkedItems(i).id;
        isUnderCUT=false;
        isOtherHarness=false;
        if strncmp(linkedItemID,filterPrefix,filterPrefixLength)
            isNonCutOutgoingLinks(i)=true;
        elseif rmisl.isHarnessIdString(linkedItemID)

            isOtherHarness=true;
        elseif~isempty(linkedItemID)&&any(harnessOwner=='/')


            objPath=getObjPath([parentName,linkedItemID]);
            if~isempty(objPath)
                isUnderCUT=strncmp(objPath,harnessOwner,length(harnessOwner));
            end
        end

        for j=1:numel(links)
            link=links(j);
            [~,destName]=fileparts(link.destUri);
            if strcmp(destName,parentName)

                if strncmp(link.destId,filterPrefix,filterPrefixLength)
                    localId=strrep(link.destId,filterPrefix,'');
                    destStruct=struct('artifact',[exportedName,exportedExt],...
                    'id',localId,'domain',domain);
                    reqData.updateLinkDestination(link,destStruct);
                    if isUnderCUT||isOtherHarness
                        doSaveParent=true;
                    end

                    origDescription=link.description;
                    if strncmp(origDescription,parentName,length(parentName))
                        link.description=[exportedName,origDescription(length(parentName)+1:end)];
                    end
                end
            end
            if isUnderCUT
                cutReqs{end+1}=slreq.utils.linkToStruct(link);%#ok<AGROW>
                cutObjs{end+1}=replaceDiagramName(objPath,harnessOwner,exportedName);%#ok<AGROW>
            end
        end

    end


    nonCutLinkedItems=allLinkedItems(isNonCutOutgoingLinks);
    for i=1:numel(nonCutLinkedItems)
        linkedItem=nonCutLinkedItems(i);
        srcStruct.id=strrep(linkedItem.id,filterPrefix,'');
        links=linkedItem.getLinks();
        linkInfo=rmi.createEmptyReqs(numel(links));



        canSetNow=repmat(rmipref('StoreDataExternally'),length(linkInfo),1);
        for j=1:numel(links)
            link=links(j);

            linkDest=link.dest;
            if~isempty(linkDest)&&isa(linkDest,'slreq.data.Requirement')&&linkDest.external

                linkInfo(j).reqsys=linkDest.domain;
                linkInfo(j).doc=linkDest.artifactUri;
                linkInfo(j).id=linkDest.artifactId;
            else



                linkInfo(j).reqsys=link.destDomain;
                linkInfo(j).doc=link.destUri;
                linkInfo(j).id=link.destId;
            end

            if~isempty(link.description)
                linkInfo(j).description=link.description;


                if strcmp(linkInfo(j).reqsys,'linktype_rmi_simulink')&&...
                    strncmp(linkInfo(j).description,harnessOwner,length(harnessOwner))
                    try


                        linkInfo(j).doc=exportedName;
                        linkInfo(j).id=':';
                        linkInfo(j).description=strrep(linkInfo(j).description,parentName,exportedName);
                        canSetNow(j)=false;
                    catch ex %#ok<NASGU>


                    end
                end
            elseif~isempty(linkDest)
                linkInfo(j).description=linkDest.summary;
            end
            if~canSetNow(j)


                localSID=strrep(linkedItem.id,filterPrefix,'');
                try
                    futurePath=getfullname(Simulink.ID.getHandle([exportedName,localSID]));
                catch ex

                    futurePath=[exportedName,localSID];
                end
                cutObjs{end+1}=futurePath;%#ok<AGROW>
                cutReqs{end+1}=linkInfo(j);%#ok<AGROW>
            end
        end
        if any(canSetNow)
            slreq.internal.setLinks(srcStruct,linkInfo(canSetNow));

            doSaveNew=true;
        end
    end



    if doSaveParent&&~slreq.utils.isEmbeddedLinkSet(linkSet)






        linkSet.save();
    end

    if doSaveNew
        newLinkSet=reqData.getLinkSet(exportedPath);
        if~isempty(reqFilePath)&&~strcmp(newLinkSet.filepath,reqFilePath)
            newLinkSet.filepath=reqFilePath;
        end
        newLinkSet.save();
    end

    success=true;
end

function harnessOwnerPath=getHarnessOwnerPath(mainModelName,harnessID)
    harnesses=Simulink.harness.find(mainModelName);
    harnessesIDs={harnesses(:).uuid};
    if harnessID(1)==':'
        harnessID(1)=[];
    end
    harnessInfo=harnesses(strcmp(harnessesIDs,harnessID));
    harnessOwnerPath=harnessInfo.ownerFullPath;
end

function objPath=getObjPath(origSID)
    try
        objH=Simulink.ID.getHandle(origSID);
    catch ME %#ok<NASGU>

        objPath=[];
        return;
    end


    if isa(objH,'Stateflow.Object')
        sfChart=obj_chart(objH.Id);
        sfBlock=sfprivate('chart2block',sfChart);
        objPath=sprintf('%s SID_%d',getfullname(sfBlock),objH.SSIdNumber);
    else
        objPath=getfullname(objH);
    end
end

function updatedPath=replaceDiagramName(objPath,harnessOwner,saveAsName)
    if length(objPath)>length(harnessOwner)
        localPath=objPath(length(harnessOwner)+1:end);
    else
        localPath='';
    end
    sfMatch=regexp(localPath,'(.*) SID_([\d\:]+)','tokens');
    if isempty(sfMatch)

        ownerName=get_param(harnessOwner,'Name');
        updatedPath=[saveAsName,'/',ownerName,localPath];
    else

        parentChart=sfMatch{1}{1};
        updatedChart=replaceDiagramName(parentChart,harnessOwner,saveAsName);
        updatedPath=[Simulink.ID.getSID(updatedChart),':',sfMatch{1}{2}];
    end
end


