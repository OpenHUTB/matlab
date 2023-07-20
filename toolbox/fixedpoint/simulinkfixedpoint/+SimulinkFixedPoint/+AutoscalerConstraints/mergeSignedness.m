function[hasConflict,mergedSignedness]=mergeSignedness(signedness1,signedness2)





















    hasConflict=false;
    if isempty(signedness1)
        mergedSignedness=signedness2;
    elseif isempty(signedness2)
        mergedSignedness=signedness1;
    elseif signedness1==signedness2
        mergedSignedness=signedness1;
    else
        mergedSignedness=[];
        hasConflict=true;
    end
end