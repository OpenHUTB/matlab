

function fullFilePath=getFullFilePath(fileName,defaultExtension)
    [pathStr,name,ext]=fileparts(fileName);
    if isempty(pathStr)
        pathStr=pwd;
    end

    if isempty(ext)
        ext=defaultExtension;
    end




    fullFilePath=[pathStr,filesep,name,ext];
end
