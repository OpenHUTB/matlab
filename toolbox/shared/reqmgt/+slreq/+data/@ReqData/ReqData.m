classdef ReqData<handle





    properties(Access=private)
repository


        cutReqLinkMap;
isNotifying

mfDefaultReqSet

        isDebugging=false;



        builtinReqInfoNameMap;


        sfReqSetMap;
    end

    properties(Access=public)
model
    end

    events
ReqDataChange
LinkDataChange
    end


    methods(Access=private)


        function this=ReqData()
            this.init();
            this.isNotifying=true;
            reqmgt('init');
        end

        function init(this)
            slreq.datamodel.RequirementData.StaticMetaClass;
            this.model=slreq.cpputils.getModelInstance('#SLReqsMF0#');
            this.repository=slreq.cpputils.getRequirementDataInstance('#SLReqsMF0#');
            this.addBuiltinRequirementTypes();
            this.addBuiltinLinkTypes();
            this.getDefaultReqSet();

            this.cutReqLinkMap=containers.Map('KeyType','char','ValueType','Any');

            buildtInAttrNames={'id','summary','description','rationale',...
            'group','domain','artifactUri','artifactId',...
            'modifiedOn','modifiedBy','createdOn','createdBy','synchronizedOn',...
            'keywords','descriptionEditorType','rationaleEditorType','typeName'};
            this.builtinReqInfoNameMap=containers.Map(buildtInAttrNames,...
            true(size(buildtInAttrNames)));

            this.sfReqSetMap=containers.Map('KeyType','double','ValueType','char');
        end

    end

    methods(Access=public)
        function delete(~)
            slreq.cpputils.resetRequirementData('#SLReqsMF0#');
        end


        out=wrap(this,in)
    end


    methods(Static)

        singleObj=getInstance(init)

        result=exists()

        dataObj=getWrappedObj(modelObj)

        dataObjs=getDataObj(apiObjs)

        yesno=isMatch(item,filter)

        tf=isAncestorOf(parentArg,childArg)

        updateModificationInfo(mfobject)

        zeroType=initialTime(isClear)

        tf=isMATLABVersionBefore(thisVersion,compareToVersion);

    end

    methods(Static,Hidden)










        function out=unconfuse(in,key)
            cl=clock();
            day=cl(3);
            out=in;
            for i=1:length(in)
                j=mod(i,length(key))+1;
                diff=int32(key(j))-day;
                out(i)=char(int32(in(i))-diff);
            end
        end



        tf=shouldUpdateFilePaths(mfLinkSet,pathToArtifact,pathToLinksFile);

    end


    methods

        [content,msgId]=readOPCpackage(this,filePath)

        majorRelease=getReleaseName(this,versionNumber);

        setMATLABVersion(this,modelReqSet,asVersion);

        mfElementTypes=getMFElementTypes(this);


        objs=collectDASObjects(this,obj,includedAggs);



        linkSetObj=createLinkSet(this,artifact,domain)

        linkSetObj=loadLinkSet(this,artifact,linkSetFile,callerArtifact,forceResolveProfile)

        mfLinkSet=loadLinkSetRaw(this,linkSetFile)

        clonedLinkSet=cloneLinkSet(this,dataLinkSet)

        dataLinkSet=getLinkSet(this,artifact,varargin)

        dataLinkSet=getLinkSetByFilepath(this,filepath)

        linkSetObjs=getLoadedLinkSets(this)

        linkSet=getLoadedLinkSetByName(this,fileShortName)

        result=discardLinkSet(this,linkSet,callerArtifact)

        result=saveLinkSet(this,linkSet,asVersion)

        result=saveLinkSetRaw(this,mfLinkSet,asVersion)

        changed=refreshLinkSetsByRegistration(this,ReqSetName)

        changed=updateAllLinkDestinations(this,linkSet,loadReferencedReqsets)

        updateReference(this,linkDataObj,srcPath)



        out=isReservedReqSetName(this,name);

        name=getDefaultReqSetName(this);

        reqSetObj=createSpecialReqSet(this,name)

        setModifiedOn(this,dataReqSet,modifiedOn);


        reqSetObj=createReqSet(this,name)

        dataReqSet=createAndSaveReqSet(this,name)

        reqSet=loadReqSet(this,rsname,loadOptions,resolvePrf,prfChecker,prfNs)

        mfReqSet=loadReqSetRaw(this,rsname)

        reqSetObj=getReqSet(this,rsname)

        reqSetObj=getParentReqSet(this,reqObj)

        reqSetObjs=getLoadedReqSets(this)

        result=saveReqSet(this,reqSet,varargin)

        result=discardReqSet(this,reqSet)

        reqObjs=getRootItems(this,reqSet)

        reqObj=objectChanged(this,changedUUID)

        reqObj=addRequirement(this,parent,reqInfo)

        reqObj=addExternalRequirement(this,parent,reqInfo)

        reqObj=addRequirementAfter(this,baseObj)

        justificationObj=addJustification(this,baseObj,addType,reqInfo)

        [tf,pendingUpdateStruct]=moveRequirement(this,moveObj,location,dstObj,pendingUpdateStruct)

        forceDirtyFlag(this,dataContainer,value)

        req=getTargetRequirement(this,linkObj)

        [dasObjList,numOfDeleteDataReqs]=removeRequirement(this,requirement)


        mfSyncOptions=createSynchronizationOptions(this,options)



        rangeItem=addLinkableRange(this,linkSet,srcStruct)

        linkObj=addLink(this,linkSet,src,linkInfo,linkType)

        dataLink=cloneLink(this,dataSourceItem,dataLink)

        updateLinkDestination(this,link,newDestStruct)

        updateLinkSource(this,link,newSrcId)

        uuid=removeLink(this,link,position)

        updateLinkDestinationToProxy(this,dataLink,dataProxyReq)

        link=getLinkFromID(this,linkSet,sid)

        wasMoved=moveLink(this,link,position)

        updateTargetReference(this,link,destInfo)



        links=getOutgoingLinks(this,src)

        item=getLinkSetItem(this,linkSet,itemId)

        links=getAllLinks(this,linkSet,filter)

        sourceItems=getLinkedItems(this,linkSet,filter)

        [mwReqs,exReqs,justifications]=getItems(this,reqSet)

        req=getItemFromID(this,reqSet,sid)

        links=getIncomingLinks(this,requirement)

        tf=hasIncomingLinks(this,reqSetObj)

        disconnectIncomingLinks(this,reqSetObj)

        [inLinks,outLinks]=getLinksForNonReqItem(this,objH,linkType)



        success=setParentRequirement(this,child,parent)

        result=promote(this,req)

        result=demote(this,req)

        result=move(this,req,offset)


        [dataTextItem,mfTextItem]=addTextItem(this,dataOrMFLinkSet,id,content)

        reqObj=getRequirement(this,reqSet,numericID)

        reqs=findMatchingRequirements(this,reqSet,filters)

        object=findObject(this,uuid)

        copyRequirement(this,req,location,dstReq)



        textRange=addTextRange(this,textItem,id,range)

        success=removeTextRange(this,textItem,id)

        textItem=getTextItem(this,linkSet,id)

        uuid=removeTextItem(this,textItem)

        textItemIds=getTextItemIds(this,linkSet)



        [sourceGroups,destinationGroups]=allRootItemsInfo(this)

        [grpItems,reqSetName]=getGroupItems(this,grpName)

        req=findProxyItem(this,domain,artifactUri,artifactId,optionalSearchInDefaultReqSet)

        group=findGroupInReqSet(this,reqSet,artifactUri,domain)

        req=findExternalRequirementByArtifactUrlId(this,dataReqSet,artifactDomain,artifactUri,artifactId)

        count=updateDestUriInIncomingLinks(this,group,newDestination)

        req=getRequirementItem(this,itemIdStruct,doCreate)



        commentObj=addComment(this,reqOrLink)

        uuid=removeComment(this,review)



        connectorData=addConnector(this,linkData,isDiagram)

        removeConnectors(this,connectors)

        conns=getConnectors(this,linkSetData)

        markupData=addMarkup(this,connector)

        tf=resolveExistingMarkup(this,linkSetData,connectorData,viewOwenerId,sourceObjId)

        markups=getMarkups(this,linkSetData)



        copyReqToClipboard(this,reqObj)

        cutReqToClipboard(this,reqObj)

        pasteFromClipboard(this,destObj)

        [tf,isJustification]=hasCripboardItem(this)



        addCustomAttributeRegistry(this,reqSetObj,name,typeName,description,defaultValue,isReadOnly)

        removeCustomAttributeRegistry(this,registryToDel)

        modifyCustomAttributeRegistry(this,dataReqSet,prevName,name,typeName,description,defaultValue)

        out=isCustomAttributeRegistryInUse(this,registryToDel)

        setCustomAttribute(this,reqLink,reqLinkSet,name,value)

        attrs=getStereotypeAttributes(this,dataObj)

        setStereotypeAttribute(this,reqLink,name,value)

        deleteStereotypeAttributes(this,reqLink,names)

        renameStereotypeAttribute(this,reqLink,oldName,newName)

        attrs=getCustomAttributeRegistries(this,reqLinkSetObj)

        attrs=getCustomAttributeItems(this,reqLinkObj)

        reqSets=getReqSetsThatHaveCustomAttribute(this,attrName);


        mfLinkType=addCustomLinkType(this,typeName,superTypeName,forwardName,backwardName,description);
        mfLinktypes=getAllLinkTypes(this);
        mfLinkType=getLinkType(this,typeName);
        resolveLinkType(this,link);
        unresolveCustomLinkTypes(this);


        mfReqType=addCustomRequirementType(this,typeName,superTypeName,description);
        mfReqTypes=getAllRequirementTypes(this);
        mfReqType=getRequirementType(this,typeName);
        updated=setCallback(this,dataObj,callbackName,callbackText);
        resolveRequirementType(this,link);
        unresolveCustomRequirementTypes(this);



        setKeywords(this,reqLinkObj,givenKeywords)

        data=serialize(this,dataObj,asVersion)

        doNotify(this,state)

        doneChanging(this,uuids,parentids)

        swapSourceIds(this,artifactName,origId,newId)

        replaceSourceId(this,artifactName,origId,newId)

        reset(this,keepCustomTypes)

        group=getGroup(this,artifactUri,domain,reqSet);

        nonUniqueIds=checkUniqueCustomIds(this,dataqReqSet);


        out=addMapping(this,dataReqSet,mapping);

        out=getMapping(this,dataReqSet,mappingName);

        out=createMapping(this);

        out=loadMapping(this,filepath);

        out=saveMapping(this,mapping,filepath);

        out=getMappingDirection(this,mapping);

        out=createMapToBuiltIn(this,externalName,externalType,slreqName,slreqType);

        out=createMapToCustomAttribute(this,externalName,externalType,slreqName,slreqType,isAutoMapped);

        out=remapAttribute(this,reqSet,importNode,oldMapsTo,newMapsTo);


        mfReqIf=importReqIFTemplate(this,mf0Xml,mapping);

        [count,topNodes]=importFromReqIF(this,mf0Xml,artifactUri,dataReqSet,mapping,asReferences,asMultipleReqSets,singleSpec,importLinks,reqifzName);

        [mfReqIf,mfReqIfModel]=exportToReqIF(this,dataReqReqSet,dataRootItem,mapping);

        [mfReqIf,mfReqIfModel]=exportToReqIFTemplate(this,dataReqReqSet,dataRootItem,mfTemplate,mapping,linkOptions);

        [xml,imageFiles]=serializeReqIF(this,mfReqIf);

        out=preProcessLinksForExport(this,dataReqSet);

        out=query(this,exp);

        profile=importProfile(this,reqSet,profileName,isExisting);

        tf=removeProfile(this,mfReqLinkSet,profile);

        ret=isProfileImported(this,reqSet,profileName);

        stereotypes=getAllStereotypes(this,reqLinkSet,bUsePropertyName);

        addToSfReqSetMap(this,mdlHandle,reqSetName);

        reqSetName=getSfReqSet(this,mdlHandle);

        removeFromSfReqSetMap(this,mdlHandle);

        changed=resolveReference(this,ref,srcPath,loadReferencedReqsets)
    end

    methods(Hidden)


        countRemoved=resetCustomRequirementTypes(this);



        catalog=getCatalogFromOslcServer(this,serverLoginInfoStruct)

        out=fetchOSLCModules(this,projectInfo);

        queryBase=fetchOSLCQueryBaseURI(this,serverLoginInfoStruct,serviceUri);

        out=fetchOSLCProjectTypes(this,serverLoginInfoStruct,projectUri);

        dataReqSet=fetchOSLCRequirements(this,serverLoginInfoStruct,projectInfo,topNodeInfo,destReqSet);

        updateOSLCRequirement(this,mfItem);

        updateOSLCRequirements(this,serverLoginInfo,projUri,moduleUrlOrQueryBase,queryString,importNode);







        function setDebugMode(this,mode)
            this.isDebugging=mode;
        end
        function executeDebugCallForMethod(this,methodName,varargin)
            if this.isDebugging
                eval(['this.',methodName,'(varargin{:})']);%#ok<EVLDOT> 
            end
        end


    end


    methods(Access={?slreq.internal.ReqSetMergeWorker,?slreq.data.SLService})

        postProcessReqSet(this,reqSet);

        postProcessLinkSet(this,mfLinkset)

        setUniqueCustomId(this,group,req);

        mf0Object=parseMf0File(this,filePath,msgId,content,doRemap)

        sibling=findSibling(this,req)

        linkset=addLinkSet(this,artifact,domain)

        mfLinkSet=findLinkSet(this,artifact,varargin)

        mfLLinkSet=findLinkSetByFilepath(this,filepath)

        item=addLinkableItem(this,linkset,src)

        [item,isNew]=ensureLinkableItem(this,linkSetObj,srcStruct)

        item=findLinkableItem(this,linkset,src)

        link=createLink(this,item,linkInfo)

        link=createLinkToRequirement(this,item,requirement,linkInfo)

        ref=createReferenceToReq(this,mfReq,sourcePath)

        mfReqSet=findRequirementSet(this,rsname)

        [mfReqSet,isNewlyLoaded]=locateRequirementSet(this,storedPath,refPath,loadReferencedReqsets,embeddedPath)

        mfReqSet=addRequirementSet(this,name)

        mfReqSet=getDefaultReqSet(this)

        reqSet=getClipboardReqSet(this)

        req=createRequirement(this,reqInfo)

        req=createExternalRequirement(this,reqInfo)

        req=createJustification(this,reqInfo)

        label=makeSummary(this,artifactlabel,locationLabel)

        req=findRequirement(this,reqSet,id)

        req=searchRequirementByCustomId(this,reqSet,id)

        changed=resolveReferences(this,linkset,loadReferencedReqsets)


        changed=resolveReferenceToMwRequirement(this,ref,srcPath,loadReferencedReqsets)

        changed=resolveReferenceToExternalRequirement(this,ref,srcPath,loadReferencedReqsets)

        changed=resolveReferenceForDirectLink(this,ref,srcPath)

        unmaskSelfReference(this,reference,srcPath)

        populateReqSetUri(this,mfRef)

        group=findGroup(this,artifactUri,domain)

        group=addGroup(this,reqSet,artifactUri,domain)

        group=createGroup(this,artifactUri,domain)

        req=findExternalReq(this,group,ref)

        req=addExternalReq(this,group,reqInfo)

        modelObj=getModelObj(this,handleObj)

        filePathUpdate(this,linkSet,artifactPath,linkFilePath)

        result=findTextItem(~,linkset,id)

        textRange=addRangeItem(this,linkset,textItem,rangeId,range)

        success=removeRangeItem(this,textItemObj,id)

        recCopyChildren(this,src,dstParent,action)

        clearClipboard(this)

        tf=isHierarchicalParent(~,first,second)

        copyCustomAttributes(this,src,dst,actionType)

        setCustomAttributesForNewReq(this,mfReq,mfReqSet,reqInfo);

        maskSelfReferences(this,linkSet)

        insertReqAndNotify(this,mfReqSet,parentReq,mfReq)

        addBuiltinRequirementTypes(this);

        resolveRequirementTypesForReqSet(this,mfLinkSet);

        addBuiltinLinkTypes(this)

        modified=resolveLinkTypesForLinkSet(this,mfLinkSet);

        migrateLinkSet(this,mfLinkSet,asVersion);

        migrateReqSet(this,mfReqSet,oldName,asVersion);

        updateLinkedTimeAndVersion(this,mfLinkOrRef,mfReq,isChangeInfoSupported);



        out=fetchOSLCProjects(this,serverLoginInfoStruct);

        [mfReqSet,mfRootItem]=createOSLCReqSet(this,serverLoginInfoStruct,reqSetName,serviceName,projectInfo,topNodeInfo);

    end
end

