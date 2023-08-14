classdef PackageInstaller<hwconnectinstaller.internal.PackageInfo





    properties(Constant,Hidden)
        MANIFEST_FILENAME='package_registry.xml';
    end

    properties(Access=private)
        SupportPkg;
        LocalXmlFile='';
        hSetup;
        ProgressBar=false;
UsageLogger



        MostRecentDownloadOnlyDirectory='';
    end

    properties(Transient,Access=private)
        ManifestLocationOverriden=false
    end

    properties(Hidden,Access=public)
        XmlHttp='';
        SystemExecuteHandle;
        PreInstallTpPkgsFcn=function_handle.empty;
        ThreadedDownloadEnabled=true;
    end

    properties(Constant,GetAccess=private)
        INSTALLPCT=struct(...
        'installSupportPkg',0.05,...
        'installSpPkgStart',0.10,...
        'installSpPkgEnd',0.90,...
        'installTpPkgStart',0.10,...
        'installTpPkgEnd',0.95,...
        'refreshMatlab',0.95);
        UNINSTALLPCT=struct(...
        'uninstallSupportPkg',0.05,...
        'uninstallSpPkgStart',0.10,...
        'uninstallSpPkgEnd',0.90,...
        'uninstallTpPkgStart',0.10,...
        'uninstallTpPkgEnd',0.90,...
        'refreshMatlab',0.95);
        DOWNLOADPCT=struct(...
        'downloadSupportPkg',0.05,...
        'downloadSpPkgStart',0.10,...
        'downloadSpPkgEnd',0.90,...
        'downloadTpPkgStart',0.10,...
        'downloadTpPkgEnd',0.90,...
        'refreshMatlab',0.95);
        WEBACCESS_TIMEOUT_SECONDS=10
    end

    methods
        function set.XmlHttp(obj,http)
            if~ischar(http)
                error(message('hwconnectinstaller:setup:InputNotChar'));
            end
            obj.XmlHttp=http;




            obj.ManifestLocationOverriden=true;%#ok<MCSUP>
        end

        function set.PreInstallTpPkgsFcn(obj,fcn)

            if~isa(fcn,'function_handle')||~isempty(fcn)
                error('Input must either be empty or a valid function handle');
            end
            obj.PreInstallTpPkgsFcn=fcn;
        end
    end

    methods(Access=public)

        function out=getMostRecentDownloadOnlyDirectory(obj)
            out=obj.MostRecentDownloadOnlyDirectory;
        end

        function setUsageLogger(obj,logger)
            assert(isa(logger,'hwconnectinstaller.internal.UsageLogger')&&isvalid(logger));
            obj.UsageLogger=logger;
        end

        function logger=getUsageLogger(obj)
            if isempty(obj.UsageLogger)||~isvalid(obj.UsageLogger)
                obj.setUsageLogger(hwconnectinstaller.internal.UsageLogger());
            end
            logger=obj.UsageLogger;
        end

        function obj=PackageInstaller()
            obj.SupportPkg=hwconnectinstaller.SupportPackage();
        end



        function showDemoPage(obj,spPkgName)
            spPkg=obj.getSpPkgInfo(spPkgName);
            if isempty(spPkg)
                return;
            end
            [fcnHandle,inputArgs]=hwconnectinstaller.internal.getExamplesFcnAndArgs(spPkg);

            if~isempty(fcnHandle)
                fcnHandle(inputArgs{:});
            end

        end


        function executeExtraInfoCmd(~,pkg)
            if isempty(pkg.ExtraInfoCheckBoxCmd)
                return;
            end

            try
                tokenMap=hwconnectinstaller.util.getTokenMap(pkg);
                pkg.ExtraInfoCheckBoxCmd=hwconnectinstaller.util.evaluateCmd(pkg.ExtraInfoCheckBoxCmd,...
                tokenMap);
            catch ME
                switch ME.identifier
                case 'hwconnectinstaller:setup:CommandEvaluationError'
                    error(message('hwconnectinstaller:setup:ExtraInfoCheckBoxCmdError',...
                    pkg.Name,ME.message,fullfile(pkg.InstallDir,'registry')));
                case 'hwconnectinstaller:setup:WrongCmd'
                    error(message('hwconnectinstaller:setup:WrongExtraInfoCheckBoxCmd',...
                    pkg.Name,fullfile(pkg.InstallDir,'registry')));
                otherwise
                    rethrow(ME);
                end
            end
        end


        function register(~,spPkg,proxyInstallDir,savePaths)























            if~exist('proxyInstallDir','var')||isempty(proxyInstallDir)
                proxyInstallDir='';
            end
            if~exist('savePaths','var')
                savePaths=false;
            end

            validateattributes(spPkg,{'hwconnectinstaller.SupportPackage'},{'scalar'},'register','spPkg');
            validateattributes(proxyInstallDir,{'char'},{},'register','proxyInstallDir');
            validateattributes(savePaths,{'numeric','logical'},{'scalar'},'register','savePaths');

            if isempty(proxyInstallDir)

                installDir=spPkg.InstallDir;
            else



                installDir=proxyInstallDir;
            end

            hwconnectinstaller.internal.inform(sprintf('register: "%s" to %s',spPkg.Name,installDir));



            hwconnectinstaller.RegistryUtils.updateInfoFcn(spPkg,installDir);

            if~isempty(proxyInstallDir)






                hwconnectinstaller.PackageInstaller.refreshMatlab();
            end
        end


        function unregister(~,spPkg,savePaths)


















            if exist('savePaths','var')
                isProxyInstall=true;
            else
                isProxyInstall=false;
                savePaths=false;
            end

            validateattributes(spPkg,{'hwconnectinstaller.SupportPackage'},{'scalar'},'unregister','spPkg');
            validateattributes(savePaths,{'logical'},{'scalar'},'unregister','savePaths');





            hwconnectinstaller.internal.inform(sprintf('unregister: "%s" from %s',spPkg.Name,spPkg.InstallDir));



            hwconnectinstaller.RegistryUtils.deleteInfoFcn(spPkg);
            if isProxyInstall



            end
        end



        function updateRecursive(obj,spPkgName,downloadDir,progressBar)

            if(nargin<4)
                progressBar=false;
            end


            spPkg=obj.getSpPkgInfo(spPkgName,struct('missingInfoAction','error'));
            obj.uninstallRecursive(spPkgName,progressBar,true,struct('uninstallErrorAction','abort','cleanExeServer',1,...
            'implicitUninstallVisiblePkgs',true));
            obj.installRecursive(spPkgName,downloadDir,spPkg.InstallDir,progressBar);
        end


        function downloadRecursive(obj,spPkgName,downloadDir,opts)

            if~exist('opts','var')
                opts=struct();
            end
            if~isfield(opts,'progressBar')
                opts.progressBar=false;
            end


            if~isfield(opts,'customTpPkgsDownloadFcn')||isempty(opts.customTpPkgsDownloadFcn)
                opts.customTpPkgsDownloadFcn=function_handle.empty;
            end

            if~isfield(opts,'skipInstalledPackages')
                opts.skipInstalledPackages=false;
            end


            validateattributes(spPkgName,{'char'},{},'downloadRecursive','spPkgName');
            validateattributes(downloadDir,{'char'},{},'downloadRecursive','downloadDir');
            validateattributes(opts.progressBar,{'logical'},{'scalar'},'downloadRecursive','opts.progressBar');
            validateattributes(opts.skipInstalledPackages,{'logical'},{'scalar'},'downloadRecursive','skipInstalledPackages')
            assert(isa(opts.customTpPkgsDownloadFcn,'function_handle')&&numel(opts.customTpPkgsDownloadFcn)<=1,...
            message('hwconnectinstaller:setup:InvalidFunctionHandle',...
            'customTpPkgsDownloadFcn'));

            try
                opts.cleanExeServer=true;
                obj.downloadRecursiveImp(spPkgName,downloadDir,opts);
            catch ex
                obj.cleanupSystemExecuteServer(true);
                rethrow(ex);
            end
        end


        function installRecursive(obj,spPkgName,downloadDir,installDir,progressBar,savePaths,opts)

            if~exist('savePaths','var')
                savePaths=true;
            end
            if~exist('opts','var')
                opts=struct();
            end



            if isempty(downloadDir),downloadDir='';end
            if isempty(installDir),installDir='';end


            validateattributes(downloadDir,{'char'},{},'installRecursive','downloadDir');
            validateattributes(installDir,{'char'},{},'installRecursive','installDir');
            validateattributes(progressBar,{'logical','numeric'},{'scalar'},'installRecursive','progressBar');
            validateattributes(savePaths,{'logical','numeric'},{'scalar'},'installRecursive','savePaths');
            validateattributes(opts,{'struct'},{'scalar'},'installRecursive','opts');

            try
                opts.cleanExeServer=true;

                installRecursiveImp(obj,spPkgName,downloadDir,installDir,progressBar,savePaths,opts);


                matlabshared.supportpkg.internal.util.refreshDocCenter();
            catch ex
                obj.cleanupSystemExecuteServer(true);
                rethrow(ex);
            end
        end


        function downloadRecursiveImp(obj,spPkgName,downloadDir,opts)

            if~isfield(opts,'cleanExeServer')
                opts.cleanExeServer=true;
            end


            if~isfield(opts,'progressBar')
                opts.progressBar=false;
            end
            obj.ProgressBar=opts.progressBar;




            spPkgsTodownload=hwconnectinstaller.util.getSpPkgDownstreamList(spPkgName,spPkgList);



            installedPkgsInd=zeros(size(spPkgsTodownload));
            if opts.skipInstalledPackages
                for ind=1:length(spPkgsTodownload)
                    pkgInfo=obj.getSpPkgInfo(spPkgsTodownload(ind).Name);
                    if~isempty(pkgInfo)


                        installedPkgsInd(ind)=1;
                    end
                end

                spPkgsTodownload(logical(installedPkgsInd))=[];
            end

            if isempty(spPkgsTodownload)
                hwconnectinstaller.internal.inform('downloadRecursiveImp: no support packages to download');
                return;
            end


            downloadDir=obj.createDownloadDirectory(downloadDir,hwconnectinstaller.SupportPackage.getPkgTag(spPkgsTodownload(end).Name));




            alreadyDownloaded=containers.Map;



            [parentSppkgName,sppkgPbDispStrings]=i_getProgressBarDisplayStrings(spPkgsTodownload,spPkgName);
            if(obj.ProgressBar)
                obj.hSetup=obj.getProgressBar(obj.DOWNLOADPCT.downloadSupportPkg,...
                ['Downloading ',parentSppkgName]);
                c=onCleanup(@()obj.hSetup.closeProgressBar());
            end

            for ind=1:length(spPkgsTodownload)
                if(obj.ProgressBar)
                    pct=obj.DOWNLOADPCT.downloadSpPkgStart+...
                    ind*(obj.DOWNLOADPCT.downloadSpPkgEnd-obj.DOWNLOADPCT.downloadSpPkgStart)/length(spPkgsTodownload);
                    obj.advanceProgressBar(obj.hSetup,pct,...
                    ['Downloading ',sppkgPbDispStrings{ind}]);
                end
                spPkgToDownload=spPkgsTodownload(ind);
                if~isKey(alreadyDownloaded,spPkgToDownload.Name)
                    obj.download(spPkgToDownload,downloadDir,opts);
                    alreadyDownloaded(spPkgToDownload.Name)=true;
                end
            end

            obj.MostRecentDownloadOnlyDirectory=downloadDir;

            obj.cleanupSystemExecuteServer(opts.cleanExeServer);
        end


        function installRecursiveImp(obj,spPkgName,downloadDir,installDir,progressBar,savePaths,opts)

            if~isfield(opts,'cleanExeServer')
                opts.cleanExeServer=true;
            end


            if~isfield(opts,'webDownload')
                opts.webDownload=isempty(downloadDir);
            end
            if~exist('progressBar','var')
                progressBar=false;
            end
            obj.ProgressBar=progressBar;



            obj.checkDirectory(installDir,struct('allowUNC',0));


            obj.createDirectory(installDir);


            if~isempty(downloadDir)

                archiveHandler=hwconnectinstaller.ArchiveHandler.getInstance();
                spPkgList=archiveHandler.getPkgListFromFolder(downloadDir);

                installedPkgList=obj.getInstalledPackages();

                if~isempty(installedPkgList)
                    installedPkgNames={installedPkgList.Name};
                    inFolderPkgNames={spPkgList.Name};
                    repeatIndices=ismember(installedPkgNames,inFolderPkgNames);
                    installedPkgList(repeatIndices)=[];
                end
                installedAndFolderPkgList=[spPkgList,installedPkgList];

                [spPkgsToinstall,parentList]=hwconnectinstaller.util.getSpPkgDownstreamList(spPkgName,installedAndFolderPkgList);
                hDir=hwconnectinstaller.util.Location(downloadDir);
                if~hDir.isFolderWritable


                    for ind=1:length(spPkgList)


                        src=downloadDir;
                        [success,msg]=copyfile(src,installDir,'f');
                        if~success
                            error(message('hwconnectinstaller:setup:CopyError',downloadDir,msg));
                        end
                    end
                    downloadDir=installDir;
                end
            else

                spPkgList=obj.getPackageListFromWeb();

                [spPkgsToinstall,parentList]=hwconnectinstaller.util.getSpPkgDownstreamList(spPkgName,spPkgList);

                downloadDir=obj.createDownloadDirForInstall(installDir,hwconnectinstaller.SupportPackage.getPkgTag(spPkgsToinstall(end).Name));
            end

            assert(numel(spPkgsToinstall)==numel(parentList));


            [parentSppkgName,sppkgPbDispStrings]=i_getProgressBarDisplayStrings(spPkgsToinstall,spPkgName);
            if(obj.ProgressBar)
                obj.hSetup=obj.getProgressBar(obj.INSTALLPCT.installSupportPkg,...
                ['Installing ',parentSppkgName]);
                c=onCleanup(@()obj.hSetup.closeProgressBar());
            end

            try
                for ind=1:length(spPkgsToinstall)







                    if(obj.ProgressBar)
                        pct=obj.INSTALLPCT.installSpPkgStart+...
                        ind*(obj.INSTALLPCT.installSpPkgEnd-obj.INSTALLPCT.installSpPkgStart)/length(spPkgsToinstall);
                        obj.advanceProgressBar(obj.hSetup,pct,...
                        ['Installing ',sppkgPbDispStrings{ind}]);
                    end
                    if~isempty(parentList{ind})
                        parentSpPkg=parentList{ind};
                        parent=struct('Name',parentSpPkg.Name,'Version',parentSpPkg.Version);
                    else
                        parent=[];
                    end

                    installedSpPkg=obj.getSpPkgInfo(spPkgsToinstall(ind).Name);

                    if isempty(installedSpPkg)

                        spPkgsToinstall(ind)=i_addParent(parent,spPkgsToinstall(ind));
                        obj.install(spPkgsToinstall(ind),downloadDir,installDir,progressBar,savePaths,opts);
                    else



                        if installedSpPkg.NumericVersion>=spPkgsToinstall(ind).NumericVersion




                            installedSpPkg=i_addParent(parent,installedSpPkg);

                            hwconnectinstaller.RegistryUtils.updateInfoFcn(installedSpPkg);
                        else



                            obj.uninstall(installedSpPkg,progressBar,savePaths);
                            spPkgsToinstall(ind)=i_addParent(parent,spPkgsToinstall(ind));
                            obj.install(spPkgsToinstall(ind),downloadDir,installDir,progressBar,savePaths,opts);
                        end
                    end
                end
            catch ME
                for i=ind:-1:1


                    spPkgsToinstall(i)=i_removeStaleParents(spPkgsToinstall(i));
                    if~isempty(obj.getSpPkgInfo(spPkgsToinstall(i).Name))&&...
                        (isempty(spPkgsToinstall(i).Parent)||any(ismember({spPkgsToinstall(i).Parent.Name},{spPkgsToinstall.Name})))
                        obj.uninstall(spPkgsToinstall(i).Name);
                    end
                end
                obj.cleanupSystemExecuteServer(opts.cleanExeServer);
                rethrow(ME);
            end
        end


        function uninstallRecursive(obj,spPkgName,progressBar,savePaths,options)


            if~exist('progressBar','var')
                progressBar=false;
            end
            if~exist('savePaths','var')
                savePaths=true;
            end
            if~exist('options','var')
                options=struct();
            end
            if~isfield(options,'uninstallErrorAction')



                options.uninstallErrorAction='continue';
            end
            if~isfield(options,'cleanExeServer')
                options.cleanExeServer=true;
            end
            if~isfield(options,'deferClearClasses')
                options.deferClearClasses=false;
            end


            validateattributes(progressBar,{'logical','numeric'},{'scalar'},'uninstallRecursive','progressBar');
            validateattributes(savePaths,{'logical','numeric'},{'scalar'},'uninstallRecursive','savePaths');
            validateattributes(options,{'struct'},{'scalar'},'uninstallRecursive','opts');

            try
                uninstallRecursiveImp(obj,spPkgName,progressBar,savePaths,options);

                matlabshared.supportpkg.internal.util.refreshDocCenter();
            catch ex
                obj.cleanupSystemExecuteServer(true);
                rethrow(ex);
            end
        end


        function uninstallRecursiveImp(obj,spPkgName,progressBar,savePaths,options)

            if~isfield(options,'cleanExeServer')
                options.cleanExeServer=true;
            end
            if~isfield(options,'uninstallErrorAction')
                options.uninstallErrorAction='continue';
            end
            if~isfield(options,'implicitUninstallVisiblePkgs')
                options.implicitUninstallVisiblePkgs=false;
            end
            if~exist('progressBar','var')
                progressBar=false;
            end
            obj.ProgressBar=progressBar;




            spPkgList=obj.getInstalledPackages();

            if isempty(spPkgList)
                error(message('hwconnectinstaller:installapi:NoInstalledSupportPackages'));
            end

            explicitSpPkg=obj.getSpPkgObject(spPkgName,spPkgList);
            if isempty(obj.getSpPkgObject(spPkgName,spPkgList))
                error(message('hwconnectinstaller:installapi:SupportPackageNotInstalled',spPkgName));
            end
















            explicitSpPkg=i_removeStaleParents(explicitSpPkg);



            if~isempty(explicitSpPkg.Parent)

                parentNames={};
                for p=1:numel(explicitSpPkg.Parent)
                    parentObj=obj.getSpPkgInfo(explicitSpPkg.Parent(p).Name);
                    parentNames{p}=parentObj.FullName;%#ok<AGROW>
                end
                parentNames=['- ',strjoin(parentNames,'\n- ')];
                error(message('hwconnectinstaller:installapi:CannotUninstall_ParentsExist',...
                explicitSpPkg.FullName,parentNames));
            end




            spPkgsTouninstall=hwconnectinstaller.util.getSpPkgDownstreamList(...
            spPkgName,spPkgList,struct('missingPackageAction','warning'));









            [parentSppkgName,sppkgPbDispStrings]=i_getProgressBarDisplayStrings(spPkgsTouninstall,spPkgName);
            if(obj.ProgressBar)
                obj.hSetup=obj.getProgressBar(obj.UNINSTALLPCT.uninstallSupportPkg,...
                ['Uninstalling ',parentSppkgName]);
                c=onCleanup(@()obj.hSetup.closeProgressBar());
            end
            for ind=length(spPkgsTouninstall):-1:1
                try
                    spPkgToUninstall=spPkgsTouninstall(ind);
                    if(obj.ProgressBar)
                        pct=obj.UNINSTALLPCT.uninstallSpPkgStart+...
                        ind*(obj.UNINSTALLPCT.uninstallSpPkgStart-obj.UNINSTALLPCT.uninstallSpPkgEnd)/length(spPkgsTouninstall);
                        obj.advanceProgressBar(obj.hSetup,pct,...
                        ['Uninstalling ',sppkgPbDispStrings{ind}]);
                    end



                    spPkgToUninstall=i_removeStaleParents(spPkgToUninstall);

                    explicitlySpecified=strcmpi(spPkgName,spPkgToUninstall.Name);
                    hasParents=~isempty(spPkgToUninstall.Parent);
                    pkgIsVisible=spPkgToUninstall.Visible;

                    if explicitlySpecified&&~hasParents



                        hwconnectinstaller.internal.inform(...
                        sprintf('uninstallRecursive - %s  - explicit, no parents - UNINSTALLING',...
                        spPkgToUninstall.Name));
                        obj.uninstall(spPkgToUninstall,progressBar,savePaths,options);

                    elseif~explicitlySpecified&&hasParents



                        hwconnectinstaller.internal.inform(...
                        sprintf('uninstallRecursive - %s  - implicit, has parents - SKIPPING',...
                        spPkgToUninstall.Name));
                        hwconnectinstaller.RegistryUtils.updateInfoFcn(spPkgToUninstall);

                    elseif pkgIsVisible&&~explicitlySpecified&&~hasParents


                        debugMsg=sprintf('uninstallRecursive - %s  - visible, implicit, no parents ',...
                        spPkgToUninstall.Name);
                        if options.implicitUninstallVisiblePkgs
                            hwconnectinstaller.internal.inform([debugMsg,'- UNINSTALLING']);
                            obj.uninstall(spPkgToUninstall,progressBar,savePaths,options);
                        else

                            hwconnectinstaller.internal.inform([debugMsg,'- SKIPPING']);
                            hwconnectinstaller.RegistryUtils.updateInfoFcn(spPkgToUninstall);
                        end

                    elseif~pkgIsVisible&&~explicitlySpecified&&~hasParents



                        hwconnectinstaller.internal.inform(...
                        sprintf('uninstallRecursive - %s  - hidden, implicit, no parents - UNINSTALLING',...
                        spPkgToUninstall.Name));
                        obj.uninstall(spPkgToUninstall,progressBar,savePaths,options);

                    else



                        assert(false,'uninstallRecursiveImp - Internal consistency');
                    end
                catch ME
                    if strcmp(ME.identifier,'hwconnectinstaller:setup:TpPkgUninstallAbort')
                        doContinue=false;
                    elseif strcmpi(options.uninstallErrorAction,'dialog')
                        userResponse=questdlg(ME.message,...
                        message('hwconnectinstaller:setup:UninstallContinueAbort').getString,...
                        message('hwconnectinstaller:setup:UninstallContinue').getString,...
                        message('hwconnectinstaller:setup:UninstallAbort').getString,...
                        message('hwconnectinstaller:setup:UninstallContinue').getString);
                        if isempty(userResponse)

                            userResponse=message('hwconnectinstaller:setup:UninstallContinue').getString;
                        end
                        doContinue=strcmp(userResponse,message('hwconnectinstaller:setup:UninstallContinue').getString);
                    else
                        doContinue=strcmpi(options.uninstallErrorAction,'continue');
                    end

                    if~doContinue
                        obj.cleanupSystemExecuteServer(options.cleanExeServer);
                        rethrow(ME);
                    end
                end
            end

        end

        function cleanupSystemExecuteServer(obj,cleanExeServer)
            if cleanExeServer&&~isempty(obj.SystemExecuteHandle)
                obj.SystemExecuteHandle.close();
                obj.SystemExecuteHandle=[];
            end
        end



        function download(obj,spPkg,downloadDir,opts)





            validateattributes(spPkg,{'hwconnectinstaller.SupportPackage'},{'scalar'},'download','spPkg');
            validateattributes(downloadDir,{'char'},{'nonempty'},'download','downloadDir');
            validateattributes(opts,{'struct'},{'scalar'},'download','opts');

            if~isfield(opts,'skipInstalledPackages')
                opts.skipInstalledPackages=false;
            end

            obj.SupportPkg=spPkg;




            if~isdir(downloadDir)
                downloadDir=obj.createDownloadDirectory(downloadDir,hwconnectinstaller.SupportPackage.getPkgTag(obj.SupportPkg.Name));
            end

            newSp=[];
            try
                obj.SupportPkg.DownloadDir=downloadDir;
                obj.downloadSupportPkg(downloadDir,opts);





                if~isempty(obj.SupportPkg.TpPkg)
                    tmpDir=tempname;
                    [st,msg,msgid]=mkdir(tmpDir);
                    cMkDir=onCleanup(@()rmdir(tmpDir,'s'));
                    if(st~=1)
                        warning(msgid,msg);
                        return;
                    end


                    newSp=obj.prepareTpPkgforDownload(obj.SupportPkg.DownloadDir,tmpDir);

                    if~isempty(newSp.UrlCatalog)
                        localCatalogFile=fullfile(obj.SupportPkg.DownloadDir,newSp.UrlCatalog);
                        pkgTag=hwconnectinstaller.SupportPackage.getPkgTag(obj.SupportPkg.Name);

                        hwconnectinstaller.internal.inform(...
                        sprintf('download: urlcatalog for "%s" = %s',obj.SupportPkg.Name,localCatalogFile));
                        obj.SupportPkg.UrlCatalogHandle=hwconnectinstaller.util.UrlCatalog(localCatalogFile);
                    end



                    obj.downloadTpPkgs(obj.SupportPkg.DownloadDir,opts);

                    obj.tpPkgDownloadCleanup(newSp);
                end

            catch ex
                if~isempty(newSp)


                    obj.tpPkgDownloadCleanup(newSp);
                end
                obj.cleanupSystemExecuteServer(true);
                rethrow(ex);
            end
        end



        function install(obj,spPkg,downloadDir,installDir,progressBar,savePaths,options)











            if~exist('savePaths','var')
                savePaths=true;
            end
            if~exist('options','var')
                options=struct();
            end
            if~isfield(options,'webDownload')
                options.webDownload=true;
            end


            if~exist('progressBar','var')
                progressBar=false;
            end
            options.progressBar=progressBar;


            obj.checkDirectory(installDir,struct('allowUNC',0));


            obj.createDirectory(installDir);



            if~isa(spPkg,'hwconnectinstaller.SupportPackage')
                validateattributes(spPkg,{'char'},{'nonempty'},'install','spPkg');

                if~isempty(downloadDir)

                    archiveHandler=hwconnectinstaller.ArchiveHandler.getInstance();
                    pkglist=archiveHandler.getPkgListFromFolder(downloadDir);
                    obj.SupportPkg=obj.getSpPkgObject(spPkg,pkglist);
                    if isempty(obj.SupportPkg)
                        error(message('hwconnectinstaller:setup:InvalidSupportPackage',spPkg));
                    end

                    hDir=hwconnectinstaller.util.Location(downloadDir);
                    if~hDir.isFolderWritable
                        src=downloadDir;
                        [success,msg]=copyfile(src,installDir,'f');
                        if~success
                            errMsg=['Error copying ',...
                            obj.SupportPkg.Name,...
                            ' files to installation folder.\nDetails: ',msg];
                            error(message('hwconnectinstaller:setup:Error',errMsg));
                        end
                        downloadDir=installDir;
                    end
                    options.webDownload=false;
                else

                    obj.SupportPkg=obj.getSpPkgInfoFromWeb(spPkg);
                    if isempty(obj.SupportPkg)
                        error(message('hwconnectinstaller:setup:InvalidSupportPackage',spPkg));
                    end

                    downloadDir=obj.createDownloadDirForInstall(installDir,hwconnectinstaller.SupportPackage.getPkgTag(obj.SupportPkg.Name));
                    options.webDownload=true;
                end
            else
                validateattributes(spPkg,{'hwconnectinstaller.SupportPackage'},{'scalar'},'install','spPkg');
                obj.SupportPkg=spPkg;
            end





            if~hwconnectinstaller.internal.isSingleSupportPackageRoot()
                obj.verifyInstallFolderIsEmpty(installDir,hwconnectinstaller.SupportPackage.getPkgTag(obj.SupportPkg.Name));
            end

            try





                obj.installSupportPkg(downloadDir,installDir,options);




                hwconnectinstaller.util.copyDocCenterBaseFiles(obj.SupportPkg.Name,obj.SupportPkg.InstallDir);
            catch ex


                obj.uninstallSupportPkg();
                rethrow(ex);
            end


            hwconnectinstaller.util.registerMessageCatalog(obj.SupportPkg);



            try


                if~isempty(obj.PreInstallTpPkgsFcn)
                    obj.PreInstallTpPkgsFcn(struct('InstallDir',installDir,'DownloadDir',downloadDir));
                end
                obj.installTpPkgs(downloadDir,installDir,options);
            catch ex
                obj.uninstallTpPkgs(struct('uninstallErrorAction','continue'));
                obj.uninstallSupportPkg();
                rethrow(ex);
            end


            if options.progressBar
                if obj.SupportPkg.Visible
                    displayStr=['Registering ',obj.SupportPkg.FullName];
                else
                    displayStr='Registering...';
                end
                obj.advanceProgressBar(obj.hSetup,-1,...
                displayStr);
            end




            obj.register(obj.SupportPkg);





            if savePaths
                hwconnectinstaller.RegistryUtils.savePath();
            end


            hwconnectinstaller.PackageInstaller.refreshMatlab();


            obj.postInstallCmd(obj.SupportPkg);

            obj.getUsageLogger().sendEventWhenEnabled('INSTALL_COMPLETE',...
            obj.SupportPkg.Name);
        end


        function uninstall(obj,spPkg,progressBar,savePaths,opts)





            if~exist('progressBar','var')
                progressBar=false;
            end
            if~exist('savePaths','var')
                savePaths=true;
            end
            if~exist('opts','var')
                opts=struct();
            end
            if~isfield(opts,'uninstallErrorAction')
                opts.uninstallErrorAction='continue';
            end
            if~isfield(opts,'deferClearClasses')
                opts.deferClearClasses=false;
            end


            obj.ProgressBar=progressBar;



            if~isa(spPkg,'hwconnectinstaller.SupportPackage')
                validateattributes(spPkg,{'char'},{'nonempty'},'uninstall','spPkg');

                obj.SupportPkg=obj.getSpPkgInfo(spPkg);
            else
                validateattributes(spPkg,{'hwconnectinstaller.SupportPackage'},{'scalar'},'uninstall','spPkg');
                obj.SupportPkg=spPkg;
            end
            if isempty(obj.SupportPkg)
                error(message('hwconnectinstaller:setup:NoSupportPackageToUninstall',spPkg));
            end










            obj.preUninstallCmd(obj.SupportPkg);




            obj.prepareForUninstall(obj.SupportPkg);



            obj.unregister(obj.SupportPkg);



            obj.uninstallTpPkgs(opts);




            hwconnectinstaller.PackageInstaller.clearMexAndClasses(opts);



            obj.uninstallSupportPkg();

            if savePaths
                hwconnectinstaller.RegistryUtils.savePath();
            end

            hwconnectinstaller.PackageInstaller.refreshMatlab();

            obj.getUsageLogger().sendEventWhenEnabled('UNINSTALL_COMPLETE',obj.SupportPkg.Name);
            obj.getUsageLogger().sendBaseCodeWhenEnabled(obj.SupportPkg.Name,obj.SupportPkg.BaseCode);
        end


        function update(obj,spPkg,downloadDir,progressBar)



            if(nargin<4)
                progressBar=false;
            end


            obj.uninstall(spPkg,progressBar);
            obj.install(spPkg,downloadDir,obj.SupportPkg.InstallDir,progressBar);
        end
    end

    methods(Access=protected)


        function downloadTpPkgs(obj,downloadDir,opts)

            if~isfield(opts,'progressBar')
                opts.progressBar=false;
            end




            opts.webDownload=true;

            obj.ProgressBar=opts.progressBar;

            numTpPkgs=numel(obj.SupportPkg.TpPkg);

            if numTpPkgs>0

                alltpPkgObj=obj.getPlatformIndependentTpPkgInfo(obj.SupportPkg);



                hwconnectinstaller.internal.ThirdPartyPkgStrategy.thirdPartyConsistencyCheck(alltpPkgObj);


                allInstructionSets=hwconnectinstaller.internal.ThirdPartyPkgStrategy.areAllTpPkgsInstructionSets(alltpPkgObj);
            end

            if numTpPkgs>0&&isempty(obj.SystemExecuteHandle)&&~allInstructionSets
                obj.SystemExecuteHandle=hwconnectinstaller.util.SystemExecute.getInstance();
            end

            for i=1:numTpPkgs

                obj.applyUrlCatalogToTppkg(obj.SupportPkg.TpPkg(i));



                if(obj.ProgressBar)
                    pct=obj.DOWNLOADPCT.downloadTpPkgStart+...
                    i*(obj.DOWNLOADPCT.downloadTpPkgEnd-obj.DOWNLOADPCT.downloadTpPkgStart)/numTpPkgs;
                    obj.advanceProgressBar(obj.hSetup,pct,...
                    ['Downloading ',obj.SupportPkg.TpPkg(i).Name]);
                end
            end
        end


        function installTpPkgs(obj,~,~,opts)
            if~isfield(opts,'progressBar')
                opts.progressBar=false;
            end
            obj.ProgressBar=opts.progressBar;

            numTpPkgs=numel(obj.SupportPkg.TpPkg);

            if numTpPkgs>0


                alltpPkgObj=obj.getPlatformIndependentTpPkgInfo(obj.SupportPkg);



                hwconnectinstaller.internal.ThirdPartyPkgStrategy.thirdPartyConsistencyCheck(alltpPkgObj);


                allInstructionSets=hwconnectinstaller.internal.ThirdPartyPkgStrategy.areAllTpPkgsInstructionSets(alltpPkgObj);
            end


            if numTpPkgs>0&&isempty(obj.SystemExecuteHandle)&&~allInstructionSets
                obj.SystemExecuteHandle=hwconnectinstaller.util.SystemExecute.getInstance();
            end

            for i=1:numTpPkgs

                obj.applyUrlCatalogToTppkg(obj.SupportPkg.TpPkg(i));







                currinstaller=obj.SupportPkg.TpPkg(i).Installer;
                for j=1:i-1
                    if strcmp(currinstaller,obj.SupportPkg.TpPkg(j).Name)
                        obj.SupportPkg.TpPkg(i).Installer=...
                        fullfile(obj.SupportPkg.TpPkg(j).RootDir,...
                        obj.SupportPkg.TpPkg(j).FileName);
                        break;
                    end
                end
            end

            tpPkg_legacy=cellfun(@isempty,{obj.SupportPkg.TpPkg.InstructionSet});
            tpPkg_is=~tpPkg_legacy;


            tpPkgs_InstructionSet=obj.SupportPkg.TpPkg(tpPkg_is);


            tpPkgs_Legacy=obj.SupportPkg.TpPkg(tpPkg_legacy);


            obj.SupportPkg.TpPkg(tpPkg_is)=tpPkgs_InstructionSet;
            obj.SupportPkg.TpPkg(tpPkg_legacy)=tpPkgs_Legacy;
        end


        function uninstallTpPkgs(obj,opts)


            if~isfield(opts,'progressBar')
                opts.progressBar=false;
            end
            obj.ProgressBar=opts.progressBar;
            if~isfield(opts,'uninstallErrorAction')
                opts.uninstallErrorAction='continue';
            end

            numTpPkgs=numel(obj.SupportPkg.TpPkg);


            if numTpPkgs>0&&isempty(obj.SystemExecuteHandle)
                obj.SystemExecuteHandle=hwconnectinstaller.util.SystemExecute.getInstance();
            end

            for i=numTpPkgs:-1:1


                if(obj.ProgressBar)
                    pct=obj.UNINSTALLPCT.uninstallTpPkgStart+...
                    (numTpPkgs-i+1)*(obj.UNINSTALLPCT.uninstallTpPkgEnd-...
                    obj.UNINSTALLPCT.uninstallTpPkgStart)/numTpPkgs;
                    obj.advanceProgressBar(obj.hSetup,pct,...
                    ['Removing ',obj.SupportPkg.TpPkg(i).Name]);
                end
                try
                    obj.SupportPkg.TpPkg(i)=obj.uninstallThirdPartyPackage(...
                    obj.SupportPkg.TpPkg(i));
                catch ME
                    if strcmpi(opts.uninstallErrorAction,'dialog')
                        userResponse=questdlg(ME.message,...
                        message('hwconnectinstaller:setup:UninstallContinueAbort').getString,...
                        message('hwconnectinstaller:setup:UninstallContinue').getString,...
                        message('hwconnectinstaller:setup:UninstallAbort').getString,...
                        message('hwconnectinstaller:setup:UninstallContinue').getString);
                        if isempty(userResponse)

                            userResponse=message('hwconnectinstaller:setup:UninstallContinue').getString;
                        end
                        doContinue=strcmp(userResponse,message('hwconnectinstaller:setup:UninstallContinue').getString);
                    else
                        doContinue=strcmpi(opts.uninstallErrorAction,'continue');
                    end

                    if~doContinue
                        throw(MException('hwconnectinstaller:setup:TpPkgUninstallAbort','%s\n%s',...
                        message('hwconnectinstaller:setup:TpPkgUninstallAbort').getString,ME.message));
                    end
                end
            end
        end



        function spPkg=getSpPkgInfoFromWeb(obj,name)
            if~isa(name,'char')
                error(message('hwconnectinstaller:setup:InvalidArgument','name'));
            end
            pkglist=obj.getPackageListFromWeb();

            spPkg=obj.getSpPkgObject(name,pkglist);
        end



        function downloadSupportPkg(obj,downloadDir,opts)

            if~isfield(opts,'webDownload')
                opts.webDownload=false;
            end
            obj.SupportPkg.IsDownloaded=false;
            logger=obj.getUsageLogger();
            downloadStrategy=hwconnectinstaller.internal.getSupportPackageDownloadStrategy();
            downloadStrategy.downloadSupportPackageFilesOverwrite(downloadDir,obj.SupportPkg);
            downloadStrategy.logNewDownloadUsageData(logger,obj.SupportPkg);
            obj.SupportPkg.IsDownloaded=true;
            logger.Enabled=true;
            obj.SupportPkg.DownloadDir=downloadDir;
        end





        function installSupportPkg(obj,downloadDir,installDir,opts)

            if~isfield(opts,'webDownload')
                opts.webDownload=false;
            end

            hwconnectinstaller.internal.inform(sprintf('installSupportPkg: "%s" to "%s"',...
            obj.SupportPkg.Name,installDir));
            pkgTag=hwconnectinstaller.SupportPackage.getPkgTag(obj.SupportPkg.Name);
            if~hwconnectinstaller.internal.isSingleSupportPackageRoot()
                obj.verifyInstallFolderIsEmpty(installDir,pkgTag);
            end
            obj.SupportPkg.IsInstalled=false;
            logger=obj.getUsageLogger();
            logger.sendEventWhenEnabled('EXISTING_DOWNLOAD',obj.SupportPkg.Name,downloadDir);
            logger.sendBaseCodeWhenEnabled(obj.SupportPkg.Name,obj.SupportPkg.BaseCode);


            obj.SupportPkg.DownloadDir=downloadDir;
            obj.SupportPkg.InstallDir=installDir;
            obj.SupportPkg.InstalledDate=datestr(now);






            oldPath=hwconnectinstaller.PackageInstaller.getFullPaths(installDir);
            archiveHandler=hwconnectinstaller.ArchiveHandler.getInstance();
            archiveHandler.extractSpPkgArchive(obj.SupportPkg,downloadDir,fullfile(installDir));
            obj.SupportPkg.RootDir=fullfile(obj.SupportPkg.InstallDir,obj.SupportPkg.ToolboxPath);
            assert(isdir(obj.SupportPkg.RootDir),'Internal Error: Support package did not install successfully. Please check installer logs.');
            obj.SupportPkg.IsInstalled=true;




            if~isempty(obj.SupportPkg.UrlCatalog)&&~isempty(obj.SupportPkg.TpPkg)
                localCatalogFile=fullfile(downloadDir,obj.SupportPkg.UrlCatalog);

                if opts.webDownload

                elseif~exist(localCatalogFile,'file')

                    downloadDir=obj.createDownloadDirForInstall(installDir,hwconnectinstaller.SupportPackage.getPkgTag(obj.SupportPkg.Name));
                    localCatalogFile=fullfile(downloadDir,obj.SupportPkg.UrlCatalog);


                end

                hwconnectinstaller.internal.inform(...
                sprintf('installSupportPkg: urlcatalog for "%s" = %s',obj.SupportPkg.Name,localCatalogFile));
                obj.SupportPkg.UrlCatalogHandle=hwconnectinstaller.util.UrlCatalog(localCatalogFile);
            end

            newPath=hwconnectinstaller.PackageInstaller.getFullPaths(installDir);


            obj.SupportPkg.Path=setdiff(newPath,oldPath);

            hwconnectinstaller.RegistryUtils.addDirsToPath(obj.SupportPkg);



            [~,srcFile,~]=hwconnectinstaller.util.getLicenseAndDialogTitle(obj.SupportPkg);


            [~,licenseFileName]=fileparts(srcFile);
            destFile=fullfile(obj.SupportPkg.InstallDir,[licenseFileName,'.txt']);

            if~logical(exist(destFile,'file'))
                copyfile(srcFile,destFile,'f');
            end
        end

        function uninstallSupportPkg(~)
        end
    end

    methods(Static,Hidden,Access=public)

        function spPkg=loadPkgInfo(localXmlFile,mlrelease)
            spPkg=hwconnectinstaller.SupportPackage;
            spPkg(1)=[];

            if~(exist(localXmlFile,'file')==2)
                error(message('hwconnectinstaller:setup:NonExistentFile',localXmlFile));
            end


            try
                domNode=parseFile(matlab.io.xml.dom.Parser,localXmlFile);
            catch
                error(message('hwconnectinstaller:setup:CorruptedManifest'));
            end

            pkgrepository=domNode.getDocumentElement();
            matlabreleases=pkgrepository.getElementsByTagName('MatlabRelease');
            currrelease=hwconnectinstaller.PackageInstaller.getelement(matlabreleases,mlrelease,'name');
            if isempty(currrelease)
                error(message('hwconnectinstaller:setup:UnsupportedRelease',mlrelease));
            end
            packages=currrelease.getElementsByTagName('SupportPackage');
            for i=0:packages.getLength-1
                currpkg=packages.item(i);
                spPkg(i+1)=hwconnectinstaller.SupportPackage(...
                char(currpkg.getAttribute('name')),...
                char(currpkg.getAttribute('url')),...
                char(currpkg.getAttribute('version')),...
                mlrelease,...
                char(currpkg.getAttribute('folder')));
                spPkg(i+1).Visible=char(currpkg.getAttribute('visible'));
                spPkg(i+1).Enable=char(currpkg.getAttribute('enable'));
                spPkg(i+1).Platform=char(currpkg.getAttribute('platform'));
                spPkg(i+1).BaseProduct=char(currpkg.getAttribute('baseproduct'));
                isDownloadWithoutInstallAllowed=char(currpkg.getAttribute('allowdownloadwithoutinstall'));
                if~isempty(isDownloadWithoutInstallAllowed)
                    spPkg(i+1).AllowDownloadWithoutInstall=~isequal(lower(isDownloadWithoutInstallAllowed),'no');
                end
                spPkg(i+1).FullName=char(currpkg.getAttribute('fullname'));
                displayName=char(currpkg.getAttribute('displayname'));
                if isempty(displayName)
                    spPkg(i+1).DisplayName=spPkg(i+1).Name;
                else
                    spPkg(i+1).DisplayName=displayName;
                end
                supportCategory=char(currpkg.getAttribute('supportcategory'));
                if isempty(supportCategory)
                    spPkg(i+1).SupportCategory='hardware';
                else
                    spPkg(i+1).SupportCategory=supportCategory;
                end
                baseCode=char(currpkg.getAttribute('basecode'));
                if isempty(baseCode)
                    spPkg(i+1).BaseCode='';
                else
                    spPkg(i+1).BaseCode=baseCode;
                end
                supportTypeQualifier=char(currpkg.getAttribute('supporttypequalifier'));
                if isempty(supportTypeQualifier)
                    spPkg(i+1).SupportTypeQualifier=char(hwconnectinstaller.SupportTypeQualifierEnum.Standard);
                else
                    spPkg(i+1).SupportTypeQualifier=supportTypeQualifier;
                end
                customMWLicenseFiles=char(currpkg.getAttribute('custommwlicensefiles'));
                if isempty(customMWLicenseFiles)
                    spPkg(i+1).CustomMWLicenseFiles='';
                else
                    spPkg(i+1).CustomMWLicenseFiles=customMWLicenseFiles;
                end
                spPkg(i+1).CustomLicense=char(currpkg.getAttribute('customlicense'));
                spPkg(i+1).CustomLicenseNotes=char(currpkg.getAttribute('customlicensenotes'));
                spPkg(i+1).ShowSPLicense=~isequal(lower(char(currpkg.getAttribute('showsplicense'))),'no');
                spPkg(i+1).DownloadUrl=char(currpkg.getAttribute('downloadurl'));
                spPkg(i+1).LicenseUrl=char(currpkg.getAttribute('licenseurl'));

                infoUrl=char(currpkg.getAttribute('infohyperlink'));
                if~isempty(infoUrl)
                    spPkg(i+1).InfoUrl=infoUrl;
                end
                spPkg(i+1).InfoText=char(currpkg.getAttribute('infotext'));

                tmp=currpkg.getElementsByTagName('DependsOn');
                for j=0:tmp.getLength-1
                    spPkg(i+1).Children(j+1).Name=char(tmp.item(j).getAttribute('name'));
                    spPkg(i+1).Children(j+1).Version=char(tmp.item(j).getAttribute('version'));
                end



                tmp=currpkg.getElementsByTagName('ThirdPartyPackage');
                spPkg(i+1).TpPkg=hwconnectinstaller.ThirdPartyPackage.empty;
                tpPkgCnt=0;
                for j=0:tmp.getLength-1
                    supportedPlatforms=char(tmp.item(j).getAttribute('platforms'));
                    if isempty(supportedPlatforms)
                        supportedPlatforms='ALL';
                    end
                    thisPlatform=hwconnectinstaller.util.getCurrentPlatform();
                    matchStatus=hwconnectinstaller.util.matchPlatformStr(thisPlatform,supportedPlatforms);
                    if matchStatus<=0
                        continue;
                    end

                    tpPkgCnt=tpPkgCnt+1;
                    spPkg(i+1).TpPkg(tpPkgCnt)=hwconnectinstaller.ThirdPartyPackage(...
                    char(tmp.item(j).getAttribute('name')),...
                    char(tmp.item(j).getAttribute('url')));
                    spPkg(i+1).TpPkg(tpPkgCnt).LicenseUrl=char(tmp.item(j).getAttribute('licenseurl'));
                    spPkg(i+1).TpPkg(tpPkgCnt).PlatformStr=upper(supportedPlatforms);
                end
            end
        end
    end

    methods(Access=private)


        function pkg=preUninstallCmd(~,pkg,downloadDir,installDir)%#ok<INUSD>
            if isempty(pkg.PreUninstallCmd)
                return;
            end
            try
                hwconnectinstaller.internal.inform(sprintf('Evaluating preuninstallcmd: %s',...
                pkg.PreUninstallCmd));
                tokenMap=hwconnectinstaller.util.getTokenMap(pkg);
                pkg.PreUninstallCmd=hwconnectinstaller.util.evaluateCmd(pkg.PreUninstallCmd,...
                tokenMap);
            catch ME


                switch ME.identifier
                case 'hwconnectinstaller:setup:CommandEvaluationError'
                    warning(message('hwconnectinstaller:setup:PreUninstallCmdError',...
                    pkg.Name,ME.message));
                case 'hwconnectinstaller:setup:WrongCmd'
                    warning(message('hwconnectinstaller:setup:WrongPreUninstallCmd',...
                    pkg.Name));
                otherwise
                    warning(ME.identifier,ME.getReport);
                end
            end
        end




        function pkg=postInstallCmd(~,pkg,downloadDir,installDir)%#ok<INUSD>
            if isempty(pkg.PostInstallCmd)
                return;
            end

            try
                tokenMap=hwconnectinstaller.util.getTokenMap(pkg);
                pkg.PostInstallCmd=hwconnectinstaller.util.evaluateCmd(pkg.PostInstallCmd,...
                tokenMap);
            catch ME
                switch ME.identifier
                case 'hwconnectinstaller:setup:CommandEvaluationError'
                    error(message('hwconnectinstaller:setup:PostInstallCmdError',...
                    pkg.Name,ME.message));
                case 'hwconnectinstaller:setup:WrongCmd'
                    error(message('hwconnectinstaller:setup:WrongPostInstallCmd',...
                    pkg.Name));
                otherwise
                    rethrow(ME);
                end
            end
        end

        function tpPkgDownloadCleanup(obj,newSp)%#ok<INUSL>
            hwconnectinstaller.RegistryUtils.removeDirsFromPath(newSp);
        end

        function newSp=prepareTpPkgforDownload(obj,downloadDir,tmpDir)



            archiveHandler=hwconnectinstaller.ArchiveHandler.getInstance();
            allSps=archiveHandler.getPkgListFromFolder(downloadDir);
            allSpNames={allSps.Name};
            newSp=allSps(strcmp(allSpNames,obj.SupportPkg.Name));
            archiveHandler.extractSpPkgArchive(newSp,downloadDir,tmpDir);
            newSp.Path=hwconnectinstaller.PackageInstaller.getFullPaths(tmpDir);
            newSp.RootDir=fullfile(tmpDir,newSp.ToolboxPath);
            hwconnectinstaller.RegistryUtils.addDirsToPath(newSp);
            obj.SupportPkg.TpPkg=newSp.TpPkg;
            obj.SupportPkg.RootDir=newSp.RootDir;
        end



        function applyUrlCatalogToTppkg(obj,tppkg)
            if~isempty(obj.SupportPkg.UrlCatalogHandle)

                propertyList={
'Url'
'FileName'
'DestDir'
'Installer'
'Archive'
'PreDownloadCmd'
'DownloadUrl'
'DownloadCmd'
'InstallCmd'
'RemoveCmd'
'LicenseUrl'
                };
                for k=1:numel(propertyList)
                    updatedProperty=...
                    obj.SupportPkg.UrlCatalogHandle.replaceTokens(tppkg.(propertyList{k}));
                    if~strcmp(updatedProperty,tppkg.(propertyList{k}))
                        hwconnectinstaller.internal.inform(...
                        sprintf('urlcatalog for "%s" %s: "%s" -> "%s"',...
                        tppkg.Name,propertyList{k},...
                        tppkg.(propertyList{k}),updatedProperty));
                        tppkg.(propertyList{k})=updatedProperty;
                    end
                end
            end
        end




        function tppkg=uninstallThirdPartyPackage(~,tppkg)




            if(~tppkg.IsInstalled)||(tppkg.PreviouslyInstalled)
                return;
            end




            if isempty(tppkg.RemoveCmd)&&isempty(tppkg.DestDir)
                return;
            end


            olddir=cd(tppkg.InstallDir);
            c=onCleanup(@()cd(olddir));


            if~isempty(tppkg.RemoveCmd)
                removeCmd=tppkg.RemoveCmd;
            else
                if exist(tppkg.RootDir,'dir')
                    removeCmd='matlab:rmdir(''$(ROOTDIR)'', ''s'')';
                else

                    removeCmd='';
                end
            end

            if~isempty(removeCmd)
                try
                    hwconnectinstaller.internal.inform(...
                    sprintf('uninstallThirdPartyPackage "%s", removecmd="%s"',tppkg.Name,removeCmd));
                    tokenMap=hwconnectinstaller.util.getTokenMap(tppkg);
                    tppkg.RemoveCmd=hwconnectinstaller.util.evaluateCmd(removeCmd,...
                    tokenMap);
                catch ME
                    switch ME.identifier
                    case 'hwconnectinstaller:setup:CommandEvaluationError'
                        error(message('hwconnectinstaller:setup:TpUninstallError',...
                        tppkg.Name,ME.message));
                    case 'hwconnectinstaller:setup:WrongCmd'
                        error(message('hwconnectinstaller:setup:WrongRemoveCmd',...
                        tppkg.Name));
                    otherwise
                        rethrow(ME);
                    end
                end
            end
        end

    end

    methods(Static,Access=public)

        function verifyInstallFolderIsEmpty(installDir,folder)
            hdir=hwconnectinstaller.util.Location(fullfile(installDir,folder));
            if(~isempty(hdir.files)||~isempty(hdir.directories))
                error(message('hwconnectinstaller:setup:SpPkgInstallDirNotEmpty',...
                hdir.Path));
            end
        end

        function dirname=getDefaultDownloadDir()
            dirname=fullfile(matlabshared.supportpkg.internal.getSupportPackageRootNoCreate(),'downloads');
        end

        function tmp_dir=getTmpLoc()













            if ispc
                tmp_dir=getenv('TEMP');
            else
                tmp_dir='';
            end

            if(isempty(tmp_dir))
                tmp_dir=getenv('TMP');
            end

            if(isempty(tmp_dir))
                if ispc
                    tmp_dir=pwd;
                else
                    tmp_dir='/tmp/';
                end
            end

            if(tmp_dir(end)~=filesep)
                tmp_dir=[tmp_dir,filesep];
            end
        end

        function defaultInstallDir=getDefaultInstallDir_PcLegacy(driveLetter,spFolder_pc)

            if~isempty(driveLetter)
                defaultInstallDir=fullfile([driveLetter,':'],spFolder_pc);
            else
                defaultInstallDir=fullfile('C:',spFolder_pc);
            end
        end

        function dirname=getDefaultInstallDir()



            mlrelease=hwconnectinstaller.util.getCurrentRelease();
            relTag=hwconnectinstaller.SupportPackage.getReleaseTag(mlrelease,'matchcase');

            currentTypeQual=hwconnectinstaller.SupportTypeQualifierEnum.getType();
            if~hwconnectinstaller.internal.isSingleSupportPackageRoot()
                pkgTypeLabel=hwconnectinstaller.SupportTypeQualifierEnum.getUserFacingFolderLabel(currentTypeQual);
            else


                pkgTypeLabel=hwconnectinstaller.SupportTypeQualifierEnum.getUserFacingFolderLabel(char(hwconnectinstaller.SupportTypeQualifierEnum.Standard));
            end
            spFolder_pc=fullfile('MATLAB',pkgTypeLabel,relTag);
            spFolder_unix=fullfile(pkgTypeLabel,relTag);
            hdir=hwconnectinstaller.util.Location(hwconnectinstaller.PackageInstaller.getTmpLoc());
            if ispc

                programData=getenv('PROGRAMDATA');
                if~isempty(programData)
                    dirname=fullfile(programData,spFolder_pc);
                else
                    dirname=hwconnectinstaller.PackageInstaller.getDefaultInstallDir_PcLegacy(hdir.Drive,spFolder_pc);
                end
            else
                upath=userpath;
                upath=regexp(upath,pathsep,'split');
                upath(cellfun(@isempty,upath))=[];
                if numel(upath)~=1||~isdir(upath{1})


                    dirname=fullfile(system_dependent('getuserworkfolder','default'),spFolder_unix);
                else
                    dirname=fullfile(upath{1},spFolder_unix);
                end
            end
        end

        function pattern=getValidCharPattern(isUNCDownload,arch)
            switch(arch)
            case{'PCWIN','PCWIN64'}
                if isUNCDownload
                    pattern='\\\\[\w\$\-\\\.]+';


                else
                    pattern='([A-Z|a-z])\:\\[\w\-\\\.]*';


                end
            case{'GLNX86','GLNXA64'}
                pattern='\~?\/?[\w\-\/\.]*';



            otherwise
                pattern='\~?\/?[\w\-\/\.]*';
            end
        end

        function isValid=isValidFileName(fileName,isUNCDownload,arch)

            if~exist('arch','var')
                arch=computer;
            end

            pattern=hwconnectinstaller.PackageInstaller.getValidCharPattern(isUNCDownload,arch);
            ret=regexp(fileName,pattern,'match','once');
            isValid=isequal(ret,fileName);
        end

    end

    methods(Static,Hidden)


        function prepareForUninstall(spPkg)

            clear functions;
            [~,mexFiles]=inmem('-completenames');
            for i=1:numel(mexFiles)
                mexPath=fileparts(mexFiles{i});
                if ismember(mexPath,spPkg.Path)
                    error(message('hwconnectinstaller:setup:ModelOpen',...
                    spPkg.Name,spPkg.Name));
                end
            end
        end

        function clearMexAndClasses(opts)
            if~exist('opts','var')
                opts=struct('deferClearClasses',false);
            end


            munlock('all');
            clear mex;
            clear functions;
            warning('off','MATLAB:ClassInstanceExists');
            warning('off','MATLAB:objectStillExists');
            if(~opts.deferClearClasses)
                clear classes;
            end
            warning('on','MATLAB:ClassInstanceExists');
            warning('on','MATLAB:objectStillExists');
        end


        function spPkgPath=getFullPaths(spPkgInstallLoc)
            pathToPhlFiles=fullfile(spPkgInstallLoc,'toolbox','local','path');
            spPkgPath={};
            if~isdir(pathToPhlFiles)
                return;
            end




            phlFiles=dir(fullfile(pathToPhlFiles,'*.phl'));
            for i=1:numel(phlFiles)
                [fid,message]=fopen(fullfile(pathToPhlFiles,phlFiles(i).name),'r');
                if(fid<=0)



                    warning('Unable to open PHL files: %s',message);
                    continue;
                end
                lines=textscan(fid,'%s','commentStyle','%');
                spPkgPath=[spPkgPath;lines{1}];%#ok<AGROW>
                fclose(fid);
            end
            spPkgPath=cellfun(@(x)fullfile(spPkgInstallLoc,x),spPkgPath,'UniformOutput',false);
        end


        function checkDirectory(inputDir,options)











            if~exist('options','var')
                options=struct('allowUNC',0);
            end
            hdir=hwconnectinstaller.util.Location(inputDir);
            if hdir.isempty
                error(message('hwconnectinstaller:setup:InstallDirEmpty'));
            end


            if(hdir.containsSpaces)
                error(message('hwconnectinstaller:setup:SpacesInFolder'));
            end


            if(hdir.exists&&~hdir.isFolderWritable)
                error(message('hwconnectinstaller:setup:FolderNotWritable'));
            end

            isUNCDownload=0;



            if((numel(inputDir)>=2)&&strcmp(inputDir(1:2),'\\'))
                if options.allowUNC
                    isUNCDownload=1;
                else
                    error(message('hwconnectinstaller:setup:UncPathError'));
                end
            end

            if~hwconnectinstaller.PackageInstaller.isValidFileName(inputDir,isUNCDownload)
                error(message('hwconnectinstaller:setup:FolderContainsSpecialChar'));
            end
        end



        function downloadDir=createDownloadDirForInstall(installDir,foldername)
            orgDownloadDir=fullfile(installDir,'downloads');
            downloadDir=hwconnectinstaller.PackageInstaller.createDownloadDirectory(orgDownloadDir,foldername);
        end

        function spPkgDownloadDir=getDownloadDirectory(inputDir,foldername)
            spPkgDownloadDirName=message('hwconnectinstaller:setup:DownloadArchive',foldername).getString();
            spPkgDownloadDir=fullfile(inputDir,spPkgDownloadDirName);
        end

        function spPkgDownloadDir=createDownloadDirectory(inputDir,foldername)
            hwconnectinstaller.PackageInstaller.checkDirectory(inputDir,struct('allowUNC',1));

            spPkgDownloadDir=hwconnectinstaller.PackageInstaller.getDownloadDirectory(inputDir,foldername);
            hwconnectinstaller.PackageInstaller.createDirectory(spPkgDownloadDir);
        end


        function createDirectory(inputDir)

            hdir=hwconnectinstaller.util.Location(inputDir);
            if~hdir.exists
                try
                    mkdir(inputDir);
                    if~hdir.exists
                        error(lastwarn);
                    end
                catch ME
                    error(message('hwconnectinstaller:setup:CannotCreateDir',...
                    inputDir,ME.message));
                end
            end
        end


        function str=doubleQuotes(str)


            str=['"',str,'"'];
        end

        function pathstr=decoratePath(pathstr,doubleQuotes)


            if(nargin<2)
                doubleQuotes=false;
            end
            pathstr=strrep(pathstr,'\','\\');

            if(doubleQuotes)
                pathstr=hwconnectinstaller.PackageInstaller.doubleQuotes(pathstr);
            end
        end

        function refreshMatlab()
            rehash pathreset;














            skipSLRefresh=getenv('SUPPORTPACKAGE_INSTALLER_SKIP_SIMULINK_REFRESH');

            if isempty(skipSLRefresh)...
                &&hwconnectinstaller.internal.isProductInstalled('Simulink')
                sl_refresh_customizations;


                lb=slLibraryBrowser('noshow');
                lb.refresh;
            end
        end

        function spPkg=getSpPkgObject(name,pkglist)

            spPkg=[];
            for i=1:numel(pkglist)
                if strcmp(name,pkglist(i).Name)
                    spPkg=pkglist(i);
                    break;
                end
            end
        end

        function tpPkg=getTpPackages(pkgList,spPkg,installerWorkflow)



            if isempty(spPkg.Children)
                tpPkg=spPkg.TpPkg;
                return;
            else
                tpPkg=spPkg.TpPkg;
                for i=1:length(spPkg.Children)
                    tmpSp=hwconnectinstaller.PackageInstaller.getSpPkgObject(...
                    spPkg.Children(i).Name,pkgList);
                    if isempty(tmpSp)
                        if installerWorkflow.isFolder
                            error(message('hwconnectinstaller:setup:Install_PkgMissing'));
                        else
                            error(message('hwconnectinstaller:setup:Manifest_PkgMissing'));
                        end
                    end
                    newTpPkg=hwconnectinstaller.PackageInstaller.getTpPackages(pkgList,tmpSp);
                    tpPkg=[tpPkg,newTpPkg];%#ok<AGROW>
                end
            end
        end


        function file=fullLnxFile(varargin)
            file=strrep(varargin{1},'\','/');
            for i=2:nargin
                file=[file,'/',varargin{i}];%#ok<AGROW>
            end
            file=regexprep(file,'/$','');
        end


        function hSetup=getProgressBar(pct,displayText)
            title=message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:setup_Title')).getString();
            hSetup=hwconnectinstaller.Setup.get();
            hSetup.showProgressBar(title,displayText,pct);
        end


        function advanceProgressBar(hSetup,pct,displayText)





            hSetup.setProgressBarValue(displayText,pct);
        end

        function alltpPkgObj=getPlatformIndependentTpPkgInfo(sppkg)
            validateattributes(sppkg,{'hwconnectinstaller.SupportPackage'},{'nonempty'});
            archiveHandler=hwconnectinstaller.ArchiveHandler.getInstance();
            alltpPkgObj=archiveHandler.loadTpPkgInfo(fullfile(sppkg.RootDir,'registry',archiveHandler.TPPKGXMLFILE),[],...
            struct('currentPlatformOnly',false));
        end

    end
end



function[parentSpPkgFullName,sppkgsDisplayStr]=i_getProgressBarDisplayStrings(spPkgs,spPkgName)











    validateattributes(spPkgs,{'hwconnectinstaller.SupportPackage'},{'nonempty'});
    validateattributes(spPkgName,{'char'},{'nonempty'});

    allSppkgNames={spPkgs.Name};
    indx=strcmp(allSppkgNames,spPkgName);
    assert(spPkgs(indx).Visible==true);
    assert(length(find(indx))==1);
    parentSpPkgFullName=spPkgs(indx).FullName;





    sppkgsDisplayStr={spPkgs.FullName};
    spindx=~[spPkgs.Visible];
    sppkgsDisplayStr(spindx)={parentSpPkgFullName};
    assert(isequal(numel(spPkgs),numel(sppkgsDisplayStr)));
end

function spPkg=i_addParent(parent,spPkg)


    if isempty(parent)

        return;
    end
    for i=1:length(spPkg.Parent)
        if isequal(spPkg.Parent(i).Name,parent.Name)
            return;
        end
    end
    if isempty(spPkg.Parent)
        spPkg.Parent=parent;
    else
        spPkg.Parent(end+1)=parent;
    end
end

function spPkg=i_removeParent(parent,spPkg)


    if isempty(parent)

        return;
    end
    indx=[];
    for i=1:length(spPkg.Parent)
        if isequal(spPkg.Parent(i).Name,parent.Name)
            indx(end+1)=i;%#ok<AGROW>
        end
    end
    spPkg.Parent(indx)=[];
end

function spPkg=i_removeStaleParents(spPkg)




    tmpParentList=spPkg.Parent;
    for p=1:numel(tmpParentList)
        parent=tmpParentList(p);
        if isempty(hwconnectinstaller.PackageInstaller.getSpPkgInfo(parent.Name))



            spPkg=i_removeParent(parent,spPkg);
        end
    end
end

