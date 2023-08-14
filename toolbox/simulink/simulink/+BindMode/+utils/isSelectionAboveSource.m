

function isAbove=isSelectionAboveSource(sourceFullPath,selectionFullPath)





    if(size(sourceFullPath,1)~=size(selectionFullPath,1))

        selectionFullPath=transpose(selectionFullPath);
    end
    isAbove=false;
    if(numel(sourceFullPath)>numel(selectionFullPath))
        isAbove=true;
    elseif(numel(sourceFullPath)==numel(selectionFullPath)...
        &&~isequal(sourceFullPath(1:end-1),selectionFullPath(1:end-1)))
        isAbove=true;
    else
        sourcePath=sourceFullPath(1:end-1);
        pathSize=numel(sourcePath);
        if(pathSize~=0&&~isequal(sourcePath,selectionFullPath(1:pathSize)))
            isAbove=true;
        end
    end
end