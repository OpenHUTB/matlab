function contents=getItemsByLevel(doc,level)


    utilObj=rmiref.WordUtil.docUtilObj(doc);
    headerIdx=find(utilObj.iLevels==level);
    totalItems=length(headerIdx);
    contents=cell(totalItems,4);
    for i=1:totalItems
        contents{i,1}=utilObj.getLabel(headerIdx(i));
        contents{i,2}=headerIdx(i);
        [contents{i,3},contents{i,4}]=utilObj.getSectionContents(headerIdx(i));
    end
end

