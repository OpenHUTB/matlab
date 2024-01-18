function mdlName=updateRanges(this,srcName,newIds,newStarts,newEnds)
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if isempty(srcRoot)
        error('RMIRepository: updateRange called for unknown source %s',srcName);
    end

    t=M3I.Transaction(this.graph);

    if isempty(srcRoot.id)

        [~,srcRoot.id]=strtok(srcName,':');
        srcRoot.setProperty('id',srcRoot.id);
    end
    srcRoot.setProperty('rangeStarts',newStarts);
    srcRoot.setProperty('rangeEnds',newEnds);
    srcRoot.setProperty('rangeLabels',newIds);
    [isMatlabFunction,mdlName]=rmisl.isSidString(srcName,false);
    cache=rmiut.escapeForXml(rmiml.getText(srcName));
    srcRoot.setProperty('cache',cache);
    if isMatlabFunction
        parentRoot=rmimap.RMIRepository.getRoot(this.graph,mdlName);
        this.updateTextNodeData(parentRoot,srcRoot);
    end

    t.commit();
end


