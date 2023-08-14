
function[name,n]=generateNextName(names,nameTemplate,startN)

    n=startN;
    foundName=false;
    while~foundName
        name=sprintf(nameTemplate,n);
        foundName=isempty(find(strcmp(names,name),1));
        n=n+1;
    end

end