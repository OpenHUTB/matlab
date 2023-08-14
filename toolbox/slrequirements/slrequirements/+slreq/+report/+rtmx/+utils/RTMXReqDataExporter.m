classdef RTMXReqDataExporter<handle
    properties(Constant)
        DOMAIN_LIST={'slreq','simulink','sltest','other'};

        SUPPORTED_RMI_DOMAIN_TYPES=containers.Map({'linktype_rmi_slreq',...
        'linktype_rmi_simulink',...
        'linktype_rmi_testmgr',...
        'linktype_rmi_data',...
        'linktype_rmi_matlab'},ones(1,5));
        SRC_DEST_TO_LINK_KEY_PATTERN='%s=>%s';
        SUPPORTED_ARTIFACT_EXT=containers.Map({'.m','.slreqx','.slx','.mdl','.sldd','.mldatx'},ones(1,6));
    end

    properties
        RowArtifacts;
        ColumnArtifacts;
        ConfigFile;
        RequestedArtifactInfo;
        ArtifactList;
        DataLinkSets;
        JSONString;
        ArtifactData;
        LinkData;
        ArtifactLinkData;
        srcDestToLinkMap;
        DataToExport;
        UserTerminate=false;
        Current_Artifact_ID=1;

        TraverserCounter=0;

        MAX_COUNTER=100;

        ArtifactToRootArtifactMap;

    end

    properties


        ArtifactHierarchy;


        ArtifactItemList;


        LinkTypeInfo;

        CurrentLinkTypeInfo;


        LinkDataInfo;



        ArtifactInfo={};


ItemDetails

        ItemID2LinkData;

        CurrentLinkData;
        ArtifactToIDMap;

        CurrentProgress;
        TotalProgress;
        TotalProgressPerArtifact;
        CurrentProgressRange;
        CurrentProgressRangeItems;
        CurrentProgressItem;
        ProgressFromStartItem;
    end

    methods

        function this=RTMXReqDataExporter()

            this.ArtifactToIDMap=containers.Map('KeyType','char','ValueType','any');
            this.reset();
        end


        function out=getArtifactInfo(this,artifactFullPath)
            [filefolder,filename,fileext]=fileparts(artifactFullPath);
            out.Artifact=artifactFullPath;
            out.ArtifactPath=artifactFullPath;
            out.ArtifactExt=fileext(2:end);
            out.ArtifactName=[filename,fileext];
        end

        function reset(this)
            this.ArtifactData=containers.Map('KeyType','char','ValueType','any');
            this.ArtifactHierarchy=containers.Map('KeyType','char','ValueType','any');
            this.ArtifactItemList=containers.Map('KeyType','char','ValueType','any');
            this.ItemDetails.simulink=containers.Map('KeyType','char','ValueType','any');
            this.ItemDetails.slreq=containers.Map('KeyType','char','ValueType','any');
            this.ItemDetails.sltest=containers.Map('KeyType','char','ValueType','any');
            this.ItemDetails.other=containers.Map('KeyType','char','ValueType','any');
            this.ArtifactLinkData=containers.Map('KeyType','char','ValueType','any');
            this.LinkData=containers.Map('KeyType','char','ValueType','any');
            this.ItemID2LinkData=containers.Map('KeyType','char','ValueType','any');
            this.srcDestToLinkMap=containers.Map('KeyType','char','ValueType','any');
            this.LinkTypeInfo=containers.Map('KeyType','char','ValueType','any');
            this.CurrentLinkData=containers.Map('KeyType','char','ValueType','any');
            this.CurrentLinkTypeInfo.TypeList=containers.Map('KeyType','char','ValueType','any');
            this.CurrentLinkTypeInfo.SubTypeList=containers.Map('KeyType','char','ValueType','any');
            this.CurrentLinkTypeInfo.Type2SubTypeMap=containers.Map('KeyType','char','ValueType','any');

            this.ArtifactToRootArtifactMap=containers.Map('KeyType','char','ValueType','any');
            this.UserTerminate=false;
            this.TraverserCounter=0;

        end


        function checkStatus(this)

            drawnow();
            if this.UserTerminate
                this.reset();
                error('UserStopped');
            end
        end


        function terminateByUser(this)
            this.UserTerminate=true;
        end


        function resetProgress(this)
            this.TotalProgress=100;
            this.CurrentProgress=0;
            this.CurrentProgressRange=[0,100];
            this.TotalProgressPerArtifact=floor(100/(length(this.ArtifactList)+1));
            this.CurrentProgressItem=0;
        end

        function setProgressRangeItems(this,value)
            if value==0
                value=inf;
            end
            this.CurrentProgressRangeItems=value;
            this.CurrentProgressItem=0;
            this.ProgressFromStartItem=this.CurrentProgress;
        end

        function updateProgressByItem(this)
            if isempty(this.CurrentProgressRangeItems)||this.CurrentProgressRangeItems==0
                return;
            end
            this.CurrentProgressItem=this.CurrentProgressItem+1;
            newProgress=floor(this.ProgressFromStartItem+(this.TotalProgressPerArtifact/this.CurrentProgressRangeItems)*this.CurrentProgressItem);
            if this.CurrentProgress~=newProgress
                this.CurrentProgress=newProgress;
                this.updateProgress;
            end
        end

        function updateProgress(this,message)

            if nargin<2
                message='';
            end

            info.progressValue=this.CurrentProgress;
            info.message=message;
            slreq.report.rtmx.utils.MatrixWindow.publishUpdateProgress(info);
        end

        function out=export(this,artifactList)

            if nargin<2
                artifactList=this.ArtifactList;
            else
                this.ArtifactList=artifactList;
            end

            if isempty(this.ConfigFile)

                defaultOptions=slreq.report.rtmx.utils.getDefaultOptions();
                preSetConfig=defaultOptions.configuration;
            else
                try
                    preSetConfigInfo=load(this.ConfigFile);
                    preSetConfig=preSetConfigInfo.result.configuration;
                catch
                    defaultOptions=slreq.report.rtmx.utils.getDefaultOptions();
                    preSetConfig=defaultOptions.configuration;
                end
            end

            try
                this.reset();
                this.resetProgress()
                this.traverseAllData();
                this.CurrentProgress=this.TotalProgressPerArtifact*length(artifactList);
                this.preExport(artifactList,preSetConfig);
                this.CurrentProgress=95;
                this.updateProgress(getString(message('Slvnv:slreq_rtmx:NewMatrixDialogCreatingMatrix')));
                this.exportToJSONString();
                out=this.JSONString;
                this.CurrentProgress=100;
                this.updateProgress();
            catch ex

                rethrow(ex);
            end


        end


        function addArtifactData(this,artifactID,data)
            this.ArtifactData(artifactID)=data;
        end


        function out=getArtifactData(this,artifactID)
            if isKey(this.ArtifactData,artifactID)
                out=this.ArtifactData(artifactID);
            else
                out=[];
            end
        end


        function out=getOrCreateLinkData(this,cLink)
            linkFullID=cLink.getFullID;
            if~isKey(this.LinkData,linkFullID)
                this.LinkData(linkFullID)=slreq.report.rtmx.utils.LinkData.createLinkDataFromLink(cLink);
            end
            out=this.LinkData(linkFullID);
        end


        function addLinkToSrcArtifact(this,artifactID,linkFullID)
            artifactLinkData=this.getArtifactLinkData(artifactID);
            artifactLinkData.Src(linkFullID)=true;
            this.ArtifactLinkData(artifactID)=artifactLinkData;
        end


        function out=getArtifactLinkData(this,artifactID)
            if~isKey(this.ArtifactLinkData,artifactID)
                this.ArtifactLinkData(artifactID)=struct('Src',...
                containers.Map('KeyType','char','ValueType','any'),...
                'Dst',containers.Map('KeyType','char','ValueType','any'));
            end
            out=this.ArtifactLinkData(artifactID);
        end


        function addLinkToDstArtifact(this,artifactID,linkFullID)
            artifactLinkData=this.getArtifactLinkData(artifactID);
            artifactLinkData.Dst(linkFullID)=true;
            this.ArtifactLinkData(artifactID)=artifactLinkData;
        end


        function out=getArtifactIDFromList(this,artifactList)
            out=zeros(size(artifactList));
            for index=1:length(artifactList)
                out(index)=this.getArtifactIDFromItem(artifactList{index});
            end
        end


        function out=getArtifactIDFromItem(this,artifactFullPath)
            if~isKey(this.ArtifactToIDMap,artifactFullPath)
                this.addArtifactToMap(artifactFullPath);
            end

            out=this.ArtifactToIDMap(artifactFullPath);
        end



        function out=getArtifactID(this,artifactFullPath)
            if isempty(artifactFullPath)
                out=0;
                return;
            end

            if iscell(artifactFullPath)
                out=this.getArtifactIDFromList(artifactFullPath);
            else

                out=this.getArtifactIDFromItem(artifactFullPath);
            end
        end

        function destinationArtifactList=getDstArtifactFromSource(~,sourceArtifactList)
            destinationArtifactMap=containers.Map('keyType','char','valuetype','logical');
            reqData=slreq.data.ReqData.getInstance;
            for index=1:length(sourceArtifactList)
                cArtifactPath=sourceArtifactList{index};
                cLinkSet=reqData.getLinkSet(cArtifactPath);
                if isempty(cLinkSet)
                    continue;
                end






                allReqSets=cLinkSet.getRegisteredRequirementSets();
                for rindex=1:length(allReqSets)
                    cReqSetName=allReqSets{rindex};

                    dataReqSet=reqData.getReqSet(cReqSetName);
                    if isempty(dataReqSet)



                        cReqSetPath=which(cReqSetName);
                        if~exist(cReqSetPath,'File')
                            continue;
                        end
                    else
                        cReqSetPath=dataReqSet.filepath;
                    end

                    if~isempty(cReqSetPath)
                        destinationArtifactMap(cReqSetPath)=true;
                    end
                end

                allDirectLinks=cLinkSet.getDirectLinks;
                for lindex=1:length(allDirectLinks)
                    cLink=allDirectLinks(lindex);
                    destArtiName=cLink.destUri;

                    if slreq.report.rtmx.utils.MatrixArtifact.isSupportedArtifact(destArtiName)
                        destPath=which(destArtiName);
                        if~exist(destPath,'File')
                            continue;
                        end

                        if~isempty(destPath)
                            destinationArtifactMap(destPath)=true;
                        end
                    end
                end

            end
            destinationArtifactList=destinationArtifactMap.keys;
        end


        function sourceArtifactList=getSourceArtifactFromDestination(this,destinationArtifactList)


            reqData=slreq.data.ReqData.getInstance;
            allLinkSet=reqData.getLoadedLinkSets;
            sourceArtifactList={};

            givenArtifactIDs=1;
            hasReqSet=false;
            hasDirectLink=false;
            for index=1:length(destinationArtifactList)
                cArtifact=destinationArtifactList{index};
                [~,~,fileext]=fileparts(cArtifact);
                if strcmpi(fileext,'.slreqx')
                    hasReqSet=true;
                else
                    hasDirectLink=true;
                end

                givenArtifactIDs=this.getArtifactID(cArtifact)*givenArtifactIDs;
            end

            for index=1:length(allLinkSet)
                cLinkSet=allLinkSet(index);

                artifactFullFilePath=cLinkSet.artifact;
                if~exist(artifactFullFilePath,'File')
                    continue;
                end

                if~slreq.report.rtmx.utils.MatrixArtifact.isSupportedArtifact(artifactFullFilePath)
                    continue;
                end



                findDest=false;

                if hasReqSet
                    allReqSets=cLinkSet.getRegisteredRequirementSets();
                    for rindex=1:length(allReqSets)
                        cReqSetName=allReqSets{rindex};

                        dataReqSet=reqData.getReqSet(cReqSetName);
                        if isempty(dataReqSet)



                            cReqSetPath=which(cReqSetName);
                            if~exist(cReqSetPath,'File')
                                continue;
                            end
                        else
                            cReqSetPath=dataReqSet.filepath;
                        end

                        if~isempty(cReqSetPath)
                            cReqSetID=this.getArtifactID(cReqSetPath);

                            if mod(givenArtifactIDs,cReqSetID)==0

                                sourceArtifactList{end+1}=artifactFullFilePath;%#ok<AGROW>
                                findDest=true;
                                break;
                            end
                        end
                    end
                end


                if hasDirectLink&&~findDest
                    allDirectLinks=cLinkSet.getDirectLinks;
                    for lindex=1:length(allDirectLinks)
                        cLink=allDirectLinks(lindex);
                        destArtiName=cLink.destUri;

                        if slreq.report.rtmx.utils.MatrixArtifact.isSupportedArtifact(destArtiName)
                            destPath=which(destArtiName);
                            if~exist(destPath,'File')
                                continue;
                            end

                            if~isempty(destPath)
                                cDestID=this.getArtifactID(destPath);
                                if mod(givenArtifactIDs,cDestID)==0

                                    sourceArtifactList{end+1}=artifactFullFilePath;%#ok<AGROW>
                                    break;
                                end
                            end
                        end
                    end
                end
            end
        end
    end


    methods(Access=private)


        function traverseAllData(this)
            import slreq.report.rtmx.utils.*
            atMgr=ArtifactTraverserManager(this);
            unresolvedInfo=this.tarverseAllLinkSet();

            for artIndex=1:length(this.ArtifactList)
                artifactFullPath=this.ArtifactList{artIndex};
                atMgr.addArtifact(artifactFullPath);
                this.ArtifactToRootArtifactMap(artifactFullPath)={artifactFullPath};
                traverserInfo=atMgr.ArtifactToTraverser(artifactFullPath);

                if~traverserInfo.IsValid
                    error("Artifact Could not be found");
                end
                this.addArtifactToMap(artifactFullPath);
            end

            atMgr.traverseAll(unresolvedInfo);

            this.updateLinkTypeInfo();
        end

        function unresolvedIDLists=tarverseAllLinkSet(this)
            reqData=slreq.data.ReqData.getInstance;
            unresolvedIDLists=containers.Map('KeyType','char','ValueType','any');

            return;

            colIDList=this.getArtifactID(this.ColumnArtifacts);
            rowIDList=this.getArtifactID(this.RowArtifacts);


            for index=1:length(this.ArtifactList)
                artifact=this.ArtifactList{index};

                linkSet=reqData.getLinkSet(artifact);
                srcArtiID=this.getArtifactID(artifact);

                if~isempty(linkSet)
                    sourceItems=linkSet.getLinkedItems;













                    unresolvedIDList={};
                    unresolvedID2AsSrcMap=containers.Map;

                    for sindex=1:length(sourceItems)
                        sourceItem=sourceItems(sindex);
                        allLinks=sourceItem.getLinks;
                        if~sourceItem.isValid

                            invalidIDInScope=false;
                            allLinksAsSrc=slreq.data.Link.empty;
                            for lindex=1:length(allLinks)
                                cLink=allLinks(lindex);







                                try
                                    destFullPath=which(cLink.destUri);
                                catch


                                    continue;

                                end

                                dstArtiID=this.getArtifactID(destFullPath);

                                if(any(srcArtiID==colIDList)&&any(dstArtiID==rowIDList))||(any(srcArtiID==rowIDList)&&any(dstArtiID==colIDList))
                                    invalidIDInScope=true;

                                    destId=cLink.destId;
                                    allLinksAsSrc(end+1)=cLink;
                                    if~slreq.utils.hasValidDest(cLink)

                                        if isKey(unresolvedIDLists,destFullPath)
                                            unresolvedIDInfo=unresolvedIDLists(destFullPath);
                                        else
                                            unresolvedIDInfo.IDList=unresolvedIDList;
                                            unresolvedIDInfo.ID2LinkAsSrc=containers.Map;
                                            unresolvedIDInfo.ID2LinkAsDst=containers.Map;
                                        end

                                        unresolvedIDInfo.IDList{end+1}=destId;
                                        if isKey(unresolvedIDInfo.ID2LinkAsDst,destId)
                                            linksAsDst=unresolvedIDInfo.ID2LinkAsDst(destId);
                                        else
                                            linksAsDst=slreq.data.Link.empty;
                                        end
                                        linksAsDst(end+1)=cLink;
                                        unresolvedIDInfo.ID2LinkAsDst(destId)=linksAsDst;
                                        unresolvedIDLists(destFullPath)=unresolvedIDInfo;
                                    end
                                end

                            end

                            if invalidIDInScope
                                unresolvedIDList{end+1}=sourceItem.id;

                                unresolvedID2AsSrcMap(sourceItem.id)=allLinksAsSrc;
                            end



























                        else


                            for lindex=1:length(allLinks)
                                cLink=allLinks(lindex);






                                try
                                    destFullPath=which(cLink.destUri);
                                catch
                                    continue;
                                end
                                dstArtiID=this.getArtifactID(destFullPath);

                                if(any(srcArtiID==colIDList)&&any(dstArtiID==rowIDList))||(any(srcArtiID==rowIDList)&&any(dstArtiID==colIDList))
                                    destId=cLink.destId;

                                    if~slreq.utils.hasValidDest(cLink)

                                        if isKey(unresolvedIDLists,destFullPath)
                                            unresolvedIDInfo=unresolvedIDLists(destFullPath);
                                        else
                                            unresolvedIDInfo.IDList=unresolvedIDList;
                                            unresolvedIDInfo.ID2LinkAsSrc=containers.Map;
                                            unresolvedIDInfo.ID2LinkAsDst=containers.Map;
                                        end

                                        unresolvedIDInfo.IDList{end+1}=destId;
                                        if isKey(unresolvedIDInfo.ID2LinkAsDst,destId)
                                            linksAsDst=unresolvedIDInfo.ID2LinkAsDst(destId);
                                        else
                                            linksAsDst=slreq.data.Link.empty;
                                        end
                                        linksAsDst(end+1)=cLink;

                                        unresolvedIDInfo.ID2LinkAsDst(destId)=linksAsDst;
                                        unresolvedIDLists(destFullPath)=unresolvedIDInfo;
                                    end
                                end
                            end

                        end

                    end

                    if isKey(unresolvedIDLists,artifact)
                        unresolvedIDInfo=unresolvedIDLists(artifact);
                    else
                        unresolvedIDInfo.IDList={};
                        unresolvedIDInfo.ID2LinkAsSrc=containers.Map;
                        unresolvedIDInfo.ID2LinkAsDst=containers.Map;
                    end

                    unresolvedIDInfo.IDList=[unresolvedIDInfo.IDList,unresolvedIDList];

                    unresolvedIDInfo.ID2LinkAsSrc=unresolvedID2AsSrcMap;

                    unresolvedIDLists(artifact)=unresolvedIDInfo;












                end
            end
        end

        function addArtifactToMap(this,artifactFullPath)
            if~isKey(this.ArtifactToIDMap,artifactFullPath)
                this.Current_Artifact_ID=getNextPrime(this.Current_Artifact_ID+1);
                this.ArtifactToIDMap(artifactFullPath)=this.Current_Artifact_ID;
            end
        end


        function updateLinkTypeInfo(this)



            mfLinkTypes=slreq.utils.getAllLinkTypes();
            for index=1:length(mfLinkTypes)
                thisMFLinkType=mfLinkTypes(index);
                thisType.IsBuiltin=thisMFLinkType.isBuiltin;
                if thisType.IsBuiltin
                    thisType.ForwardName=getString(message(thisMFLinkType.forwardName));
                    thisType.BackwardName=getString(message(thisMFLinkType.backwardName));
                else
                    thisType.ForwardName=thisMFLinkType.forwardName;
                    thisType.BackwardName=thisMFLinkType.backwardName;
                end

                this.LinkTypeInfo(thisMFLinkType.typeName)=thisType;
            end

        end


        function exportToJSONString(this)
            this.JSONString=jsonencode(this.DataToExport);
        end


        function updateLinkInfo(this,links,artifactList)

            this.CurrentLinkData=containers.Map('KeyType','char','ValueType','any');

            colIDList=this.getArtifactID(this.ColumnArtifacts);
            rowIDList=this.getArtifactID(this.RowArtifacts);

            for index=1:length(links)
                cLink=links{index};
                linkInfo=this.LinkData(cLink);
                linkSrcArt=linkInfo.SrcArtifact;
                linkDstArt=linkInfo.DstArtifact;
                try
                    linkSrcArtID=this.getArtifactID(this.ArtifactToRootArtifactMap(linkSrcArt));
                    linkDstArtID=this.getArtifactID(this.ArtifactToRootArtifactMap(linkDstArt));
                catch


                    continue;
                end
                if(all(ismember(linkSrcArtID,colIDList))&&all(ismember(linkDstArtID,rowIDList)))||...
                    (all(ismember(linkDstArtID,colIDList))&&all(ismember(linkSrcArtID,rowIDList)))
                    this.CurrentLinkData(cLink)=linkInfo;
                    this.updateCurrentLinkType(linkInfo);
                    this.updateHasLinkInside(linkSrcArt,linkDstArt,linkInfo);
                    srcItemID=linkInfo.SrcID;
                    dstItemID=linkInfo.DstID;
                    if isKey(this.ItemID2LinkData,srcItemID)
                        srcItemIDLinkInfo=this.ItemID2LinkData(srcItemID);
                    else
                        srcItemIDLinkInfo.AsSrc=containers.Map;
                        srcItemIDLinkInfo.AsDst=containers.Map;
                    end
                    srcItemIDLinkInfo.AsSrc(dstItemID)=true;

                    this.ItemID2LinkData(srcItemID)=srcItemIDLinkInfo;

                    if isKey(this.ItemID2LinkData,dstItemID)
                        dstItemIDLinkInfo=this.ItemID2LinkData(dstItemID);
                    else
                        dstItemIDLinkInfo.AsSrc=containers.Map;
                        dstItemIDLinkInfo.AsDst=containers.Map;
                    end
                    dstItemIDLinkInfo.AsDst(srcItemID)=true;
                    this.ItemID2LinkData(dstItemID)=dstItemIDLinkInfo;

                    if linkInfo.HasChangedSource||linkInfo.HasChangedDestination

                        rootArts=this.ArtifactToRootArtifactMap(linkSrcArt);
                        for rIndex=1:length(rootArts)
                            artiInfo=this.ArtifactData(rootArts{rIndex});
                            srcIDList=getFullIDListFromItemID(srcItemID,artiInfo);
                            for sIndex=1:length(srcIDList)
                                cID=srcIDList{sIndex};
                                cSrcInfo=artiInfo.ItemDetails(cID);
                                cSrcInfo('HasChangedLink')='Yes';
                                cSrcInfo('Link')='HasChangedLink';
                                changedLinks=cSrcInfo('ChangedLinks');


                                changedLinks(linkInfo.FullID)=true;
                                cSrcInfo('ChangedLinks')=changedLinks;

                                if linkInfo.HasChangedSource
                                    cSrcInfo('Change')='WithChangeIssue';
                                    changedLinksAsSrc=cSrcInfo('ChangedLinksAsSrc');
                                    changedLinksAsSrc(linkInfo.FullID)=true;
                                    cSrcInfo('ChangedLinksAsSrc')=changedLinksAsSrc;
                                end
                            end


                        end

                        rootArts=this.ArtifactToRootArtifactMap(linkDstArt);
                        for rIndex=1:length(rootArts)
                            artiInfo=this.ArtifactData(rootArts{rIndex});
                            dstIDList=getFullIDListFromItemID(dstItemID,artiInfo);
                            for dIndex=1:length(dstIDList)
                                cID=dstIDList{dIndex};
                                cDstInfo=artiInfo.ItemDetails(cID);
                                cDstInfo('HasChangedLink')='Yes';
                                cDstInfo('Link')='HasChangedLink';

                                changedLinks=cDstInfo('ChangedLinks');


                                changedLinks(linkInfo.FullID)=true;
                                cDstInfo('ChangedLinks')=changedLinks;


                                if linkInfo.HasChangedDestination
                                    cDstInfo('Change')='WithChangeIssue';
                                    changedLinksAsDst=cDstInfo('ChangedLinksAsDst');

                                    changedLinksAsDst(linkInfo.FullID)=true;
                                    cDstInfo('ChangedLinksAsDst')=changedLinksAsDst;
                                end
                            end
                        end
                    end

                end
            end
        end


        function updateCurrentLinkType(this,linkInfo)





            if strcmpi(linkInfo.Type,'Unset')
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesLinkUnresolved'));
            else

                typeLabel=slreq.internal.ProfileLinkType.getForwardNameWithLinkSetID(...
                linkInfo.LinkSetID,linkInfo.Type);
                if isempty(typeLabel)

                    typeLabel=slreq.app.LinkTypeManager.getForwardName(linkInfo.Type);
                end
            end
            updateTypeList(this.CurrentLinkTypeInfo.TypeList,linkInfo.Type,typeLabel)


            if strcmpi(linkInfo.SubType,'#Other#')
                subTypeLabel='Built In Type';
            else
                subTypeLabel=slreq.internal.ProfileLinkType.getForwardNameWithLinkSetID(...
                linkInfo.LinkSetID,linkInfo.SubType);
                if isempty(subTypeLabel)
                    subTypeLabel=slreq.app.LinkTypeManager.getForwardName(linkInfo.SubType);
                end
            end
            updateSubTypeList(this.CurrentLinkTypeInfo.SubTypeList,this.CurrentLinkTypeInfo.Type2SubTypeMap,linkInfo.Type,[linkInfo.Type,'##',linkInfo.SubType],subTypeLabel);
        end

        function updateHasLinkInside(this,linkSrcArt,linkDstArt,linkInfo)
            srcArtiInfos=cellfun(@(x)this.ArtifactData(x),this.ArtifactToRootArtifactMap(linkSrcArt),'UniformOutput',false);
            dstArtiInfos=cellfun(@(x)this.ArtifactData(x),this.ArtifactToRootArtifactMap(linkDstArt),'UniformOutput',false);

            srcIDList={};
            dstIDList={};
            for sIndex=1:length(srcArtiInfos)
                for dIndex=1:length(dstArtiInfos)
                    srcArtiInfo=srcArtiInfos{sIndex};
                    dstArtiInfo=dstArtiInfos{dIndex};
                    [srcIDListTmp,dstIDListTmp]=getSrcAndDstIDList(linkInfo,srcArtiInfo,dstArtiInfo);
                    srcIDList=[srcIDList,srcIDListTmp];%#ok<AGROW> 
                    dstIDList=[dstIDList,dstIDListTmp];%#ok<AGROW> 
                end
            end

            for pairIdx=1:length(srcIDList)
                srcID=srcIDList{pairIdx};
                destID=dstIDList{pairIdx};

                if~srcArtiInfo.ItemDetails.isKey(srcID)||~dstArtiInfo.ItemDetails.isKey(destID)
                    continue;
                end
                srcInfo=srcArtiInfo.ItemDetails(srcID);
                dstInfo=dstArtiInfo.ItemDetails(destID);

                if strcmpi(srcInfo('Link'),'HasNoLink')
                    srcInfo('Link')='HasLink';
                end

                if strcmpi(dstInfo('Link'),'HasNoLink')
                    dstInfo('Link')='HasLink';
                end

                currentSrc=srcInfo;

                while true
                    currentDst=dstInfo;
                    if~isKey(currentSrc,'HasLinkInside')
                        currentSrcMapping=containers.Map;
                    else
                        currentSrcMapping=currentSrc('HasLinkInside');
                    end

                    if isKey(currentSrcMapping,currentDst('FullID'))
                        break;
                    end

                    while true
                        if~isKey(currentDst,'HasLinkInside')
                            currentDstMapping=containers.Map;
                        else
                            currentDstMapping=currentDst('HasLinkInside');
                        end

                        if isKey(currentDstMapping,currentSrc('FullID'))
                            break;
                        end

                        currentSrcMapping(currentDst('FullID'))=true;
                        currentSrc('HasLinkInside')=currentSrcMapping;

                        currentDstMapping(currentSrc('FullID'))=true;
                        currentDst('HasLinkInside')=currentDstMapping;
                        if currentDst('Level')==0
                            break;
                        end
                        currentDst=dstArtiInfo.ItemDetails(currentDst('ParentID'));
                    end

                    if currentSrc('Level')==0
                        break;
                    end

                    currentSrc=srcArtiInfo.ItemDetails(currentSrc('ParentID'));
                end
            end
        end


        function preExport(this,artifactList,preSetConfig)
            result=getOutputFormat();
            result.ArtifactList=artifactList;
            links={};
            for index=1:length(artifactList)
                artifact=artifactList{index};








                artifactData=this.ArtifactData(artifact);
                result.ArtifactHierarchy=[result.ArtifactHierarchy;artifactData.HierarchyInfo];
                result.ArtifactItemList=[result.ArtifactItemList;artifactData.ItemList];
                result.ItemDetails.(artifactData.Domain)=[result.ItemDetails.(artifactData.Domain);artifactData.ItemDetails];
                result.AllItemDetails=[result.AllItemDetails;artifactData.ItemDetails];

                if isKey(this.ArtifactLinkData,artifact)
                    allLinksForArtifact=this.ArtifactLinkData(artifact);
                    links=[links,allLinksForArtifact.Src.keys,allLinksForArtifact.Dst.keys];%#ok<AGROW>
                end
            end

            alllinks=unique(links);

            this.updateLinkInfo(alllinks,artifactList);
            for index=1:length(artifactList)
                artifact=artifactList{index};







                artifactData=this.ArtifactData(artifact);
                if strcmpi(artifactData.Domain,'simulink')
                    [~,modelName]=fileparts(artifact);
                    if~Simulink.internal.isArchitectureModel(modelName)


                        slreq.report.rtmx.utils.ModelTraverser.updateHISL_0070(artifactData,artifact);
                    end
                end
            end


            if isempty(alllinks)
                result.LinkDetails=containers.Map;
            else
                result.LinkDetails=containers.Map(alllinks,this.LinkData.values(alllinks));
            end

            srcToLinkKeyPattern=this.SRC_DEST_TO_LINK_KEY_PATTERN;
            for index=1:length(alllinks)

                cLink=alllinks{index};
                linkInfo=result.LinkDetails(cLink);

                linkSrcArt=linkInfo.SrcArtifact;
                linkDstArt=linkInfo.DstArtifact;
                if isempty(linkSrcArt)||isempty(linkDstArt)
                    continue;
                end

                srcArtifacts=this.ArtifactToRootArtifactMap(linkSrcArt);
                dstArtifacts=this.ArtifactToRootArtifactMap(linkDstArt);

                for sIndex=1:length(srcArtifacts)
                    for dIndex=1:length(dstArtifacts)
                        srcArtifact=srcArtifacts{sIndex};
                        dstArtifact=dstArtifacts{dIndex};
                        srcArtiInfo=this.ArtifactData(srcArtifact);
                        dstArtiInfo=this.ArtifactData(dstArtifact);
                        [srcIDList,dstIDList]=getSrcAndDstIDList(linkInfo,srcArtiInfo,dstArtiInfo);

                        for idIndex=1:length(srcIDList)
                            srcToDest=sprintf(srcToLinkKeyPattern,srcIDList{idIndex},dstIDList{idIndex});
                            result.SrcDestToLinkMap(srcToDest)=cLink;
                        end
                    end
                end
            end
            linkConfigInfo.Domain="link";
            linkConfigInfo.ArtifactID="linkInfo";
            linkConfigInfo.TypeInfo=this.CurrentLinkTypeInfo;

            highlightConfigInfo.Domain="highlight";
            highlightConfigInfo.ArtifactID="highlightinfo";
            matrixConfigInfo.Domain='matrix';
            matrixConfigInfo.ArtifactID='matrixinfo';






            result.ArtifactData=this.ArtifactData;
            result.CurrentLinkData=this.CurrentLinkData;
            result.CurrentLinkTypeInfo=this.CurrentLinkTypeInfo;
            result.ItemID2LinkData=this.ItemID2LinkData;
            result.ArtifactToRootArtifactMap=this.ArtifactToRootArtifactMap;

            this.DataToExport.Configuration.Row=this.getConfigList(this.RowArtifacts,preSetConfig.left);
            this.DataToExport.Configuration.Col=this.getConfigList(this.ColumnArtifacts,preSetConfig.top);
            this.DataToExport.Configuration.Cell=slreq.report.rtmx.utils.ConfigurationFactory.getConfiguration(linkConfigInfo,preSetConfig.cell);
            this.DataToExport.Configuration.Highlight=slreq.report.rtmx.utils.ConfigurationFactory.getConfiguration(highlightConfigInfo,preSetConfig.highlight);
            this.DataToExport.Configuration.Matrix=slreq.report.rtmx.utils.ConfigurationFactory.getConfiguration(matrixConfigInfo,preSetConfig.matrix);

            this.DataToExport.Options.Columns=this.ColumnArtifacts;
            this.DataToExport.Options.Rows=this.RowArtifacts;
            this.DataToExport.InfoData=result;
            this.DataToExport.LinkTypeInfo=this.LinkTypeInfo;
        end

        function configList=getConfigList(this,artifactList,preSetConfig)
            configs=cell(1,length(artifactList));
            for index=1:length(artifactList)
                cArtifact=artifactList{index};
                configs{index}=slreq.report.rtmx.utils.ConfigurationFactory.getConfiguration(this.ArtifactData(cArtifact),preSetConfig);
            end

            configList=this.combineConfigs(configs);
        end

        function configList=combineConfigs(this,configs)
            if length(configs)==1
                configList=configs{1};
                configList.Domain={configList.Domain};
                configList.DomainLabel={configList.DomainLabel};
                configList.ArtifactID={configList.ArtifactID};
                return;
            end












            domainToConfigMap=containers.Map('keytype','char','valuetype','any');
            domainToFinalConfigMap=containers.Map('keytype','char','valuetype','any');

            for index=1:length(configs)
                cConfigInfo=configs{index};
                if isKey(domainToConfigMap,cConfigInfo.Domain)
                    domainToConfigMap(cConfigInfo.Domain)=[domainToConfigMap(cConfigInfo.Domain),{cConfigInfo}];
                else
                    domainToConfigMap(cConfigInfo.Domain)={cConfigInfo};
                end
            end
















            allDomains=domainToConfigMap.keys;
            for dIndex=1:length(allDomains)
                cDomain=allDomains{dIndex};
                cArtiConfig=domainToConfigMap(cDomain);

                configItemMap=containers.Map('keytype','char','valuetype','any');

                artifactID=cell(1,length(cArtiConfig));
                for cIndex=1:length(cArtiConfig)
                    cConfigInfo=cArtiConfig{cIndex};
                    artifactID{cIndex}=cConfigInfo.ArtifactID;
                    for clIndex=1:length(cConfigInfo.ConfigList)
                        cConfigList=cConfigInfo.ConfigList{clIndex};
                        if~isKey(configItemMap,cConfigList.ConfigName)
                            cConfigList.ConfigDomain={cDomain};
                            configItemObj=slreq.report.rtmx.utils.ConfigItem(cConfigList);
                            configItemMap(cConfigList.ConfigName)=configItemObj;
                        else
                            configItemObj=configItemMap(cConfigList.ConfigName);
                            configItemObj.addDomain(cDomain);
                            configItemObj.addPropList(cConfigList.PropList);
                        end
                    end
                end


                allConfigItemObjs=configItemMap.values;
                configList=cell(1,length(allConfigItemObjs));
                for coIndex=1:length(allConfigItemObjs)
                    cConfigObj=allConfigItemObjs{coIndex};
                    configList{coIndex}=cConfigObj.export();
                end

                cArtiConfigInfo.Domain=cDomain;
                cArtiConfigInfo.DomainLabel=cArtiConfig{1}.DomainLabel;
                cArtiConfigInfo.QueryName=cArtiConfig{1}.QueryName;
                cArtiConfigInfo.ConfigList=configList;
                cArtiConfigInfo.ArtifactID=artifactID;

                domainToFinalConfigMap(cDomain)=cArtiConfigInfo;
            end


            allDomains=domainToFinalConfigMap.keys;
            if length(allDomains)>1
                firstConfig=domainToFinalConfigMap(allDomains{1});
                firstConfigObj=slreq.report.rtmx.utils.ConfigListObj(firstConfig);
                if length(allDomains)>1
                    firstConfigObj.demoteTypeConfig();
                end

                for dIndex=2:length(allDomains)
                    cDomain=allDomains{dIndex};
                    cArtiConfigInfo=domainToFinalConfigMap(cDomain);

                    firstConfigObj.mergetConfigList(cArtiConfigInfo);
                end
                configList=firstConfigObj.export();
            else
                configList=domainToFinalConfigMap(allDomains{1});
            end
        end




        function result=getAllArtifactList(this,topArtifactList,leftArtifactList,queryInvolvedOnly)
            allArtifacts=containers.Map('KeyType','char','ValueType','any');
            allViewList=containers.Map('KeyType','char','ValueType','any');
            viewColors=containers.Map('KeyType','char','ValueType','any');
            isComposer=containers.Map('KeyType','char','ValueType','any');
            topArtifactID=topArtifactList;
            leftArtifactID=leftArtifactList;
            foundTop=~isempty(topArtifactID);
            foundLeft=~isempty(leftArtifactID);
            hasLinkToItSelf=false;

            givenArtifactPlainList=unique([topArtifactList;leftArtifactList]);

            if foundTop&&foundLeft&&queryInvolvedOnly
                result.allArtifacts=givenArtifactPlainList;
                result.topArtifact=topArtifactID;
                result.leftArtifact=leftArtifactID;
                result.allViewList=containers.Map();
                result.viewColors=containers.Map();
                result.isComposer=containers.Map();
                result.srcToDst=containers.Map();
                result.dstToSrc=containers.Map();
                return;
            end

            reqData=slreq.data.ReqData.getInstance;
            givenArtifactIDs=1;

            givenArtifactList=slreq.report.rtmx.utils.MatrixArtifact.empty;
            for index=1:length(givenArtifactPlainList)


                cArtifact=givenArtifactPlainList{index};
                givenArtifactList(end+1)=slreq.report.rtmx.utils.MatrixArtifact(cArtifact);%#ok<AGROW>
                if ismember(cArtifact,topArtifactID)
                    givenArtifactList(end).setLocation('top');
                end

                if ismember(cArtifact,leftArtifactID)
                    if ismember(cArtifact,topArtifactID)
                        givenArtifactList(end).setLocatiohn('both');
                    else
                        givenArtifactList(end).setLocation('left');
                    end
                end
            end

            inLinkSet=slreq.data.LinkSet.empty();
            if~isempty(givenArtifactList)
                inLinkSet=slreq.data.LinkSet.empty();
                for index=1:length(givenArtifactList)
                    cLinkSet=reqData.getLinkSet(givenArtifactList(index).FullPath);
                    cArtifactPath=givenArtifactList(index).FullPath;
                    if isempty(cArtifactPath)
                        continue;
                    end
                    allArtifacts(cArtifactPath)=true;
                    givenArtifactIDs=this.getArtifactID(cArtifactPath)*givenArtifactIDs;
                    if~isempty(cLinkSet)
                        inLinkSet(end+1)=cLinkSet;%#ok<AGROW>
                    end

                    if strcmpi(givenArtifactList(index).Location,'left')||strcmpi(givenArtifactList(index).Location,'both')
                        foundLeft=true;
                        leftArtifactID={givenArtifactList(index).FullPath};
                    else
                        foundTop=true;
                        topArtifactID={givenArtifactList(index).FullPath};
                    end
                end



                if foundTop&&foundLeft&&queryInvolvedOnly
                    result.allArtifacts=[topArtifactID;leftArtifactID];
                    result.topArtifact=topArtifactID;
                    result.leftArtifact=leftArtifactID;
                    result.allViewList=containers.Map();
                    result.viewColors=containers.Map();
                    result.isComposer=containers.Map();
                    result.srcToDst=containers.Map();
                    result.dstToSrc=containers.Map();
                    return;
                end
            end
            allLinkSet=reqData.getLoadedLinkSets;
            allLinkSet=unique([inLinkSet,allLinkSet],'stable');


            if isempty(allLinkSet)&&~isempty(givenArtifactList)&&length(givenArtifactList)<2&&queryInvolvedOnly
                result.allArtifacts={};
                result.topArtifact={};
                result.leftArtifact={};
                result.allViewList=containers.Map;
                result.viewColors=containers.Map;
                result.isComposer=containers.Map;
                result.srcToDst=containers.Map();
                result.dstToSrc=containers.Map();
                return;
            end

            srcToDstMap=containers.Map;
            dstToSrcMap=containers.Map;

            for index=1:length(allLinkSet)
                cLinkSet=allLinkSet(index);
                artifactIsGiven=false;
                artifactFullFilePath=cLinkSet.artifact;


                if~exist(artifactFullFilePath,'File')
                    continue;
                end

                if~slreq.report.rtmx.utils.MatrixArtifact.isSupportedArtifact(artifactFullFilePath)
                    continue;
                end

                currentArtifactID=this.getArtifactID(artifactFullFilePath);

                if mod(givenArtifactIDs,currentArtifactID)==0

                    artifactIsGiven=true;
                    allArtifacts(artifactFullFilePath)=true;
                elseif givenArtifactIDs==1||~queryInvolvedOnly
                    allArtifacts(artifactFullFilePath)=true;
                end



                allReqSets=cLinkSet.getRegisteredRequirementSets();
                for rindex=1:length(allReqSets)
                    cReqSetName=allReqSets{rindex};

                    dataReqSet=reqData.getReqSet(cReqSetName);
                    if isempty(dataReqSet)



                        cReqSetPath=which(cReqSetName);
                        if~exist(cReqSetPath,'File')
                            continue;
                        end
                    else
                        cReqSetPath=dataReqSet.filepath;
                        addSrcDstArtifactsToMap(artifactFullFilePath,cReqSetPath,srcToDstMap,dstToSrcMap);
                    end

                    if strcmp(artifactFullFilePath,cReqSetPath)
                        hasLinkToItSelf=true;
                    end

                    if~isempty(cReqSetPath)
                        cReqSetID=this.getArtifactID(cReqSetPath);

                        if mod(givenArtifactIDs,cReqSetID)==0

                            allArtifacts(cReqSetPath)=true;
                            allArtifacts(artifactFullFilePath)=true;

                            if~strcmp(artifactFullFilePath,cReqSetPath)
                                if~foundTop
                                    if artifactIsGiven
                                        topArtifactID={cReqSetPath};
                                    else
                                        topArtifactID={artifactFullFilePath};
                                    end
                                    foundTop=true;
                                end
                                if~foundLeft
                                    if artifactIsGiven
                                        leftArtifactID={cReqSetPath};
                                    else
                                        leftArtifactID={artifactFullFilePath};
                                    end
                                    foundLeft=true;
                                end
                            end
                        elseif artifactIsGiven
                            allArtifacts(cReqSetPath)=true;
                            if~foundTop
                                topArtifactID={cReqSetPath};
                                foundTop=true;
                            end
                            if~foundLeft
                                leftArtifactID={cReqSetPath};
                                foundLeft=true;
                            end
                        elseif~queryInvolvedOnly&&~strcmp(artifactFullFilePath,cReqSetPath)

                            if~foundTop
                                topArtifactID={artifactFullFilePath};
                                foundTop=true;
                            end
                            if~foundLeft
                                leftArtifactID={cReqSetPath};
                                foundLeft=true;
                            end
                        end
                    end
                end

                allDirectLinks=cLinkSet.getDirectLinks;
                for lindex=1:length(allDirectLinks)
                    cLink=allDirectLinks(lindex);
                    destArtiName=cLink.destUri;

                    if slreq.report.rtmx.utils.MatrixArtifact.isSupportedArtifact(destArtiName)
                        destPath=which(destArtiName);
                        if~exist(destPath,'File')
                            continue;
                        end

                        if strcmp(destPath,artifactFullFilePath)
                            hasLinkToItSelf=true;
                        end
                        addSrcDstArtifactsToMap(artifactFullFilePath,destPath,srcToDstMap,dstToSrcMap)
                        if~isempty(destPath)
                            cDestID=this.getArtifactID(destPath);
                            if mod(givenArtifactIDs,cDestID)==0

                                allArtifacts(destPath)=true;
                                allArtifacts(artifactFullFilePath)=true;

                                if~strcmp(artifactFullFilePath,destPath)
                                    if~foundTop
                                        if artifactIsGiven
                                            topArtifactID={destPath};
                                        else
                                            topArtifactID={artifactFullFilePath};
                                        end
                                        foundTop=true;
                                    end
                                    if~foundLeft
                                        if artifactIsGiven
                                            leftArtifactID={destPath};
                                        else
                                            leftArtifactID={artifactFullFilePath};
                                        end
                                        foundLeft=true;
                                    end
                                end
                            elseif artifactIsGiven||~queryInvolvedOnly

                                allArtifacts(destPath)=true;

                                if~foundTop
                                    topArtifactID={destPath};
                                    foundTop=true;
                                end
                                if~foundLeft
                                    leftArtifactID={destPath};
                                    foundLeft=true;
                                end
                            end
                        end
                    end
                end

            end

            if~queryInvolvedOnly
                allReqSets=reqData.getLoadedReqSets();

                for rIndex=1:length(allReqSets)
                    cReqSet=allReqSets(rIndex);
                    fPath=slreq.internal.LinkUtil.getParentPath(cReqSet);
                    if~exist(fPath,'File')
                        continue;
                    end
                    allArtifacts(cReqSet.filepath)=true;
                end
            end

            if~queryInvolvedOnly&&dig.isProductInstalled('Simulink')&&is_simulink_loaded


                allModels=find_system('type','Block_Diagram');
                for index=1:length(allModels)
                    try
                        modelFilePath=get_param(allModels{index},'filename');




                        if exist(modelFilePath,'file')&&~contains(modelFilePath,fullfile(matlabroot,'toolbox'))
                            allArtifacts(modelFilePath)=true;
                            if Simulink.internal.isArchitectureModel(allModels{index})

                                isComposer(modelFilePath)=true;
                                [~,modelName]=fileparts(modelFilePath);
                                if Simulink.internal.isArchitectureModel(modelName,'AUTOSARArchitecture')





                                    allViews=[];
                                else
                                    archModel=systemcomposer.loadModel(modelFilePath);
                                    allViews=archModel.Views;
                                end

                                allViewNames=cell(size(allViews));
                                for vIndex=1:length(allViews)
                                    cView=allViews(vIndex);
                                    allViewNames{vIndex}=cView.Name;
                                    viewColors([modelFilePath,'::',cView.Name])=cView.Color;
                                end
                                if~isempty(allViews)
                                    allViewList(modelFilePath)=allViewNames;
                                end
                            end
                        end
                    catch ex


                        continue;
                    end
                end


                if dig.isProductInstalled('Simulink Test')&&contains(path,['toolbox',filesep,'stm',filesep,'stm'])
                    allTestFiles=sltest.testmanager.getTestFiles;
                    for index=1:length(allTestFiles)
                        try
                            cFile=allTestFiles(index);
                            cFilePath=cFile.FilePath;
                            if exist(cFilePath,'file')
                                allArtifacts(cFilePath)=true;
                            end
                        catch ex %#ok<NASGU> 
                            continue;
                        end
                    end
                end


                allDataFiles=Simulink.data.dictionary.getOpenDictionaryPaths;

                for index=1:length(allDataFiles)
                    try
                        cFilePath=allDataFiles{index};
                        if exist(cFilePath,'file')
                            allArtifacts(cFilePath)=true;
                        end
                    catch ex
                        continue;
                    end
                end
            end


            try
                proj=currentProject();
                allFileInProj=proj.Files;
                for index=1:length(allFileInProj)
                    try
                        cProjFile=allFileInProj(index).Path;
                        if slreq.report.rtmx.utils.MatrixArtifact.isSupportedArtifact(cProjFile)
                            allArtifacts(cProjFile)=true;
                        end
                    catch ex %#ok<NASGU>
                        continue;
                    end
                end
            catch ex %#ok<NASGU>


            end


            if allArtifacts.Count~=0&&(~foundTop||~foundLeft)
                firstArtifact=allArtifacts.keys;
                if~foundTop
                    topArtifactID=firstArtifact(1);
                end
                if~foundLeft
                    leftArtifactID=firstArtifact(1);
                end
            end


            result.allArtifacts=allArtifacts.keys;

            if~foundTop&&~isempty(result.allArtifacts)
                if hasLinkToItSelf&&~isempty(givenArtifactList)
                    topArtifactID={givenArtifactList(1).FullPath};
                else
                    topArtifactID=result.allArtifacts(1);
                end
            end

            if~foundLeft&&~isempty(result.allArtifacts)
                if hasLinkToItSelf&&~isempty(givenArtifactList)
                    leftArtifactID={givenArtifactList(1).FullPath};
                else
                    leftArtifactID=result.allArtifacts(1);
                end
            end

            result.allArtifacts=allArtifacts.keys;
            result.topArtifact=topArtifactID;
            result.leftArtifact=leftArtifactID;
            result.allViewList=allViewList;
            result.viewColors=viewColors;
            result.isComposer=isComposer;
            result.srcToDst=srcToDstMap;
            result.dstToSrc=dstToSrcMap;
        end
    end


    methods(Static)

        function this=getInstance(artifactList)



            persistent cachedObj
            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.RTMXReqDataExporter();

            end
            if nargin==1
                cachedObj.ArtifactList=artifactList;
            end

            this=cachedObj;
        end

        function out=exportData(rowArtifactList,colArtifactList,configFile)
            datamgr=slreq.report.rtmx.utils.RTMXReqDataExporter.getInstance;

            datamgr.RequestedArtifactInfo=containers.Map('KeyType','char','ValueType','any');
            for index=1:length(rowArtifactList)
                datamgr.RequestedArtifactInfo(rowArtifactList(index).Artifact)=rowArtifactList(index);
            end

            for index=1:length(colArtifactList)
                datamgr.RequestedArtifactInfo(colArtifactList(index).Artifact)=colArtifactList(index);
            end

            datamgr.RowArtifacts={rowArtifactList.Artifact};
            datamgr.ColumnArtifacts={colArtifactList.Artifact};
            datamgr.ArtifactList=datamgr.RequestedArtifactInfo.keys;
            if nargin<3
                configFile='';
            end
            datamgr.ConfigFile=configFile;


            out=datamgr.export();
        end

        function[jsonResult,result]=getArtifactList(artifactInfoInJSON)





















            queryInvolvedOnly=false;
            if nargin==1&&~isempty(artifactInfoInJSON)

                artifactInfo=jsondecode(artifactInfoInJSON);
                if~artifactInfo.options.queryOtherDataInMemory||~artifactInfo.options.showArtifactSelector
                    queryInvolvedOnly=true;
                end
                topArtifactList=artifactInfo.topArtifacts;
                leftArtifactList=artifactInfo.leftArtifacts;
                showArtifactSelector=artifactInfo.options.showArtifactSelector;
            else
                topArtifactList={};
                leftArtifactList={};
                showArtifactSelector=true;
            end

            exporter=slreq.report.rtmx.utils.RTMXReqDataExporter.getInstance;

            result=exporter.getAllArtifactList(topArtifactList,leftArtifactList,queryInvolvedOnly);

            result.numOfGivenByUsers=length(topArtifactList)+length(leftArtifactList);
            result.showArtifactSelector=showArtifactSelector;
            jsonResult=jsonencode(result);
        end
    end
end

function result=getOutputFormat()
    result.ArtifactList={};
    result.ArtifactHierarchy=containers.Map('KeyType','char','ValueType','any');
    result.ArtifactItemList=containers.Map('KeyType','char','ValueType','any');
    result.ItemDetails.simulink=containers.Map('KeyType','char','ValueType','any');
    result.ItemDetails.slreq=containers.Map('KeyType','char','ValueType','any');
    result.ItemDetails.sltest=containers.Map('KeyType','char','ValueType','any');
    result.ItemDetails.sldd=containers.Map('KeyType','char','ValueType','any');
    result.ItemDetails.sltest=containers.Map('KeyType','char','ValueType','any');
    result.ItemDetails.matlabcode=containers.Map('KeyType','char','ValueType','any');
    result.ItemDetails.other=containers.Map('KeyType','char','ValueType','any');
    result.AllItemDetails=containers.Map('KeyType','char','ValueType','any');
    result.LinkDetails=containers.Map('KeyType','char','ValueType','any');
    result.SrcDestToLinkMap=containers.Map('KeyType','char','ValueType','char');
    result.CurrentLinkData='';
    result.ArtifactData='';
end

function out=getNextPrime(currentNum)
    out=currentNum;
    if currentNum<3
        out=2;
        return;
    end

    if rem(out,2)==0

        out=out+1;
    end
    while~isprime(out)
        out=out+2;
    end
end




function updateTypeList(typeListMap,typeName,typeLabel)
    if isKey(typeListMap,typeName)
        typeInfo=typeListMap(typeName);
        typeInfo.Count=typeInfo.Count+1;
        typeListMap(typeName)=typeInfo;
    else
        if nargin<3
            typeLabel=typeName;
        end
        typeInfo.Label=typeLabel;
        typeInfo.Name=typeName;
        typeInfo.Count=1;
        typeListMap(typeName)=typeInfo;
    end
end

function updateSubTypeList(subTypeListMap,type2SubTypeMap,typeName,subTypeName,subTypeLabel)

    subTypeKey=subTypeName;
    if isKey(subTypeListMap,subTypeKey)
        subTypeStruct=subTypeListMap(subTypeKey);
        subTypeStruct.Count=subTypeStruct.Count+1;

        subTypeListMap(subTypeKey)=subTypeStruct;
    else
        if nargin<4
            subTypeParsing=strsplit(subTypeName,'##');
            subTypeLabel=subTypeParsing{2};
        end


        subTypeStruct.Label=subTypeLabel;
        subTypeStruct.Name=subTypeName;
        subTypeStruct.Count=1;

        subTypeListMap(subTypeKey)=subTypeStruct;


        subTypeList={};

        if isKey(type2SubTypeMap,typeName)
            subTypeList=type2SubTypeMap(typeName);
        end

        subTypeList{end+1}=subTypeName;
        type2SubTypeMap(typeName)=subTypeList;
    end
end
function idList=getFullIDListFromItemID(itemID,artiInfo)
    keyPos=strfind(itemID,'#:#');
    if~isempty(keyPos)
        itemID=itemID(keyPos+3:end);
    end

    idList=artiInfo.ItemID2FullIDList(itemID);
end

function[srcFinalList,dstFinalList]=getSrcAndDstIDList(linkInfo,srcArtiInfo,dstArtiInfo)
    if strcmp(linkInfo.SrcDomain,'linktype_rmi_matlab')
        srcIDList=cell(size(linkInfo.SrcTextLines));
        for index=1:length(linkInfo.SrcTextLines)
            srcIDList{index}=sprintf('%s:%d-%d',linkInfo.SrcArtifact,linkInfo.SrcTextLines{index}(1),linkInfo.SrcTextLines{index}(2));
        end
    else
        srcIDList=getFullIDListFromItemID(linkInfo.SrcID,srcArtiInfo);



    end

    if strcmp(linkInfo.DstDomain,'linktype_rmi_matlab')
        dstIDList=cell(size(linkInfo.DstTextLines));
        for index=1:length(linkInfo.DstTextLines)
            dstIDList{index}=sprintf('%s:%d-%d',linkInfo.DstArtifact,linkInfo.DstTextLines{index}(1),linkInfo.DstTextLines{index}(2));
        end
    else
        dstIDList=getFullIDListFromItemID(linkInfo.DstID,dstArtiInfo);




    end
    srcFinalList=cell(size(1,length(srcIDList)*length(dstIDList)));
    dstFinalList=cell(size(1,length(srcIDList)*length(dstIDList)));
    cIndex=1;
    for sIndex=1:length(srcIDList)
        cSrcID=srcIDList{sIndex};
        for dIndex=1:length(dstIDList)
            cDstID=dstIDList{dIndex};
            srcFinalList{cIndex}=cSrcID;
            dstFinalList{cIndex}=cDstID;
            cIndex=cIndex+1;
        end
    end





end

function addArtifactToMap(src,dst,srcToDstMap)
    if isKey(srcToDstMap,src)
        srcMap=srcToDstMap(src);
    else
        srcMap=containers.Map();
    end

    srcMap(dst)=true;
    srcToDstMap(src)=srcMap;
end

function addSrcDstArtifactsToMap(srcArtifact,dstArtifact,srcToDstMap,dstToSrcMap)
    addArtifactToMap(srcArtifact,dstArtifact,srcToDstMap);
    addArtifactToMap(dstArtifact,srcArtifact,dstToSrcMap);
end
