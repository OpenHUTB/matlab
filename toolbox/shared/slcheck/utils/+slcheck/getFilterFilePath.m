function[fileName,bInside]=getFilterFilePath(modelName)







    fileName='';
    bInside=true;
    try
        sysroot=bdroot(modelName);
        fileName=get_param(sysroot,'MAModelFilterFile');
        if isempty(fileName)
            bInside=true;
            partName='/advisor/filters.xml';
            fileName=Simulink.slx.getUnpackedFileNameForPart(sysroot,partName);
            Simulink.slx.extractFileForPart(sysroot,partName);
        else
            bInside=false;
        end
    catch ME


    end
