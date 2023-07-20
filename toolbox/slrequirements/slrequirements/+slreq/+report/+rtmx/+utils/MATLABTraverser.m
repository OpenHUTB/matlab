classdef MATLABTraverser<slreq.report.rtmx.utils.ArtifactTraverser




    properties




MTree
Text
NewLinePositions
MaxLineNum

        SupportedType;

LinkIDToRangeMap
LowerRangeToID
UpperRangeToID
MATLABLinkDataTree
MATLABLinkDataTable




LineNumberToBookIds
IsMTest
IsScript
IsFunction
IsClass

    end

    methods(Access=private)
        function this=MATLABTraverser()

            this@slreq.report.rtmx.utils.ArtifactTraverser()
            this.Domain='matlabcode';
            this.LoadIfNotLoaded=false;
            this.SupportedType=containers.Map({'COMMENT','EVENTS','EVENT','CLASSDEF','METHODS',...
            'FUNCTION','PROPERTIES','ENUMERATION'},...
            {false,false,false,true,true,true,false,false});
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent cachedObj
            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.MATLABTraverser();
            end
            obj=cachedObj;
            obj.ItemDetails=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods
        function loadArtifact(this,matlabcodePath)%#ok<INUSD>

        end

        function clearData(this)
            clearData@slreq.report.rtmx.utils.ArtifactTraverser(this);
            this.MTree={};
            this.IsMTest=false;
            this.ArtifactID='';
            this.LineNumberToBookIds={};
        end

        function out=isSupportedTypes(this,nodeType)
            out=isKey(this.SupportedType,nodeType)&&this.SupportedType(nodeType);
        end

        function preTraverse(this)
            this.IsMTest=false;
            this.getLinkInfoFromFile();
        end

        function traverse(this)


            this.preTraverse();














































            import slreq.report.rtmx.utils.*
            this.MTree=mtree(this.ArtifactPath,'-file','-comments');
            this.setupTextInfo(this.ArtifactPath);
            this.traverseFlatList();
            this.traverseHierarchy();
        end
    end

    methods(Access=private)

        function setupTextInfo(this,artifactPath)









            this.Text=fileread(artifactPath);
            this.Text=strrep(this.Text,char(13),'');
            this.NewLinePositions=strfind(this.Text,newline);
            this.MaxLineNum=numel(this.NewLinePositions)+1;
        end


        function range=getRangeFromLineNumber(this,startLine,endLine)
            if startLine==1
                startRange=1;
            elseif startLine>this.MaxLineNum



                startRange=length(this.Text)+1;
            else
                startRange=this.NewLinePositions(startLine-1)+1;
            end


            if endLine>=this.MaxLineNum





                endRange=length(this.Text)+1;
            else
                endRange=this.NewLinePositions(endLine);
            end

            range=[startRange,endRange];
        end


        function lineNo=getLineNumberFromPosition(this,position)






            lineNo=this.getClosestLineNumberFromPos([1,this.MaxLineNum],position)+1;
        end


        function out=getClosestLineNumberFromPos(this,newLineRanges,pos)


            if newLineRanges(1)>=newLineRanges(2)-1
                out=newLineRanges(1);
                return;
            end

            middleOne=newLineRanges(1)+floor((newLineRanges(2)-newLineRanges(1))/2);

            if this.NewLinePositions(middleOne)>pos
                out=this.getClosestLineNumberFromPos([middleOne,newLineRanges(2)],pos);
            elseif this.NewLinePositions(middleOne)<pos
                out=this.getClosestLineNumberFromPos([middleOne,newLineRanges(2)],pos);
            else
                out=middleOne-1;
            end
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


        function traverseFlatList(this)





            this.setProgressRangeItems(0);
            if strcmpi(this.MTree.root.kind,'err')
                error(message('Slvnv:slreq_rtmx:TraverseErrorInvalidMATLABCode',this.ArtifactPath));
            end
            if this.MTree.FileType==mtree.Type.ClassDefinitionFile
                if rmiml.RmiMUnitData.isMUnitFile(this.ArtifactPath)
                    this.IsMTest=true;
                end
                this.IsClass=true;
                this.IsScript=false;
                this.IsFunction=false;
                parsingClass(this);
            elseif this.MTree.FileType==mtree.Type.FunctionFile
                if rmiml.RmiMUnitData.isMUnitFile(this.ArtifactPath)
                    this.IsMTest=true;
                end
                this.IsClass=false;
                this.IsScript=false;
                this.IsFunction=true;
                parsingFunction(this);
            elseif this.MTree.FileType==mtree.Type.ScriptFile
                this.IsClass=false;
                this.IsScript=true;
                this.IsFunction=false;
                parsingScripts(this);
            else



                error('We could not parsing this matlab file')
            end
        end

        function parsingClass(this)
            itemData=this.createTextItemData(this.MTree,[]);
            parsingNext(this,this.MTree.root,itemData('FullID'));
        end

        function parsingScripts(this)
            import slreq.report.rtmx.utils.*
            this.createTextItemData(this.MTree,[]);

            allTextRanges=slreq.utils.getLinkedRanges(this.ArtifactID);
            artifactInfo=this.ItemDetails(this.ArtifactID);
            allChildren=artifactInfo('ChildrenIDs');
            for rIndex=1:length(allTextRanges)
                cTextRange=allTextRanges(rIndex);
                textStruct.artifact=cTextRange.artifactUri;
                textStruct.domain='linktype_rmi_matlab';
                textStruct.id=[this.ArtifactID,'~',cTextRange.id];
                outRangeLinks=cTextRange.getLinks;
                dataReq=slreq.data.ReqData.getInstance.getRequirementItem(textStruct,false);
                if isempty(dataReq)
                    inRangeLinks=[];
                else
                    inRangeLinks=dataReq.getLinks();
                end
                if~isempty(outRangeLinks)||~isempty(inRangeLinks)




                    startPosition=cTextRange.startPos;
                    endPosition=cTextRange.endPos;
                    startLineNo=this.getLineNumberFromPosition(startPosition);
                    endLineNo=this.getLineNumberFromPosition(endPosition);
                    id=cTextRange.id;
                    lineRange=[num2str(startLineNo),'-',num2str(endLineNo)];
                    range=[num2str(startPosition),'-',num2str(endPosition)];
                    fullID=[this.ArtifactID,':',lineRange];

                    itemData=TextItemIDData(fullID);
                    itemData.ArtifactID=this.ArtifactID;
                    itemData.ItemID=range;
                    this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
                    itemData.Domain='matlabcode';
                    itemData.Range=range;
                    itemData.StartPos=cTextRange.startPos;
                    itemData.EndPos=cTextRange.endPos;
                    itemData.StartLine=startLineNo;
                    itemData.EndLine=endLineNo;
                    itemData.TextIDList={id};
                    itemData.IsRoot=false;

                    itemData.HasID=true;
                    itemData.ParentID=this.ArtifactID;
                    allChildren{end+1}=fullID;%#ok<AGROW> mapping update
                    itemData.Type='ScriptInMATLABFile';
                    this.updateTypeList('ScriptInMATLABFile',getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABScriptInFile')));
                    textAdapter=cTextRange.getAdapter;



                    [~,desc,longDesc]=textAdapter.getIconSummaryTooltipFromSourceItem(cTextRange,textStruct.artifact,id);
                    if isempty(desc)
                        desc='?';
                    end
                    itemData.Desc=desc;
                    itemData.LongDesc=longDesc;








                    updateLinkInfo(this,itemData)










                    outData=itemData.exportData();
                    this.ItemDetails(itemData.FullID)=outData;
                end
            end

            artifactDetails=this.ItemDetails(this.ArtifactID);
            artifactDetails('ChildrenIDs')=allChildren;%#ok<NASGU> mapping update

        end


        function parsingInvalidMCode(this)%#ok<MANU>

        end


        function getLinkInfoFromFile(this)
            this.MATLABLinkDataTree=containers.Map('keytype','char','valuetype','any');
            this.MATLABLinkDataTable=rmiml.getReqTableData(this.ArtifactPath);
            this.createLinkDataRangeTree();
            this.setupLineNumberToBookIds();
        end


        function out=getLinkInfoFromLineRange(this,lineRange)
            out=this.searchNodeFromTree(this.MATLABLinkDataTree,lineRange,false);
        end


        function interval=searchNodeFromTree(this,currentNode,nodeRange,firstOnly)
            if nargin<3
                firstOnly=true;
            end
            interval={};
            if isempty(currentNode)
                interval={};
                return;
            end

            if nodeRange(1)>currentNode('max')
                interval={};
                return;
            end







            if(nodeRange(1)>=floor(currentNode('low'))&&nodeRange(2)<=currentNode('high'))...
                ||(nodeRange(1)<=floor(currentNode('low'))&&nodeRange(2)>=floor(currentNode('low')))...
                ||(nodeRange(1)<=currentNode('high')&&nodeRange(2)>=currentNode('high'))...
                ||(nodeRange(1)<=floor(currentNode('low'))&&nodeRange(2)>=currentNode('high'))
                interval={currentNode};
                if firstOnly
                    return;
                end
            end

            if isempty(currentNode('leftNode'))
                currentInterval=this.searchNodeFromTree(currentNode('rightNode'),nodeRange,firstOnly);
                if firstOnly
                    interval=currentInterval;
                    return;
                end
                interval=[currentInterval;interval];
            else
                leftnode=currentNode('leftNode');
                if firstOnly&&leftnode('max')<nodeRange(1)
                    currentInterval=this.searchNodeFromTree(currentNode('rightNode'),nodeRange,firstOnly);
                    if firstOnly
                        interval=currentInterval;
                        return;
                    end
                    interval=[currentInterval;interval];
                else
                    currentInterval=this.searchNodeFromTree(currentNode('rightNode'),nodeRange,firstOnly);
                    interval=[currentInterval;interval];
                end

                currentInterval=this.searchNodeFromTree(currentNode('leftNode'),nodeRange,firstOnly);
                if firstOnly
                    interval=currentInterval;
                    return;
                end
                interval=[currentInterval;interval];
            end
        end

        function insertModeIntoTree(this,currentNode,nodeMap)
            currentNode('max')=max(currentNode('max'),nodeMap('max'));
            if nodeMap('low')<currentNode('low')
                if isempty(currentNode('leftNode'))
                    currentNode('leftNode')=nodeMap;
                else
                    this.insertModeIntoTree(currentNode('leftNode'),nodeMap);
                end
            end

            if nodeMap('low')==currentNode('low')

                if nodeMap('high')==currentNode('high')
                    return
                else
                    nodeMap('low')=nodeMap('low')+0.001;
                end
            end

            if nodeMap('low')>currentNode('low')
                if isempty(currentNode('rightNode'))
                    currentNode('rightNode')=nodeMap;%#ok<NASGU>
                else
                    this.insertModeIntoTree(currentNode('rightNode'),nodeMap);
                end
            end

        end



        function setupLineNumberToBookIds(this)
            nodeList=this.MATLABLinkDataTable;
            this.LineNumberToBookIds={};
            nodeSize=size(nodeList);
            for index=1:nodeSize(1)

                lineRange=nodeList{index,4};
                bookmarkId=nodeList{index,1};
                for rIndex=lineRange(1):lineRange(2)
                    if length(this.LineNumberToBookIds)<rIndex
                        this.LineNumberToBookIds{rIndex}={};
                    end
                    this.LineNumberToBookIds{rIndex}=[this.LineNumberToBookIds{rIndex},bookmarkId];
                end

            end
        end


        function createLinkDataRangeTree(this)
            nodeList=this.MATLABLinkDataTable;
            if isempty(nodeList)
                this.MATLABLinkDataTree=containers.Map;
                return;
            else
                indexList=randperm(size(nodeList,1));
                this.MATLABLinkDataTree=containers.Map('keytype','char','valuetype','any');
                this.MATLABLinkDataTree('low')=nodeList{indexList(1),4}(1);
                this.MATLABLinkDataTree('high')=nodeList{indexList(1),4}(2);
                this.MATLABLinkDataTree('max')=nodeList{indexList(1),4}(2);
                this.MATLABLinkDataTree('bookMark')=nodeList{indexList(1),1};
                this.MATLABLinkDataTree('range')=nodeList{indexList(1),2};
                this.MATLABLinkDataTree('leftNode')=[];
                this.MATLABLinkDataTree('rightNode')=[];
            end


            for index=2:length(indexList)
                cNode=nodeList(indexList(index),1:end);
                cNodeMap=containers.Map('keytype','char','valuetype','any');
                cNodeMap('low')=cNode{4}(1);
                cNodeMap('high')=cNode{4}(2);
                cNodeMap('bookMark')=cNode{1};
                cNodeMap('range')=cNode{2};
                cNodeMap('max')=cNode{4}(2);
                cNodeMap('leftNode')=[];
                cNodeMap('rightNode')=[];
                this.insertModeIntoTree(this.MATLABLinkDataTree,cNodeMap);
            end
        end

        function parsingFunction(this)
            itemData=this.createTextItemData(this.MTree,[]);
            parsingNext(this,this.MTree.root,itemData('FullID'));
        end


        function parsingNext(this,currentNode,parentID)


            if this.isSupportedTypes(currentNode.kind)
                parentInfo=this.ItemDetails(parentID);
                if strcmpi(currentNode.kind,'comment')

                    [nextNode,itemData]=this.createCommentData(currentNode,parentID);
                else
                    itemData=this.createTextItemData(currentNode,parentID);
                    nextNode=currentNode.Next;
                end

                childrenIDs=parentInfo('ChildrenIDs');
                childrenIDs{end+1}=itemData('FullID');
                parentInfo('ChildrenIDs')=childrenIDs;%#ok<NASGU>

            else
                nextNode=currentNode.Next;
            end

            if nextNode.count~=0
                this.parsingNext(nextNode,parentID);
            end

        end

        function[lineRange,charRange]=getRangesForNode(this,node,useFirstLineOnly)






            startLine=node.lineno;
            if useFirstLineOnly
                endLine=node.lineno;
            else
                endLine=node.lastone;
            end

            if numel(startLine)>1
                startLine=node.pos2lc(node.leftposition);
            end

            if numel(endLine)>1
                endLine=node.pos2lc(node.rightposition);
            end

            lineRange=[startLine,endLine];
            if nargout>1
                charRange=this.getRangeFromLineNumber(startLine,endLine);
            end
        end


        function[nextNode,outData]=createCommentData(this,commentNode,parentFullID)

            import slreq.report.rtmx.utils.*

            [lineRange,charRange]=this.getRangesForNode(commentNode,false);
            startPosition=charRange(1);
            endPosition=charRange(2);
            startLineNo=lineRange(1);
            endLineNo=lineRange(2);

            nextNode=commentNode.Next;
            commentString=commentNode.string;
            while nextNode.count~=0&&strcmpi(nextNode.kind,'comment')
                nextNodeStartLine=nextNode.pos2lc(nextNode.leftposition);
                if nextNodeStartLine-endLineNo<2
                    endPosition=nextNode.rightposition;
                    endLineNo=nextNode.pos2lc(endPosition);
                    commentString=sprintf('%s\n%s',commentString,nextNode.string);
                    nextNode=nextNode.Next;
                else
                    break;
                end
            end


            [hasID,id]=isInSameIDBetweenLines(this,startLineNo,endLineNo);
            lineRange=[num2str(startLineNo),'-',num2str(endLineNo)];
            range=[num2str(startPosition),'-',num2str(endPosition)];
            fullID=[this.ArtifactID,':',lineRange];

            itemData=TextItemIDData(fullID);
            itemData.ArtifactID=this.ArtifactID;
            itemData.ItemID=range;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.Range=range;
            itemData.StartPos=startPosition;
            itemData.EndPos=endPosition;
            itemData.StartLine=startLineNo;
            itemData.EndLine=endLineNo;
            itemData.HasID=hasID;
            itemData.TextIDList=id;
            itemData.Desc=commentString;
            itemData.LongDesc=commentString;
            itemData.ParentID=parentFullID;
            itemData.Type='COMMENT';

            this.updateTypeList(itemData.Type,getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABComment')));

            if hasID
                updateLinkInfo(this,itemData)
            else
                this.loopInsideContent(startLineNo,endLineNo,itemData)
            end

            outData=itemData.exportData();
            this.ItemDetails(itemData.FullID)=outData;
        end

        function loopInsideContent(this,startLineNo,endLineNo,itemData)
            cLine=startLineNo;
            while cLine<=endLineNo
                cPos=this.MTree.lc2pos(cLine,1);
                cID=slreq.getRangeId(this.ArtifactID,cPos,false);
                if isempty(cID)
                    cLine=cLine+1;
                else

                    [endLineNumber,childFullID]=this.createTextIDDataBasedOnID(cID,itemData.FullID);
                    itemData.ChildrenIDs{end+1}=childFullID;
                    cLine=endLineNumber+1;
                end
            end
        end


        function[idToLineRangeMap,startLineToIDMap,endLineToIDMap]=getIDListBetweenLineNumbers(this,startLineNo,endLineNo)
            idToLineRangeMap=containers.Map('KeyType','char','ValueType','any');
            startLineToIDMap=containers.Map('KeyType','double','ValueType','char');
            endLineToIDMap=containers.Map('KeyType','double','ValueType','char');

            allLinkInfo=this.getLinkInfoFromLineRange([startLineNo,endLineNo]);
            for index=1:length(allLinkInfo)
                cLinkInfo=allLinkInfo{index};
                idToLineRangeMap(cLinkInfo('bookMark'))=[floor(cLinkInfo('low')),cLinkInfo('high')];
                startLineToIDMap(floor(cLinkInfo('low')))=cLinkInfo('bookMark');
                endLineToIDMap(cLinkInfo('high'))=cLinkInfo('bookMark');
            end
        end


        function outData=createTextItemData(this,currentNode,parentFullID,parentAttributeList)


            if nargin<4
                parentAttributeList={};
            end

            import slreq.report.rtmx.utils.*

            [attributeList,useFirstLineOnly]=this.getMLTestAttributes(currentNode,parentAttributeList);

            [fullID,hasID,ID,itemId]=this.getTextFullID(currentNode,useFirstLineOnly);
            itemData=TextItemIDData(fullID);
            itemData.ArtifactID=this.ArtifactID;
            itemData.ItemID=itemId;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);

            [lineRange,charRange]=this.getRangesForNode(currentNode,useFirstLineOnly);
            itemData.StartPos=charRange(1);
            itemData.EndPos=charRange(2);
            itemData.StartLine=lineRange(1);
            itemData.EndLine=lineRange(2);
            itemData.Range=[num2str(charRange(1)),'-',num2str(charRange(2))];



            itemData.HasID=hasID;
            itemData.TextIDList=ID;

            itemData.IsRoot=false;
            try
                itemData.Type=currentNode.kind;
                typeLabel=getMATLABTypeLabelFromKind(itemData.Type);
            catch
                itemData.Type='MATLABFile';
                itemData.Link='NotLinkable';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABFile'));
            end

            itemData.ParentID=parentFullID;
            this.updateTypeList(itemData.Type,typeLabel);
            needNext=false;
            switch lower(itemData.Type)
            case 'comment'
                itemData.Attribute=getCommentsNodeInfo(currentNode);
                itemData.Desc=currentNode.string;
                itemData.LongDesc=itemData.Desc;
            case 'function'
                itemData.Attribute=getFunctionNodeInfo(currentNode);
                if~isempty(attributeList)
                    itemData.Attributes=attributeList;
                    this.updateAttributeList(itemData.Attributes)
                end
                itemData.Desc=currentNode.Fname.string;

                itemData.LongDesc=itemData.Desc;
                if~hasID
                    startLineNo=currentNode.lineno;
                    endLineNo=currentNode.lastone;
                    [idListMap,~,~]=this.getIDListBetweenLineNumbers(startLineNo,endLineNo);

                    itemData.TextIDList=idListMap.keys;
                    if(idListMap.Count>0)
                        hasID=true;
                    end

                end
            case 'classdef'
                itemData.Attribute=getClassDefNodeInfo(currentNode);
                itemData.Desc=['Class: ',itemData.Attribute.ClassName];
                itemData.LongDesc=itemData.Desc;
                needNext=true;
            case 'properties'

                itemData.Attribute=getPropertiesNodeInfo(currentNode);


                childNode=currentNode.Body;
                while childNode.count~=0

                    if strcmpi(childNode.kind,'comment')

                        if this.isSupportedTypes('COMMENT')
                            [childNode,commentDataMap]=this.createCommentData(childNode,itemData.FullID);
                            itemData.ChildrenIDs{end+1}=commentDataMap('FullID');
                        else
                            childNode=childNode.Next;
                        end
                    else
                        childItemMap=this.createTextItemData(childNode,itemData.FullID);
                        if strcmpi(childItemMap('Type'),'EQUALS')

                            childItemMap('Type')='PROPERTY';
                            this.updateTypeList(childItemMap('Type'),getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABProperty')));







                            childItemMap('Desc')=childNode.Left.string;
                            itemData.LongDesc=itemData.Desc;
                            childItemMap('Attribute')=itemData.Attribute;
                        end
                        itemData.ChildrenIDs{end+1}=childItemMap('FullID');
                        childNode=childNode.Next;
                    end
                end
                itemData.Desc=['Properties(',strjoin(itemData.Attribute.AttributeList,';'),')'];
                itemData.LongDesc=itemData.Desc;
            case 'events'
                itemData.Attribute=getEventsNodeInfo(currentNode);
                itemData.Desc=['Events(',strjoin(itemData.Attribute.AttributeList,';'),')'];
                itemData.LongDesc=itemData.Desc;

                childNode=currentNode.Body;
                while childNode.count~=0

                    if strcmpi(childNode.kind,'comment')

                        if this.isSupportedTypes('COMMENT')
                            [childNode,commentDataMap]=this.createCommentData(childNode,itemData.FullID);
                            itemData.ChildrenIDs{end+1}=commentDataMap('FullID');
                        else
                            childNode=childNode.Next;
                        end
                    else

                        childItemMap=this.createTextItemData(childNode,itemData.FullID);
                        if strcmpi(childItemMap('Type'),'event')
                            childItemMap('Attribute')=itemData.Attribute;
                        end
                        itemData.ChildrenIDs{end+1}=childItemMap('FullID');
                        childNode=childNode.Next;
                    end
                end

            case 'methods'
                itemData.Attribute=getMethodsNodeInfo(currentNode);
                itemData.Attributes=itemData.Attribute.AttributeList;
                this.updateAttributeList(itemData.Attributes);
                childNode=currentNode.Body;

                while childNode.count~=0
                    if strcmpi(childNode.kind,'comment')

                        if this.isSupportedTypes('COMMENT')
                            [childNode,commentDataMap]=this.createCommentData(childNode,itemData.FullID);
                            itemData.ChildrenIDs{end+1}=commentDataMap('FullID');
                        else
                            childNode=childNode.Next;
                        end
                    else
                        childItemMap=this.createTextItemData(childNode,itemData.FullID,itemData.Attributes);
                        if strcmpi(childItemMap('Type'),'FUNCTION')
                            childItemMap('Type')='FUNCTION';
                            this.updateTypeList(childItemMap('Type'),getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABFunction')));






                            tempAttributes=childItemMap('Attribute');
                            tempAttributes.Attribute=itemData.Attribute;
                            childItemMap('Attribute')=tempAttributes;
                            setAttributes(childItemMap,itemData.Attribute.AttributeList);
                            this.updateAttributeList(tempAttributes.Attribute.AttributeList);
                        end
                        itemData.ChildrenIDs{end+1}=childItemMap('FullID');
                        childNode=childNode.Next;
                    end
                end
                if isempty(itemData.Attribute.AttributeList)
                    itemData.Desc='Methods';
                else
                    itemData.Desc=['Methods(',strjoin(itemData.Attribute.AttributeList,';'),')'];
                end
                itemData.LongDesc=itemData.Desc;

            case 'event'
                itemData.Desc=currentNode.Left.string;
                itemData.LongDesc=itemData.Desc;
            case 'enumeration'
                itemData.Attribute=getEnumerationNodeInfo(currentNode);
                if isempty(itemData.Attribute.AttributeList)
                    itemData.Desc='Enumeration';
                else
                    itemData.Desc=['Enumeration(',strjoin(itemData.Attribute.AttributeList,';'),')'];
                end
                itemData.LongDesc=itemData.Desc;

                childNode=currentNode.Body;
                while childNode.count~=0
                    if strcmpi(childNode.kind,'comment')
                        if this.isSupportedTypes('COMMENT')
                            [childNode,commentDataMap]=this.createCommentData(childNode,itemData.FullID);
                            itemData.ChildrenIDs{end+1}=commentDataMap('FullID');
                        else
                            childNode=childNode.Next;
                        end
                    else
                        childItemMap=this.createTextItemData(childNode,itemData.FullID);
                        if strcmpi(childItemMap('Type'),'ID')
                            childItemMap('Attribute')=itemData.Attribute;
                            childItemMap('Type')='EnumerationID';
                            this.updateTypeList(childItemMap('Type'),getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABEnumerationID')));







                        end
                        itemData.ChildrenIDs{end+1}=childItemMap('FullID');
                        childNode=childNode.Next;
                    end
                end
            otherwise

            end

            if isempty(parentFullID)
                [~,fileName,fileext]=fileparts(this.ArtifactID);
                itemData.Desc=[fileName,fileext];
                itemData.LongDesc=this.ArtifactID;
            end

            if hasID&&~strcmpi(itemData.Type,'MATLABFile')
                updateLinkInfo(this,itemData)
            end

            outData=itemData.exportData();
            this.ItemDetails(itemData.FullID)=outData;
            if needNext
                this.parsingNext(currentNode.Body,itemData.FullID);
            end
        end

        function[fullid,hasID,id,itemId]=getTextFullID(this,nodeInfo,useFirstLineOnly)
            if nargin<3
                useFirstLineOnly=false;
            end
            [lineRange,charRange]=this.getRangesForNode(nodeInfo,useFirstLineOnly);
            leftPos=charRange(1);
            rightPos=charRange(2);
            startLineNo=lineRange(1);
            endLineNo=lineRange(2);

            lineRange=[num2str(startLineNo),'-',num2str(endLineNo)];
            range=[num2str(leftPos),'-',num2str(rightPos)];

            [hasID,id]=isInSameIDBetweenLines(this,startLineNo,endLineNo);

            itemId=range;
            if nodeInfo.iswhole
                fullid=this.ArtifactID;
            else
                fullid=[this.ArtifactID,':',lineRange];
            end

        end

        function bookmarkIds=getIDForLine(this,lineNum)
            if lineNum>length(this.LineNumberToBookIds)
                bookmarkIds={};
                return
            end

            bookmarkIds=this.LineNumberToBookIds{lineNum};
        end

        function[tf,id]=isInSameIDBetweenLines(this,startLine,endLine)

            startIds=this.getIDForLine(startLine);
            endIds=this.getIDForLine(endLine);

            commonIds=intersect(startIds,endIds);

            if isempty(commonIds)
                tf=false;
                id={};
            else
                tf=true;
                id=commonIds;
            end
        end

        function[endLineNumber,fullID]=createTextIDDataBasedOnID(this,linkableID,parentFullID)
            import slreq.report.rtmx.utils.*
            textRangeObj=slreq.utils.getLinkedRanges(this.ArtifactID,linkableID);




            startLine=this.getLineNumberFromPosition(textRangeObj.startPos);
            endLine=this.getLineNumberFromPosition(textRangeObj.endPos);

            range=[num2str(textRangeObj.startPos),'-',num2str(textRangeObj.endPos)];

            lineRange=[num2str(startLine),'-',num2str(endLine)];


            fullID=[this.ArtifactID,':',lineRange];

            itemData=TextItemIDData(fullID);
            itemData.ArtifactID=this.ArtifactID;
            itemData.Range=range;
            itemData.ItemID=range;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.StartPos=textRangeObj.startPos;
            itemData.EndPos=textRangeObj.endPos;
            itemData.StartLine=startLine;
            itemData.EndLine=endLine;
            itemData.HasID=true;
            itemData.TextIDList={linkableID};

            itemData.IsRoot=false;

            itemData.Type='ScriptInFunction';
            itemData.ParentID=parentFullID;

            this.updateTypeList(itemData.Type,getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABScriptInFunction')));







            adapter=textRangeObj.getAdapter();

            srcStr=adapter.getSummary(this.ArtifactID,linkableID);

            itemData.Desc=srcStr;
            itemData.LongDesc=itemData.Desc;

            updateLinkInfo(this,itemData)
            endLineNumber=itemData.EndLine;
            outData=itemData.exportData();
            this.ItemDetails(itemData.FullID)=outData;
        end

        function updateLinkInfo(this,itemData)
            reqData=slreq.data.ReqData.getInstance;

            dataLinkSet=reqData.getLinkSet(this.ArtifactID);
            if~isempty(dataLinkSet)



                outgoingLinks=slreq.data.Link.empty();
                incomingLinks=slreq.data.Link.empty();

                for index=1:length(itemData.TextIDList)
                    cID=itemData.TextIDList{index};
                    dataSourceItem=dataLinkSet.getLinkedItem(cID);

                    outgoingLinks=[outgoingLinks,dataSourceItem.getLinks()];%#ok<AGROW> not big

                    sourceStruct=struct();
                    sourceStruct.artifact=this.ArtifactID;
                    sourceStruct.id=['@',cID];
                    sourceStruct.domain='linktype_rmi_matlab';

                    dataReq=slreq.data.ReqData.getInstance.getRequirementItem(sourceStruct,false);
                    if~isempty(dataReq)
                        incomingLinks=[incomingLinks,dataReq.getLinks()];%#ok<AGROW> not big
                    end
                end
                itemData.updateLinkInfo(incomingLinks,outgoingLinks);
            end
        end

        function[attributeList,useFirstLine]=getMLTestAttributes(this,node,parentAttributeList)


            useFirstLine=false;
            attributeList={};
            if this.IsMTest
                try
                    nodeType=node.kind;
                catch
                    nodeType='MATLABFile';
                end

                switch lower(nodeType)
                case 'function'
                    if this.IsFunction
                        nodeName=node.Fname.string;
                        if startsWith(nodeName,'test','IgnoreCase',true)||endsWith(nodeName,'test','IgnoreCase',true)
                            attributeList={getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABAtrributeTest'))};
                            useFirstLine=true;
                        elseif strcmp(nodeName,'setupOnce')||strcmp(nodeName,'teardownOnce')
                            attributeList={getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABAtrributeFileFilexture'))};
                        elseif strcmp(nodeName,'setup')||strcmp(nodeName,'teardown')
                            attributeList={getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABAtrributeFreshFixture'))};
                        else
                            [~,fileName]=fileparts(this.ArtifactPath);
                            if strcmp(nodeName,fileName)
                                attributeList={getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABAtrributeMainFunction'))};
                                useFirstLine=true;
                            else
                                attributeList={getString(message('Slvnv:slreq_rtmx:FilterTypesMATLABAtrributeLocal'))};
                            end
                        end
                    end

                    if this.IsClass
                        if ismember('Test',parentAttributeList)



                            useFirstLine=true;
                        end
                    end

                case 'classdef'
                    useFirstLine=true;
                case 'methods'
                    attribute=getMethodsNodeInfo(node);
                    attributesList=attribute.AttributeList;
                    if ismember('Test',attributesList)
                        useFirstLine=true;
                    end
                otherwise

                end
            end
        end
    end



end



function out=getClassDefNodeInfo(classNode)
    out=struct();
    if(classNode.Cexpr.Right.count==0)

        out.ParentClass={};
        out.ClassName=classNode.Cexpr.string;
    else

        out.ClassName=classNode.Cexpr.Left.string;

        parentClasses=classNode.Cexpr.Right.tree2str;
        parentClassList=strsplit(parentClasses,'&');
        out.ParentClasses=strtrim(parentClassList);
    end
end

function out=getFunctionNodeInfo(functionNode)
    out=struct();
    out.FunctionName=functionNode.Fname.string;
    out.OutArts=functionNode.Outs.strings;
    out.Arguments=functionNode.Arguments.strings;

end

function out=getCommentsNodeInfo(commentsNode)%#ok<INUSD>
    out=struct();
end


function out=getEventsNodeInfo(eventsNode)
    out=struct();
    out.AttributeList=getAttributeList(eventsNode.Attr);
end

function out=getPropertiesNodeInfo(propertiesNode)
    out=struct();
    out.AttributeList=getAttributeList(propertiesNode.Attr);
end

function out=getMethodsNodeInfo(methodsNode)
    out=struct();
    out.AttributeList=getAttributeList(methodsNode.Attr);
end

function out=getAttributeList(attrNode)
    if attrNode.count~=0
        arg=attrNode.Arg;
        attributeMap=containers.Map('KeyType','char','ValueType','any');
        while arg.count~=0
            if arg.Right.count==0
                attributeMap(arg.Left.string)=true;
            else
                attributeString=[arg.Left.string,':',arg.Right.string];
                attributeMap(attributeString)=true;
            end
            arg=arg.Next;
        end
        out=attributeMap.keys;
    else
        out={};
    end
end

function out=getEnumerationNodeInfo(enumerationNode)
    out=struct();
    out.AttributeList=getAttributeList(enumerationNode.Attr);
end

function setAttributes(childItemMap,attributeList)
    for aIndex=1:length(attributeList)
        cAttribute=attributeList{aIndex};
        childItemMap(['attributes##',cAttribute])=true;
    end
end

function out=getMATLABTypeLabelFromKind(kindName)
    kindKeyName=[upper(kindName(1)),lower(kindName(2:end))];
    kindKey=['FilterTypesMATLAB',kindKeyName];
    try
        out=getString(message(['Slvnv:slreq_rtmx:',kindKey]));
    catch ex %#ok<NASGU>

        out=kindName;
    end

end

function lineNo=getLineFromPos(mtreeobj,pos)%#ok<DEFNU> 
    try
        lineNo=mtreeobj.pos2lc(pos);
    catch ex
        if strcmpi(ex.identifier,'MATLAB:badsubscript')


            lineNo=mtreeobj.pos2lc(pos-1);
        else
            rethrow(ex);
        end

    end
end

