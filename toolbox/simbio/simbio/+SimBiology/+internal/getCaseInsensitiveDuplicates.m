function duplicateNames=getCaseInsensitiveDuplicates(names)

















    duplicateNames={};

    if numel(names)<=1
        return;
    end

    names=reshape(names,1,[]);
    caseInsensitiveNames=lower(names);

    [uniqueNames,~,idx]=unique(caseInsensitiveNames,"stable");

    if numel(uniqueNames)==numel(caseInsensitiveNames)
        return;
    end

    [idx,sortIdx]=sort(idx);
    names=names(sortIdx);
    count=accumarray(idx,1);
    duplicateIndex=ismember(idx,find(count>1));
    duplicateNames=names(duplicateIndex);

end