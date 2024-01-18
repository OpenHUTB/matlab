function[isModified,lostIds]=verifyTextRanges(this,srcName)

    isModified=false;
    lostIds=[];
    status=rmiml.RmiMlData.getInstance.getStatus(srcName);
    if~strcmp(status,'loaded')
        return;
    end
    root=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if isempty(root)
        return;
    end
    [isMatlabInSl,mdlName]=rmisl.isSidString(srcName);

    contents=rmiml.getText(srcName);
    cached=rmiut.unescapeFromXml(root.getProperty('cache'));
    if strcmp(contents,cached)
        return;
    else
        isModified=true;
    end

    if isempty(cached)
        tr=M3I.Transaction(this.graph);
        root.setProperty('cache',contents);
        tr.commit();
        return;
    end

    ids=root.getProperty('rangeLabels');
    if length(ids)<=length('{  }')

        tr=M3I.Transaction(this.graph);
        root.setProperty('cache',contents);
        tr.commit();
        return;
    end

    if isMatlabInSl
        disp(getString(message('Slvnv:rmigraph:AnalyzingStaleChild',srcName,mdlName)));
    else
        disp(getString(message('Slvnv:rmigraph:AnalyzingStale',srcName)));
    end
    starts=root.getProperty('rangeStarts');
    ends=root.getProperty('rangeEnds');
    [newStarts,newEnds,remainingIds,lostIds]=rmiut.RangeUtils.remapRanges(contents,cached,starts,ends,ids);

    tr=M3I.Transaction(this.graph);
    root.setProperty('cache',contents);
    if~strcmp(newStarts,starts)||~strcmp(newEnds,ends)
        root.setProperty('rangeStarts',newStarts);
        root.setProperty('rangeEnds',newEnds);
        if~isempty(lostIds)
            root.setProperty('rangeLabels',remainingIds);
        end
    end
    if isMatlabInSl
        parentRoot=rmimap.RMIRepository.getRoot(this.graph,mdlName);
        this.updateTextNodeData(parentRoot,root);
    end
    tr.commit();
end


