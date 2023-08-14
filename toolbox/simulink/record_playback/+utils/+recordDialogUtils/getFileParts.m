
function fileParts=getFileParts(blockHandle)
    fileName=get_param(blockHandle,'Filename');
    [fileLocation,name,ext]=fileparts(fileName);
    fileParts.name=strcat(name,ext);
    fileParts.ext=ext;
    if isempty(fileLocation)
        fileLocation=pwd;
    end
    fileParts.fileLocation=fileLocation;
end