function[fileName,bInside]=getOldExclusionFileDetails(system)
    fileName='';
    bInside=true;
    try
        sysroot=bdroot(system);
        fileName=get_param(sysroot,'MAModelExclusionFile');
        if isempty(fileName)
            bInside=true;
            fileName=Simulink.slx.getUnpackedFileNameForPart(sysroot,'/advisor/exclusions.xml');
            Simulink.slx.extractFileForPart(sysroot,'/advisor/exclusions.xml');
        else
            bInside=false;
        end

    catch ME


    end

end
