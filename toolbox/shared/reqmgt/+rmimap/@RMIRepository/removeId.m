function result=removeId(this,srcName,id)




    result=false;
    root=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if isempty(root)
        return;
    end
    [isMatlabInSl,mdlName]=rmisl.isSidString(srcName);
    ids=root.getProperty('rangeLabels');
    starts=root.getProperty('rangeStarts');
    ends=root.getProperty('rangeEnds');
    [newStarts,newEnds,remainingIds,removedId]=rmiut.RangeUtils.removeId(starts,ends,ids,id);
    if~isempty(removedId)
        tr=M3I.Transaction(this.graph);
        root.setProperty('rangeStarts',newStarts);
        root.setProperty('rangeEnds',newEnds);
        root.setProperty('rangeLabels',remainingIds);
        if isMatlabInSl
            parentRoot=rmimap.RMIRepository.getRoot(this.graph,mdlName);
            this.updateTextNodeData(parentRoot,root);
        end
        tr.commit();
        result=true;
    end
end


