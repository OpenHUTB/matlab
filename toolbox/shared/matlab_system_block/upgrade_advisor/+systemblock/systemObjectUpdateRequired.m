function[updateReq,message]=systemObjectUpdateRequired(hBlock)
    className=get_param(hBlock,'system');
    inputFileName=which(className);
    message={};
    updateReq=false;

    try
        sysobjupdate(className,'-inplace');
    catch e
        message{end+1}=e.message;
        return;
    end


    [filepath,name,ext]=fileparts(inputFileName);
    cachedFileName=fullfile(filepath,[name,'_orig',ext]);
    tempDir=tempname;
    mkdir(tempDir);
    tempFile=fullfile(tempDir,[name,'_update',ext]);

    if~exist(cachedFileName,'file')
        updateReq=false;
    else
        try
            movefile(inputFileName,tempFile,'f');
            movefile(cachedFileName,inputFileName,'f');
        catch e
            updateReq=false;
            message=e.message;
            return;
        end
        updateReq=true;
        message=tempFile;
    end
end