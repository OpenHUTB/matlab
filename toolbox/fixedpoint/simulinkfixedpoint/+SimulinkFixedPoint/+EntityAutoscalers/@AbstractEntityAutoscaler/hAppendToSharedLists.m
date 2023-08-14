function sharedLists=hAppendToSharedLists(h,sharedLists,newList)%#ok





    if~isempty(newList)

        newList=newList(cellfun('isempty',newList)==0);
        if iscell(newList{1})
            sharedLists(end+1:end+length(newList))=newList;
        else
            sharedLists{end+1}=newList;
        end
    end