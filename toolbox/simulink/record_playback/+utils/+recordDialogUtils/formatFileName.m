



function ret=formatFileName(blockHandle,value)
    fullFileName=get_param(blockHandle,'Filename');
    [fileLocation,~,ext]=fileparts(fullFileName);

    value=strtrim(value);
    [newLocation,newName,newExt]=fileparts(value);
    if~isempty(newLocation)
        fileLocation=newLocation;
    end
    if~isempty(newExt)
        if isRecordingType(newExt)
            ext=newExt;
        else
            newName=strcat(newName,newExt);
        end
    end

    ret=fullfile(fileLocation,strcat(newName,ext));
end


function ret=isRecordingType(ext)
    if isequal(ext,'.mldatx')||...
        isequal(ext,'.mat')||...
        isequal(ext,'.xlsx')
        ret=true;
    else
        ret=false;
    end
end