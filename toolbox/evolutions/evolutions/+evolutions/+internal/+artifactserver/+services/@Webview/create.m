function tf=create(obj,data)





    key=data.Id;


    [fileroot,~,ext]=fileparts(data.File);
    ext=convertStringsToChars(ext);
    webviewPath=fullfile(fileroot,'slprj');
    fileHandler=evolutions.internal.FileTypeHandler;
    webviewFile=fileHandler.createWebView(data.File,webviewPath);

    if~isempty(webviewFile)

        [viewPath,viewName,viewExt]=fileparts(webviewFile);
        newFile=fullfile(viewPath,[strcat(convertStringsToChars(viewName),...
        ext(2:end)),convertStringsToChars(viewExt)]);


        movefile(webviewFile,newFile);


        [~,storedId]=getStorageService(obj).create(newFile);


        obj.addToDb(key,storedId);

    else
        obj.addToDb(key,'NoPreview');
    end


    tf=true;
end


