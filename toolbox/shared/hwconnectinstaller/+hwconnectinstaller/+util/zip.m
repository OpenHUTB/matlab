function zip(zipfilename,filesToZip,rootfolder,arch)





















    if~exist('arch','var')
        arch='generic';
    end

    mfile=['hwconnectinstaller.util.',mfilename];
    validateattributes(zipfilename,{'char'},{'nonempty'},mfile,'zipfilename');
    validateattributes(filesToZip,{'char','cell'},{'nonempty'},mfile,'filesToZip')
    validateattributes(rootfolder,{'char'},{'nonempty'},mfile,'rootfolder');
    validateattributes(arch,{'char'},{'nonempty'},mfile,'arch');

    if any(strcmpi(arch,{'common','win32','win64','generic'}))
        hwconnectinstaller.internal.inform(sprintf('MATLAB zip (%s): %s\n',arch,zipfilename));
        zip(zipfilename,filesToZip,rootfolder);
        return;
    end

    if~any(strcmpi(arch,{'glnxa64','maci64'}))
        assert(false,sprintf('Unknown architecture option: %s ',arch));
    end



    assert(isunix,'Unix-specific zip invoked on a non-Unix platform');
    hwconnectinstaller.internal.inform(sprintf('Unix zip (%s): %s\n',arch,zipfilename));

    if~(isempty(strfind(zipfilename,'~'))&&isempty(strfind(rootfolder,'~')))
        assert(false,'Tilde (~) characters not supported in zipfilename and rootfolder');
    end


    [~,~,extension]=fileparts(zipfilename);
    if isempty(extension)
        zipfilename=[zipfilename,'.zip'];
    end

    if zipfilename(1)~='/'

        zipfilename=fullfile(pwd,zipfilename);
    end


    filesToZip=cellstr(filesToZip);
    assert(numel(filesToZip)>0);
    for i=1:numel(filesToZip)
        assert(exist(fullfile(rootfolder,filesToZip{i}),'file')~=0,sprintf('No such file or directory: %s',filesToZip{i}));
    end

    listfile=tempname;
    fid=fopen(listfile,'wt');
    for i=1:numel(filesToZip)
        fprintf(fid,'%s\n',filesToZip{i});
    end
    fclose(fid);
    listCleanup=onCleanup(@()delete(listfile));


    zipCmdName=hwconnectinstaller.util.checkUnixCommand('/usr/bin','zip');

    cmd=[zipCmdName,' -y -r "',zipfilename,'" -@ < "',listfile,'"'];
    originalDir=cd(rootfolder);
    dirCleanup=onCleanup(@()cd(originalDir));

    [status,output]=system(cmd);
    if(status~=0)
        error(message('hwconnectinstaller:setup:UnixCommandInvocationError',cmd,output));
    else
        hwconnectinstaller.internal.inform(output);
    end
