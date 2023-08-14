

function[out,searchString]=loc_getFileUrl(url)
    [filePath,searchString]=Simulink.document.parseFileURL(url);
    if~isempty(filePath)
        url=filePath;
    end

    if isempty(searchString)
        searchString='?useExternalBrowser=false';
    else
        searchString=[searchString,'&useExternalBrowser=false'];
    end
    out=Simulink.document.fileURL(url,searchString);

end
