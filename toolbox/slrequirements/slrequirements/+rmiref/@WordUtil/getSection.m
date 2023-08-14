function contents=getSection(doc,paragIdx)


    utilObj=rmiref.WordUtil.docUtilObj(doc);
    contents{1}=utilObj.sLabels{paragIdx};
    contents{2}=utilObj.iParents(paragIdx);
    [contents{3},contents{4}]=utilObj.getSectionContents(paragIdx);
end


