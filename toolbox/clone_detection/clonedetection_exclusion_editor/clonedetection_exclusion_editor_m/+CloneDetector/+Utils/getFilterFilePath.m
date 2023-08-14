function[fileName]=getFilterFilePath(modelName)






    fileName='';
    try
        sysroot=bdroot(modelName);
        partName='/advisor/clonesExclusions.xml';
        fileName=Simulink.slx.getUnpackedFileNameForPart(sysroot,partName);
        Simulink.slx.extractFileForPart(sysroot,partName);
    catch


    end


