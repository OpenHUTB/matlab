classdef SingleRootHandler<matlabshared.supportpkg.internal.SupportPackageRootHandler









    properties(Access=private,Constant)
        MAX_DEFAULTS=100;
    end

    methods(Access=public)
        function obj=SingleRootHandler(writerReader)
            obj=obj@matlabshared.supportpkg.internal.SupportPackageRootHandler(writerReader);
        end
    end

    methods(Access=public)

        function[spRoot,isDefaultRoot]=getInstallRootNoCreate(obj,opts)






            validateattributes(opts,{'struct'},{'nonempty'});
            settingFile=obj.SettingWriterReader.SettingFileFullPath;

            [spRoot,isDefaultRoot]=matlabshared.supportpkg.internal.biGetSupportPackageRootNoCreate(settingFile);




            if opts.ErrorIfDefaultsMaxed&&isDefaultRoot&&isempty(spRoot)
                error(message('supportpkgservices:supportpackageroot:DefaultsMaxed'))
            end



            if isempty(getenv('SUPPORTPACKAGEROOT_OVERRIDE'))


                matlabshared.supportpkg.internal.SingleRootHandler.isUsableSproot(spRoot,true);
            end

        end

        function spRoot=getInstallRoot(obj)
















            opts=struct('ErrorIfDefaultsMaxed',true);
            [spRoot,isDefaultRoot]=obj.getInstallRootNoCreate(opts);




            if~exist(spRoot,'dir')&&isDefaultRoot
                try

                    mkdir(spRoot);

                    if ispc
                        obj.setDirectoryWorldWritable(spRoot);
                    end

                    currentMatlabID=matlabshared.supportpkg.internal.SingleRootHandler.getCurrentMatlabIdentifier();
                    matlabshared.supportpkg.internal.SingleRootHandler.writeMatlabInfoTextFileToDir(currentMatlabID,spRoot);
                catch ex
                    error(message('supportpkgservices:supportpackageroot:CannotCreate',spRoot,ex.message));
                end
            end





            if~exist(spRoot,'dir')&&~isDefaultRoot
                error(message('supportpkgservices:supportpackageroot:NonExistentRoot'));
            end




            spRoot=matlabshared.supportpkg.internal.SingleRootHandler.getCanonicalPath(spRoot);




            matlabshared.supportpkg.internal.SingleRootHandler.isUsableSproot(spRoot,true);



            if~matlabshared.supportpkg.internal.SingleRootHandler.containsMatlabInfoTextFile(spRoot)
                currentMatlabID=matlabshared.supportpkg.internal.SingleRootHandler.getCurrentMatlabIdentifier();
                matlabshared.supportpkg.internal.SingleRootHandler.writeMatlabInfoTextFileToDir(currentMatlabID,spRoot);
            end

        end

        function restoreDefaultState(obj)

















            try
                currentRoot=obj.getInstallRootNoCreate(struct('ErrorIfDefaultsMaxed',true));
            catch ME

                currentRoot='';
                warning(ME.identifier,'%s',ME.getReport);
            end


            matlabshared.supportpkg.internal.SingleRootHandler.removeSupportPackagesFromPath(currentRoot);


            try
                obj.SettingWriterReader.createDefaultSettingFile();
            catch ME
                warning(ME.identifier,'%s',ME.getReport);
            end

            matlabshared.supportpkg.internal.SingleRootHandler.refreshDocCenter();

            obj.refreshMatlab();
        end

        function setInstallRoot(obj,spRoot)

























            validateattributes(spRoot,{'char','string'},{'nonempty','scalartext'},'SingleRootHandler.setRoot','spRoot');



            if isstring(spRoot)
                spRoot=convertStringsToChars(spRoot);
            end


            if~matlabshared.supportpkg.internal.biIsAbsolute(spRoot)
                error(message('supportpkgservices:supportpackageroot:RelativePath',spRoot));
            end



            matlabshared.supportpkg.internal.SingleRootHandler.checkDirectory(spRoot);



            if~isdir(spRoot)
                try





                    oldState=warning('off','MATLAB:MKDIR:DirectoryExists');
                    restoreDirExistsWarn=onCleanup(@()warning(oldState));
                    mkdir(spRoot);
                    delete(restoreDirExistsWarn);


                    if ispc
                        obj.setDirectoryWorldWritable(spRoot);
                    end
                catch ex
                    error(message('supportpkgservices:supportpackageroot:CannotCreate',spRoot,ex.message));
                end
            end




            spRoot=matlabshared.supportpkg.internal.SingleRootHandler.getCanonicalPath(spRoot);




            matlabshared.supportpkg.internal.SingleRootHandler.isUsableSproot(spRoot,true);



            currentMatlabID=matlabshared.supportpkg.internal.SingleRootHandler.getCurrentMatlabIdentifier();
            matlabshared.supportpkg.internal.SingleRootHandler.writeMatlabInfoTextFileToDir(currentMatlabID,spRoot);








            foundDefaultToken=false;
            try
                opts=struct('ErrorIfDefaultsMaxed',true);
                [currentRoot,foundDefaultToken]=obj.getInstallRootNoCreate(opts);
            catch




                currentRoot='';
            end




            if~strcmp(currentRoot,spRoot)||foundDefaultToken



                try
                    obj.SettingWriterReader.writeRootSetting(spRoot);
                catch ex
                    matlabshared.supportpkg.internal.SingleRootHandler.deleteMatlabInfoTextFileFromDir(spRoot);
                    rethrow(ex);
                end
            end















            obj.loadUnloadSupportPackages(currentRoot,spRoot);
        end


        function loadUnloadSupportPackages(obj,currentRoot,newRoot)














            validateattributes(currentRoot,{'char','string'},{'scalartext'},'matlabshared.supportpkg.internal.SingleRootHandler.loadUnloadSupportPackages','currentRoot');
            validateattributes(newRoot,{'char','string'},{'scalartext'},'matlabshared.supportpkg.internal.SingleRootHandler.loadUnloadSupportPackages','newRoot');




            pathsRemoved=matlabshared.supportpkg.internal.SingleRootHandler.removeSupportPackagesFromPath(currentRoot);




            pathsAdded=matlabshared.supportpkg.internal.SingleRootHandler.addSupportPackagesToPath(newRoot);






            matlabshared.supportpkg.internal.SingleRootHandler.refreshDocCenter();



            matlabshared.supportpkg.internal.SingleRootHandler.removeMessageCatalogsIfAvailable(currentRoot);


            matlabshared.supportpkg.internal.SingleRootHandler.addMessageCatalogsIfAvailable(newRoot);


            if pathsRemoved||pathsAdded

                obj.refreshMatlab();
                savepath();
            end
        end

    end


    methods(Access=private,Static)
        function pathChanged=removeSupportPackagesFromPath(spRoot)





            pathChanged=false;

            if matlabshared.supportpkg.internal.SingleRootHandler.containsPHLfiles(spRoot)



                phlEntries=matlabshared.supportpkg.internal.SingleRootHandler.getFullPaths(spRoot);
                phlEntries=matlabshared.supportpkg.internal.SingleRootHandler.ensurePlatformAppropriatePath(phlEntries);
                matlabshared.supportpkg.internal.SingleRootHandler.removeDirsFromPath(phlEntries);
                pathChanged=true;
            end
        end

        function pathChanged=addSupportPackagesToPath(spRoot)






            pathChanged=false;
            if matlabshared.supportpkg.internal.SingleRootHandler.containsPHLfiles(spRoot)
                phlEntries=matlabshared.supportpkg.internal.SingleRootHandler.getFullPaths(spRoot);
                phlEntries=matlabshared.supportpkg.internal.SingleRootHandler.ensurePlatformAppropriatePath(phlEntries);

                matlabshared.supportpkg.internal.SingleRootHandler.addDirsToPath(phlEntries);
                pathChanged=true;
            end
        end
    end

    methods(Access=public,Static)

        function refreshDocCenter()


            try
                matlab.internal.doc.invalidateSupportPackageCache();
            catch
            end
        end

        function addDirsToPath(phlEntriesCell)




            validDirs={};
            for i=1:numel(phlEntriesCell)
                if isdir(phlEntriesCell{i})
                    validDirs{end+1}=phlEntriesCell{i};%#ok<AGROW>
                end
            end


            if isempty(validDirs)
                return;
            end

            addpath(validDirs{:});
        end

        function removeDirsFromPath(phlEntriesCell)






            if isempty(phlEntriesCell)
                return;
            end
            warnState=warning('off','MATLAB:rmpath:DirNotFound');
            cleanup=onCleanup(@()warning(warnState));
            rmpath(phlEntriesCell{:});
        end

        function out=ensurePlatformAppropriatePath(pathCell)



            out=cellfun(@fullfile,pathCell,'UniformOutput',false);
        end


        function checkDirectory(inputDir)











            validateattributes(inputDir,{'char','string'},{'nonempty','scalartext'});
            if isstring(inputDir)
                inputDir=convertStringsToChars(inputDir);
            end

            if(matlabshared.supportpkg.internal.SingleRootHandler.containsSpaces(inputDir))
                error(message('supportpkgservices:supportpackageroot:SpacesInFolder'));
            end


            if(exist(inputDir,'dir')&&~matlabshared.supportpkg.internal.SingleRootHandler.isFolderWritable(inputDir))
                error(message('supportpkgservices:supportpackageroot:FolderNotWritable'));
            end


            if matlabshared.supportpkg.internal.SingleRootHandler.isUNCPath(inputDir)
                error(message('supportpkgservices:supportpackageroot:UncPathError'));
            end


            if~matlabshared.supportpkg.internal.SingleRootHandler.isValidFilePath(inputDir)
                error(message('setup:FolderContainsSpecialChar'));
            end


            if~matlabshared.supportpkg.internal.biIsAbsolute(inputDir)
                error(message('supportpkgservices:supportpackageroot:RelativePath',inputDir));
            end
        end

        function pattern=getValidCharPattern(arch)


            validateattributes(arch,{'char','string'},{'nonempty','scalartext'});

            switch(arch)
            case{'PCWIN','PCWIN64'}
                pattern='([A-Z|a-z])\:\\[\w\-\\\.]*';


            case{'GLNX86','GLNXA64'}
                pattern='\~?\/?[\w\-\/\.]*';



            otherwise
                pattern='\~?\/?[\w\-\/\.]*';
            end
        end

        function isValid=isValidFilePath(inputDir)



            validateattributes(inputDir,{'char','string'},{'nonempty','scalartext'});
            arch=computer;
            pattern=matlabshared.supportpkg.internal.SingleRootHandler.getValidCharPattern(arch);
            ret=regexp(inputDir,pattern,'match','once');
            isValid=isequal(ret,inputDir);
        end

        function isUNC=isUNCPath(inputDir)


            isUNC=((numel(inputDir)>=2)&&strcmp(inputDir(1:2),'\\'));
        end

        function writableFlag=isFolderWritable(inputDir)


            validateattributes(inputDir,{'char','string'},{'nonempty','scalartext'});
            writableFlag=false;
            if isstring(inputDir)
                [succes,dirAttribs]=fileattrib(convertStringsToChars(inputDir));
            else
                [succes,dirAttribs]=fileattrib(inputDir);
            end
            if((succes==true)&&(dirAttribs.UserWrite==1))
                writableFlag=true;
            end
        end

        function hasSpaces=containsSpaces(inputDir)


            validateattributes(inputDir,{'char','string'},{'nonempty','scalartext'});
            hasSpaces=false;
            if(any(inputDir==' '))
                hasSpaces=true;
            end
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

        function refreshMatlab()
            rehash pathreset;














            skipSLRefresh=getenv('SUPPORTPACKAGE_INSTALLER_SKIP_SIMULINK_REFRESH');

            if isempty(skipSLRefresh)...
                &&matlabshared.supportpkg.internal.ssi.util.isProductInstalled('Simulink')
                sl_refresh_customizations;


                lb=slLibraryBrowser('noshow');
                lb.refresh;
            end
        end

        function canonicalPath=getCanonicalPath(currPath)


            validateattributes(currPath,{'char','string'},{'nonempty','scalartext'});
            if isstring(currPath)
                canonicalPath=matlabshared.supportpkg.internal.biGetCanonicalPath(convertStringsToChars(currPath));
            else
                canonicalPath=matlabshared.supportpkg.internal.biGetCanonicalPath(currPath);
            end
        end

        function hasPHLFiles=containsPHLfiles(rootLocation)
            phlFilesDir=fullfile(rootLocation,'toolbox','local','path');
            hasPHLFiles=~isempty(dir(fullfile(phlFilesDir,'*.phl')));
        end


        function addMessageCatalogsIfAvailable(spRoot)






            if~isempty(spRoot)&&isdir(fullfile(spRoot,'resources'))
                try
                    matlab.internal.msgcat.setAdditionalResourceLocation(spRoot);
                catch
                end
            end
        end

        function removeMessageCatalogsIfAvailable(spRoot)






            if~isempty(spRoot)&&isdir(fullfile(spRoot,'resources'))
                try
                    matlab.internal.msgcat.removeAdditionalResourceLocation(spRoot);
                catch
                end
            end
        end

        function isUsable=checkSpRootForMatlabInfoTextFile(requestedMatlabID,spRoot,doThrowErr)















            isUsable=true;



            if matlabshared.supportpkg.internal.SingleRootHandler.containsMatlabInfoTextFile(spRoot)
                existingMatlabID=matlabshared.supportpkg.internal.SingleRootHandler.readMatlabInfoTextFileFromDir(spRoot);
                if~isempty(existingMatlabID)&&~strcmp(existingMatlabID,requestedMatlabID)
                    if doThrowErr
                        error(message('supportpkgservices:supportpackageroot:DirInUse',spRoot,existingMatlabID));
                    else
                        isUsable=false;
                    end
                end
            end
        end

        function isUsable=isUsableSproot(spRoot,doThrowError)







            if isstring(spRoot)
                spRoot=convertStringsToChars(spRoot);
            end
            [isUsable,usedBy]=matlabshared.supportpkg.internal.biIsUsableSproot(spRoot);
            if doThrowError&&~isUsable
                error(message('supportpkgservices:supportpackageroot:DirInUse',spRoot,usedBy));
            end
        end


        function id=getCurrentMatlabIdentifier()
            id=matlabshared.supportpkg.internal.biGetCurrentMatlabIdentifier();
        end

        function id=readMatlabInfoTextFileFromDir(spRoot)
            if isstring(spRoot)
                spRoot=convertStringsToChars(spRoot)
            end
            [~,id]=matlabshared.supportpkg.internal.biIsUsableSproot(spRoot);
        end

        function writeMatlabInfoTextFileToDir(requestedMatlabID,spRoot)












            matlabshared.supportpkg.internal.SingleRootHandler.checkSpRootForMatlabInfoTextFile(requestedMatlabID,spRoot,true);



            if matlabshared.supportpkg.internal.SingleRootHandler.containsMatlabInfoTextFile(spRoot)
                return;
            end


            if isstring(spRoot)
                spRoot=convertStringsToChars(spRoot);
            end
            infoTextFilePath=fullfile(spRoot,matlabshared.supportpkg.internal.SingleRootHandler.getInfoTextFileName());
            [fid,msg]=fopen(infoTextFilePath,'w');
            if isequal(fid,-1)
                error(message('supportpkgservices:supportpackageroot:FailedInfoFile',spRoot,msg));
            end
            fprintf(fid,'%s',requestedMatlabID);
            fclose(fid);
        end

        function deleteMatlabInfoTextFileFromDir(spRoot)
            if isstring(spRoot)
                spRoot=convertStringsToChars(spRoot);
            end
            infoTextFilePath=fullfile(spRoot,matlabshared.supportpkg.internal.SingleRootHandler.getInfoTextFileName);
            delete(infoTextFilePath);
        end

        function hasInfoTextFile=containsMatlabInfoTextFile(spRoot)


            if isstring(spRoot)
                spRoot=convertStringsToChars(spRoot);
            end
            hasInfoTextFile=matlabshared.supportpkg.internal.biContainsMatlabInfoTextFile(spRoot);
        end

        function setDirectoryWorldWritable(spRoot)



            validateattributes(spRoot,{'char','string'},{'nonempty','scalartext'});
            assert(logical(exist(spRoot,'dir')),sprintf('Cannot set permissions on non-existent directory %s\n',spRoot));

            if isstring(spRoot)
                spRoot=convertStringsToChars(spRoot);
            end

            try
                if isunix
                    fileattrib(spRoot,'+w','a');
                else
                    cmd=sprintf('icacls "%s" /grant Everyone:(OI)(CI)F /T /Q',spRoot);
                    [~,~]=system(cmd);
                end
            catch
            end

        end

        function fileName=getInfoTextFileName()
            fileName='sppkg_matlab_info.txt';
        end
    end
end
