classdef(Abstract)Constants
    properties(Constant)
        BaseImageRepository=getBaseImageRepository
        BaseOSImage='ubuntu:20.04'
        ContainerUserName='appuser'
        ContextSubDir='applicationFilesForMATLABCompiler'
        ExternalRepository='containers.mathworks.com/matlab-runtime-utils'
        InstallerExtractedDir='/opt/matlabruntime/unzippedinstaller'
        InstallerImageEnvironmentVariable='INTERNAL_MATLAB_RUNTIME_INSTALLER_IMAGE_NAME'
        InstallerPullEnvironmentVariable='INTERNAL_MATLAB_RUNTIME_INSTALLER_ALWAYS_PULL'

        InternalRepository='mw-docker.repositories.mathworks.com/bat'
        ImageApplicationDir='/usr/bin/mlrtapp'
        ImageRuntimeDir='/opt/matlabruntime'
        MATLABReleaseString=char(lower(matlabRelease.Release))
        MATLABStageString=char(lower(matlabRelease.Stage))
        MATLABUpdateString=sprintf('update%d',matlabRelease.Update)
        ModifiedProductNumbers=getModifiedProductNumbers
        ProductComponentModuleNavigator=matlab.depfun.internal.ProductComponentModuleNavigator
        RequiredPackages=getRequiredPackages
        RuntimeVxxDir=getRuntimeVxxDir

    end

    methods(Static)
        function wd=WorkingDirectory





            wd=getWorkingDirectory;
        end

        function repo=InstallerImageRepository





            nm=compiler.internal.package.docker.Constants.InstallerImageEnvironmentVariable;
            repo=char(getenv(nm));
            if strlength(repo)==0
                repo=getInstallerImageRepository;
            end
        end
    end
end

function allprods=getModifiedProductNumbers

    pcmn=compiler.internal.package.docker.Constants.ProductComponentModuleNavigator;
    if isempty(pcmn)
        pcmn=matlab.depfun.internal.ProductComponentModuleNavigator;
    end
    pcmn.doSql('SELECT External_Product_ID FROM Product WHERE External_Product_ID > 34999 AND External_Product_ID < 36000;')
    addinscell=pcmn.fetchRows;
    addinsnums=zeros(1000,1);
    for n=1:numel(addinscell)
        addinsnums(addinscell{n}{1}-34999)=1;
    end
    allprods=find(addinsnums);

end

function wd=getWorkingDirectory


    username=getenv('USER');
    if isempty(username)
        username=matlab.lang.internal.uuid;
    else

        badchars=compiler.internal.utils.CLIConstants.BadFolderCharacters;
        badchars=unique([badchars(:);{'\'}]);
        for n=1:numel(badchars)
            bad=badchars{n};
            good=sprintf('_CHAR%d_',double(bad));
            username=replace(username,bad,good);
        end
    end

    wd=fullfile(tempdir,username,'matlabruntime','docker',...
    char(lower(matlabRelease.Release)),...
    char(lower(matlabRelease.Stage)),...
    sprintf('update%d',matlabRelease.Update));

end

function nm=getBaseImageRepository

    nm=sprintf('matlabruntimebase/%s/%s/update%d',...
    lower(matlabRelease.Release),...
    lower(matlabRelease.Stage),...
    matlabRelease.Update);

end

function fullname=getInstallerImageRepository















    isInternal=compiler.internal.package.docker.isInternal;
    if isInternal
        repo=compiler.internal.package.docker.Constants.InternalRepository;
    else
        repo=compiler.internal.package.docker.Constants.ExternalRepository;
    end

    mr=matlabRelease;
    rel=lower(mr.Release);
    fullname=sprintf('%s/matlab-runtime-installer:%s',repo,rel);

    if mr.Update==0
        updateDecoration='';
    else
        updateDecoration=sprintf('-update-%d',mr.Update);
    end

    stg=lower(mr.Stage);
    if strcmpi(stg,'release')
        stageDecoration='';
    else
        stageDecoration=sprintf('-%s',stg);
    end

    fullname=sprintf('%s%s%s',fullname,updateDecoration,stageDecoration);

    if isInternal
        fullname=sprintf('%s-SNAPSHOT',fullname);
    end

end

function reldir=getRuntimeVxxDir

    reldir=char(matlabRelease.Release);

end

function pckgs=getRequiredPackages

    pckgs={'ca-certificates';...
    'gstreamer1.0-libav';...
    'gstreamer1.0-plugins-base';...
    'gstreamer1.0-plugins-good';...
    'gstreamer1.0-tools';...
    'libasound2';...
    'libatk-bridge2.0-0';...
    'libatk1.0-0';...
    'libatspi2.0-0';...
    'libc6';...
    'libcairo-gobject2';...
    'libcairo2';...
    'libcap2';...
    'libcrypt1';...
    'libcups2';...
    'libdbus-1-3';...
    'libdrm2';...
    'libfontconfig1';...
    'libgbm1';...
    'libgdk-pixbuf2.0-0';...
    'libgl1';...
    'libglib2.0-0';...
    'libglu1-mesa';...
    'libgstreamer-plugins-base1.0-0';...
    'libgstreamer1.0-0';...
    'libgtk-3-0';...
    'libnspr4';...
    'libnss3';...
    'libodbc1';...
    'libpam0g';...
    'libpango-1.0-0';...
    'libpangocairo-1.0-0';...
    'libpangoft2-1.0-0';...
    'libsm6';...
    'libsndfile1';...
    'libssl1.1';...
    'libuuid1';...
    'libx11-6';...
    'libx11-xcb1';...
    'libxcb-composite0';...
    'libxcb-cursor0';...
    'libxcb-damage0';...
    'libxcb-dpms0';...
    'libxcb-dri3-0';...
    'libxcb-ewmh2';...
    'libxcb-icccm4';...
    'libxcb-image0';...
    'libxcb-keysyms1';...
    'libxcb-randr0';...
    'libxcb-record0';...
    'libxcb-render-util0';...
    'libxcb-res0';...
    'libxcb-screensaver0';...
    'libxcb-shape0';...
    'libxcb-sync1';...
    'libxcb-util1';...
    'libxcb-xf86dri0';...
    'libxcb-xfixes0';...
    'libxcb-xinerama0';...
    'libxcb-xinput0';...
    'libxcb-xrm0';...
    'libxcb-xtest0';...
    'libxcb-xv0';...
    'libxcb-xvmc0';...
    'libxcb1';...
    'libxcomposite1';...
    'libxcursor1';...
    'libxdamage1';...
    'libxext6';...
    'libxfixes3';...
    'libxft2';...
    'libxi6';...
    'libxinerama1';...
    'libxkbcommon0';...
    'libxkbcommon-x11-0';...
    'libxrandr2';...
    'libxrender1';...
    'libxt6';...
    'libxtst6';...
    'libxxf86vm1';...
    'net-tools';...
    'procps';...
    'unzip';...
    'zlib1g'};

end