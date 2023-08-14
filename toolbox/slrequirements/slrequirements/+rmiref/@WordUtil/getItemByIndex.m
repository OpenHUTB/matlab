function contents=getItemByIndex(filename,idx)


    utilObj=rmiref.WordUtil.docUtilObj(filename);
    contents=cell(1,4);
    contents{1,1}=utilObj.getLabel(idx);
    contents{1,2}=idx;
    [contents{1,3},contents{1,4}]=utilObj.getSectionContents(idx);
end
