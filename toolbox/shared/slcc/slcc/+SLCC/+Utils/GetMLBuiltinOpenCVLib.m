
function openCVLibPath=GetMLBuiltinOpenCVLib(libname)
    openCVLibPath='';
    if(~ischar(libname))
        libname=char(libname);
    end
    arch=computer('arch');
    ocvcgDir=fullfile(matlabroot,'toolbox','vision','builtins','src','ocvcg');

    if ispc
        libpath=fullfile(ocvcgDir,'opencv',arch,'lib');
    else
        libpath=fullfile(matlabroot,'bin',arch);
    end
    if ispc
        ocvVer='452';
        prefix='opencv_';
        libext='.lib';
    elseif ismac
        ocvVer='.4.5.2';
        prefix='libopencv_';
        libext='.dylib';
    else
        ocvVer='.so.4.5.2';
        prefix='libopencv_';
        libext='';
    end
    if exist(fullfile(libpath,strcat(prefix,libname,ocvVer,libext)),'file')
        openCVLibPath=['"',fullfile(libpath,strcat(prefix,libname,ocvVer,libext)),'"'];
    end
end

