function nUnique=numUniqueNames(names)














    if~isempty(names)

        sortedNames=sort(names(:));


        nUnique=nnz(~strcmp(sortedNames(1:end-1),sortedNames(2:end)))+1;
    else
        nUnique=0;
    end


