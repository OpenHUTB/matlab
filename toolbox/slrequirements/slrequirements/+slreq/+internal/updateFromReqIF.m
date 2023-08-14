

















































function[status,changelog]=updateFromReqIF(mainReqSet,optionalOtherSetNames,rootItem,reqIFFileName)




    status=struct('message','','id','');
    changelog=[];%#ok<NASGU>


    reqData=slreq.data.ReqData.getInstance();
    dataReqSet=reqData.getReqSet(mainReqSet);
    if isempty(dataReqSet)
        error('Internal error: invalid reqset.');
    end


    if isempty(rootItem)


        rootItems=reqData.getRootItems(dataReqSet);
        if length(rootItems)==1
            rootItem=rootItems(1);
        end
    end

    if isempty(rootItem)
        error('Internal error: root item not provided.');
    end

    [~,useLegacyReqIf]=slreq.uri.isImportedReqIF(rootItem.domain);

    if useLegacyReqIf
        [mappingFile,~]=slreq.internal.extractLegacyReqIfOptions(rootItem.artifactUri,mainReqSet);
        scratchReqSet=slreq.internal.scratchImportFromReqIF(mainReqSet,rootItem,reqIFFileName,mappingFile);
        scratchReqSet.children(1).customId=rootItem.customId;
    else
        scratchReqSet=slreq.internal.scratchImportFromReqIF(mainReqSet,rootItem,reqIFFileName);
    end
    scratchCleanup=onCleanup(@()reqData.discardReqSet(scratchReqSet));


    [numChanges,exMessage,changelog]=dataReqSet.synchronize(rootItem.customId,scratchReqSet,[]);

    if strcmp(exMessage,message('Slvnv:reqmgt:synchro:ReqIFContainsEmptyCustomID','').string)
        [~,fname,fext]=fileparts(reqIFFileName);
        error(message('Slvnv:reqmgt:synchro:ReqIFContainsEmptyCustomID',[fname,fext]));
    end


    nonUniqueCustomIds={};


    artifactUri=rootItem.artifactUri;
    status=slreq.internal.synchronizeStatus(rootItem.index,artifactUri,numChanges,exMessage,nonUniqueCustomIds);
end
