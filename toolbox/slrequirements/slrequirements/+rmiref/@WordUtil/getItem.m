function contents=getItem(filename,idx)


    if ischar(idx)
        error('WordUtil.getItem(): getting item by label is not supported');
    else
        utilObj=rmiref.WordUtil.docUtilObj(filename);
        contents=cell(1,4);
        contents{1,1}=utilObj.getLabel(idx);
        contents{1,2}=idx;
        [contents{1,3},contents{1,4}]=utilObj.getSectionContents(idx);
    end
end
