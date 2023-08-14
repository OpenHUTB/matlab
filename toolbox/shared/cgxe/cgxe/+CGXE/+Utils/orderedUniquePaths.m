function orderedList=orderedUniquePaths(orderedList)










    if ispc
        orderedList=lower(orderedList);
        for i=1:length(orderedList)
            if(~isempty(orderedList{i}))&&(orderedList{i}(end)=='\')



                orderedList{i}=orderedList{i}(1:end-1);
            end
        end
    end
    orderedList=unique(orderedList,'stable');
