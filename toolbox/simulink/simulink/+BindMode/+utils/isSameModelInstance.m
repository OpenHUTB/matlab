

function isSameInstance=isSameModelInstance(sourceFullPath,selectionFullPath)


    if(size(sourceFullPath,1)~=size(selectionFullPath,1))

        selectionFullPath=transpose(selectionFullPath);
    end
    isSameInstance=false;
    if(numel(sourceFullPath)==numel(selectionFullPath)&&...
        isequal(sourceFullPath(1:end-1),selectionFullPath(1:end-1)))
        isSameInstance=true;
    end
end