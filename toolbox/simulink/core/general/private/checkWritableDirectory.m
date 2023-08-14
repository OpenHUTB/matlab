
function checkWritableDirectory(filePath)


    [~,fname]=fileparts(tempname);
    tmpDir=fullfile(filePath,fname);
    try
        mkdir(tmpDir);
        rmdir(tmpDir);
    catch me
        if strcmp(me.identifier,'MATLAB:MKDIR:OSError')


            DAStudio.error('Simulink:protectedModel:CannotWriteToDir',filePath);
        end
    end
end
