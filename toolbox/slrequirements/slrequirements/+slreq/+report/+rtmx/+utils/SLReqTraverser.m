classdef SLReqTraverser<slreq.report.rtmx.utils.ArtifactTraverser


    properties




        CustomAttributesInfo;
        CustomAttributeList;
    end

    methods(Access=private)
        function this=SLReqTraverser()

            this@slreq.report.rtmx.utils.ArtifactTraverser()
            this.Domain='slreq';
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent cachedObj
            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.SLReqTraverser();
            end
            obj=cachedObj;
            obj.ItemDetails=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods
        function loadArtifact(~,reqSetPath)
            artifactPath=slreq.internal.LinkUtil.artifactPathToCheck(reqSetPath);
            slreq.load(artifactPath);
        end


        function clearData(this)
            clearData@slreq.report.rtmx.utils.ArtifactTraverser(this);
            this.CustomAttributesInfo='';
            this.CustomAttributeList=containers.Map('KeyType','char','ValueType','any');
        end


        function out=getTraverseData(this)
            out=getTraverseData@slreq.report.rtmx.utils.ArtifactTraverser(this);
            out.CustomAttributesInfo=this.CustomAttributesInfo;
            out.CustomAttributeList=this.CustomAttributeList;
        end

        function traverse(this)
            this.preTraverse(this.ArtifactPath);




























            import slreq.report.rtmx.utils.*

            dataReqSet=slreq.data.ReqData.getInstance.getReqSet(this.ArtifactPath);
            this.traverseFlatList(dataReqSet);
            this.traverseUnresolvedIDList();
            this.traverseHierarchy(dataReqSet);

        end

        function traverseUnresolvedIDList(this)

            if~isempty(this.UnresolvedIDList)
                parentDetails=this.createItemDataFromUnresolvedIDParent();

                fullID=parentDetails('FullID');
                this.ItemList{end+1}=fullID;
                this.ItemDetails(fullID)=parentDetails;
                for index=1:length(this.UnresolvedIDList)
                    currentID=this.UnresolvedIDList{index};
                    itemDetails=this.createItemDataFromUnresolvedID(currentID);
                    fullID=itemDetails('FullID');
                    this.ItemList{end+1}=fullID;
                    this.ItemDetails(fullID)=itemDetails;
                end
            end

        end



        function updateCustomAttributesData(this,customAttributeList)
            for cIndex=1:length(customAttributeList)
                cAttribute=customAttributeList(cIndex);
                cKey=['customattribute##',cAttribute.Name];
                if isKey(this.CustomAttributeList,cKey)
                    attributeInfo=this.CustomAttributeList(cKey);
                    attributeInfo.Count=attributeInfo.Count+1;
                    this.CustomAttributeList(cKey)=attributeInfo;
                else
                    if strcmpi(cAttribute.Type,'checkbox')||strcmpi(cAttribute.Type,'combobox')
                        attributeInfo.Name=cKey;
                        attributeInfo.Label=cAttribute.Name;
                        attributeInfo.Type=cAttribute.Type;
                        attributeInfo.Count=1;
                        this.CustomAttributeList(cKey)=attributeInfo;
                    end
                end
            end
        end


        function traverseHierarchy(this,dataReqSet)
            hierarchy=traverseChildren(this,dataReqSet,0);
            this.HierarchyInfo=hierarchy;
        end


        function hierarchy=traverseChildren(this,dataReqOrSet,level)

            if isa(dataReqOrSet,'slreq.data.RequirementSet')
                fullID=dataReqOrSet.filepath;
                addInvalidChildren=false;
                children=dataReqOrSet.children;
            elseif isa(dataReqOrSet,'char')&&strcmpi(dataReqOrSet,[this.ArtifactID,this.UnresolvedParentID])
                addInvalidChildren=true;
                fullID=dataReqOrSet;
                children=this.UnresolvedIDList;
            elseif isa(dataReqOrSet,'char')
                addInvalidChildren=true;
                fullID=dataReqOrSet;
                children={};
            else
                fullID=dataReqOrSet.getFullID;
                addInvalidChildren=false;
                children=dataReqOrSet.children;
            end

            itemDetails=this.ItemDetails(fullID);
            itemDetails('Level')=level;


            childrenIDs=cell(size(children));
            level=level+1;

            hierarchy.FullID=fullID;
            childrenInfo=cell(size(children));
            [~,filename,fileext]=fileparts(this.ArtifactID);
            if addInvalidChildren
                for index=1:length(children)
                    child=children{index};
                    childFullID=[filename,fileext,':#',child];
                    childrenIDs{index}=childFullID;
                    childrenInfo{index}=traverseChildren(this,childFullID,level);
                end

            else
                for index=1:length(children)
                    child=children(index);
                    childFullID=child.getFullID;
                    childrenIDs{index}=childFullID;
                    childrenInfo{index}=traverseChildren(this,child,level);
                end
                if isa(dataReqOrSet,'slreq.data.RequirementSet')&&~isempty(this.UnresolvedIDList)
                    childFullID=[this.ArtifactID,this.UnresolvedParentID];
                    childrenIDs{end+1}=childFullID;
                    childrenInfo{end+1}=traverseChildren(this,childFullID,level);
                end
            end





            hierarchy.Children=childrenInfo;
            itemDetails('ChildrenIDs')=childrenIDs;
            itemDetails('Children')=slreq.report.rtmx.utils.Misc.getChildrenIDsStruct(childrenIDs);
            this.ItemDetails(fullID)=itemDetails;
        end


        function traverseFlatList(this,dataReqSet)
            outData=this.createItemDataForReqSet(dataReqSet);

            allItems=dataReqSet.getAllItems();
            this.setProgressRangeItems(length(allItems));
            flatList=cell(size(allItems));

            for index=1:length(allItems)
                cItem=allItems(index);
                itemDetails=this.createItemData(cItem);
                fullID=cItem.getFullID;
                flatList{index}=fullID;
                this.ItemDetails(fullID)=itemDetails;
            end
            this.ItemList=flatList;

            this.ArtifactID=dataReqSet.filepath;
            this.ItemDetails(dataReqSet.filepath)=outData;
        end


        function outData=createItemDataForReqSet(this,dataReqSet)
            import slreq.report.rtmx.utils.*
            fullid=dataReqSet.filepath;
            itemData=ReqItemIDData(fullid);
            itemData.Desc=dataReqSet.name;
            itemData.LongDesc=dataReqSet.filepath;
            itemData.Domain=this.Domain;
            itemData.ItemID=fullid;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);

            itemData.IconType='reqset';
            itemData.ParentID='';
            itemData.IsRoot=true;

            itemData.Link='NotLinkable';
            itemData.CustomAttributesInfo=getCustomAttributesInfoForReqSet(dataReqSet);
            this.CustomAttributesInfo=itemData.CustomAttributesInfo;

            outData=itemData.exportData();
        end


        function outData=createItemDataFromUnresolvedIDParent(this)
            import slreq.report.rtmx.utils.*

            this.needContinue();

            fullID=sprintf('%s%s',this.ArtifactID,this.UnresolvedParentID);
            itemData=ReqItemIDData(fullID);

            itemData.ItemID='#';
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            [~,artifactName]=fileparts(this.ArtifactID);
            itemData.Desc='Unresolved Items';
            itemData.LongDesc=['This is the container for unresolvable items in ',artifactName];
            itemData.ArtifactID=this.ArtifactID;
            itemData.Domain=this.Domain;
            itemData.Keywords={};
            itemData.IconType='slreq-in';
            itemData.CustomAttributesInfo={};

            itemData.Type='UnresolableItemContainer';
            itemData.IsRoot=false;
            itemData.ParentID=this.ArtifactID;
            outData=itemData.exportData();
        end


        function outData=createItemDataFromUnresolvedID(this,id)
            import slreq.report.rtmx.utils.*

            this.needContinue();

            [~,artifactName,artifactExt]=fileparts(this.ArtifactID);
            fullID=sprintf('%s%s:#%s',artifactName,artifactExt,id);
            itemData=ReqItemIDData(fullID);

            itemData.ItemID=sprintf('#%d',id);
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);

            itemData.Desc=sprintf('%s#%s',artifactName,id);
            itemData.LongDesc=['Unresolved Item in ',this.ArtifactID];
            itemData.ArtifactID=this.ArtifactID;
            itemData.Domain=this.Domain;
            itemData.Keywords={};
            itemData.IconType='slreq-in';
            itemData.CustomAttributesInfo={};

            itemData.Type='UnresolableItem';

            typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesUnresolvedItems'));
            itemData.SubType='';
            this.updateTypeList(itemData.Type,typeLabel);
            itemData.IsRoot=false;
            itemData.ParentID=[this.ArtifactID,this.UnresolvedParentID];
            if isKey(this.UnresolvedID2LinkAsSrc,id)
                outgoingLinks=this.UnresolvedID2LinkAsSrc(id);
            else

                outgoingLinks=slreq.data.Link.empty;
            end
            if isKey(this.UnresolvedID2LinkAsDst,id)
                incomingLinks=this.UnresolvedID2LinkAsDst(id);
            else

                incomingLinks=slreq.data.Link.empty;
            end
            itemData.updateLinkInfo(incomingLinks,outgoingLinks)
            outData=itemData.exportData();
        end

        function outData=createItemData(this,dataReq)
            import slreq.report.rtmx.utils.*

            this.needContinue();
            fullid=dataReq.getFullID;
            itemData=ReqItemIDData(fullid);
            itemData.ItemID=sprintf('#%d',dataReq.sid);
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);

            [adapter,artifactUri,artifactId]=dataReq.getAdapter();


            summary=adapter.getSummary(artifactUri,artifactId);
            if isempty(summary)
                summary='?';
            end
            itemData.Desc=summary;
            itemData.LongDesc=[dataReq.index,' ',dataReq.id,' ',dataReq.summary];
            itemData.Index=dataReq.index;
            itemData.ArtifactID=dataReq.getReqSet().filepath;
            itemData.Domain=this.Domain;
            itemData.Keywords=dataReq.keywords;

            this.updateKeywordList(itemData.Keywords);
            reqData=slreq.data.ReqData.getInstance;
            if dataReq.external
                itemData.IconType='slreq-ex';
            elseif dataReq.isJustification
                itemData.IconType='slreq-justification';
            else
                itemData.IconType='slreq-in';
            end



            itemData.CustomAttributesInfo=getCustomAttributesInfoForReq(dataReq,this.CustomAttributesInfo);
            this.updateCustomAttributesData(itemData.CustomAttributesInfo);
            if dataReq.isJustification
                itemData.Type='Justification';
                typeLabel=getString(message('Slvnv:slreq:Justification'));
                itemData.SubType='';
            else
                isStereotype=slreq.internal.ProfileReqType.isProfileStereotype(...
                dataReq.getReqSet,dataReq.typeName);
                if isStereotype
                    baseBehavior=slreq.internal.ProfileTypeBase.getMetaAttrValue(dataReq.typeName,'BaseBehavior');
                    if isempty(baseBehavior)
                        itemData.Type=dataReq.typeName;
                        itemData.SubType=dataReq.typeName;
                        typeLabel=dataReq.typeName;
                        subTypeLabel='Stereotype';
                    else
                        itemData.Type=baseBehavior;
                        itemData.SubType=[itemData.Type,'##',dataReq.typeName];
                        typeLabel=baseBehavior;
                        subTypeLabel=dataReq.typeName;
                    end
                else
                    mfReqType=reqData.getRequirementType(dataReq.typeName);
                    if mfReqType.isBuiltin
                        itemData.Type=dataReq.typeName;
                        itemData.SubType=[itemData.Type,'##','#Other#'];
                        typeLabel=slreq.app.RequirementTypeManager.getDisplayName(dataReq.typeName);
                        subTypeLabel='Built in';
                    else
                        itemData.Type=mfReqType.superType.name;
                        itemData.SubType=[itemData.Type,'##',dataReq.typeName];
                        if strcmpi(mfReqType.superType.name,'Unset')
                            typeLabel=getString(message('Slvnv:slreq:Unset'));
                        else
                            typeLabel=slreq.app.RequirementTypeManager.getDisplayName(mfReqType.superType.name);
                        end

                        subTypeLabel=slreq.app.RequirementTypeManager.getDisplayName(dataReq.typeName);
                    end
                end

            end
            this.updateTypeList(itemData.Type,typeLabel);
            if~isempty(itemData.SubType)
                this.updateSubTypeList(itemData.Type,itemData.SubType,subTypeLabel);
            end

            itemData.IsRoot=false;
            if isempty(dataReq.parent)
                itemData.ParentID=dataReq.getReqSet.filepath;
            else
                itemData.ParentID=dataReq.parent.getFullID;
            end

            [incomingLinks,outgoingLinks]=dataReq.getLinks;

            itemData.updateLinkInfo(incomingLinks,outgoingLinks)

























            outData=itemData.exportData();
        end
    end
end

function out=getCustomAttributesInfoForReqSet(dataReqSet)
    allAttributes=dataReqSet.CustomAttributeRegistry.toArray;
    out=struct([]);
    for aIndex=1:length(allAttributes)
        cAtt=allAttributes(aIndex);
        out(aIndex).Name=cAtt.name;
        out(aIndex).Label=cAtt.name;
        out(aIndex).Type=cAtt.typeName.char;
        out(aIndex).Description=cAtt.description;
        out(aIndex).IsSystem=cAtt.isSystem;
        out(aIndex).IsReadOnly=cAtt.isReadOnly;
        if strcmpi(cAtt.typeName,'checkbox')
            out(aIndex).DefaultValue=cAtt.default;
        elseif strcmpi(cAtt.typeName,'Combobox')
            out(aIndex).Entries=cAtt.entries.toArray;
            out(aIndex).DefaultValue='Unset';
        elseif strcmpi(cAtt.typeName,'edit')
            out(aIndex).DefaultValue='';
        elseif strcmpi(cAtt.typeName,'datetime')
            out(aIndex).DefaultValue='';

        end
    end
end

function out=getCustomAttributesInfoForReq(dataReq,customAttributesInfo)
    out=struct([]);
    for index=1:length(customAttributesInfo)
        out(index).Name=customAttributesInfo(index).Name;
        out(index).Type=customAttributesInfo(index).Type;
        out(index).Value=dataReq.getAttribute(customAttributesInfo(index).Name,false);
    end

end
