function parents=getParents(doc,parIdx)
    allSections=rmiref.WordUtil.getDocStructure(doc);
    myItem=allSections(parIdx,:);
    parentIdx=myItem{2};
    parents=cell(0,2);
    while parentIdx>0
        parent=allSections(parentIdx,:);
        label=strtrim(parent{1});
        if~isempty(label)
            parents=[{parentIdx,label};parents];%#ok<AGROW>
        end
        parentIdx=parent{2};
    end
end

