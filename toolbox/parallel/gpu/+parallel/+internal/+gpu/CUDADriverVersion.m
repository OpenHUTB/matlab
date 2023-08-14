function v=CUDADriverVersion







    if ispc
        v=iPcDriverVersion();
    elseif isequal(computer,'GLNXA64')
        v=iLinuxDriverVersion();
    else
        error(message('parallel:gpu:device:DriverVersionUnknownComputer',computer));
    end
end




function verstr=iPcDriverVersion()


    DRIVER_NAME='nvcuda.dll';


    cmd=sprintf('cmd /c for %%I in (%s) do @echo %%~f$PATH:I',DRIVER_NAME);
    [s,w]=system(cmd);
    driverFullFname=strtrim(w);
    if s||~exist(driverFullFname,'file')
        error(message('parallel:gpu:device:DriverVersionNoDriver',DRIVER_NAME));
    end


    fsobj=actxserver('Scripting.FileSystemObject');
    verstr=fsobj.GetFileVersion(driverFullFname);
    verpieces=regexp(verstr,'([0-9]+)','match');



    if length(verpieces)==4
        piece3=str2double(verpieces{3});
        piece4=str2double(verpieces{4});
        verstr=sprintf('%s (%.2f)',verstr,...
        (((piece3-10)*10000)+piece4)/100);
    end

end



function verstr=iLinuxDriverVersion()

    VERSION_FILE='/proc/driver/nvidia/version';
    fh=fopen(VERSION_FILE,'rt');

    if fh==-1
        error(message('parallel:gpu:device:DriverVersionNoVersionFile',VERSION_FILE));
    end
    cleanup=onCleanup(@()fclose(fh));


    tline=fgetl(fh);
    while ischar(tline)
        match=regexp(tline,'(?<=NVRM.*Kernel Module\s*)([0-9\.]+)','match');
        if length(match)==1
            verstr=match{1};
            return;
        end
        tline=fgetl(fh);
    end


    error(message('parallel:gpu:device:DriverVersionInvalidVersionFile',VERSION_FILE));
end
