classdef SLDDTraverser<slreq.report.rtmx.utils.ArtifactTraverser

    properties
DDConnection
    end

    methods(Access=private)
        function this=SLDDTraverser()

            this@slreq.report.rtmx.utils.ArtifactTraverser()
            this.Domain='sldd';
        end
    end

    methods(Static)
        function obj=getInstance()


            persistent cachedObj
            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.SLDDTraverser;
            end
            obj=cachedObj;
        end
    end
    methods
        function loadArtifact(this,ddFile)
            this.DDConnection=Simulink.dd.open(ddFile);
            this.ArtifactID=ddFile;
        end

        function clearData(this)
            clearData@slreq.report.rtmx.utils.ArtifactTraverser(this);
            this.DDConnection=[];
        end

        function traverse(this)

            this.preTraverse(this.ArtifactPath);












            import slreq.report.rtmx.utils.*






            this.traverseFlatList();
            this.traverseHierarchy();
        end


        function traverseFlatList(this)

            import slreq.report.rtmx.utils.*
            ddConn=this.DDConnection;

            entryNames=ddConn.getChildNames('Global');
            this.setProgressRangeItems(length(entryNames));
            itemData=SLDataItemIDData(this.ArtifactID);
            [~,fileName,fileext]=fileparts(this.ArtifactID);
            itemData.Desc=[fileName,fileext];
            itemData.LongDesc=this.ArtifactID;
            itemData.ArtifactID=this.ArtifactID;
            itemData.ItemID=this.ArtifactID;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.Domain=this.Domain;
            itemData.IsRoot=true;
            itemData.IconType='linktype-rmi-data';
            itemData.Type='DataDictionaryFile';
            itemData.Link='NotLinkable';

            for index=1:length(entryNames)
                cEntry=entryNames{index};
                outData=this.createItemData(cEntry);
                itemData.ChildrenIDs{end+1}=outData('FullID');
            end

            outData=itemData.exportData();

            this.ItemDetails(itemData.FullID)=outData;
        end


        function traverseHierarchy(this)
            hierarchy=traverseChildren(this,this.ArtifactID,0);
            this.HierarchyInfo=hierarchy;
        end



        function hierarchy=traverseChildren(this,currentID,level)
            itemDetails=this.ItemDetails(currentID);
            itemDetails('Level')=level;

            hierarchy.FullID=currentID;
            children=itemDetails('ChildrenIDs');
            childrenInfo=cell(size(children));
            level=level+1;
            for index=1:length(children)
                child=children{index};
                childrenInfo{index}=traverseChildren(this,child,level);
            end

            hierarchy.Children=childrenInfo;
            this.ItemDetails(currentID)=itemDetails;
        end



        function outData=createItemData(this,entryName)
            import slreq.report.rtmx.utils.*

            this.needContinue();
            ddConn=this.DDConnection;
            entryID=ddConn.getEntryID(['Global.',entryName]);
            entryInfo=ddConn.getEntryInfo(entryID);
            uuid=['UUID_',entryInfo.UUID.char];
            fullID=[this.ArtifactID,':',uuid];


            itemData=SLDataItemIDData(fullID);

            itemData.Desc=entryInfo.Name;
            itemData.LongDesc=entryInfo.Name;
            itemData.Domain=this.Domain;
            itemData.IsRoot=false;
            itemData.ItemID=uuid;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.Type=class(entryInfo.Value);
            if isnumeric(entryInfo.Value)
                itemData.Value=entryInfo.Value;
            else
                itemData.Value='N/A';
            end
            itemData.IconType='linktype-rmi-data';
            itemData.ClassName=entryInfo.ClassName;
            itemData.ValueTypeID=entryInfo.ValueTypeID;
            itemData.MetaclassName=entryInfo.MetaclassName;
            this.updateTypeList(itemData.Type);







            itemData.ArtifactID=this.ArtifactID;

            itemData.ParentID=this.ArtifactID;

            rData=slreq.data.ReqData.getInstance;





            dataLinkSet=rData.getLinkSet(this.ArtifactID);

            outgoingLinks=slreq.data.Link.empty();
            if~isempty(dataLinkSet)
                srcItem=dataLinkSet.getLinkedItem(uuid);
                if~isempty(srcItem)
                    outgoingLinks=srcItem.getLinks();
                end
            end


            sourceStruct=struct();
            sourceStruct.artifact=this.ArtifactID;
            sourceStruct.id=uuid;
            sourceStruct.domain='linktype_rmi_data';

            dataReq=rData.getRequirementItem(sourceStruct,false);
            if isempty(dataReq)
                incomingLinks=slreq.data.Link.empty();
            else
                incomingLinks=dataReq.getLinks();
            end

            itemData.updateLinkInfo(incomingLinks,outgoingLinks);

            outData=itemData.exportData();

            this.ItemDetails(itemData.FullID)=outData;
        end

    end

end





