function plugin=loadAudioPlugin(varargin)































    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    mlock;


    import matlab.internal.lang.capability.Capability;
    if~Capability.isSupported(Capability.LocalClient)
        error(message('audio:plugin:UnsupportedHostingOnline'));
    end

    if~any(strcmp(computer('arch'),{'win64','maci64'}))
        error(message('audio:plugin:UnsupportedHostingPlatform',computer('arch')));
    end


    pluginPath=processCommandLine(varargin{:});
















    ompFullPath=fullfile(pluginPath,'Contents','Resources','mkl-dnn_lib','libomp.dylib');
    restoreOmp=onCleanup(@()revertOmpSymbLink(pluginPath));
    if ismac&&exist(ompFullPath,'file')

        ompBackupFullPath=fullfile(pluginPath,'Contents','Resources','mkl-dnn_lib','libomp.dylib.donotdelete');

        if~exist(ompBackupFullPath,'file')
            movefile(ompFullPath,ompBackupFullPath,'f');


            omp5FullPath=fullfile(matlabroot,'sys','os','maci64','libiomp5.dylib');
            symbLinkCmd=sprintf('ln -s "%s" "%s"',omp5FullPath,ompFullPath);
            [ok,~]=system(symbLinkCmd);
            if ok~=0
                error(message('audio:plugin:MKLDNNPluginLoadingFailed'));
            end
        end
    end


    pluginManager=getPluginManager;
    pluginInstance=hostmexif.newplugininstance(pluginManager,pluginPath);
    if pluginInstance==0
        if ispc&&pluginIsWin32(pluginPath)
            error(message('audio:plugin:InstantiationFailedWin32',pluginPath));
        end

        if ismac&&endsWith(pluginPath,{'.component','.component/'})
            auPath='/Library/Audio/Plug-Ins/Components/';
            if~startsWith(pluginPath,{filesep,'.'})

                pluginPathAU=strcat(auPath,pluginPath);
                pluginInstance=hostmexif.newplugininstance(pluginManager,pluginPathAU);
            end
            if pluginInstance==0

                error(message('audio:plugin:InstantiationFailedAU',pluginPath,auPath));
            end
        else
            error(message('audio:plugin:InstantiationFailed',pluginPath));
        end
    end

    if hostmexif.getnuminputs(pluginInstance)==0



        plugin=externalAudioPluginSource(pluginPath,pluginInstance);

    else



        plugin=externalAudioPlugin(pluginPath,pluginInstance);

    end
end


function pluginPath=processCommandLine(varargin)
    if nargin==0
        error(message('audio:plugin:PluginPathMissing'));
    end
    pluginPath=varargin{1};

    if~(ischar(pluginPath)&&isrow(pluginPath)&&~isempty(pluginPath))
        error(message('audio:plugin:PluginPathInvalid'));
    end

    pluginExists=false;
    if ispc
        pluginExists=(exist(pluginPath,'file')==2);
    elseif ismac
        auPath='/Library/Audio/Plug-Ins/Components/';




        pluginPath=regexprep(pluginPath,[filesep,'$'],'');
        pluginLibPath=regexprep(strcat(auPath,pluginPath),[filesep,'$'],'');
        pluginExists=strncmp(pluginPath,'AudioUnit:',10)||...
        (exist(pluginPath,'dir')==7)||...
        (exist(pluginLibPath,'dir')==7);
    else
        assert(0,'unexpected platform');
    end

    if~pluginExists
        error(message('audio:plugin:PluginPathNonexistent',pluginPath));
    end


    if nargin>1

















        error(message('audio:plugin:TooManyArgs'));
    end
end

function pm=getPluginManager()

    persistent pluginManager oc

    if isempty(pluginManager)
        pluginManager=hostmexif.newpluginmanager;
        if pluginManager==0
            error(message('audio:plugin:PluginManagerFailed'));
        end
        hostmexif.mexlock;
        if coder.target('MATLAB')
            oc=onCleanup(@cleanupPluginManager);
        else
            coder.internal.atexit(@cleanupPluginManager);
        end
    end
    pm=pluginManager;
end

function cleanupPluginManager
    pm=getPluginManager;
    hostmexif.deletepluginmanager(pm);


end

function yes=pluginIsWin32(pluginPath)


    yes=false;

    fid=fopen(pluginPath);
    if fid<0
        return
    end
    oc=onCleanup(@(f)fclose(fid));






    if fseek(fid,60,"bof")<0
        return
    end
    offsetToPESignature=fread(fid,1,"uint32");
    if isempty(offsetToPESignature)
        return
    end
    if fseek(fid,offsetToPESignature,"bof")<0
        return
    end


    peHeader=fread(fid,[1,4],"*char");
    if numel(peHeader)<4||~strcmp(peHeader,['PE',0,0])
        return
    end


    mctype=fread(fid,1,"uint16");




    yes=(mctype==hex2dec("14c"));
end

function revertOmpSymbLink(pluginPath)

    ompBackupFilePath=fullfile(pluginPath,'Contents','Resources','mkl-dnn_lib','libomp.dylib.donotdelete');
    if exist(ompBackupFilePath,'file')&&ismac

        ompSymLink=fullfile(pluginPath,'Contents','Resources','mkl-dnn_lib','libomp.dylib');
        movefile(ompBackupFilePath,ompSymLink,"f");
    end
end



