
function result=isAbsolutePath(filePath)



    [directoryPart,~,~]=fileparts(filePath);
    if isempty(directoryPart)
        result=false;
    else
        result=slci.internal.isAbsoluteDir(directoryPart);
    end
end
