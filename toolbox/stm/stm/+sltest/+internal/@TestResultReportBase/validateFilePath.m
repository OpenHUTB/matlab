function filePath=validateFilePath(filePath,defaultExtension,isReport)




    errors.DataNotFound='stm:reportOptionDialogText:DataNotFound';
    errors.FailedToGetData='stm:reportOptionDialogText:FailedToGetData';
    errors.UnsupportedFileType='stm:reportOptionDialogText:UnsupportedFileType';
    errors.PDFNotSupportedDueToConverter='stm:reportOptionDialogText:PDFNotSupportedDueToConverter';
    errors.InvalidPathName='stm:reportOptionDialogText:InvalidPathName';
    errors.FailToCreateOutputFile='stm:reportOptionDialogText:FailToCreateOutputFile';
    errors.InvalidTemplatePath='stm:reportOptionDialogText:InvalidTemplatePath';

    [outputPath,outputName,outputExt]=fileparts(filePath);
    if(isempty(outputPath))
        outputPath=pwd();
    end
    if(isempty(outputExt))
        filePath=fullfile(outputPath,strcat(outputName,defaultExtension));
    end

    ret=stm.internal.report.checkFilePath(filePath,isReport);
    if(ret==-1)
        if(isReport)
            error(message(errors.InvalidPathName));
        else
            error(message(errors.InvalidTemplatePath));
        end
    elseif(ret==-2||ret==-3)
        error(message(errors.FailToCreateOutputFile));
    end

    if(isReport)
        if(strcmp(outputExt,'.zip'))
        elseif(strcmp(outputExt,'.docx'))
        elseif(strcmp(outputExt,'.pdf'))
        else
            error(message(errors.UnsupportedFileType));
        end
        filePath=fullfile(outputPath,strcat(outputName,outputExt));
        filePath=stm.internal.report.incrementFilePath(filePath);
    end
end

