classdef ArtifactTraverser<handle
    properties
        ArtifactPath;
        LoadIfNotLoaded=true;
        HierarchyInfo;
        ItemList;
        ItemID2FullIDList;
        ItemDetails;
        Domain;
        ArtifactID;
        Checksum;
        IsRoot;
        TypeList;
        Type2SubTypeMap;
        SubTypeList;
        KeywordList;
        AttributeList;
        IconType;
        DataExporter;
        UnresolvedIDList;
        UnresolvedID2LinkAsSrc;
        UnresolvedID2LinkAsDst;
        UnresolvedParentID='#?UnResolvedIDList?#';
    end

    methods
        function this=ArtifactTraverser()
            this.clearData();
        end

        function preTraverse(this,artifactName)
            if this.LoadIfNotLoaded
                this.loadArtifact(artifactName);
            end
        end

        function setArtifactID(this,artifactID)
            this.ArtifactID=artifactID;
        end

        function setArtifactPath(this,artifactPath)
            this.ArtifactPath=artifactPath;
        end

        function setArtifactInfo(this,artifactInfo)
            this.setArtifactID(artifactInfo.Artifact);
            this.setArtifactPath(artifactInfo.ArtifactPath);

        end

        function clearData(this)
            this.HierarchyInfo=containers.Map('KeyType','char','ValueType','any');
            this.ItemList='';
            this.ItemDetails=containers.Map('KeyType','char','ValueType','any');
            this.ArtifactID='';
            this.ArtifactPath='';
            this.Checksum='';
            this.IsRoot=false;
            this.TypeList=containers.Map('KeyType','char','ValueType','any');
            this.ItemID2FullIDList=containers.Map('KeyType','char','ValueType','any');
            this.SubTypeList=containers.Map('KeyType','char','ValueType','any');
            this.Type2SubTypeMap=containers.Map('KeyType','char','ValueType','any');
            this.KeywordList=containers.Map('KeyType','char','ValueType','any');
            this.AttributeList=containers.Map('KeyType','char','ValueType','any');
        end

        function out=getTraverseData(this)
            out.HierarchyInfo=containers.Map('KeyType','char','ValueType','any');
            out.HierarchyInfo(this.ArtifactID)=this.HierarchyInfo;
            out.ItemList=containers.Map('KeyType','char','valueType','any');
            out.ItemList(this.ArtifactID)=this.ItemList;
            out.ItemDetails=this.ItemDetails;
            out.ArtifactID=this.ArtifactID;
            out.ArtifactPath=this.ArtifactPath;
            out.Domain=this.Domain;

            out.TypeList=this.TypeList;
            out.SubTypeList=this.SubTypeList;
            out.Type2SubTypeMap=this.Type2SubTypeMap;
            out.ItemID2FullIDList=this.ItemID2FullIDList;
            out.KeywordList=this.KeywordList;
            out.AttributeList=this.AttributeList;
        end

        function needContinue(this)
            if~isempty(this.DataExporter)
                if this.DataExporter.TraverserCounter>this.DataExporter.MAX_COUNTER
                    this.DataExporter.TraverserCounter=1;
                    this.DataExporter.checkStatus();
                end

                this.DataExporter.TraverserCounter=this.DataExporter.TraverserCounter+1;
                this.DataExporter.updateProgressByItem()
            end
        end

        function setProgressRangeItems(this,value)
            if~isempty(this.DataExporter)

                this.DataExporter.setProgressRangeItems(value);
            end
        end

        function combineTwoData(this,extraData)
            this.ItemDetails=[this.ItemDetails;extraData.ItemDetails];
            this.TypeList=[this.TypeList;extraData.TypeList];
            this.SubTypeList=[this.SubTypeList;extraData.SubTypeList];
            this.Type2SubTypeMap=[this.Type2SubTypeMap;extraData.Type2SubTypeMap];
            this.ItemID2FullIDList=[this.ItemID2FullIDList;extraData.ItemID2FullIDList];
            this.KeywordList=[this.KeywordList;extraData.KeywordList];
            this.AttributeList=[this.AttributeList;extraData.AttributeList];
        end

        function updateKeywordList(this,keywordList)
            for kIndex=1:length(keywordList)
                cKeyword=keywordList{kIndex};
                if isKey(this.KeywordList,cKeyword)
                    keywordInfo=this.KeywordList(cKeyword);
                    keywordInfo.Count=keywordInfo.Count+1;
                    this.KeywordList(cKeyword)=keywordInfo;
                else
                    keywordInfo.Name=cKeyword;
                    keywordInfo.Count=1;
                    this.KeywordList(cKeyword)=keywordInfo;
                end
            end
        end


        function updateAttributeList(this,attributeList)
            for aIndex=1:length(attributeList)
                cAttribute=attributeList{aIndex};
                if isKey(this.AttributeList,cAttribute)
                    attributeInfo=this.AttributeList(cAttribute);
                    attributeInfo.Count=attributeInfo.Count+1;
                    this.AttributeList(cAttribute)=attributeInfo;
                else
                    attributeInfo.Name=cAttribute;
                    attributeInfo.Count=1;
                    this.AttributeList(cAttribute)=attributeInfo;
                end
            end
        end

        function updateTypeList(this,typeName,typeLabel)
            if isKey(this.TypeList,typeName)
                typeInfo=this.TypeList(typeName);
                typeInfo.Count=typeInfo.Count+1;
                this.TypeList(typeName)=typeInfo;
            else
                if nargin<3
                    typeLabel=typeName;
                end
                typeInfo.Label=typeLabel;
                typeInfo.Name=typeName;
                typeInfo.Count=1;
                this.TypeList(typeName)=typeInfo;
            end
        end

        function updateItemID2FullList(this,itemID,itemFullID)

            if isKey(this.ItemID2FullIDList,itemID)
                fullIDList=this.ItemID2FullIDList(itemID);
            else
                fullIDList={};
            end

            if~ismember(itemFullID,fullIDList)
                fullIDList{end+1}=itemFullID;
            end

            this.ItemID2FullIDList(itemID)=fullIDList;
        end

        function updateSubTypeList(this,typeName,subTypeName,subTypeLabel)
            subTypeKey=subTypeName;
            if isKey(this.SubTypeList,subTypeKey)
                subTypeStruct=this.SubTypeList(subTypeKey);
                subTypeStruct.Count=subTypeStruct.Count+1;

                this.SubTypeList(subTypeKey)=subTypeStruct;
            else
                if nargin<4
                    subTypeParsing=strsplit(subTypeName,'##');
                    subTypeLabel=subTypeParsing{2};
                end

                subTypeStruct.Label=subTypeLabel;
                subTypeStruct.Name=subTypeName;
                subTypeStruct.Count=1;

                this.SubTypeList(subTypeKey)=subTypeStruct;


                subTypeList={};

                if isKey(this.Type2SubTypeMap,typeName)
                    subTypeList=this.Type2SubTypeMap(typeName);
                end

                subTypeList{end+1}=subTypeName;
                this.Type2SubTypeMap(typeName)=subTypeList;

            end


        end
    end

    methods(Abstract)
        traverse(this,artifactName,unresolvedIDInfo);
        loadArtifact(this,artifactName);
    end

end