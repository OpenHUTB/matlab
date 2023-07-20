classdef RequirementSet<slreq.data.BaseSet




    properties(Access=private)
        reqData;


        imageMgr;




        lastSavedFilePath;

        Debug=false;

    end

    properties(Dependent)
        name;
        filepath;
        parent;
        idPrefix;
        idDelimiter;
        description;
        MATLABVersion;
        CustomAttributeNames;
        CustomAttributeRegistry;
        lastNumericID;
preSaveFcn
postLoadFcn
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
        children;
        dirty;
    end

    methods(Access=?slreq.data.ReqData)



        function this=RequirementSet(modelObject)
            this.modelObject=modelObject;
            this.reqData=slreq.data.ReqData.getInstance();




            this.imageMgr=slreq.opc.ImageManager(modelObject.name);
        end
    end

    methods(Static,Access=?slreq.data.ReqData)



        function value=defaultPrefix()
            value='';
        end
        function value=defaultDelimiter()
            value='.';
        end
    end

    methods

        function out=getLastSavedFilePath(this)
            out=this.lastSavedFilePath;
        end


        function out=getImageFilenamesToPack(this)


            out=this.imageMgr.getImageList();
        end


        function out=getImageFileFullNamesToPack(this)

            out=this.imageMgr.getImageFilenamesToPack();
        end


        function out=getImageListForReq(this,sid,propertyName)
            out=this.imageMgr.getImageListForReq(sid,propertyName);
        end


        function collectImagesFromReq(this,reqUUID,propertyName)













            try
                dataReq=this.reqData.findObject(reqUUID);
            catch ex

                return;
            end

            if~isa(dataReq,'slreq.data.Requirement')
                return;
            end
            editorType=[propertyName,'EditorType'];
            if strcmpi(dataReq.(editorType),'word')
                useReqSetMacro=true;
                resourceFolder=slreq.opc.getReqSetTempDir(this.name);
            else
                useReqSetMacro=false;
                resourceFolder=slreq.opc.getUsrTempDir;

            end
            [~,imageList]=slreq.utils.HTMLProcessor.packingImage(dataReq.(propertyName),resourceFolder,useReqSetMacro);
            this.collectImagesForPacking(imageList);

        end


        function removeImages(this,imageList)

            this.imageMgr.removeImages(imageList);
        end


        function collectImagesForPacking(this,images)
            this.imageMgr.collectImagesForPacking(images);
        end


        function out=unpackImages(this,htmlText)
            out=this.imageMgr.unpackImages(htmlText);
        end


        function refreshImagesMacrosIfNecessary(this,asVersion)
            this.imageMgr.refreshImagesMacrosIfNecessary(asVersion);
        end


        function moveImagesIfNecessary(this,oldPath)






            if strcmp(this.name,oldPath)

            else
                imageUpdated=false;
                allImages=this.getImageFilenamesToPack();
                for index=1:length(allImages)
                    cImage=allImages{index};
                    imageObj=slreq.uri.SourcePath(cImage);
                    imageObj.setReqSetName(oldPath);

                    if imageObj.isExternalMacro


                        imageOldPath=imageObj.getFullPath();
                        imageObj.setReqSetName(this.name);
                        imageNewPath=imageObj.getFullPath();

                        filefolder=fileparts(imageNewPath);
                        if exist(filefolder,'dir')~=7
                            mkdir(filefolder);
                        end

                        try
                            status=copyfile(imageOldPath,imageNewPath);
                        catch ex
                            if this.Debug
                                disp([imageOldPath,' copy fails']);
                                disp(ex);
                            end
                        end
                        if~status

                            if this.Debug
                                disp([imageOldPath,' copy fails']);
                            end
                        end

                        newImage=imageObj.getResourcePath();
                        imageUpdated=true;
                        allImages{index}=newImage;
                    end
                end
                if imageUpdated
                    this.imageMgr.refreshImages(allImages);
                end
                this.imageMgr.ReqSetName=this.name;
                this.imageMgr.ReqSetTempDir=slreq.opc.getReqSetTempDir(this.name);
            end
        end


        function collectImagesFromHTML(this,htmlText)
            this.imageMgr.collectImagesFromHTML(htmlText);
        end

        function dirty=get.dirty(this)
            dirty=this.modelObject.dirty;
        end

        function out=isOSLC(this)
            srcDomain=this.modelObject.getProperty('externalDomain');
            out=startsWith(srcDomain,slreq.data.Requirement.OSLC_DOMAIN_PREFIX);
        end

        function children=get.children(this)
            children=this.getRootItems();
        end

        function name=get.name(this)
            name=this.modelObject.name;
        end

        function callbackText=get.preSaveFcn(this)
            callbackText='';
            if~isempty(this.modelObject.preSave)
                callbackText=this.modelObject.preSave.text;
            end
        end

        function callbackText=get.postLoadFcn(this)
            callbackText='';
            if~isempty(this.modelObject.postLoad)
                callbackText=this.modelObject.postLoad.text;
            end
        end

        function set.preSaveFcn(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if slreq.data.ReqData.getInstance.setCallback(this,'preSave',value)
                this.setDirty(true);
            end
        end

        function set.postLoadFcn(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if slreq.data.ReqData.getInstance.setCallback(this,'postLoad',value)
                this.setDirty(true);
            end
        end

        function set.name(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if~ischar(value)||isempty(value)
                disp('Warning: Please pass a valid name string');
                return;
            end

            [~,newName,~]=fileparts(value);
            if strcmp(newName,this.modelObject.name)
                return;
            end
            origName=this.modelObject.name;
            this.modelObject.name=newName;


            this.duplicateImportOptionsFiles(origName,newName);


            [fPath,~,fExt]=fileparts(this.modelObject.filepath);


            updatedPath=fullfile(fPath,[newName,fExt]);
            if~strcmp(this.modelObject.filepath,updatedPath)
                this.setLastSavedFilePath(this.modelObject.filepath);
                this.modelObject.filepath=updatedPath;
            end
        end


        function lastNumericID=get.lastNumericID(this)
            lastNumericID=this.modelObject.lastNumericID;
        end


        function set.lastNumericID(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.lastNumericID=value;
        end

        function name=get.filepath(this)
            name=this.modelObject.filepath;
        end


        function set.filepath(this,value)
            this.update_filepath(value,'');
        end

        function update_filepath(this,newpath,asVersion)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if~ischar(newpath)||isempty(newpath)
                disp('Warning: Please pass a valid path string');
                return;
            end


            [updatedPath,newName]=slreq.uri.getReqSetFilePath(newpath);

            if~strcmp(this.modelObject.filepath,updatedPath)








                this.setLastSavedFilePath(this.modelObject.filepath);
                [origDir,origName]=fileparts(this.modelObject.filepath);
                linkSet=this.reqData.getLinkSet(this.modelObject.filepath);

                this.modelObject.filepath=updatedPath;

                if~strcmp(this.modelObject.name,newName)
                    this.modelObject.name=newName;

                    this.duplicateImportOptionsFiles(origName,newName);
                end
                if~isempty(linkSet)

                    linkSet.moveArtifact(updatedPath,asVersion);

                    linkSet.save;
                end
                newDir=fileparts(updatedPath);
                if isempty(origDir)
                    origDir=pwd;
                end
                if~strcmp(origDir,newDir)
                    wasMoved=true;
                    if~this.isOSLC()
                        this.verifyExternalArtifactPathsAfterReqsetMove(origDir,newDir);
                    end
                else
                    wasMoved=false;
                end


                linkSets=this.reqData.getLoadedLinkSets();
                myUuid=this.getUuid();
                for i=1:numel(linkSets)

                    linkSets(i).updateRegisteredReqSet(myUuid,updatedPath,wasMoved);
                end
            end
        end

        function parent=get.parent(this)
            parent=this.modelObject.parent;
        end

        function set.parent(this,parent)
            this.modelObject.parent=parent;
        end

        function name=get.idPrefix(this)
            name=this.modelObject.idPrefix;
        end

        function set.idPrefix(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.idPrefix=value;

            updateHIdx(this);
        end



        function updateHIdx(this)
            this.modelObject.updateHIdx();
        end

        function name=get.idDelimiter(this)
            name=this.modelObject.idDelimiter;
        end

        function set.idDelimiter(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.idDelimiter=value;

            this.updateHIdx();
        end

        function value=get.description(this)
            value=this.modelObject.description;
        end

        function set.description(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end


            if isequal(this.modelObject.description,value)
                return;
            end

            this.modelObject.description=value;
            this.setDirty(true);
        end

        function value=get.MATLABVersion(this)
            value=this.modelObject.MATLABVersion;
        end

        function names=get.CustomAttributeNames(this)

            registry=this.reqData.getCustomAttributeRegistries(this);
            names=registry.keys();
        end

        function registry=get.CustomAttributeRegistry(this)
            registry=this.reqData.getCustomAttributeRegistries(this);
        end

        function success=save(this,varargin)

            success=this.reqData.saveReqSet(this,varargin{:});
        end

        function importProfile(this,profileName,isExistingProfile)
            if nargin<3
                isExistingProfile=false;
            end
            if reqmgt('rmiFeature','SupportProfile')
                this.reqData.importProfile(this,profileName,isExistingProfile);
            end
        end

        function exportToReqIF(this,fileName,rootNode,mappingFile,templateFile,linkOptions)
            if nargin<6
                linkOptions=struct('exportLinks',false,'minimalAttributes',false);
            end

            if~isempty(templateFile)

                exportMode=slreq.internal.ExportMode.UpdateExistingSpec;
            elseif isempty(mappingFile)




                exportMode=slreq.internal.ExportMode.UpdateExistingSpec;
            else
                exportMode=slreq.internal.ExportMode.CreateNewFile;
            end

            noImages=false;
            slreq.internal.exportToReqIF(this.name,fileName,rootNode,...
            mappingFile,exportMode,templateFile,noImages,linkOptions);
        end

        function discard(this)

            possibleLinkSet=slreq.data.ReqData.getInstance.getLinkSet(this.name,'linktype_rmi_slreq');
            if~isempty(possibleLinkSet)
                possibleLinkSet.discard();
            end
            this.reqData.discardReqSet(this);
        end

        function req=addRequirement(this,varargin)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            req=this.reqData.addRequirement(this,varargin{:});
        end

        function req=addExternalRequirement(this,reqInfo)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            req=this.reqData.addExternalRequirement(this,reqInfo);
        end

        function[objs,numOfDeletedReqs]=removeRequirement(this,req)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            [objs,numOfDeletedReqs]=this.reqData.removeRequirement(req);
        end

        function just=addJustification(this,reqInfo)
            if nargin<2
                reqInfo=[];
            end
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            just=this.reqData.addJustification(this,'child',reqInfo);
        end

        function req=getRequirementById(this,sid)
            if ischar(sid)
                sid=str2num(erase(sid,'#'));%#ok<ST2NM>
            end
            if isempty(sid)
                error(message('Slvnv:slreq:NotAValidReqID',sid));
            else
                req=this.reqData.getRequirement(this,sid);
            end
        end

        function[mwReqs,extReqs,justifications]=getItems(this)
            [mwReqs,extReqs,justifications]=this.reqData.getItems(this);
        end

        function allReqs=getAllItems(this)



            [mwReqs,extReqs,justifications]=this.getItems();
            allReqs=[mwReqs,extReqs,justifications];
        end


        function req=getItemFromID(this,sid)


            if isnumeric(sid)
                sid=num2str(sid);
            end

            req=this.reqData.getItemFromID(this,sid);
        end

        function dataReqs=find(this,varargin)
            numArgs=nargin;
            if numArgs==1
                dataReqs=this.getAllItems();
            elseif rem(numArgs,2)~=1
                error('To search by property values, arguments must be property/value pairs.');
            else
                filters=struct.empty;
                for i=2:2:numArgs
                    filters(i/2).property=varargin{i-1};
                    filters(i/2).value=varargin{i};
                end
                dataReqs=this.reqData.findMatchingRequirements(this,filters);
            end
        end

        function idx=indexOf(this,chDataReq)
            mfChildReq=chDataReq.modelObject;
            if this.modelObject.rootItems.Size>0
                idx=this.modelObject.rootItems.indexOf(mfChildReq);
            else
                idx=0;
            end
        end

        function tf=hasIncomingLinks(this)

            tf=this.reqData.hasIncomingLinks(this);
        end

        function disconnectIncomingLinks(this)




            this.reqData.disconnectIncomingLinks(this);
        end

        function updateIncomingLinks(this)

            this.reqData.updateTargetReference([],this.filepath);


            reqObjs=this.getAllItems;
            for i=1:length(reqObjs)
                req=reqObjs(i);
                links=req.getLinks();
                for j=1:numel(links)
                    this.reqData.updateTargetReference(links(j),req);
                end
            end
        end
















        function mfChangeSet=rawSynchronize(this,rootCustomId,tempReqSet,optionsStruct)

            if nargin<4

                optionsStruct=struct('ignoreWhiteSpace',true,'diagnosticsMode',false);
            end

            mfSyncOptions=this.reqData.createSynchronizationOptions(optionsStruct);


            mfChangeSet=this.modelObject.synchronize(rootCustomId,tempReqSet.modelObject,mfSyncOptions);


            mfSyncOptions.destroy();




        end

        function out=preSynchronize(this,rootCustomId)
            out=this.modelObject.preSynchronize(rootCustomId);
        end

        function[numChanges,exMessage,changelog]=synchronize(this,importRootId,tempReqSet,syncOptions)

            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            exMessage='';
            changelog='';

            alluuids=cell(1,0);
            parentids=cell(1,0);

            try



                changeSet=this.rawSynchronize(importRootId,tempReqSet,syncOptions);

                changes=changeSet.changes.toArray();
                numChanges=numel(changes);


                alluuids=cell(1,numChanges);
                parentids=cell(1,numChanges);

                for i=1:numChanges
                    change=changes(i);
                    uuid=change.changedUUID;
                    parentUuid=change.parentUUID;
                    alluuids{i}=uuid;
                    parentids{i}=parentUuid;

                    switch class(change)



                    case 'slreq.datamodel.InsertionChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>



                        this.collectImagesFromReq(change.changedUUID,'description');
                        this.collectImagesFromReq(change.changedUUID,'rationale');

                    case 'slreq.datamodel.DeletionChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>


                    case 'slreq.datamodel.MoveChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>


                    case 'slreq.datamodel.OrderingChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>


                    case 'slreq.datamodel.UpdateChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>





                        allChangedProperties=change.properties.toArray;
                        for index=length(allChangedProperties)
                            cProperty=allChangedProperties{index};
                            if strcmpi(cProperty,'description')||strcmpi(cProperty,'rationale')
                                this.collectImagesFromReq(change.changedUUID,cProperty);
                            end
                        end

                    end
                end



                changeSet.destroy();

            catch ex







                numChanges=-1;


                exMessage=ex.message;
            end


            if numChanges>0

                this.updateHIdx();



                this.reqData.doneChanging(alluuids,parentids);
            end






            if numChanges>=0
                this.setDirty(true);
            end


            tempReqSet.setDirty(false);

            detectionMgr=slreq.dataexchange.UpdateDetectionManager.getInstance();
            detectionMgr.checkUpdatesForAllArtifacts();



        end

        function updateSrcArtifactUri(this,origDocInfo,newLocation,treatAsFile)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if nargin<4
                treatAsFile=true;
            end
            if ischar(origDocInfo)


                topRef=this.reqData.findExternalRequirementByArtifactUrlId(this,'',origDocInfo,'');

                if isempty(topRef)
                    error(message('Slvnv:reqmgt:NotFoundIn',origDocInfo,[this.name,'.slreqx']));
                end
                if length(topRef)>1



                    topRef=topRef(1);
                end
                if~isempty(topRef.parent)
                    error(message('Slvnv:slreq:TopLevelReferenceOnly','updateSrcFileLocation()'));
                end
                domain=topRef.domain;
                origStoredDocName=topRef.artifactUri;
            elseif isa(origDocInfo,'slreq.Reference')
                origStoredDocName=origDocInfo.Artifact;
                domain=origDocInfo.Domain;
            elseif isa(origDocInfo,'slreq.data.Requirement')&&origDocInfo.external
                origStoredDocName=origDocInfo.artifactUri;
                domain=origDocInfo.domain;
            else
                error(message('Slvnv:rmipref:InvalidInput',class(origDocInfo),'OLD_DOC_NAME'));
            end
            group=slreq.data.ReqData.getInstance.findGroupInReqSet(this,origStoredDocName,domain);
            if isempty(group)
                if treatAsFile
                    shorterSrcID=slreq.uri.getShortNameExt(origStoredDocName);
                else
                    shorterSrcID=origStoredDocName;
                end
                reqSetFileName=slreq.uri.getShortNameExt(this.filepath);
                error(message('Slvnv:slreq_import:NoImportOptionsData',shorterSrcID,reqSetFileName));
            end



            if slreq.internal.updateSrcArtifactUri(group,newLocation,treatAsFile)
                this.setDirty(true);
            end
        end

        function updateImplementationStatus(this)
            preVisitor=slreq.analysis.PreprocessVisitor;
            preVisitor.setAnalysisForImplementation;

            visitor=slreq.analysis.ImplementationVisitor;

            this.acceptVisitor(preVisitor,visitor);
        end


        function updateImplementationStatusForStatsOnly(this)


            this.initImplementationStatus();
            postVisitor=slreq.analysis.ImplementationVisitor;

            postVisitor.visitRequirementSet(this);
        end

        function accept(this,visitor)
            visitor.visitRequirementSet(this);
        end

        function updateVerificationStatus(this)
            resultsManager=slreq.data.ResultManager.getInstance();
            resultsManager.resetCache();

            preVisitor=slreq.analysis.PreprocessVisitor;
            preVisitor.setAnalysisForVerification;

            postVisitor=slreq.analysis.VerificationVisitor;

            this.acceptVisitor(preVisitor,postVisitor);
        end


        function updateVerificationStatusForStatsOnly(this)



            this.initVerificationStatus();
            postVisitor=slreq.analysis.VerificationVisitor;
            postVisitor.visitRequirementSet(this);
        end

        function out=getChildrenWithChangeIssues(this)

            out.asSrc={};
            out.asDst={};
            out.count=0;
            allDataReqs=this.getAllItems;
            for index=1:length(allDataReqs)
                cDataReq=allDataReqs(index);
                changed=false;
                if cDataReq.changedLinkAsSrc.Count~=0
                    out.asSrc{end+1}=cDataReq;
                    changed=true;
                end

                if cDataReq.changedLinkAsDst.Count~=0
                    out.asDst{end+1}=cDataReq;
                    changed=true;
                end
                if changed
                    out.count=out.count+1;
                end
            end
        end


        function req=findTopNodeById(this,docName,subDoc)
            req=[];

            if rmiut.is_url(docName)
                topId=docName;
            else
                [~,shortName]=fileparts(docName);
                if nargin>2&&~isempty(subDoc)
                    topId=[shortName,'!',subDoc];
                else
                    topId=shortName;
                end
            end



            topItems=this.children;
            for i=1:numel(topItems)
                topNode=topItems(i);
                if strcmp(topNode.domain,'linktype_rmi_slreq')||...
                    topNode.external&&isempty(topNode.artifactId)
                    if strcmp(topNode.id,topId)
                        req=topNode;
                        break;
                    end
                end
            end
        end

        function tf=removeProfile(this,profile)
            tf=slreq.data.ReqData.getInstance.removeProfile(this.modelObject,profile);
        end

        function profiles=getAllProfiles(this)
            profiles=slreq.data.ReqData.getInstance.getAllProfiles(this.modelObject);
        end

        function stereotypes=getAllStereotypes(this)
            stereotypes=slreq.data.ReqData.getInstance.getAllStereotypes(this.modelObject);
        end

        function modelSid=getModelSid(this)
            modelSid=this.modelObject.modelSid;
        end

        function setModelSid(this,sid)
            this.modelObject.modelSid=sid;
        end

    end

    methods(Access=private)


        function setLastSavedFilePath(this,value)
            [fPath,~,~]=fileparts(value);

            if isempty(fPath)
                value=fullfile(pwd,value);
            end
            this.lastSavedFilePath=value;
        end

        function tf=hasLinkSetFile(this)
            linkSetFileName=this.getLinkSetFileName();
            tf=exist(linkSetFileName,'file')==2;
        end

        function linkFile=getLinkSetFileName(this)
            linkFile=rmimap.StorageMapper.getInstance.getStorageFor(this.filepath);
        end

        function duplicateImportOptionsFiles(this,origName,newName)

            slreq.internal.duplicateImportOptionsFilesForReqSet(origName,newName,this.modelObject);
        end

        function verifyExternalArtifactPathsAfterReqsetMove(this,origDir,newDir)
            groups=this.modelObject.groups.toArray();
            for j=1:numel(groups)
                grpFilePath=groups(j).artifactUri;
                if~rmiut.isCompletePath(grpFilePath)


                    resolvedPath=rmiut.full_path(grpFilePath,origDir);
                    if~isempty(resolvedPath)
                        newRelativePath=slreq.uri.getPreferredPath(resolvedPath,newDir);
                        if~isempty(newRelativePath)&&~rmiut.isCompletePath(newRelativePath)
                            groups(j).artifactUri=newRelativePath;
                        end
                    end
                end
            end
        end
    end

    methods(Access={?slreq.ReqSet})
        function rootReqs=getRootItems(this)
            rootReqs=this.reqData.getRootItems(this);
        end
    end

    methods(Access={?slreq.data.Requirement,?slreq.data.ReqData,?slreq.internal.ProfileReqType})
        function setDirty(this,value)
            if this.modelObject.dirty~=value
                this.modelObject.dirty=value;
                if value
                    this.reqData.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('ReqSetDirtied',this));
                else

                    [reqs,refs,just]=this.getItems();
                    reqObjs=[reqs,refs,just];
                    for i=1:length(reqObjs)
                        reqObjs(i).setDirty(false);
                    end

                    this.reqData.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('ReqSetUndirtied',this));
                end
            end
        end

        function dirtySlxModel(this)
            if~isempty(this.modelObject.parent)
                dirtySlxModelHelper(this.modelObject.parent);
            end
        end
    end

    methods(Access=?slreq.data.ReqData)

        function updateModificationInfoForDirtyItems(this)

            [mwReqs,extReqs,~]=this.getItems();
            reqObjs=[mwReqs,extReqs];
            for i=1:length(reqObjs)
                req=reqObjs(i);
                if req.dirty
                    req.updateRevisionInfo(this);
                end
            end
        end
    end
end

function dirtySlxModelHelper(slxFile)
    [~,mdlName]=fileparts(slxFile);






    if dig.isProductInstalled('Simulink')&&bdIsLoaded(mdlName)
        mdlHandle=get_param(mdlName,'Handle');

        mdlLocked=~rmisl.isUnlocked(mdlHandle,0);
        if mdlLocked
            Simulink.harness.internal.setBDLock(mdlHandle,false);
            cobj=onCleanup(@()Simulink.harness.internal.setBDLock(mdlHandle,true));
        end
        set_param(mdlName,'Dirty','on');
    end
end
