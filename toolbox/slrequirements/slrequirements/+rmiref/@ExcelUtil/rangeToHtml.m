function resultsFile=rangeToHtml(hRange,targetFilePath,itemId)

    try
        hSheet=hRange.Parent;
        hWorkbook=hSheet.Parent;
        wasSaved=hWorkbook.Saved;

        hPublisher=hWorkbook.PublishObjects.Add('xlSourceRange',targetFilePath,hSheet.Name,hRange.Address,...
        0,'RmiTarget','');
        hPublisher.Publish;
        if exist(targetFilePath,'file')
            resultsFile=targetFilePath;
            rmiref.cleanupExportedHtml(targetFilePath);
        else
            resultsFile='';
        end



        if wasSaved
            hWorkbook.Saved=1;
        end
    catch ME
        warning(ME.identifier,getString(message('Slvnv:rmiref:ExcelUtil:ExceptionWhenLookingFor',ME.message,itemId)));
        resultsFile='';
    end
end
