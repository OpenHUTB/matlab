function paste(~)




    ed=Simulink.typeeditor.app.Editor.getInstance;
    treeComp=ed.getTreeComp;
    listComp=ed.getListComp;
    clipboard=ed.getClipboard;

    statusMsg=DAStudio.message('Simulink:busEditor:BusEditorPasteInProgressStatusMsg');
    ed.getStudio.setStatusBarMessage(statusMsg);

    assert(~isempty(clipboard.contents));

    treeCompSel=ed.getCurrentTreeNode;
    assert((length(treeCompSel)==1)&&...
    isa(treeCompSel{1},'Simulink.typeeditor.app.Source'));
    treeCompSelRow=treeCompSel{1};

    contentsArr=[clipboard.contents{:}];

    try
        getNewNames=@(parent)Simulink.typeeditor.utils.getUniqueChildName(parent,clipboard.names);
        switch clipboard.type
        case 'object'


            newParent=treeCompSelRow.getRoot;
            newNodeNames=getNewNames(newParent);
            busObjsToPaste={contentsArr.SourceObject};
            arrayfun(@(idx)newParent.NodeConnection.assignin(newNodeNames{idx},...
            busObjsToPaste{idx}),1:length(clipboard.names));
            newParent.insertNode(newNodeNames);
            newNodes=cell(length(newNodeNames),1);
            for i=1:length(newNodeNames)
                newNodes{i}=Simulink.typeeditor.utils.getNodeFromPath(newParent,newNodeNames{i});
            end
            treeComp.update(true);
            listComp.update(true);
            ed.setCurrentListNode(newNodes);
        case 'element'
            toWarn=false;
            warnStr='';
            warnTitle='';

            listCompSel=ed.getCurrentListNode;
            if isa(listCompSel{1},'Simulink.typeeditor.app.Object')
                newParent=listCompSel{1};
                isCurNodeElement=false;
            else
                newParent=listCompSel{1}.Parent;
                if length(listCompSel)>1
                    isCurNodeElement=false;
                else
                    isCurNodeElement=true;
                end
            end

            if newParent.IsConnectionType
                propName='Type';
                isConnectionElement=true;
            else
                propName='DataType';
                isConnectionElement=false;
            end

            root=newParent.getRoot;
            newElemNames=getNewNames(newParent);
            assert(newParent.IsConnectionType==all([contentsArr.IsConnectionType]));



            nodeIdxInParent=0;
            if isempty(newParent.Children)
                newChildren=copy(contentsArr);
                tempElemNodeNew=newChildren;
            else
                if isCurNodeElement
                    nodeIdxInParent=newParent.findIdx(listCompSel{1}.Name);
                end
                arrayfun(@(idx)evalin('caller',['contentsArr(',num2str(idx),').SourceObject.Name = ''',newElemNames{idx},''';']),1:length(contentsArr))
                tempElemNodesPrev=newParent.Children(1:nodeIdxInParent);
                tempElemNodeNew=copy(contentsArr);
                tempElemNodesNext=newParent.Children(nodeIdxInParent+1:end);
                newChildren=[tempElemNodesPrev,tempElemNodeNew,tempElemNodesNext];
            end

            tempObject=newParent.SourceObject;
            tempObject.Elements=[newChildren.SourceObject];
            newParent.getRoot.NodeConnection.assignin(newParent.Name,tempObject);

            arrayfun(@(newChild)newChild.updateParent(newParent),tempElemNodeNew);
            [tempElemNodeNew.ReadOnlyElement]=deal(false);
            parentIdxInCache=strcmp(newParent.Name,root.WorkspaceCache(:,1));
            root.WorkspaceCache{parentIdxInCache,2}=tempObject;
            newParent.Children=newChildren;
            newParent.SourceObject=tempObject;

            isBusContents=[tempElemNodeNew.IsBus];
            subBusesInContents=tempElemNodeNew(isBusContents);
            subBusTypes=cell(length(subBusesInContents),1);
            for i=1:length(subBusTypes)
                subBusTypes{i}=subBusesInContents(i).SourceObject.Type(6:end);
            end
            idxSubBuses=find(ismember(subBusTypes,root.InvalidTypeCache(newParent.Name)));
            invalidTypes=subBusTypes(idxSubBuses);

            if~isempty(invalidTypes)
                idxsInContents=find(isBusContents);
                namesToFlag=cell(1,length(tempElemNodeNew));
                if isConnectionElement
                    resetValue='Connection: <domain name>';
                else
                    resetValue='double';
                end
                for i=1:length(idxSubBuses)
                    currContent=tempElemNodeNew(idxsInContents(idxSubBuses(i)));
                    currContent.NotifyListener=false;
                    currContent.setPropValue(propName,resetValue);
                    currContent.NotifyListener=true;
                    namesToFlag{i}=currContent.Name;
                end
                toWarn=true;
            end

            eventType='BusElementAdded';
            newSrcObjs=[tempElemNodeNew.SourceObject];
            eventData=Simulink.typeeditor.app.EventData(eventType,BusName=newParent.Name,ElemName={newSrcObjs.Name},ElemIdx=nodeIdxInParent,...
            IsConnType=isConnectionElement,ElemObj=newSrcObjs);
            root.notify(eventType,eventData);

            treeComp.update(true);
            listComp.update(true);
            listComp.expand(newParent,false);
            if toWarn
                if isConnectionElement
                    warnID='Simulink:busEditor:FixingCyclicDependencyMsgType';
                else
                    warnID='Simulink:busEditor:FixingCyclicDependencyMsg';
                end
                for i=1:length(idxSubBuses)
                    currContent=tempElemNodeNew(idxsInContents(idxSubBuses(i)));
                    currContent.reportErrorFromContext(warnID,DAStudio.message(warnID,['''',namesToFlag{i},'''']),'Type','Warning');
                    listComp.update(currContent);
                end
            else
                nodesToSelect=arrayfun(@(row){row},tempElemNodeNew);
                ed.setCurrentListNode(nodesToSelect);
            end
            treeCompSelRow.refreshDataSourceChildren(newParent.Name);
        end
        treeCompSelRow.notifySLDDChanged;
    catch ME
        Simulink.typeeditor.utils.reportError(ME.message);
    end

    statusMsg=DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg');
    ed.getStudio.setStatusBarMessage(statusMsg);
end