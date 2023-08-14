function deleteEntry(~)




    ed=Simulink.typeeditor.app.Editor.getInstance;
    listComp=ed.getListComp;

    treeCompSel=ed.getCurrentTreeNode;
    assert((length(treeCompSel)==1)&&...
    isa(treeCompSel{1},'Simulink.typeeditor.app.Source'));
    listCompSel=ed.getCurrentListNode;
    assert(~isempty(listCompSel));
    root=treeCompSel{1};
    try
        if isa(listCompSel{1},'Simulink.typeeditor.app.Object')
            if length(listCompSel)>1
                nodeToSelect=[];
            else
                keys=root.Children.keys;
                lenKeys=length(keys);
                if lenKeys==1
                    nodeToSelect=[];
                else
                    selRowIdxs=find(strcmp(keys,listCompSel{1}.Name));
                    if selRowIdxs==lenKeys
                        nodeToSelectIdx=selRowIdxs-1;
                    else
                        nodeToSelectIdx=selRowIdxs+1;
                    end
                    nodeToSelect=root.Children(keys{nodeToSelectIdx});
                end
            end
            if length(listCompSel)==root.Children.Count
                root.InvalidTypeCache=containers.Map;
            end
            eventType='BusObjectRemoved';

            for i=1:length(listCompSel)
                rowName=listCompSel{i}.Name;
                rowIsBus=listCompSel{i}.IsBus;
                rowIsConnection=listCompSel{i}.IsConnectionType;
                root.refreshDataSourceChildren(rowName);
                root.deleteNode({rowName},true);
                if rowIsBus
                    eventData=Simulink.typeeditor.app.EventData(eventType,BusName=rowName,IsConnType=rowIsConnection);
                    root.notify(eventType,eventData);
                end
            end
            listComp.update(true);
            listComp.view(nodeToSelect);
        else
            assert(isa(listCompSel{1},'Simulink.typeeditor.app.Element'));
            lenListSel=length(listCompSel);
            elemPath=listCompSel{1}.Path;
            pathStrs=split(elemPath,'.');
            parent=root.find(pathStrs{1});
            elems=parent.Children;
            lenElems=length(elems);
            listCompSelRows=[listCompSel{:}];
            if lenListSel==1
                selRowIdxs=find(elems==listCompSelRows);
            else
                selRowIdxs=arrayfun(@(elem)find(elem==elems),listCompSelRows,'UniformOutput',false);
                selRowIdxs=[selRowIdxs{:}];
            end
            if lenElems==1
                elemToSelect=parent;
            else
                if lenListSel==1
                    refRow=selRowIdxs;
                else
                    refRow=max(selRowIdxs);
                end
                if refRow==lenElems
                    if lenListSel>1
                        elemToSelectIdx=max(setdiff(1:lenElems,selRowIdxs));
                    else
                        elemToSelectIdx=refRow-1;
                    end
                else
                    elemToSelectIdx=refRow+1;
                end
                elemToSelect=elems(elemToSelectIdx);
            end
            busID=root.NodeDataAccessor.identifyByName(parent.Name);
            if root.hasDictionaryConnection
                numVarIDs=length(busID);
                if numVarIDs>1
                    [~,ddName,~]=fileparts(root.NodeConnection.filespec);
                    ddName=[ddName,'.sldd'];
                    for j=1:numVarIDs
                        if strcmp(busID(j).getDataSourceFriendlyName,ddName)
                            busID=busID(j);
                            break;
                        end
                    end
                end
            end
            busVariable=root.NodeDataAccessor.getVariable(busID);
            busVariable.Elements(selRowIdxs)=[];
            root.NodeDataAccessor.updateVariable(busID,busVariable);
            objs=parent.Children(selRowIdxs);
            parent.Children(selRowIdxs)=[];
            delete(objs);
            newElems=[parent.Children.SourceObject];
            parent.SourceObject.Elements=newElems;
            parentIdxInCache=strcmp(parent.Name,root.WorkspaceCache(:,1));
            tempObj=root.WorkspaceCache{parentIdxInCache,2};
            tempObj.Elements=newElems;
            root.WorkspaceCache{parentIdxInCache,2}=tempObj;
            eventType='BusElementRemoved';
            eventData=Simulink.typeeditor.app.EventData(eventType,BusName=parent.Name,ElemIdx=selRowIdxs,IsConnType=parent.IsConnectionType);
            parent.getRoot.notify(eventType,eventData);
            listComp.view(elemToSelect);
            listComp.update(true);
            root.refreshDataSourceChildren(parent.Name);
        end
        root.notifySLDDChanged;
    catch ME
        Simulink.typeeditor.utils.reportError(ME.message);
    end
end