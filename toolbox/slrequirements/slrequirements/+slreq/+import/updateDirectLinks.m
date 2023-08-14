function count=updateDirectLinks(artifact,doPrompt)








    count=0;

    if~ischar(artifact)

        srcPath=get_param(artifact,'FileName');
        srcName=get_param(artifact,'Name');
        if isempty(srcPath)
            srcPath=fullfile(pwd,[srcName,'.slx']);
        end
    else
        srcPath=artifact;
        srcName=slreq.uri.getShortNameExt(srcPath);
    end

    linkSet=slreq.utils.getLinkSet(srcName);
    if isempty(linkSet)||~linkSet.hasDirectLinks()
        return;
    end

    directLinks=linkSet.getDirectLinks();
    [docIdx,docs,reqSets]=findItemsThatCanBeUpdated(directLinks,srcPath);
    if~any(docIdx)
        return;
    end

    uniqueIdx=unique(docIdx);
    for i=1:length(uniqueIdx)
        docName=docs{i};
        reqSetName=reqSets{i};
        links=directLinks(docIdx==i);
        if doPrompt
            doUpdate=promptForUpdate(srcName,sum(docIdx==i),docName,reqSetName);
        else
            doUpdate=true;
            fprintf(1,getString(message('Slvnv:slreq_import:UpdatingNLinksToDoc',num2str(count),docName)));
        end
        if doUpdate

            count=count+updateLinks(links,docName,reqSetName);
        else
            continue;
        end
    end

    if count>0
        if doPrompt
            msgbox(...
            getString(message('Slvnv:slreq_import:NLinksUpdated',num2str(count))),...
            getString(message('Slvnv:slreq_import:DlgTitleUpdateDirectLinks')));
        else
            fprintf(1,getString(message('Slvnv:slreq_import:NLinksUpdated',num2str(count))));
        end
    elseif~doPrompt

        error(message('Slvnv:slreq_import:FailedToUpdateLinksIn',srcName));
    end
end

function cnt=updateLinks(links,docName,reqSetName)
    cnt=0;
    reqData=slreq.data.ReqData.getInstance();
    reqSet=reqData.getReqSet(reqSetName);
    if isempty(reqSet)
        reqSet=reqData.loadReqSet(reqSetName);
    end
    for j=1:numel(links)
        link=links(j);
        [~,destDomain,destId]=link.getReferenceInfo();
        req=reqData.findExternalRequirementByArtifactUrlId(reqSet,destDomain,docName,destId);
        if isempty(req)
            rmiut.warnNoBacktrace('Slvnv:slreq_import:UnableToUpdateLinkTo',...
            link.dest.artifactId,docName);
        else
            reqData.updateLinkDestinationToProxy(link,req);
            cnt=cnt+1;
        end
    end
end


function[idx,docs,reqSets]=findItemsThatCanBeUpdated(allLinks,refSrc)
    refPath=fileparts(refSrc);
    idx=zeros(size(allLinks));
    docs={};
    reqSets={};
    docIdx=[];
    localDocToReqset=containers.Map('KeyType','char','ValueType','char');
    for i=1:numel(allLinks)
        link=allLinks(i);
        dest=link.dest;
        if isempty(dest)||~dest.external
            continue;
        end
        storedDocId=dest.artifactUri;
        if slreq.uri.isBackedByFile(link.destDomain)
            docPath=slreq.uri.ResourcePathHandler.getFullPath(storedDocId,refPath);
            docName=slreq.uri.getShortNameExt(docPath);
        else
            docPath=storedDocId;
            docName=docPath;
        end

        if isKey(localDocToReqset,docPath)
            reqSetName=localDocToReqset(docPath);
            if isempty(reqSetName)
                continue;
            else
                mapIdx=find(strcmp(docs,docName));
            end
        else
            reqSetName=checkForReqSet(docPath,refPath);
            if isempty(reqSetName)
                localDocToReqset(docPath)='';
                continue;
            else
                localDocToReqset(docPath)=reqSetName;
                docs{end+1}=docName;%#ok<AGROW>
                reqSets{end+1}=reqSetName;%#ok<AGROW>
                mapIdx=length(docs);
                docIdx(end+1)=mapIdx;%#ok<AGROW>
            end
        end
        idx(i)=mapIdx;
    end
end

function reqSetName=checkForReqSet(doc,ref)
    reqSetName=slreq.import.docToReqSetMap(doc);
    if isempty(reqSetName)&&~rmiut.isCompletePath(doc)
        pathToDoc=rmi.locateFile(doc,ref);
        if~isempty(pathToDoc)
            reqSetName=slreq.import.docToReqSetMap(pathToDoc);
        end
    end
end

function tf=promptForUpdate(artifact,count,docName,reqSetName)
    [~,artifact]=fileparts(artifact);
    response=questdlg({...
    getString(message('Slvnv:slreq_import:ArtifactHasNLinksToDoc',artifact,num2str(count),docName)),...
    getString(message('Slvnv:slreq_import:ContentsOfDocImportedIntoReqSet',docName,reqSetName))...
    ,getString(message('Slvnv:slreq_import:WouldYouLikeToUpdateLinksIn',artifact,reqSetName))},...
    getString(message('Slvnv:slreq_import:DlgTitleUpdateDirectLinks')),...
    getString(message('Slvnv:slreq_import:Update')),...
    getString(message('Slvnv:slreq_import:NotNow')),...
    getString(message('Slvnv:slreq_import:Update')));
    tf=~isempty(response)&&strcmp(response,getString(message('Slvnv:slreq_import:Update')));
end


