function move(direction,~)




    ed=Simulink.typeeditor.app.Editor.getInstance;

    treeCompSel=ed.getCurrentTreeNode;
    assert((length(treeCompSel)==1)&&...
    isa(treeCompSel{1},'Simulink.typeeditor.app.Source'));
    listCompSel=ed.getCurrentListNode;
    listSelTypes=cellfun(@class,listCompSel,'UniformOutput',false);
    isHomogeneous=true;
    if length(listCompSel)>1
        isHomogeneous=isequal(listSelTypes{:});
    end
    assert(~isempty(listCompSel)&&...
    isHomogeneous&&...
    isa(listCompSel{1},'Simulink.typeeditor.app.Element'));
    parentNode=listCompSel{1}.Parent;
    allChildren=parentNode.Children;
    lenSource=length(listCompSel);




    if lenSource>1
        idxArray=arrayfun(@(sourceObj)find(allChildren==sourceObj{1}),listCompSel);
    else
        idxArray=find(allChildren==listCompSel{1});
    end


    newChildren=allChildren;
    srcNodeIdx=idxArray(1);
    if strcmp(direction,'Down')
        dstNodeIdx=srcNodeIdx+1;
        newChildren(srcNodeIdx)=allChildren(srcNodeIdx+lenSource);
        newChildren(dstNodeIdx:dstNodeIdx+lenSource-1)=[listCompSel{:}];
    else
        assert(strcmp(direction,'Up'));
        dstNodeIdx=srcNodeIdx-1;
        newChildren(dstNodeIdx:dstNodeIdx+lenSource-1)=[listCompSel{:}];
        newChildren(dstNodeIdx+lenSource)=allChildren(dstNodeIdx);
    end

    root=parentNode.getRoot;
    parentNode.Children=newChildren;
    ed.getListComp.update(true);
    tempObject=parentNode.SourceObject;
    tempObject.Elements=[newChildren.SourceObject];
    parentNode.SourceObject=tempObject;
    parentIdxInCache=strcmp(parentNode.Name,root.WorkspaceCache(:,1));
    root.WorkspaceCache{parentIdxInCache,2}=tempObject;
    parentVarID=root.NodeDataAccessor.identifyByName(parentNode.Name);
    if root.hasDictionaryConnection
        numVarIDs=length(parentVarID);
        if numVarIDs>1
            [~,ddName,~]=fileparts(root.NodeConnection.filespec);
            ddName=[ddName,'.sldd'];
            for j=1:numVarIDs
                if strcmp(parentVarID(j).getDataSourceFriendlyName,ddName)
                    parentVarID=parentVarID(j);
                    break;
                end
            end
        end
    end
    root.NodeDataAccessor.updateVariable(parentVarID,tempObject);
    [~,~,newOrder]=intersect(newChildren,allChildren,'stable');
    eventType='BusElementMoved';
    eventData=Simulink.typeeditor.app.EventData(eventType,BusName=parentNode.Name,ElemIdx=newOrder,IsConnType=parentNode.IsConnectionType);
    root.notify(eventType,eventData);
    root.notifySLDDChanged;
    root.refreshDataSourceChildren(parentNode.Name);
    ed.update;
end