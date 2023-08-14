function info=getSoftwareInfo()











    info=[];

    hostImageFileName='slrtssd.raw';
    hostImageFileChksum='slrtssd.cksum';
    hostQNXTarFileName='qnxtools.tar';
    hostQNXTarFileChksum='qnxtools.cksum';
    hostSlrtTarFileName='slrttools.tar';
    hostSlrtTarFileChksum='slrttools.cksum';

    userConfigDir='/home/slrt/.config/updateos/';
    info.userConfigDir=userConfigDir;

    if(isdeployed)


        fullPathToImages=fullfile(ctfroot,'toolbox','slrealtime','target','supportpackage');





        if~exist(fullPathToImages,'dir')
            fullPathToImages=fullfile(ctfroot,'test','toolbox','slrealtime','target','qnx_spkg','testdata',computer('arch'));
        end

    else



        fullPathToImages=slrealtime.internal.getSupportPackageRoot;
        if isempty(fullPathToImages)
            fullPathToImages=fullfile(matlabroot,'test','toolbox','slrealtime','target','qnx_spkg','testdata',computer('arch'));
        end
    end



    info.ImageFile.host.file=fullfile(fullPathToImages,hostImageFileName);
    info.ImageFile.host.chksumFile=fullfile(fullPathToImages,hostImageFileChksum);
    info.ImageFile.target.file=['/.boot/',hostImageFileName];
    info.ImageFile.target.chksumFile=[userConfigDir,hostImageFileChksum];

    info.QNXTarFile.host.file=fullfile(fullPathToImages,hostQNXTarFileName);
    info.QNXTarFile.host.chksumFile=fullfile(fullPathToImages,hostQNXTarFileChksum);
    info.QNXTarFile.target.file=[userConfigDir,hostQNXTarFileName];
    info.QNXTarFile.target.chksumFile=[userConfigDir,hostQNXTarFileChksum];

    info.SlrtTarFile.host.file=fullfile(matlabroot,'toolbox','slrealtime','target','qnx_images',computer('arch'),hostSlrtTarFileName);
    info.SlrtTarFile.host.chksumFile=fullfile(matlabroot,'toolbox','slrealtime','target','qnx_images',computer('arch'),hostSlrtTarFileChksum);
    info.SlrtTarFile.target.file=[userConfigDir,hostSlrtTarFileName];
    info.SlrtTarFile.target.chksumFile=[userConfigDir,hostSlrtTarFileChksum];

    isSpeedgoatLibInstalled=exist('SGtarlist','file');
    if isSpeedgoatLibInstalled
        nFile=1;
        sgfiles=SGtarlist();
        for idx=1:length(sgfiles)
            sgfile=sgfiles{idx};
            sghostfile=which(sgfile);
            if isempty(sghostfile)
                continue;
            end
            [sghostfilep,sghostfilen,~]=fileparts(sghostfile);
            chksumFileName=[sghostfilen,'.cksum'];
            info.SpeedgoatLibraryFiles(nFile).host.file=sghostfile;
            info.SpeedgoatLibraryFiles(nFile).host.chksumFile=fullfile(sghostfilep,chksumFileName);
            info.SpeedgoatLibraryFiles(nFile).target.file=[userConfigDir,sgfile];
            info.SpeedgoatLibraryFiles(nFile).target.chksumFile=[userConfigDir,chksumFileName];
            nFile=nFile+1;
        end
    else
        info.SpeedgoatLibraryFiles=[];
    end



    try
        [fd,errmsg]=fopen(info.ImageFile.host.chksumFile);
        if fd==-1
            error(message('slrealtime:target:updateFileOpenError',...
            info.ImageFile.host.chksumFile,errmsg));
        end
        info.ImageFile.host.chksumValue=fscanf(fd,'%u %u');
        fclose(fd);
    catch
        info.ImageFile.host.chksumValue=[];
        try
            fclose(fd);
        catch
        end
    end

    try
        [fd,errmsg]=fopen(info.QNXTarFile.host.chksumFile);
        if fd==-1
            error(message('slrealtime:target:updateFileOpenError',...
            info.QNXTarFile.host.chksumFile,errmsg));
        end
        info.QNXTarFile.host.chksumValue=fscanf(fd,'%u %u');
        fclose(fd);
    catch
        info.QNXTarFile.host.chksumValue=[];
        try
            fclose(fd);
        catch
        end
    end

    try
        [fd,errmsg]=fopen(info.SlrtTarFile.host.chksumFile);
        if fd==-1
            error(message('slrealtime:target:updateFileOpenError',...
            info.SlrtTarFile.host.chksumFile,errmsg));
        end
        info.SlrtTarFile.host.chksumValue=fscanf(fd,'%u %u');
        fclose(fd);
    catch
        info.SlrtTarFile.host.chksumValue=[];
        try
            fclose(fd);
        catch
        end
    end

    try
        for i=1:length(info.SpeedgoatLibraryFiles)
            [fd,errmsg]=fopen(info.SpeedgoatLibraryFiles(i).host.chksumFile);
            if fd==-1
                error(message('slrealtime:target:updateFileOpenError',...
                info.SpeedgoatLibraryFiles(i).host.chksumFile,errmsg));
            end
            info.SpeedgoatLibraryFiles(i).host.chksumValue=fscanf(fd,'%u %u');
            fclose(fd);
        end
    catch
        info.SpeedgoatLibraryFiles(i).host.chksumValue=[];
        try
            fclose(fd);
        catch
        end
    end



    if~exist(info.ImageFile.host.file,'file')||~exist(info.QNXTarFile.host.file,'file')
        error(message('slrealtime:supportpackage:supportPackageRequiredMsgInFun'));
    end
end
