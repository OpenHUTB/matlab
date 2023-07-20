classdef ModelTraverser<slreq.report.rtmx.utils.ArtifactTraverser




    properties
        ModelName;
        ModelHandle;
    end

    properties(Access=protected)
        inLinksMap;
        outLinksMap;
        refInLinksMap;
        refOutLinksMap;
        processedRefArtifacts;
        sid2SLTypeMap;
        blockUnderLinkedSysMap;
        slFunctionInStateflowToSubsysMap;
    end

    properties(Constant)
        SubsystemSLtype={'simulink-subsystem','simulink-chart','simulink-testseq','simulink-model'};
    end

    properties
        TypesAtTheFront={'simulink-subsystem','simulink-chart','simulink-testseq','simulink-model'};
        TypesAtTheEnd={};
    end

    methods(Access=protected)
        function this=ModelTraverser()

            this@slreq.report.rtmx.utils.ArtifactTraverser()
            this.Domain='simulink';
            this.TypesAtTheEnd={};
            this.sid2SLTypeMap=containers.Map('KeyType','char','ValueType','char');
        end
    end

    methods(Static)
        function obj=getInstance()


            persistent cachedObj
            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.ModelTraverser;
            end
            obj=cachedObj;
        end
    end
    methods
        function loadArtifact(~,modelPath)
            load_system(modelPath);
        end

        function out=getArtifactID(this)
            out=get_param(this.ModelName,'filename');
        end

        function traverse(this)


            this.processedRefArtifacts={};


            this.slFunctionInStateflowToSubsysMap=containers.Map('KeyType','char','ValueType','char');

            this.refOutLinksMap=containers.Map('KeyType','char','ValueType','Any');

            this.preTraverse(this.ArtifactPath);












            import slreq.report.rtmx.utils.*





            [~,modelName]=fileparts(this.ArtifactPath);
            this.ModelName=modelName;
            this.buildLinkMap()
            this.traverseFlatList();


            this.traverseHierarchy();

        end


        function traverseFlatList(this)
            [objHs,parentIdx,isSf,SIDs]=rmi('getobjectsInModel',this.ModelName);
            this.buildFilter(objHs,parentIdx,isSf,SIDs);


            annHs=find_system(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','LookUnderMasks','all','IncludeCommented','on','type','annotation');
            annSIDs=arrayfun(@(x)[':',get(x,'SID')],annHs,'UniformOutput',false);
            objHs=[objHs;annHs];
            parentIdx=[parentIdx;ones(size(annHs))];%#ok<NASGU>
            isSf=[isSf;false(size(annHs))];
            SIDs=[SIDs;annSIDs];
            allItemHandles=objHs;
            this.DataExporter.setProgressRangeItems(length(allItemHandles));
            this.ModelHandle=get_param(this.ModelName,'Handle');
            itemDetails=this.createItemData(this.ModelHandle,'');

            fullID=itemDetails('FullID');
            itemDetails('ItemID')=fullID;
            this.updateItemID2FullList(itemDetails('ItemID'),itemDetails('FullID'));
            itemDetails('IsRoot')=true;
            this.ItemDetails(fullID)=itemDetails;
            flatList=cell(size(allItemHandles));
            flIndex=0;
            for index=1:length(allItemHandles)
                if isSf(index)
                    continue;
                end
                cItemHandle=allItemHandles(index);
                itemDetails=this.createItemData(cItemHandle,SIDs{index});
                fullID=itemDetails('FullID');
                this.ItemDetails(fullID)=itemDetails;
                flIndex=flIndex+1;
                flatList{flIndex}=fullID;

                isSfReqTable=false;
                if slprivate('is_stateflow_based_block',cItemHandle)
                    chartId=sf('Private','block2chart',cItemHandle);
                    isSfReqTable=sf('Private','is_requirement_chart',chartId);
                end

                if strcmpi(itemDetails('IconType'),'simulink-chart')&&...
                    isempty(get_param(cItemHandle,'ReferenceBlock'))&&...
                    ~isSfReqTable



                    chartId=sfprivate('block2chart',cItemHandle);
                    chartObj=idToHandle(sfroot,chartId);
                    sfFilter=rmisf.sfisa('isaFilter');
                    allChildren=chartObj.find(sfFilter);

                    flatList(length(flatList)+length(allChildren))={0};
                    for cIndex=1:length(allChildren)
                        cChild=allChildren(cIndex);
                        if cChild==chartObj
                            continue;
                        end
                        sfItemDetails=this.createItemDataSFObj(allChildren(cIndex));
                        sfFullID=sfItemDetails('FullID');
                        this.ItemDetails(sfFullID)=sfItemDetails;
                        flIndex=flIndex+1;
                        flatList{flIndex}=sfFullID;
                    end
                elseif strcmpi(itemDetails('IconType'),'simulink-eml')


                    this.dealWithMATLABCode(fullID,itemDetails('ItemID'));
                    this.dealWithMATLABCodeReferences(fullID);
                end

                if rmifa.isFaultLinkingEnabled()
                    if strcmp(get_param(cItemHandle,'type'),'block')


                        faultList=[];


                        mdlElem.handle=cItemHandle;
                        if safety.fault.internal.isElementFaultable(mdlElem)
                            faultList=[faultList,Simulink.fault.findFaults(this.ModelName,'ModelElement',cItemHandle)];%#ok<AGROW> 
                        end

                        prtHs=get_param(cItemHandle,'PortHandles').Outport;
                        for i=1:numel(prtHs)
                            faultList=[faultList,Simulink.fault.findFaults(this.ModelName,'ModelElement',prtHs(i))];%#ok<AGROW> 
                        end


                        flatList(length(flatList)+length(faultList))={0};
                        for i=1:numel(faultList)
                            faultItemDetails=this.createItemDataFaultObj(faultList(i),fullID);
                            faultFullID=faultItemDetails('FullID');
                            this.ItemDetails(faultFullID)=faultItemDetails;
                            flIndex=flIndex+1;
                            flatList{flIndex}=faultFullID;
                        end
                    elseif strcmp(get_param(cItemHandle,'type'),'block_diagram')||(cItemHandle==this.ModelHandle)


                        conditionalList=Simulink.fault.findConditionals(this.ModelHandle);
                        flatList(length(flatList)+length(conditionalList))={0};
                        for i=1:numel(conditionalList)
                            condItemDetails=this.createItemDataFaultObj(conditionalList(i),fullID);
                            faultFullID=condItemDetails('FullID');
                            this.ItemDetails(faultFullID)=condItemDetails;
                            flIndex=flIndex+1;
                            flatList{flIndex}=faultFullID;
                        end
                    end
                end
            end
            this.ItemList=flatList;
            this.reparentingForAnnotation(annHs);
            this.reparentingForSLInSF();

        end

        function reparentingForSLInSF(this)
            if this.slFunctionInStateflowToSubsysMap.Count>0
                allSFFullIDs=this.slFunctionInStateflowToSubsysMap.keys;
                for index=1:length(allSFFullIDs)
                    sfObjFullID=allSFFullIDs{index};
                    slObjFullID=this.slFunctionInStateflowToSubsysMap(sfObjFullID);

                    if isKey(this.ItemDetails,sfObjFullID)&&isKey(this.ItemDetails,slObjFullID)
                        sfDetails=this.ItemDetails(sfObjFullID);
                        slDetails=this.ItemDetails(slObjFullID);

                        slDetails('ParentID')=sfDetails('ParentID');
                        slDetails('Type')=sfDetails('Type');
                        slDetails('SubType')=sfDetails('SubType');
                        slDetails('IconType')=sfDetails('IconType');
                        slDetails('Desc')=sfDetails('Desc');
                        slDetails('LongDesc')=sfDetails('LongDesc');
                        this.ItemDetails.remove(sfObjFullID);
                    else
                        disp(1);
                    end


                end
            end
        end



















        function reparentingForAnnotation(this,annHs)
            sortedAnnHs=sortAreaAnnoatation(this,annHs);
            for index=1:length(sortedAnnHs)
                annH=sortedAnnHs(index);
                if strcmp(get_param(annH,'AnnotationType'),'area_annotation')
                    areaPosition=get_param(annH,'Position');
                    blockchildren=find_system(get_param(annH,'Parent'),'FindAll','on','LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'type','block');
                    areachildren=find_system(get_param(annH,'Parent'),'FindAll','on','LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'type','annotation');
                    children=setdiff([blockchildren;areachildren],[annH,get_param(get_param(annH,'Parent'),'Handle')]);

                    annSid=[this.ModelName,':',get(annH,'sid')];
                    annDetail=this.ItemDetails(annSid);
                    for idx=1:length(children)
                        child=get_param(children(idx),'Object');
                        blockPosition=child.Position;
                        if blockPosition(:,1)>=areaPosition(1)&&blockPosition(:,3)<=areaPosition(3)&&blockPosition(:,2)>=areaPosition(2)&&blockPosition(:,4)<=areaPosition(4)
                            childSID=[this.ModelName,':',get(child,'sid')];
                            childDetail=this.ItemDetails(childSID);
                            cParentID=childDetail('ParentID');

                            parentDetail=this.ItemDetails(cParentID);
                            if~strcmpi(parentDetail('Type'),'AreaAnnotation')
                                childDetail('ParentID')=annSid;
                            else

                            end
                        end
                    end
                end
            end

            function sortedAnnHs=sortAreaAnnoatation(~,annHs)
                areas=zeros(size(annHs));
                for aindex=1:length(annHs)
                    aPos=get(annHs(aindex),'Position');
                    areas(aindex)=(aPos(3)-aPos(1))*(aPos(4)-aPos(2));
                end
                [~,indecies]=sort(areas);
                sortedAnnHs=annHs(indecies);
            end

        end


        function traverseHierarchy(this)
            hierarchy=traverseChildren(this);
            this.HierarchyInfo=hierarchy;
        end

        function level=getLevel(this,itemID)
            itemDetails=this.ItemDetails(itemID);
            if isempty(itemDetails('ParentID'))
                level=0;
                return;
            end
            level=1;
            while~strcmp(itemDetails('ParentID'),this.ArtifactID)
                level=level+1;
                cItemID=itemDetails('ParentID');
                itemDetails=this.ItemDetails(cItemID);
            end

        end

        function addChild(this,itemID,parentID)
            parentDetails=this.ItemDetails(parentID);
            childrenIDs=parentDetails('ChildrenIDs');
            if~ismember(itemID,childrenIDs)
                childrenIDs{end+1}=itemID;
                parentDetails('ChildrenIDs')=childrenIDs;%#ok<NASGU> map updating. no need to reuse
            end
        end

        function hierarchy=traverseChildren(this)
            allItems=this.ItemDetails.keys;

            for index=1:length(allItems)
                cItemID=allItems{index};
                cItemDetails=this.ItemDetails(cItemID);
                cLevel=this.getLevel(cItemID);

                cItemDetails('Level')=cLevel;
                if cLevel>0
                    this.addChild(cItemID,cItemDetails('ParentID'));
                end
            end

            hierarchy=this.traverseChildrenHierarchy(this.ArtifactID,0);
        end

        function hierarchy=traverseChildrenHierarchy(this,currentID,level)
            itemDetails=this.ItemDetails(currentID);
            hierarchy.FullID=currentID;
            children=itemDetails('ChildrenIDs');
            childrenInfo=cell(size(children));
            level=level+1;
            nCh=length(children);
            ssIdx=zeros(1,nCh);
            for index=1:nCh
                child=children{index};
                childDetail=this.ItemDetails(child);

                if isKey(this.sid2SLTypeMap,child)
                    slType=this.sid2SLTypeMap(child);
                else
                    slType=childDetail('IconType');
                end

                if any(strcmp(slType,this.TypesAtTheFront))
                    ssIdx(index)=1;
                end

                if any(strcmp(slType,this.TypesAtTheEnd))
                    ssIdx(index)=-1;
                end

                childrenInfo{index}=traverseChildrenHierarchy(this,child,level);
            end

            hierarchy.Children=[childrenInfo(ssIdx==1),childrenInfo(ssIdx==0),childrenInfo(ssIdx==-1)];

            itemDetails('ChildrenIDs')=[children(ssIdx==1),children(ssIdx==0),children(ssIdx==-1)];%#ok<NASGU> map updating. no need to reuse

        end


        function fullID=getFullID(this,itemHandle)

            if strcmpi(get(itemHandle,'type'),'block_diagram')
                fullID=this.ArtifactID;
            else
                fullID=Simulink.ID.getSID(itemHandle);
            end
        end


        function outData=createItemData(this,itemHandle,sid)
            import slreq.report.rtmx.utils.*

            this.needContinue();

            linkKey=sid;
            fullID=[this.ModelName,sid];

            bObj=get(itemHandle,'Object');

            slType=slreq.utils.getSLTypeByObj(bObj);
            isRoot=false;
            itemData=ItemIDData(fullID);
            itemData.ItemID=sid;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            [objName,subType]=rmi.objname(itemHandle);
            if isempty(objName)
                itemData.Desc='?';
            else
                itemData.Desc=objName;
            end
            itemData.LongDesc=getfullname(itemHandle);

            itemData.IsExcludeFromHISL_0070=isExcludedSLObjFromHISL_0070(bObj);

            if isa(bObj,'Simulink.BlockDiagram')
                fullID=get_param(itemHandle,'filename');
                itemData=ItemIDData(fullID);
                itemData.ItemID=fullID;
                this.updateItemID2FullList(itemData.ItemID,itemData.FullID);

                type='Subsystem';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesModelSubsystem'));
                subType='Block diagram';
                isRoot=true;
                itemData.Desc=this.ModelName;
                itemData.LongDesc=fullID;
            elseif any(strcmp(slType,this.SubsystemSLtype))
                isRoot=false;
                type='Subsystem';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesModelSubsystem'));
            elseif strcmp(slType,'simulink-chart')
                type='StateflowObject';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesModelStateflowObject'));
            elseif strcmp(slType,'simulink-area-annotation')
                type='AreaAnnotation';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesModelAreaAnnotation'));
            else
                type='LeafBlock';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesModelLeafBlock'));
            end

            itemData.Domain=this.Domain;
            itemData.IsRoot=isRoot;
            itemData.Type=type;
            if this.blockUnderLinkedSysMap.isKey(sid)



            end
            itemData.IconType=slType;
            this.updateTypeList(type,typeLabel);

            if~isempty(subType)
                itemData.SubType=[type,'##',subType];
            end
            itemData.ArtifactID=this.ArtifactID;
            parentPath=get(itemHandle,'Parent');

            if isempty(parentPath)
                itemData.ParentID=[];
            else
                if isa(get_param(parentPath,'Object'),'Simulink.BlockDiagram')
                    parentID=get_param(parentPath,'filename');
                else
                    parentID=Simulink.ID.getSID(parentPath);
                end
                itemData.ParentID=parentID;
            end
            incomingLinks=[];
            if isKey(this.inLinksMap,linkKey)
                incomingLinks=this.inLinksMap(linkKey);
            end
            outgoingLinks=[];
            if isKey(this.outLinksMap,linkKey)
                outgoingLinks=this.outLinksMap(linkKey);
            end
            itemData.updateLinkInfo(incomingLinks,outgoingLinks)

            outData=itemData.exportData();
        end

        function outData=createItemDataSFObj(this,sfObj)
            import slreq.report.rtmx.utils.*
            this.needContinue();

            fullID=Simulink.ID.getSID(sfObj);
            if isa(sfObj,'Stateflow.SLFunction')||isa(sfObj,'Stateflow.SimulinkBasedState')

                slObj=sfObj.getDialogProxy;
                slHandle=slObj.Handle;

                slSid=Simulink.ID.getSID(slHandle);
                this.slFunctionInStateflowToSubsysMap(fullID)=slSid;
            end


            [~,linkKey]=strtok(fullID,':');
            itemData=ItemIDData(fullID);
            itemData.ItemID=linkKey;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.Type='StateflowObject';
            typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesModelStateflowObject'));
            itemData.SubType=[itemData.Type,'##',class(sfObj)];
            itemData.IconType=slreq.utils.getSLTypeByObj(sfObj);
            if isprop(sfObj,'LabelString')&&~isempty(sfObj.LabelString)
                itemData.Desc=sfObj.LabelString;
            elseif isprop(sfObj,'Name')&&~isempty(sfObj.Name)
                itemData.Desc=sfObj.Name;
            else
                itemData.Desc='?';
            end

            itemData.LongDesc=itemData.Desc;


            if strcmpi(itemData.IconType,'simulink-emlaction')
                this.dealWithMATLABCode(fullID,itemData.ItemID);
                this.dealWithMATLABCodeReferences(fullID);
            end



            itemData.Domain=this.Domain;
            itemData.IsRoot=false;
            this.updateTypeList(itemData.Type,typeLabel);
            this.updateSubTypeList(itemData.Type,itemData.SubType);

            itemData.ArtifactID=this.ArtifactID;
            parentID=Simulink.ID.getSID(sfObj.getParent);

            itemData.ParentID=parentID;

            incomingLinks=[];
            if isKey(this.inLinksMap,linkKey)
                incomingLinks=this.inLinksMap(linkKey);
            end
            outgoingLinks=[];
            if isKey(this.outLinksMap,linkKey)
                outgoingLinks=this.outLinksMap(linkKey);
            end
            itemData.updateLinkInfo(incomingLinks,outgoingLinks)
            outData=itemData.exportData();
        end

        function out=createItemDataFaultObj(this,faultInfoObj,parentID)
            import slreq.report.rtmx.utils.*
            this.needContinue();

            linkKey=[rmifa.itemIDPref,faultInfoObj.Uuid];
            fullID=[this.ModelName,'|',linkKey];
            itemData=ItemIDData(fullID);
            itemData.ItemID=linkKey;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            [objName,~]=rmi.objname(faultInfoObj);
            if isempty(objName)
                itemData.Desc='?';
            else
                itemData.Desc=objName;
            end

            if isa(faultInfoObj,'Simulink.fault.Fault')
                itemData.Type='FAObjectFault';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesFaultInfoFault'));
                if strcmp(faultInfoObj.Type,getString(message('safetyanalyzer:faultinfo:FaultTypeNameZC')))
                    cl=getString(message('Slvnv:slreq_rtmx:FilterTypesFaultSubtypeZC'));
                elseif strcmp(faultInfoObj.Type,getString(message('safetyanalyzer:faultinfo:FaultTypeNameSS')))
                    cl=getString(message('Slvnv:slreq_rtmx:FilterTypesFaultSubtypeSS'));
                else
                    cl=getString(message('Slvnv:slreq_rtmx:FilterTypesFaultSubtypeSL'));
                end
                itemData.SubType=[itemData.Type,'##',cl];
                this.updateTypeList(itemData.Type,typeLabel);
                this.updateSubTypeList(itemData.Type,itemData.SubType);
            else
                itemData.Type='FAObjectConditional';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesFaultInfoConditional'));
                this.updateTypeList(itemData.Type,typeLabel);
            end
            itemData.IconType=slreq.utils.getSLTypeByObj(faultInfoObj);

            itemData.LongDesc=itemData.Desc;
            itemData.Domain=this.Domain;
            itemData.IsRoot=false;

            itemData.ArtifactID=this.ArtifactID;
            itemData.ParentID=parentID;
            incomingLinks=[];
            if isKey(this.inLinksMap,linkKey)
                incomingLinks=this.inLinksMap(linkKey);
            end
            outgoingLinks=[];
            if isKey(this.outLinksMap,linkKey)
                outgoingLinks=this.outLinksMap(linkKey);
            end
            itemData.updateLinkInfo(incomingLinks,outgoingLinks)
            out=itemData.exportData();
        end

        function buildRefLinkMap(this,refArtifact,artifact)
            reqData=slreq.data.ReqData.getInstance();
            linkSet=reqData.getLinkSet(refArtifact);
            if~isempty(linkSet)
                linkedItems=linkSet.getLinkedItems;
                for n=1:length(linkedItems)
                    li=linkedItems(n);
                    this.refOutLinksMap([refArtifact,li.id])=li.getLinks();
                end
            end
            if~this.DataExporter.ArtifactToRootArtifactMap.isKey(refArtifact)
                this.DataExporter.ArtifactToRootArtifactMap(refArtifact)={artifact};
            else
                this.DataExporter.ArtifactToRootArtifactMap(refArtifact)=...
                [this.DataExporter.ArtifactToRootArtifactMap(refArtifact),artifact];
            end
        end

        function outLinks=getOutLinksForArtifact(this,refArtifact,itemID,artifact)
            if~any(strcmp(refArtifact,this.processedRefArtifacts))
                this.buildRefLinkMap(refArtifact,artifact);
                this.processedRefArtifacts{end+1}=refArtifact;
            end
            mapKey=[refArtifact,itemID];
            if isKey(this.refOutLinksMap,mapKey)
                outLinks=this.refOutLinksMap(mapKey);
            else
                outLinks=[];
            end
        end

        function buildLinkMap(this)



            oMap=containers.Map('KeyType','char','ValueType','Any');
            reqData=slreq.data.ReqData.getInstance();

            srcArtifact=get_param(this.ModelName,'FileName');
            linkSet=reqData.getLinkSet(srcArtifact);
            if~isempty(linkSet)
                linkedItems=linkSet.getLinkedItems;
                for n=1:length(linkedItems)
                    li=linkedItems(n);
                    oMap(li.id)=li.getLinks();
                end
            end
            this.outLinksMap=oMap;

            srcShortNameExt=slreq.uri.getShortNameExt(srcArtifact);

            defaultReqSet=reqData.getReqSet('default');
            artifactsInDefault=defaultReqSet.children;
            destReqs=[];
            for n=1:length(artifactsInDefault)
                thisOne=artifactsInDefault(n);
                if strcmp(srcShortNameExt,thisOne.artifactUri)
                    destReqs=thisOne.children;
                    break;
                end
            end

            iMap=containers.Map('KeyType','char','ValueType','Any');
            for n=1:length(destReqs)
                dReq=destReqs(n);
                inLinks=dReq.getLinks;
                if~isempty(inLinks)
                    iMap(dReq.customId)=dReq.getLinks;
                end
            end
            this.inLinksMap=iMap;
        end

        function buildFilter(this,bHs,parentIdx,isSf,SIDs)
            this.blockUnderLinkedSysMap=containers.Map('KeyType','char','ValueType','logical');
            recBuildMap(1,false);

            function[chHasLink,chSIDs]=recBuildMap(idx,isUnderMask)
                chHasLink=false;
                chSIDs={};
                if isSf(idx)
                    return;
                end
                sid=SIDs{idx};
                if~isempty(sid)
                    bObj=get(bHs(idx),'Object');
                    slType=slreq.utils.getSLTypeByObj(bObj);
                    this.sid2SLTypeMap([this.ModelName,sid])=slType;
                    if isUnderMask

                    else
                        if strcmp(slType,'simulink-subsystem')&&bObj.isMasked
                            isUnderMask=true;
                        else
                            isUnderMask=false;
                        end
                    end
                end
                idxs=find(parentIdx==idx);
                for n=1:length(idxs)
                    [chLink,cSIDs]=recBuildMap(idxs(n),isUnderMask);
                    chSIDs=[chSIDs,cSIDs];
                    chHasLink=chHasLink||chLink;
                end
                thisHasLink=this.outLinksMap.isKey(sid);
                if thisHasLink&&~chHasLink&&~isempty(idxs)
                    for m=1:length(chSIDs)
                        this.blockUnderLinkedSysMap(chSIDs{m})=true;
                    end
                end
                chHasLink=chHasLink||thisHasLink;
                chSIDs{end+1}=sid;
            end
        end

        function dealWithMATLABCode(this,blockFullID,blockItemID)
            import slreq.report.rtmx.utils.*
            allTextRanges=slreq.utils.getLinkedRanges(blockFullID);
            for rIndex=1:length(allTextRanges)
                cTextRange=allTextRanges(rIndex);
                textStruct.artifact=cTextRange.artifactUri;
                textStruct.domain='linktype_rmi_simulink';
                textStruct.id=[blockItemID,'~',cTextRange.id];
                outRangeLinks=cTextRange.getLinks;
                dataReq=slreq.data.ReqData.getInstance.getRequirementItem(textStruct,false);
                if isempty(dataReq)
                    inRangeLinks=[];
                else
                    inRangeLinks=dataReq.getLinks();
                end
                if~isempty(outRangeLinks)||~isempty(inRangeLinks)




                    itemData=TextItemIDData([this.ArtifactID,textStruct.id]);
                    itemData.ArtifactID=this.ArtifactID;
                    itemData.ItemID=textStruct.id;
                    this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
                    itemData.Domain='simulink';
                    itemData.Range=[num2str(cTextRange.startPos),'-',num2str(cTextRange.endPos)];
                    itemData.StartPos=cTextRange.startPos;
                    itemData.EndPos=cTextRange.endPos;
                    itemData.HasID=true;
                    itemData.ParentID=blockFullID;
                    itemData.Type='MATLABCode';
                    this.updateTypeList('MATLABCode',getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABCode')));
                    textAdapter=cTextRange.getAdapter;
                    [~,desc,longDesc]=textAdapter.getIconSummaryTooltipFromSourceItem(cTextRange,textStruct.artifact,textStruct.id);
                    if isempty(desc)
                        desc='?';
                    end
                    itemData.Desc=desc;
                    itemData.LongDesc=longDesc;








                    itemData.updateLinkInfo(inRangeLinks,outRangeLinks);










                    outData=itemData.exportData();
                    this.ItemDetails(itemData.FullID)=outData;
                end
            end
        end

        function dealWithMATLABCodeReferences(this,matlabBlkID)
            blockMapInfo=this.buildMATLABCodeHierarchy(matlabBlkID);

            allRefFiles=blockMapInfo.keys;
            for index=1:length(allRefFiles)
                cRef=blockMapInfo(allRefFiles{index});
                fullID=cRef('FileName');
                this.DataExporter.ArtifactToRootArtifactMap(fullID)={this.ArtifactID};
                artifactInfo=this.DataExporter.getArtifactInfo(fullID);
                traverser=slreq.report.rtmx.utils.TraverserAdapter(artifactInfo);
                traverser.traverse();
                matlabData=traverser.getTraverseData();
                topInfo=matlabData.ItemDetails(fullID);
                topInfo('ParentID')=cRef('Parent');
                matlabData.ItemDetails(fullID)=topInfo;
                this.combineTwoData(matlabData);
            end
        end



        function blockMapInfo=buildMATLABCodeHierarchy(this,blockID)
            blockHandle=Simulink.ID.getHandle(blockID);

            if isa(blockHandle,'double')
                blockObj=get_param(blockHandle,'Object');
                rootModel=bdroot(blockID);
                blockFullName=getfullname(blockID);
            else
                blockObj=blockHandle;
                rootModel=blockHandle.Machine.Name;
                blockPath=blockObj.Path;
                blockPathSID=Simulink.ID.getSID(blockPath);
                blockFullName=strrep(blockID,blockPathSID,blockPath);
            end

            blockMapInfo=containers.Map('keytype','char','valuetype','any');
            referenceInfo=Advisor.Utils.Eml.getReferencedMFiles(rootModel,{blockObj});

            for index=1:length(referenceInfo)
                cRef=referenceInfo{index};
                if isstruct(cRef)
                    cInfo=containers.Map;
                    if strcmpi(cRef.ReferenceLocation,blockFullName)
                        cInfo('Parent')=blockID;
                    else
                        cInfo('Parent')=cRef.ReferenceLocationPath;
                    end
                    cInfo('FileName')=cRef.FileName;
                    cInfo('ParentPath')=cRef.ReferenceLocationPath;
                    blockMapInfo(cRef.FileName)=cInfo;
                end
            end
        end

    end

    methods(Static)


        function updateHISL_0070(artifactData,itemID)




















            itemDetail=artifactData.ItemDetails(itemID);

            allChildren=itemDetail('ChildrenIDs');
            allChildren=slreq.report.rtmx.utils.ModelTraverser.getFlattenChildren(allChildren,artifactData);

            if~isempty(allChildren)
                if strcmpi(itemDetail('Link'),'HasNoLink')


                    foundNoLinkChildren=false;
                    containsAreaOrBox=false;
                    for cIndex=1:length(allChildren)
                        childFullID=allChildren{cIndex};

                        childDetail=artifactData.ItemDetails(childFullID);
                        if~childDetail('IsExcludeFromHISL_0070')&&strcmpi(childDetail('Link'),'HasNoLink')&&isempty(childDetail('ChildrenIDs'))
                            foundNoLinkChildren=true;
                            break;
                        end
                    end

                    if foundNoLinkChildren

                        itemDetail('ExpectedMissingLinks')='HasNoExpectedLink';
                    else

                    end


                end

                for cIndex2=1:length(allChildren)
                    childFullID=allChildren{cIndex2};
                    childDetail=artifactData.ItemDetails(childFullID);
                    if strcmpi(childDetail('Type'),'AreaAnnotation')&&strcmpi(childDetail('Link'),'HasNoLink')
                        continue;
                    end
                    slreq.report.rtmx.utils.ModelTraverser.updateHISL_0070(artifactData,childFullID)
                end

            else

            end
        end


        function flattenChildren=getFlattenChildren(allChildren,artifactData)



            flattenChildren={};
            extraChildren={};
            for index=1:length(allChildren)
                childFullID=allChildren{index};
                childDetail=artifactData.ItemDetails(childFullID);

                if strcmpi(childDetail('Type'),'AreaAnnotation')&&strcmpi(childDetail('Link'),'HasNoLink')
                    newChildren=childDetail('ChildrenIDs');
                    extraChildren=[extraChildren,newChildren];
                else
                    flattenChildren{end+1}=childFullID;
                end
            end

            if isempty(extraChildren)
                return;
            else
                extraFlattenChildren=slreq.report.rtmx.utils.ModelTraverser.getFlattenChildren(extraChildren,artifactData);
                flattenChildren=[flattenChildren,extraFlattenChildren];
            end


        end
    end

end

function out=isExcludedSLObjFromHISL_0070(slObj)




    excludedBlockType={'Ground','Terminator','Inport','Outport','InportShadow'};
    excludedSubsystemType={'CMBlock','System Requirements','DocBlock','System REquirement Item'};
    out=strcmpi(slObj.Type,'block')&&ismember(slObj.BlockType,excludedBlockType);

    out=out||(strcmpi(slObj.Type,'block')&&strcmpi(slObj.BlockType,'Subsystem')&&ismember(slObj.MaskType,excludedSubsystemType));
end

