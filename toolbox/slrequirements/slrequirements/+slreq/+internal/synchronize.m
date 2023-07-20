function[status,changelog]=synchronize(dataModelObject,syncOptions)




    origReqSet=dataModelObject.getReqSet();

    changelog=[];%#ok<NASGU>


    if nargin<2
        syncOptions=struct('ignoreWhiteSpace',true,'diagnosticsMode',false);
    end




    artifactUri=dataModelObject.artifactUri;

    [isReqIF,useLegacyReqIF]=slreq.uri.isImportedReqIF(dataModelObject.domain);

    importNodeId=dataModelObject.customId;
    if isReqIF




        if~rmiut.isCompletePath(artifactUri)
            reqSetLocation=fileparts(origReqSet.filepath);
            artifactUri=slreq.uri.ResourcePathHandler.getFullPath(artifactUri,reqSetLocation);
        end
        if useLegacyReqIF
            [mappingFile,specName]=slreq.internal.extractLegacyReqIfOptions(artifactUri,origReqSet.name);


            importNodeId=specName;
            scratchReqSet=slreq.internal.scratchImportFromReqIF(origReqSet.name,dataModelObject,artifactUri,mappingFile);
        else
            scratchReqSet=slreq.internal.scratchImportFromReqIF(origReqSet.name,dataModelObject,artifactUri);
        end
    else





        [~,subDoc]=slreq.internal.getDocSubDoc(dataModelObject.customId);


        [scratchReqSet,~]=slreq.import.scratchImport(origReqSet,artifactUri,subDoc,useLegacyReqIF);
    end


    scratchCleanup=onCleanup(@()cleanupScratch());


    topNodes=scratchReqSet.children;
    hasImportedItems=false;
    if isempty(topNodes)

        currentArtifactUri=artifactUri;
    else
        currentArtifactUri=topNodes(1).artifactUri;
    end

    for i=1:numel(topNodes)
        if~isempty(topNodes(i).children)
            hasImportedItems=true;
            break;
        end
    end
    if hasImportedItems

        nonUniqueCustomIds=scratchReqSet.preSynchronize(importNodeId);
    else

        uiSelection=slreq.getCurrentObject();
        if~isempty(uiSelection)&&strcmp(uiSelection.CustomId,importNodeId)
            msgbox(getString(message('Slvnv:slreq_import:NothingImportedFrom',artifactUri)),...
            getString(message('Slvnv:slreq_import:Update')));
        end
        nonUniqueCustomIds=[];
    end

    if useLegacyReqIF

        importNodeId=dataModelObject.customId;
        scratchReqSet.children(1).customId=importNodeId;
    end


    [numChanges,reqMessage,changelog]=origReqSet.synchronize(importNodeId,scratchReqSet,syncOptions);

    if strcmp(reqMessage,message('Slvnv:reqmgt:synchro:ReqIFContainsEmptyCustomID','').string)
        [~,fname,fext]=fileparts(artifactUri);
        error(message('Slvnv:reqmgt:synchro:ReqIFContainsEmptyCustomID',[fname,fext]));
    end


    linkMessage=[];
    reqData=slreq.data.ReqData.getInstance();
    if isReqIF&&~useLegacyReqIF
        domain='linktype_rmi_slreq';

        scratchArtifact=scratchReqSet.filepath;
        scratchLinkSet=reqData.getLinkSet(scratchArtifact,domain);

        origArtifact=origReqSet.filepath;
        origLinkSet=reqData.getLinkSet(origArtifact,domain);

        if~isempty(scratchLinkSet)&&isempty(origLinkSet)




            origLinkSet=reqData.createLinkSet(origReqSet.filepath,domain);
        end

        if~isempty(origLinkSet)&&~isempty(scratchLinkSet)
            [linkChanges,linkMessage,linkChangeLog]=origLinkSet.synchronize(scratchLinkSet);
        else
            linkChanges=0;
            linkChangeLog=[];
        end


        numChanges=numChanges+linkChanges;
        changelog=[changelog,linkChangeLog];
    end


    errorMessage=reqMessage;

    if~isempty(linkMessage)
        if~isempty(errorMessage)
            errorMessage=[errorMessage,newline];
        end

        errorMessage=[errorMessage,linkMessage];
    end

    status=slreq.internal.synchronizeStatus(dataModelObject.index,artifactUri,numChanges,errorMessage,nonUniqueCustomIds);


    reqData.refreshLinkSetsByRegistration(origReqSet.name);


    if isempty(currentArtifactUri)||exist(currentArtifactUri,'file')~=2
        shortUri=currentArtifactUri;
    else
        shortUri=slreq.uri.getShortNameExt(currentArtifactUri);
    end
    topImportNode=origReqSet.find('customId',importNodeId);

    if isempty(topImportNode)

        topImportNode=reqData.findExternalRequirementByArtifactUrlId(origReqSet,'',shortUri,'');
    end

    if isempty(topImportNode)

        warning('unexpected error happens during executing postImportFcn: could not found the imported node ')
    else
        topImportNode.executeCB('postImportFcn',[]);
    end
end



function cleanupScratch()

    reqData=slreq.data.ReqData.getInstance();
    scratchReqSet=reqData.getReqSet('SCRATCH');
    if~isempty(scratchReqSet)


        scratchArtifact=scratchReqSet.filepath;
        domain='linktype_rmi_slreq';

        scratchLinkSet=reqData.getLinkSet(scratchArtifact,domain);
        if~isempty(scratchLinkSet)

            scratchLinkSet.discard();
        end



        scratchReqSet.discard();
    end
end


