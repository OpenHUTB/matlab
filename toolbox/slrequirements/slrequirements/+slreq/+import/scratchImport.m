function[scratchReqSet,topNode]=scratchImport(origReqSet,artifactUri,subDoc,useLegacyReqIF)








    if nargin<3
        subDoc='';
    end

    if nargin<4
        useLegacyReqIF=false;
    end

    topNode=[];

    reqData=slreq.data.ReqData.getInstance();


    if isa(origReqSet,'slreq.ReqSet')
        origReqSet=reqData.getReqSet(origReqSet.Filename);

    elseif ischar(origReqSet)
        origReqSet=reqData.getReqSet(origReqSet);

    elseif~isa(origReqSet,'slreq.data.RequirementSet')
        error(message('Slvnv:slreq_import:ImportInvalidArgument','first',class(origReqSet)));
    end





    if~rmiut.isCompletePath(origReqSet.filepath)
        error(message('Slvnv:slreq:RequirementSetNotSaved'))
    end


    if isa(artifactUri,'slreq.Reference')
        artifactUri=artifactUri.Artifact;
        [~,subDoc]=slreq.internal.getDocSubDoc(artifactUri.Id);
    elseif isa(artifactUri,'slreq.data.Requirement')
        artifactUri=artifactUri.artifactUri;
        [~,subDoc]=slreq.internal.getDocSubDoc(artifactUri.id);
    elseif~ischar(artifactUri)
        error(message('Slvnv:slreq_import:ImportInvalidArgument','second',class(artifactUri)));
    end





    if~rmiut.isCompletePath(artifactUri)
        refPath=fileparts(origReqSet.filepath);
        externalArtifactInfo=relativeToFullPath(artifactUri,refPath);
    else
        externalArtifactInfo=artifactUri;
    end

    if isempty(externalArtifactInfo)||exist(externalArtifactInfo,'file')~=2



        isFile=false;
        artifactName=artifactUri;

        rootNode=origReqSet.findTopNodeById(artifactName);
        if isempty(rootNode)
            error(message('Slvnv:slreq_import:ImportMissingFile',artifactName));
        end



        srcDomain=rootNode.domain;





        externalArtifactInfo=srcDomain;


        domainType=rmi.linktype_mgr('resolveByRegName',srcDomain);
        domainType.NavigateFcn(artifactUri,'');







        documentSetupCallback=domainType.BeforeUpdateFcn;

    else

        isFile=true;
        docType=rmi.linktype_mgr('resolveByFileExt',artifactUri);
        if~isempty(docType)
            srcDomain=docType.Registration;
        else
            srcDomain='REQIF';

        end
        [~,artifactName]=fileparts(externalArtifactInfo);
        documentSetupCallback=[];
    end



    importOptions=processImportOptions(origReqSet.name,artifactName,subDoc,documentSetupCallback);


    if~isfield(importOptions,'docPath')
        if isfield(importOptions,'DocID')
            importOptions.docPath=importOptions.DocID;
        else
            importOptions.docPath=externalArtifactInfo;
        end
    end
    importOptions.ReqSet=origReqSet.filepath;


    reqData=slreq.data.ReqData.getInstance;
    if isFile
        artifactShortName=slreq.uri.getShortNameExt(artifactUri);
    else
        artifactShortName=artifactUri;
    end
    importNodeDataObj=reqData.findExternalRequirementByArtifactUrlId(origReqSet,srcDomain,artifactShortName,'');

    if~isempty(importNodeDataObj)
        oldDocPath=importOptions.docPath;

        importOptionsObj=slreq.internal.callback.ImportOptionFactory.createImportOptions(srcDomain,importOptions);
        slreq.internal.callback.Utils.executeCallback(importNodeDataObj,'preImportFcn',importNodeDataObj.preImportFcn,importOptionsObj);


        importOptions=importOptionsObj.exportOptions;


        if~isempty(oldDocPath)&&~strcmpi(oldDocPath,importOptions.docPath)
            slreq.internal.updateSrcArtifactUri(importNodeDataObj,importOptions.docPath)
        end
    else

    end

    if isfield(importOptions,'ReqSet')


        importOptions=rmfield(importOptions,'ReqSet');
    end
    origReqSetLocation=fileparts(origReqSet.filepath);
    scratchReqSet=createScratchReqSet(reqData,origReqSetLocation);





    scratchReqSet.lastNumericID=origReqSet.lastNumericID;


    count=slreq.import(externalArtifactInfo,'ReqSet',scratchReqSet,'useLegacyReqIF',useLegacyReqIF,'options',importOptions);
    if count>0
        topNode=reqData.getRootItems(scratchReqSet);



        if length(topNode)~=1||...
            ~isempty(topNode.artifactId)||...
            ~contains(topNode.artifactUri,artifactName)
            error(message('Slvnv:slreq_import:SyncImportMalfunction',artifactName));
        end





        [rhsDocName,rhsSubDoc]=slreq.internal.getDocSubDoc(topNode.customId);
        if~strcmp(subDoc,rhsSubDoc)
            if isempty(subDoc)

                topNode.customId=rhsDocName;
            else




                error(message('Slvnv:slreq_import:SyncImportMalfunction',artifactName));
            end
        end

    else


        rmiut.warnNoBacktrace('Slvnv:slreq_import:NothingImportedFrom',artifactName);
    end
end

function scratch=createScratchReqSet(reqData,refPath)


    scratch=reqData.getReqSet('SCRATCH');
    if~isempty(scratch)
        scratch.discard();
    end





    scratch=reqData.createSpecialReqSet('SCRATCH');



    scratch.filepath=fullfile(refPath,scratch.name);
end

function usablePath=relativeToFullPath(relPath,refPath)
    fullPath=fullfile(refPath,relPath);
    resolvedPath=rmiut.simplifypath(fullPath,filesep);
    if exist(resolvedPath,'file')
        usablePath=resolvedPath;
    else
        usablePath=which(relPath);
    end
end

function importOptions=processImportOptions(origReqSetName,artifactName,subDoc,documentSetupCallback)
    importOptions=slreq.import.ImportDataChecker.loadStoredImportOptions(origReqSetName,artifactName,subDoc);

    if isempty(importOptions)



        importOptions.DocID=artifactName;
        importOptions.richText=false;
    end
    if~isempty(documentSetupCallback)




        actionInfo=struct('importOptions',importOptions,'hasChanges',false);
        actionInfo=documentSetupCallback(actionInfo);
        if actionInfo.hasChanges


            importOptions=actionInfo.importOptions;

            tempOptFile=slreq.import.impOptFile(origReqSetName,artifactName);
            save(tempOptFile,'importOptions');
        end
    end

end


