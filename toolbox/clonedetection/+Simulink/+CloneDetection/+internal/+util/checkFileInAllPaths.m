
function[isFileExist,fileFullPathWithExtension]=checkFileInAllPaths(fullFilePath)



    [filePath,fileNameWithoutExtension,fileExtension]=fileparts(fullFilePath);

    isFileExist=true;
    if isempty(fileExtension)
        try
            [isFileExist_new,fileFullPathWithExtension_new]=...
            Simulink.CloneDetection.internal.util.checkFileInAllPaths([fullFilePath,'.mdl']);
            if(isFileExist_new)
                fileFullPathWithExtension=fileFullPathWithExtension_new;
                isFileExist=isFileExist_new;
                return;
            end
        catch
            fileExtension='.slx';
        end
    end

    fileFullPathWithExtension=[fileNameWithoutExtension,fileExtension];
    if isempty(filePath)
        localFilePathWithExtension=[fullfile(pwd,fileNameWithoutExtension),fileExtension];
        if isfile(localFilePathWithExtension)
            fileFullPathWithExtension=localFilePathWithExtension;
        else
            fileNameOnSearchPathWithExtension=[fileNameWithoutExtension,fileExtension];
            if exist(fileNameOnSearchPathWithExtension,'file')
                fileFullPathWithExtension=which(fileNameOnSearchPathWithExtension);
            else
                isFileExist=false;
                DAStudio.error('sl_pir_cpp:creator:FileNotFound',fullFilePath);
            end
        end
    else
        relativeFilePathWithExtension=[fullfile(pwd,...
        filePath,fileNameWithoutExtension),fileExtension];
        absoluteFilePathWithExtension=[fullfile(...
        filePath,fileNameWithoutExtension),fileExtension];
        if isfile(relativeFilePathWithExtension)
            fileFullPathWithExtension=relativeFilePathWithExtension;
        elseif isfile(absoluteFilePathWithExtension)
            fileFullPathWithExtension=absoluteFilePathWithExtension;



        else
            isFileExist=false;
            DAStudio.error('sl_pir_cpp:creator:FileNotFound',fullFilePath);
        end
    end
end
