function filenames=unzip(zipfilename,outputdir,arch)























    if~exist('arch','var')
        arch='generic';
    end

    mfile=['hwconnectinstaller.util.',mfilename];
    validateattributes(zipfilename,{'char'},{'nonempty'},mfile,'zipfilename');
    validateattributes(outputdir,{'char'},{'nonempty'},mfile,'outputdir');
    validateattributes(arch,{'char'},{'nonempty'},mfile,'arch');



    if outputdir(end)~=filesep
        outputdir=fullfile(outputdir,filesep);
    end

    if any(strcmpi(arch,{'common','win32','win64','generic'}))
        hwconnectinstaller.internal.inform(sprintf('MATLAB unzip (%s): %s\n',arch,zipfilename));
        filenames=unzip(zipfilename,outputdir);
        return;
    end

    if~any(strcmpi(arch,{'glnxa64','maci64'}))
        assert(false,sprintf('Unknown architecture option: %s ',arch));
    end



    assert(isunix,'Unix-specific unzip invoked on a non-Unix platform');
    hwconnectinstaller.internal.inform(sprintf('Unix unzip (%s): %s\n',arch,zipfilename));




    zipfilename=hwconnectinstaller.util.resolveTildeChars(zipfilename);
    outputdir=hwconnectinstaller.util.resolveTildeChars(outputdir);








    unzipCmdName=hwconnectinstaller.util.checkUnixCommand('/usr/bin','unzip');

    cmd=[unzipCmdName,' -Z -1 "',zipfilename,'"'];
    output=invokeSystemCommand(cmd);
    filenames=regexp(output,'\n','split');

    filenames=filenames(cellfun(@isempty,regexpi(filenames,'/$|^$','emptymatch')));

    dirspec=[outputdir,filesep];
    filenames=cellfun(@(s)[dirspec,s],filenames,'UniformOutput',false);





    cmd=[unzipCmdName,' -o "',zipfilename,'" -d "',outputdir,'"'];
    invokeSystemCommand(cmd);

end



function output=invokeSystemCommand(cmd)

    [status,output]=system(cmd);
    if(status~=0)
        error(message('hwconnectinstaller:setup:UnixCommandInvocationError',cmd,output));
    else
        hwconnectinstaller.internal.inform(output);
    end

end