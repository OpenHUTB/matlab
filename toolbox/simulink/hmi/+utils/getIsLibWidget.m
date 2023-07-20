function isLibWidget=getIsLibWidget(blockObj)


    if isempty(get(blockObj,'ReferenceBlock'));
        isLibWidget=false;
    else
        isLibWidget=true;
    end
end

