classdef LinkSet<slreq.data.BaseSet






















    properties(Access=private)
        reqData;
    end


    properties(GetAccess=public,SetAccess={?slreq.data.Link,?slreq.analysis.ChangeTrackingVisitor})


        changedSource;
        changedDestination;
        numberOfChangedSource;
        numberOfChangedDestination;
        changeStatus=slreq.analysis.ChangeStatus.Undecided;
    end


    properties(Dependent)
description
filepath
        MATLABVersion;
    end


    properties(Dependent,GetAccess=public,SetAccess=private)
name
artifact
domain
dirty
CustomAttributeNames
    end

    methods(Access=?slreq.data.ReqData)



        function this=LinkSet(modelObject)
            this.modelObject=modelObject;
            this.reqData=slreq.data.ReqData.getInstance();
            this.resetChangeInfo;
        end
    end

    methods(Access={?slreq.analysis.ChangeTrackingVisitor})


        function resetChangeInfo(this)
            this.changedSource=containers.Map('keyType','char','valueType','logical');
            this.changedDestination=containers.Map('keyType','char','valueType','logical');
        end


        function addChangedSource(this,linkUuid)
            if~isKey(this.changedSource,linkUuid)
                this.changedSource(linkUuid)=true;
            end
        end

        function addChangedDestination(this,linkUuid)
            if~isKey(this.changedDestination,linkUuid)
                this.changedDestination(linkUuid)=true;
            end
        end

        function removeChangedSource(this,linkUuid)
            if isKey(this.changedSource,linkUuid)
                this.changedSource.remove(linkUuid);
            end
        end

        function removeChangedDestination(this,linkUuid)
            if isKey(this.changedDestination,linkUuid)
                this.changedDestination.remove(linkUuid);
            end
        end

        function updateChangedLink(this,dataLink)
            linkUuid=dataLink.getUuid;

            if dataLink.sourceChangeStatus.isFail
                this.addChangedSource(linkUuid);
            else
                this.removeChangedSource(linkUuid);
            end

            if dataLink.destinationChangeStatus.isFail
                this.addChangedDestination(linkUuid);
            else
                this.removeChangedDestination(linkUuid);
            end
        end

        function updateChangeInfo(this)
            allDataLink=this.getAllLinks;
            for index=1:length(allDataLink)
                cDataLink=allDataLink(index);
                this.updateChangedLink(cDataLink);
            end
        end
    end

    methods

        function dirty=get.dirty(this)
            dirty=this.modelObject.dirty;
        end

        function name=get.name(this)
            if slreq.utils.isEmbeddedLinkSet(this.filepath)
                [~,name]=fileparts(this.artifact);
            else
                name=this.modelObject.name;
            end
        end

        function names=get.CustomAttributeNames(this)

            registry=this.reqData.getCustomAttributeRegistries(this);
            names=registry.keys();
        end

        function set.name(this,value)
            if~ischar(value)||isempty(value)
                rmiut.warnNoBacktrace('Slvnv:slreq:NeedValidString');
                return;
            end
            if strcmp(this.name,value)
                return;
            end

            if~this.checkLicense(this.modelObject.artifactUri)
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            [~,fname,~]=fileparts(value);
            this.modelObject.name=fname;


            [fpath,~,fext]=fileparts(this.modelObject.filepath);
            this.modelObject.filepath=fullfile(fpath,[fname,fext]);

            this.modelObject.dirty=true;
        end

        function set.filepath(this,value)



            this.modelObject.filepath=value;
            this.modelObject.dirty=true;
        end

        function value=get.MATLABVersion(this)
            value=this.modelObject.MATLABVersion;
        end

        function setProperty(this,propName,propValue)

            setProperty@slreq.data.AttributeOwner(this,propName,propValue);
            this.setDirty(true);
        end


        function value=get.numberOfChangedSource(this)
            value=double(this.changedSource.Count);
        end


        function value=get.numberOfChangedDestination(this)
            value=double(this.changedDestination.Count);
        end


        function value=get.changedSource(this)
            value=this.changedSource;
        end


        function value=get.changedDestination(this)
            value=this.changedDestination;
        end

        function accept(this,visitor)
            visitor.visitLinkSet(this);
        end

        function allLinkedItems=moveArtifact(this,newArtifactPath,asVersion)






            if nargin<3
                asVersion='';
            end

            srcUri=this.modelObject.artifactUri;
            srcDomain=this.modelObject.domain;
            [~,origUriShortName]=fileparts(srcUri);
            origName=this.modelObject.name;
            origFilepath=this.modelObject.filepath;


            this.modelObject.artifactUri=newArtifactPath;
            this.modelObject.dirty=true;
            [~,newArthifactShortName,newExt]=fileparts(newArtifactPath);
            if~strcmp(origName,'_linkset')

                this.modelObject.name=newArthifactShortName;
                linkFilePath=rmimap.StorageMapper.getInstance.getStorageFor(newArtifactPath,asVersion);
                this.modelObject.filepath=linkFilePath;
            end


            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(srcDomain);
            isImplementingSaveAs=adapter.isImplementingSaveAs();
            if isImplementingSaveAs

                adapter.postSaveAsReset(newArthifactShortName);
            end


            allLinkedItems=this.getLinkedItems();
            itemsWithSelfLinks={};
            for i=1:numel(allLinkedItems)
                sourceItem=allLinkedItems(i);
                sourceItemHasSelfLinks=false;



                if isImplementingSaveAs
                    adapter.postSaveAsUpdate(sourceItem);
                end



                myLinks=sourceItem.getLinks();
                for j=1:numel(myLinks)
                    dataLink=myLinks(j);


                    if~strcmp(dataLink.destDomain,srcDomain)
                        continue;
                    end
                    storedDestUri=dataLink.getStoredDestUri();
                    [~,origDestShortUri]=fileparts(storedDestUri);
                    if any(strcmp(origDestShortUri,{'_SELF',origUriShortName}))
                        sourceItemHasSelfLinks=true;

                        dataLink.destUri=[newArthifactShortName,newExt];


                        if~contains(dataLink.getStoredDescription(),'_SELF')
                            dataLink.description=...
                            adapter.updateLabelOnArtifactRename(dataLink.description,origUriShortName,newArthifactShortName);
                        end


                        if isImplementingSaveAs
                            adapter.postSaveAsUpdate(dataLink);
                        end
                    end
                end
                if sourceItemHasSelfLinks
                    itemsWithSelfLinks{end+1}=sourceItem;%#ok<AGROW>


                end
            end

            if isImplementingSaveAs
                adapter.postSaveAsReset('');
            end

            if~isempty(itemsWithSelfLinks)

                this.reqData.updateAllLinkDestinations(this);



                for i=1:length(itemsWithSelfLinks)
                    updatedItem=itemsWithSelfLinks{i};
                    adapter.refreshLinkOwner(newArtifactPath,updatedItem.id,[],[]);
                end
            end
            if slreq.internal.isSharedSlreqInstalled()


                lsm=slreq.linkmgr.LinkSetManager.getInstance;
                if reqmgt('rmiFeature','LSMNoJava')
                    lsm.onLinkSetSaveAs(this,origFilepath,newArtifactPath,srcDomain);
                else
                    lsm.onLinkSetSaveAs(this,srcUri,newArtifactPath,srcDomain);
                end
            end
        end

        function initialChangeNotify(this)



            filePath=this.modelObject.filepath;
            [~,base,ext]=fileparts(filePath);
            if~exist(filePath,'file')
                try
                    if strcmpi(this.modelObject.domain,'linktype_rmi_simulink')
                        [~,modelName,modelExt]=fileparts(this.modelObject.artifactUri);

                        if~is_writeable_file_path(filePath)





                            modelH=get_param(modelName,'Handle');
                            msgBody=message('Slvnv:slreq:LinkFileNotWritable',modelName,filePath);
                            rmisl.notify(modelH,msgBody);


                        else

                            modelH=get_param(modelName,'Handle');
                            if slreq.utils.isEmbeddedLinkSet(this)
                                msgBody=message('Slvnv:slreq:LinkFileToBeEmbedded',[modelName,modelExt]);
                            else
                                msgBody=message('Slvnv:slreq:LinkFileToBeCreated',modelName,[base,ext]);
                            end
                            rmisl.notify(modelH,msgBody);
                        end
                    elseif strcmpi(this.modelObject.domain,'linktype_rmi_matlab')
                        [~,srcFileName]=fileparts(this.modelObject.artifactUri);
                        if~contains(filePath,matlabroot)&&~is_writeable_file_path(filePath)
                            error(message('Slvnv:slreq:LinkFileNotWritable',srcFileName,filePath));
                        elseif isempty(this.modelObject.description)
                            this.modelObject.description=getString(message('Slvnv:slreq:LinkSetForMFile'));
                        end
                    end
                catch Mx %#ok<NASGU>
                end
            end
        end


        function updateLinksFileLocation(this,newFilePath)
            origFilePath=this.filepath;
            if~strcmp(origFilePath,newFilePath)

                this.modelObject.filepath=newFilePath;
                [~,newName]=fileparts(newFilePath);
                this.modelObject.name=newName;
                this.setDirty(true);


                if slreq.utils.isEmbeddedLinkSet(origFilePath)

                    if exist(origFilePath,'file')==2
                        delete(origFilePath);
                        slreq.utils.setPackageDirty(this.modelObject.artifactUri);
                    end
                elseif slreq.utils.isEmbeddedLinkSet(newFilePath)

                    if exist(origFilePath,'file')==2
                        movefile(origFilePath,[origFilePath,'.bak']);
                    end
                end
            end
        end

        function updateEmbeddedLinksetLocation(this,newPath)
            if slreq.utils.isEmbeddedLinkSet(newPath)



                wasDirty=this.dirty;
                [~,artifactName,fext]=fileparts(this.artifact);
                switch fext
                case '.slx'
                    try
                        unpackedLocation=get_param(artifactName,'UnpackedLocation');
                    catch ex
                        if strcmp(ex.identifier,'Simulink:Commands:InvSimulinkObjectName')
                            rmiut.warnNoBacktrace('Slvnv:slreq:ModelRenamedOutsideSimulink',artifactName);



                            if isempty(this.reqData.getLinkSet(bdroot))
                                unpackedLocation=get_param(bdroot,'UnpackedLocation');
                                this.moveArtifact(get_param(bdroot,'FileName'));
                            else
                                return;
                            end
                        else
                            rethrow(ex);
                        end
                    end
                    [~,linksetPart]=slreq.utils.getEmbeddedLinksetName();
                    currentLinksetFilePath=fullfile(unpackedLocation,linksetPart);
                otherwise

                    error('LinkSet.updateEmbeddedLinksetLocation() is not applicable for artifacts of type %s',fext);
                end
                this.modelObject.filepath=currentLinksetFilePath;
                this.setDirty(wasDirty);
            end
        end

        function success=embed(this)
            success=false;

            [~,~,aExt]=fileparts(this.artifact);
            if~strcmp(aExt,'.slx')
                rmiut.warnNoBacktrace('Slvnv:slreq:EmbedCalledForWrongSource','LinkSet.embed()');
                return;
            end
            linksetPartName=slreq.utils.getEmbeddedLinksetName();
            if~strcmp(this.name,linksetPartName)
                this.name=linksetPartName;
                this.save();
                success=true;
            end
        end

        function name=get.filepath(this)
            name=this.modelObject.filepath;
        end

        function path=get.artifact(this)
            path=this.modelObject.artifactUri;
        end

        function type=get.domain(this)
            type=this.modelObject.domain;
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




        function result=save(this,newFilePath,asVersion,artifactUri)

            isRename=false;

            origDirty=this.modelObject.dirty;
            origName=this.modelObject.name;
            origFilePath=this.modelObject.filepath;

            if nargin<3
                asVersion='';
            end

            if nargin<4
                artifactUri='';
            end

            if nargin>1


                if~isempty(asVersion)&&contains(newFilePath,'~')
                    newFilePath=regexprep(newFilePath,'~\w*\.slmx$','.slmx');
                end


                [dName,~,fExt]=fileparts(newFilePath);
                if isempty(fExt)
                    newFilePath=[newFilePath,'.slmx'];
                end
                if isempty(dName)
                    newFilePath=fullfile(pwd,newFilePath);
                end




                if~strcmp(newFilePath,origFilePath)&&isempty(asVersion)
                    this.updateLinksFileLocation(newFilePath);
                    isRename=true;
                end
            else



            end



            if origDirty
                this.updateRegisteredReqSets();
            end

            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(this.domain);
            if~isempty(adapter)
                adapter.preSave(this);
            end

            if~isempty(asVersion)


                this.modelObject.dirty=origDirty;
                result=this.exportToPrevious(newFilePath,asVersion,artifactUri);
            else
                result=this.reqData.saveLinkSet(this);
            end

            if result
                if~isempty(adapter)
                    adapter.postSave(this,artifactUri);
                end
                if slreq.utils.isEmbeddedLinkSet(this)



                elseif isRename


                    [aPath,aName]=fileparts(this.modelObject.artifactUri);
                    [nPath,nName]=fileparts(newFilePath);
                    if~strcmp(aPath,nPath)||~strcmp(aName,nName)

                        rmimap.StorageMapper.getInstance.set(this.modelObject.artifactUri,newFilePath);
                    else

                        rmimap.StorageMapper.getInstance.forget(this.modelObject.artifactUri,true);
                    end
                end

            else

                if isRename
                    this.modelObject.filepath=origFilePath;
                    this.modelObject.name=origName;
                    this.modelObject.dirty=origDirty;
                end
            end
        end


        function result=exportToPrevious(this,newFilePath,asVersion,newArtifactUri)








            if nargin<4
                newArtifactUri='';
            end
            tempToDelete='';
            if exist(this.filepath,'file')~=2

                tempToDelete=this.filepath;
                if is_writeable_file_path(this.filepath)

                    this.reqData.saveLinkSet(this);
                else

                    modelName='';
                    if strcmpi(this.modelObject.domain,'linktype_rmi_simulink')
                        [~,modelName]=fileparts(this.modelObject.artifactUri);
                    end



                    rmiut.warnNoBacktrace('Slvnv:slreq:LinkFileNotExportable',modelName);
                    result=false;
                    return;
                end
            end




            mfClonedLinkSet=this.reqData.cloneLinkSet(this);


            if~isempty(tempToDelete)
                delete(tempToDelete);
            end

            if~isempty(mfClonedLinkSet)



                mfClonedLinkSet.filepath=newFilePath;




                dataClonedLinkSet=slreq.data.ReqData.getWrappedObj(mfClonedLinkSet);





                if isempty(newArtifactUri)
                    [~,~,aExt]=fileparts(mfClonedLinkSet.artifactUri);
                    [newDir,newBaseName]=fileparts(newFilePath);
                    newArtifactUri=fullfile(newDir,[newBaseName,aExt]);
                end

                dataClonedLinkSet.moveArtifact(newArtifactUri,asVersion);


                mfClonedLinkSet.filepath=newFilePath;


                result=this.reqData.saveLinkSetRaw(mfClonedLinkSet,asVersion);


                dataClonedLinkSet.discard();
            else

                result=false;
            end
        end

        function discard(this)
            this.reqData.discardLinkSet(this);
        end

        function link=addLink(this,src,linkInfo,linkType)
            if~this.checkLicense(this.modelObject.artifactUri)
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if nargin<4
                linkType='';
            end
            link=this.reqData.addLink(this,src,linkInfo,linkType);
            link.updateRevisionInfo(this);
            this.setDirty(true);
        end

        function uuid=removeLink(this,link)
            if~this.checkLicense(this.modelObject.artifactUri)
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            uuid=this.reqData.removeLink(link);
            this.setDirty(true);
        end

        function items=getLinkedItems(this,varargin)
            items=this.reqData.getLinkedItems(this,varargin{:});
        end

        function items=getAllLinks(this,varargin)
            items=this.reqData.getAllLinks(this,varargin{:});
            if~isempty(items)&&rmi.isInstalled()




                adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(this.domain);
                isHidden=adapter.isHiddenLink(items);
                if any(isHidden)
                    items=items(~isHidden);
                end
            end
        end

        function item=getLinkedItem(this,itemId)
            item=this.reqData.getLinkSetItem(this,itemId);
        end

        function links=getLinks(this,source)
            if isa(source,'slreq.data.SourceItem')
                links=source.getLinks();
            else
                links=this.reqData.getOutgoingLinks(source);
            end
        end

        function link=getLinkFromID(this,sid)



            link=this.reqData.getLinkFromID(this,sid);
        end

        function textItem=getTextItem(this,id)
            textItem=this.reqData.getTextItem(this,id);
        end

        function textItemIds=getTextItemIds(this)
            textItemIds=this.reqData.getTextItemIds(this);
        end

        function drlinks=getDirectLinks(this)
            drlinks=slreq.data.Link.empty();
            linkedItems=this.getLinkedItems();
            for n=1:numel(linkedItems)
                links=this.getLinks(linkedItems(n));
                for m=1:length(links)
                    link=links(m);
                    if~strcmp(link.destDomain,'linktype_rmi_slreq')
                        drlinks(end+1)=link;%#ok<AGROW>
                    end
                end
            end
        end

        function tf=hasDirectLinks(this)


            tf=false;
            linkedItems=this.getLinkedItems();
            for n=1:numel(linkedItems)
                links=this.getLinks(linkedItems(n));
                for m=1:length(links)
                    link=links(m);
                    if~strcmp(link.destDomain,'linktype_rmi_slreq')
                        tf=true;

                        return;
                    end
                end
            end
        end

        function[convertCount,unresolvedCount]=redirectLinksToImportedContent(this,reqSetObj,showInfo)
            if nargin<3
                showInfo=false;
            end

            directLinks=this.getDirectLinks();

            convertCount=0;
            unresolvedCount=0;

            for idx=1:numel(directLinks)
                link=directLinks(idx);

                destDomain=link.destDomain;
                artifactId=link.destId;
                if any(strcmp(destDomain,{'linktype_rmi_doors','linktype_rmi_oslc'}))

                    doc=strtok(link.destUri);
                    if artifactId(1)=='#'
                        artifactId(1)=[];
                    end
                else
                    doc=link.destUri;
                end


                group=this.reqData.findGroupInReqSet(reqSetObj,doc,destDomain);
                if~isempty(group)
                    proxyReq=[];

                    proxyReqs=group.items{artifactId};

                    if~isempty(proxyReqs)

                        proxyReq=this.reqData.getWrappedObj(proxyReqs(1));
                    end
                    if~isempty(proxyReq)

                        this.reqData.updateLinkDestinationToProxy(link,proxyReq);
                        convertCount=convertCount+1;
                    else

                        unresolvedCount=unresolvedCount+1;
                    end
                end
            end

            if(convertCount>0)

                this.save();

                this.reqData.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('ReqSetRegUpdated',this));
            end

            if showInfo
                slreq.utils.showLinkConversionSummary(convertCount,unresolvedCount);
            end
        end

        function textItem=addTextItem(this,id,content)
            if~this.checkLicense(this.modelObject.artifactUri)
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            textItem=this.reqData.addTextItem(this,id,content);
            this.setDirty(true);
        end

        function content=serialize(this)
            serializer=mf.zero.io.XmlSerializer;
            content=serializer.serializeToString(this.modelObject);
        end

        function reqSetsNames=getDependeeReqSets(this,activeOnly)






            allLinks=this.getAllLinks();
            if activeOnly
                destReqSets=containers.Map('KeyType','char','ValueType','logical');
                for i=1:numel(allLinks)
                    myLink=allLinks(i);

                    linkDest=myLink.dest;
                    if~isempty(linkDest)
                        if strcmp(myLink.destDomain,'linktype_rmi_slreq')
                            reqSet=linkDest.getReqSet();
                            if~isempty(reqSet)&&~isKey(destReqSets,reqSet.name)
                                destReqSets(reqSet.name)=true;
                            end
                        end
                    end
                end
                reqSetsNames=destReqSets.keys;
            else

                destUris=containers.Map('KeyType','char','ValueType','logical');
                for i=1:numel(allLinks)
                    myLink=allLinks(i);
                    if~isKey(destUris,myLink.destUri)&&strcmp(myLink.destDomain,'linktype_rmi_slreq')
                        destUris(myLink.destUri)=true;
                    end
                end
                reqSetsNames=destUris.keys;
            end
        end

        function reqSetObjs=getDependeeReqSetObjecs(this)
            uuids=containers.Map('KeyType','char','ValueType','logical');
            reqSetObjs=slreq.data.RequirementSet.empty();
            linkedItems=this.getLinkedItems();
            for i=1:numel(linkedItems)
                myLinks=linkedItems(i).getLinks();
                for j=1:numel(myLinks)
                    myLink=myLinks(j);
                    if strcmp(myLink.destDomain,'linktype_rmi_slreq')
                        linkDest=myLink.dest;
                        if~isempty(linkDest)
                            myReqSet=linkDest.getReqSet;
                            myUuid=myReqSet.getUuid;
                            if~isKey(uuids,myUuid)
                                reqSetObjs(end+1)=myReqSet;%#ok<AGROW>
                                uuids(myUuid)=true;
                            end
                        end
                    end
                end
            end
        end

        function reqSetNames=getUnsavedDependeeReqSets(this)

            reqSetNames=this.getDependeeReqSets(true);
            for i=length(reqSetNames):-1:1
                reqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetNames{i});
                if isempty(reqSet)||~reqSet.dirty
                    reqSetNames(i)=[];
                end
            end
        end

        function conns=getConnectors(this)
            conns=this.reqData.getConnectors(this);
        end

        function[regReqSetFiles,regReqSetUuids]=getRegisteredRequirementSets(this)
            [regReqSetFiles,regReqSetUuids]=this.getRegisteredReqSetsRaw();


            linkSetLocation=fileparts(this.filepath);
            for n=1:length(regReqSetFiles)
                regReqSetFiles{n}=slreq.uri.ResourcePathHandler.validatePath(regReqSetFiles{n},linkSetLocation);
            end
        end

        function updateRegisteredReqSet(this,rSetUuid,rSetPath,wasMoved)
            if nargin<4
                wasMoved=true;
            end

            [regReqSetFiles,regReqSetUuids]=this.getRegisteredReqSetsRaw();
            isMatch=strcmp(regReqSetUuids,rSetUuid);
            if any(isMatch)
                matchedIdx=find(isMatch);
                if wasMoved
                    preferredPath=slreq.uri.getPreferredPath(rSetPath,this.filepath);
                else

                    [~,newName]=fileparts(rSetPath);
                    [~,rName]=fileparts(regReqSetFiles{matchedIdx});
                    preferredPath=strrep(regReqSetFiles{matchedIdx},[rName,'.slreqx'],[newName,'.slreqx']);
                end
                this.modelObject.registeredReqSetFiles.removeAt(matchedIdx);
                this.modelObject.registeredReqSetUuids.removeAt(matchedIdx);
                this.modelObject.registeredReqSetFiles.insertAt(preferredPath,matchedIdx);
                this.modelObject.registeredReqSetUuids.insertAt(rSetUuid,matchedIdx);
                assert(this.modelObject.registeredReqSetUuids.Size==this.modelObject.registeredReqSetFiles.Size);
            end
        end

        function addRegisteredRequirementSet(this,rSetObj)



            if strcmp(rSetObj.filepath,this.modelObject.artifactUri)
                return;
            end

            expectedStoredPath=slreq.uri.getPreferredPath(rSetObj.filepath,this.modelObject.artifactUri);

            [origReqSetRegs,origUuids]=this.getRegisteredReqSetsRaw();

            if isempty(origReqSetRegs)
                this.initialChangeNotify();
            end

            idxUuid=find(ismember(origUuids,rSetObj.getUuid),1);
            idxReqSet=find(ismember(origReqSetRegs,expectedStoredPath),1);
            if~isempty(idxUuid)



















                if strcmp(origReqSetRegs{idxUuid},expectedStoredPath)


                    return;
                else

                    [oDir,oName]=fileparts(origReqSetRegs{idxUuid});
                    [~,eName]=fileparts(expectedStoredPath);
                    if isempty(oDir)&&strcmp(oName,eName)
                        return;
                    end



                    if rmiut.isCompletePath(expectedStoredPath)...
                        ||exist(expectedStoredPath,'file')==0
                        this.modelObject.registeredReqSetFiles(idxUuid)=...
                        slreq.internal.LinkUtil.makeReqSetRegisterPath(rSetObj,[eName,'.slreqx']);
                    else


                        this.modelObject.registeredReqSetFiles(idxUuid)=...
                        slreq.internal.LinkUtil.makeReqSetRegisterPath(rSetObj,expectedStoredPath);
                    end




                end
            elseif~isempty(idxReqSet)




                this.modelObject.registeredReqSetUuids(idxReqSet)=rSetObj.getUuid;
            else
                if~this.checkLicense(this.modelObject.artifactUri)
                    error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
                end

                this.modelObject.registeredReqSetUuids.add(rSetObj.getUuid);
                regPath=slreq.internal.LinkUtil.makeReqSetRegisterPath(rSetObj,expectedStoredPath);
                this.modelObject.registeredReqSetFiles.add(regPath);
                this.modelObject.dirty=true;
            end
            assert(this.modelObject.registeredReqSetUuids.Size==this.modelObject.registeredReqSetFiles.Size);
        end

        function removeRegisteredRequirementSet(this,reqSetName)


            if~this.checkLicense(this.modelObject.filepath)
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            allReqSetFileNames=this.modelObject.registeredReqSetFiles.toArray;
            [~,nameNoExt,ext]=fileparts(reqSetName);
            if isempty(ext)

                reqSetName=[reqSetName,'.slreqx'];
            end
            match=ismember(allReqSetFileNames,reqSetName)|...
            ismember(allReqSetFileNames,nameNoExt);
            if any(match)
                idx=find(match);

                this.modelObject.registeredReqSetUuids.removeAt(idx);
                this.modelObject.registeredReqSetFiles.removeAt(idx);
                this.modelObject.dirty=true;
                assert(this.modelObject.registeredReqSetUuids.Size==this.modelObject.registeredReqSetFiles.Size);
            end
        end

        function updateRegisteredReqSets(this,clearUnloaded)






            if nargin==1
                clearUnloaded=false;
            end




















            if~clearUnloaded

                reqSetObjs=this.getDependeeReqSetObjecs();
                for n=1:length(reqSetObjs)
                    this.addRegisteredRequirementSet(reqSetObjs(n));
                end
            else






                registeredReqSetFilesStored=this.modelObject.registeredReqSetFiles.toArray;

                dependeeReqSets=this.getDependeeReqSets(false);

                for n=1:length(registeredReqSetFilesStored)
                    thisReqSetPath=registeredReqSetFilesStored{n};
                    if~ismember(thisReqSetPath,dependeeReqSets)

                        this.removeRegisteredRequirementSet(thisReqSetPath);
                    end
                end
            end
        end

        function tf=isArtifactLoaded(this)
            tf=slreq.utils.isArtifactLoaded(this.modelObject.artifactUri,this.modelObject.domain);
        end

        function updateAllLinkDestinations(this)
            this.reqData.updateAllLinkDestinations(this);
        end

        function[updateCount,linkCount,srcCount]=updateDocUri(this,origPattern,newPattern)

            if origPattern(1)=='~'
                origPattern=origPattern(2:end);
                useRegexp=true;
            else
                useRegexp=false;
                if ispc
                    origPattern(origPattern==filesep)='/';
                    newPattern(newPattern==filesep)='/';
                end
            end
            srcPath=this.artifact;
            updateCount=0;
            linkCount=0;
            srcCount=0;
            linkedItems=this.getLinkedItems();
            for i=1:numel(linkedItems)
                srcCount=srcCount+1;
                links=linkedItems(i).getLinks();
                for j=1:numel(links)
                    linkCount=linkCount+1;
                    link=links(j);
                    destUri=link.destUri;
                    if ispc


                        destUri(destUri==filesep)='/';
                    end
                    if useRegexp&&~isempty(regexp(destUri,origPattern,'once'))
                        link.destUri=regexprep(destUri,origPattern,newPattern);
                    elseif~useRegexp&&contains(destUri,origPattern)
                        link.destUri=strrep(destUri,origPattern,newPattern);
                    else
                        continue;
                    end
                    this.reqData.updateReference(link,srcPath);
                    updateCount=updateCount+1;
                end
            end
            if updateCount>0


                this.setDirty(true);
            end
        end

        function[numChecked,numAdded,numRemoved]=updateBacklinks(this)







            [numChecked,numAdded,numRemoved]=slreq.backlinks.updateForLinkset(this);
        end





        function[numChanges,exMessage,changelog]=synchronize(this,tempLinkSet)

            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            exMessage='';
            changelog='';

            alluuids=cell(1,0);
            parentids=cell(1,0);

            try



                mfChangeSet=this.modelObject.synchronize(tempLinkSet.modelObject);

                changes=mfChangeSet.changes.toArray();
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


                    case 'slreq.datamodel.DeletionChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>


                    case 'slreq.datamodel.MoveChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>


                    case 'slreq.datamodel.OrderingChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>


                    case 'slreq.datamodel.UpdateChange'
                        changelog=[changelog,change.toString(),newline];%#ok<AGROW>
                    end
                end



                mfChangeSet.destroy();

            catch ex







                numChanges=-1;


                exMessage=ex.message;
            end


            if numChanges>0



                this.reqData.doneChanging(alluuids,parentids);
            end






            if numChanges>=0
                this.setDirty(true);
            end


            tempLinkSet.setDirty(false);


        end

        function importProfile(this,profileName)
            if reqmgt('rmiFeature','SupportProfile')
                this.reqData.importProfile(this,profileName);
                this.setDirty(true);
            end
        end

        function tf=removeProfile(this,profile)
            tf=slreq.data.ReqData.getInstance.removeProfile(this.modelObject,profile);
        end

        function profiles=getAllProfiles(this)
            profiles=slreq.data.ReqData.getInstance.getAllProfiles(this.modelObject);
        end

        function stereotypes=getAllStereotypes(this,bUsePropertyName)
            if nargin<2
                bUsePropertyName=false;
            end
            stereotypes=slreq.data.ReqData.getInstance.getAllStereotypes(this.modelObject,bUsePropertyName);
        end

        function textRange=getTextRangeById(this,rangeId)

            if any(rangeId=='~')
                [rangeId,textId]=slreq.utils.getShortIdFromLongId(rangeId);
            else
                textId='';
            end
            textItem=this.getTextItem(textId);
            textRange=textItem.getRange(rangeId);
        end

        function textRanges=getTextRanges(this,textId,lines)
            if nargin<2
                textId='';
            end
            if nargin<3
                lines=[];
            end
            textRanges=slreq.data.TextRange.empty();
            dataTextItem=this.getTextItem(textId);
            if~isempty(dataTextItem)
                dataRanges=dataTextItem.getRanges();
                for i=1:numel(dataRanges)
                    oneRange=dataRanges(i);
                    if isempty(lines)
                        textRanges(end+1)=oneRange;%#ok<AGROW> 
                    else


                        rangeLines=oneRange.startLine:oneRange.endLine;
                        wantedLines=lines(1):lines(end);
                        if any(ismember(rangeLines,wantedLines))
                            textRanges(end+1)=oneRange;%#ok<AGROW> 
                        end
                    end
                end
            end
        end

        function textRange=createTextRange(this,textId,lines)
            textItem=this.getTextItem(textId);
            if isempty(textItem)
                if isempty(textId)
                    content=rmiml.getText(this.artifact);
                else
                    [~,mName]=fileparts(this.artifact);
                    content=rmiml.getText([mName,textId]);
                end
                textItem=this.addTextItem(textId,content);
                isNewParent=true;
            else
                isNewParent=false;
            end
            rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
            editorId=textItem.getEditorId();
            firstChar=rangeHelper.lineNumberToCharPosition(editorId,lines(1),1);
            lastChar=rangeHelper.lineNumberToCharPosition(editorId,lines(end),-1);
            if isNewParent
                existingRange=[];
            else
                existingRange=textItem.getRange([firstChar,lastChar]);
            end
            if isempty(existingRange)
                textRange=textItem.addTextRange([firstChar,lastChar]);
                this.setDirty(true);

                rmiml.notifyEditor(editorId,textRange.id);
            else
                rangeString=sprintf('%d-%d',lines(1),lines(end));
                error(message('Slvnv:slreq_objtypes:TextRangeExists',rangeString,editorId));
            end
        end

    end

    methods(Access={...
        ?slreq.data.Link,...
        ?slreq.data.SourceItem,...
        ?slreq.data.TextItem,...
        ?slreq.data.ReqData,...
        ?slreq.data.Markup,...
        ?slreq.data.Connector})

        function setDirty(this,value)
            if this.modelObject.dirty==value
                return;
            else
                this.modelObject.dirty=value;
            end

            if value

                if slreq.utils.isEmbeddedLinkSet(this)

                    slreq.utils.setPackageDirty(this.artifact);
                end
                this.reqData.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('LinkSetDirtied',this));
                if slreq.internal.isSharedSlreqInstalled()
                    slreq.internal.Events.getInstance.notify('LinkSetDirtied',slreq.internal.LinkSetEventData(this));
                end
            else


                items=this.getLinkedItems();
                for i=1:numel(items)
                    links=items(i).getLinks();
                    for j=1:numel(links)
                        links(j).setDirty(false);
                    end
                end
                this.reqData.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('LinkSetUnDirtied',this));
                if slreq.internal.isSharedSlreqInstalled()
                    slreq.internal.Events.getInstance.notify('LinkSetUnDirtied',slreq.internal.LinkSetEventData(this));
                end
            end
        end

    end

    methods(Access=?slreq.data.ReqData)
        function updateModificationInfoForDirtyItems(this)

            linkedItems=this.getLinkedItems();
            for i=1:numel(linkedItems)
                myLinks=linkedItems(i).getLinks();
                for j=1:numel(myLinks)
                    if myLinks(j).dirty
                        myLinks(j).updateRevisionInfo(this);
                    end
                end
            end
        end
    end

    methods(Access=private)
        function[regReqSetFiles,regReqSetUuids]=getRegisteredReqSetsRaw(this)



            if this.modelObject.registeredReqSetFiles.Size==0
                regReqSetFiles={};
                regReqSetUuids={};
            else
                regReqSetFiles=this.modelObject.registeredReqSetFiles.toArray;
                regReqSetUuids=this.modelObject.registeredReqSetUuids.toArray;
            end

            idx=strcmp(regReqSetFiles,'default.slreqx')|...
            strcmp(regReqSetFiles,'clipboard.slreqx')|...
            strcmp(regReqSetFiles,'slinternal_scratchpad.slreqx');
            if any(idx)
                regReqSetFiles(idx)=[];
                regReqSetUuids(idx)=[];
            end
        end
    end
end

function out=is_writeable_file_path(fPath)



    if slreq.utils.isEmbeddedLinkSet(fPath)
        pDir=fileparts(fPath);
        if exist(pDir,'dir')==0

            [fName,partName]=slreq.utils.getEmbeddedLinksetName();
            partName=strrep(partName,'/',filesep);
            fPath=strrep(fPath,partName,[filesep,fName,'.slmx']);
        end
    end

    out=slreq.uri.isWriteable(fPath);
end



