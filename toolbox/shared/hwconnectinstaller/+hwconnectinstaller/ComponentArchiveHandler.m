classdef ComponentArchiveHandler<hwconnectinstaller.ArchiveHandler







    properties(Constant,Hidden)
        SPPKGXMLEXTRAFILE='support_package_registry_extra.sppkg';
    end

    methods(Access=public)

        function spPkg=getPkgListFromFolder(obj,folder)
            spPkg=hwconnectinstaller.SupportPackage;
            spPkg(1)=[];



            hdir=hwconnectinstaller.util.Location(folder);
            zipFiles=hdir.files('*.zip');

            for i=1:numel(zipFiles)

                if(obj.validateArchiveName(zipFiles{i}.FullPathName))


                    loadedSpPkgObj=obj.getSpPkgInfoFromArchive(zipFiles{i}.FullPathName);
                    tagsValid=obj.checkSpPkgTags(loadedSpPkgObj,zipFiles{i}.FullPathName);
                    if tagsValid
                        spPkg(end+1)=loadedSpPkgObj;%#ok<AGROW>
                    end
                end
            end


            spPkg=obj.getLatestSppkgs(spPkg);
        end

        function loadedSpPkgObj=getSpPkgInfoFromArchive(obj,fullPathToZipFile,unzipLocation)














            if(nargin<3)
                unzipLocation='';
            end
            if isempty(unzipLocation)


                unzipLocation=tempname;
                [statusFlag,msg,msgid]=mkdir(unzipLocation);
                cMkDir=onCleanup(@()rmdir(unzipLocation,'s'));
                if(statusFlag~=1)
                    warning(msgid,msg);
                end
            end


            unzip(fullPathToZipFile,unzipLocation);

            loadedSpPkgObj=obj.loadSpPkgInfo(fullfile(unzipLocation,obj.SPPKGXMLFILE));



            loadedSpPkgObj=obj.loadThirdPartyInfoForSpPkg(loadedSpPkgObj,unzipLocation);

        end
        function diagnoseInstallFromFolder(~,folder)


            folderInfo=hwconnectinstaller.internal.diagnoseInstallFromFolder(folder);

            if strcmpi(folderInfo.status,'PkgsFoundForDifferentRelease')
                error(message('hwconnectinstaller:setup:Install_NoPkgFoundForThisRelease',...
                folder));
            else
                error(message('hwconnectinstaller:setup:Install_NoPkgFound',...
                folder));
            end
        end

        function isNameValid=validateArchiveName(obj,fullPathToZipFile)





            isNameValid=false;
            pattern=obj.getSpPkgArchiveNameRegexpPattern();
            patternMatches=regexp(fullPathToZipFile,pattern,'names');
            if~isempty(patternMatches)
                isNameValid=true;
            end
        end

        function tagsValid=checkSpPkgTags(obj,loadedSpPkgObj,fullPathToZipFile)




            tagsValid=false;
            pattern=obj.getSpPkgArchiveNameRegexpPattern();
            patternMatches=regexp(fullPathToZipFile,pattern,'names');
            pkgTag=hwconnectinstaller.SupportPackage.getPkgTag(loadedSpPkgObj.Name);
            verTag=hwconnectinstaller.SupportPackage.getVerTag(loadedSpPkgObj.Version);
            if isequal(pkgTag,patternMatches.pkgTag)...
                &&isequal(verTag,patternMatches.verTag)
                tagsValid=true;
            end
        end

        function toolboxPath=getToolboxPath(~,options)


            if isequal(options.populateRootDir,false)
                toolboxPath='';
            else
                if~exist(options.dataFiles,'file')
                    error(DAStudio.message('hwconnectinstaller:setup:MissingRequiredFilesForInstall'))
                else
                    fid=fopen(options.dataFiles,'rt');
                    contents=fread(fid);
                    fclose(fid);
                    lines=textscan(char(contents'),'%[^\n]\n',3);
                    delimiters=char([10,13]);
                    toolboxPath=strtok(lines{1}{3},delimiters);
                    assert(~isempty(toolboxPath),'srcdir line missing in support_package_registry_extra.sppkg file');
                end
            end
        end

        function spPkg=loadSpPkgInfo(obj,loadTarget,options)







            validateattributes(loadTarget,{'char'},{'nonempty'},'loadSpPkgInfo','loadTarget');

            if~exist('options','var')
                options=struct();
            end

            if~isfield(options,'populateRootDir')




                options.populateRootDir=true;
            end

            assert(logical(exist(loadTarget,'file')),sprintf('loadSpPkgInfo: no support package registry XML file present in specified folder: %s',loadTarget));
            options.dataFiles=fullfile(fileparts(loadTarget),obj.SPPKGXMLEXTRAFILE);
            spPkg=hwconnectinstaller.internal.PackageInfo.readSpPkgRegistry(loadTarget,options);
        end



        function tpPkg=loadTpPkgInfo(~,loadTarget,thirdPartyXML,options)









            if~exist('options','var')
                options=struct();
            end

            if~isfield(options,'currentPlatformOnly')
                options.currentPlatformOnly=true;
            end

            if~exist('thirdPartyXML','var')||isempty(thirdPartyXML)
                thirdPartyXML=loadTarget;
            end
            tpPkg=hwconnectinstaller.internal.PackageInfo.readTpPkgRegistry(thirdPartyXML,options);
        end

    end

    methods(Access=protected)
        function loadedSpPkgObj=loadThirdPartyInfoForSpPkg(obj,loadedSpPkgObj,pathToArchive)







            tppkgXmlDir=hwconnectinstaller.internal.SPITestSettings.thirdpartyPackageRegistry();
            tpXml=fullfile(pathToArchive,obj.TPPKGXMLFILE);
            if isempty(tppkgXmlDir)
                loadedSpPkgObj.TpPkg=obj.loadTpPkgInfo(tpXml);
            else
                loadedSpPkgObj.TpPkg=obj.loadTpPkgInfo(tpXml,...
                tppkgXmlDir);
            end
        end


    end

end
