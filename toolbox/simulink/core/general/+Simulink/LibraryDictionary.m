classdef LibraryDictionary<handle






    methods(Static,Access=public,Hidden)
        function obj=getInstanceOfDependencyInfo()
            mlock;





            persistent librarySLDDInfo;



            if isempty(librarySLDDInfo)||~isvalid(librarySLDDInfo)
                userInfoFileName=[prefdir,filesep,'SLLibraryLinkageData',filesep,'LibraryLinkageCache.mat'];
                librarySLDDInfo=Simulink.LibraryDictionary.helperLoadOnDiscLinkageInfoFile(userInfoFileName);
                librarySLDDInfo.mergeGraphs(Simulink.LibraryDictionary.helperLoadOnDiscCacheFiles(Simulink.LibraryDictionary.getToolboxInternalPath));

                librarySLDDInfo.initializeSlidCache();
                librarySLDDInfo.setAutoSerializeInDestructor(false);
                librarySLDDInfo.updateLibDDHashMapForAllNodes;
            end
            obj=librarySLDDInfo;
        end


        function sldds=getLibSLDDS(aLibName)
            libraryLinkedSLDDInfo=Simulink.LibraryDictionary.getInstanceOfDependencyInfo;
            sldds=libraryLinkedSLDDInfo.getLibraryConnectedSLDDs(aLibName);
        end



        function processNewLibDDHost(libPath,~)

            libraryLinkedSLDDInfo=Simulink.LibraryDictionary.getInstanceOfDependencyInfo;
            [dir1,~,~]=fileparts(libPath);
            libraryLinkedSLDDInfo.refreshLibraryLinks(dir1);

            dir2=cd;
            if~strcmp(dir1,dir2)
                libraryLinkedSLDDInfo.refreshLibraryLinks(dir2);
            end
        end


        function processLibSave(libPath)
            libraryLinkedSLDDInfo=Simulink.LibraryDictionary.getInstanceOfDependencyInfo;
            libraryLinkedSLDDInfo.refreshLibraryLinks(libPath);
        end


        function disp()
            libraryLinkedSLDDInfo=Simulink.LibraryDictionary.getInstanceOfDependencyInfo;
            libraryLinkedSLDDInfo.disp;
        end

        function clear()
            libraryLinkedSLDDInfo=Simulink.LibraryDictionary.getInstanceOfDependencyInfo;
            libraryLinkedSLDDInfo.clear();
        end


        function toolboxInternal=getToolboxInternalPath()
            toolboxInternal=fullfile(matlabroot,'/toolbox/simulink/core/general/+Simulink/+data/+internal/ToolboxLibSLDDInfo/');
        end
    end

    methods(Access=public,Static)



        function refresh(varargin)
            libraryLinkedSLDD=Simulink.LibraryDictionary.getInstanceOfDependencyInfo;
            if nargin>0
                libraryLinkedSLDD.refreshLibraryLinks(varargin{1})
            else
                libraryLinkedSLDD.refreshLibraryLinks(cd);
            end
        end


        function resetLibraryLinks()




            cacheFileFullPath=[prefdir,filesep,'SLLibraryLinkageData',filesep,'LibraryLinkageCache.mat'];
            if isfile(cacheFileFullPath)
                delete(cacheFileFullPath);
            end


            singletonLinkageObj=Simulink.LibraryDictionary.getInstanceOfDependencyInfo();
            if isvalid(singletonLinkageObj)
                singletonLinkageObj.setAutoSerializeInDestructor(false);
                delete(singletonLinkageObj);
            end
        end
    end

    methods(Static,Access=public,Hidden)

        function createToolboxLibrarySLDDInfoMATFile(fullLibraryPath,cacheFilePath,saveFileName)
            libraryDependencyInfo=Simulink.data.internal.LibDictionaryDependencyInfo;
            libraryDependencyInfo.buildDependencyTree(fullLibraryPath);
            saveFileFullname=[cacheFilePath,filesep,saveFileName,'.mat'];
            save(saveFileFullname,'libraryDependencyInfo');
            disp(getString(message('Simulink:util:ToolboxLibrarySLDDRegistration',saveFileFullname)));
        end



        function libDependencyInfo=helperLoadOnDiscCacheFiles(toolboxLibSLDDInfoDir)
            libDependencyInfo=Simulink.data.internal.LibDictionaryDependencyInfo;
            if~isfolder(toolboxLibSLDDInfoDir)
                return;
            end
            cacheFiles=dir([toolboxLibSLDDInfoDir,filesep,'*.mat']);
            if~isempty(cacheFiles)
                for aFile=cacheFiles'
                    fullFileName=[toolboxLibSLDDInfoDir,filesep,aFile.name];
                    aLibSLDDInfo=load(fullFileName);
                    aLibSLDDInfo=aLibSLDDInfo.libraryDependencyInfo;
                    libDependencyInfo.mergeGraphs(aLibSLDDInfo);
                end
            end
        end


        function libDependencyInfo=helperLoadOnDiscLinkageInfoFile(pathToFile)
            if isfile(pathToFile)



                try

                    libDependencyInfo=load(savedFileName);
                    return;
                catch


                end
            end



            libDependencyInfo=Simulink.data.internal.LibDictionaryDependencyInfo;

        end



        function libDependencyInfo=helperCreateLibraryDependencyInfo(dirName)
            libDependencyInfo=Simulink.data.internal.LibDictionaryDependencyInfo;
            libDependencyInfo.buildDependencyTree(dirName);
        end



        function refreshToolBoxCache()
            libraryLinkedSLDD=Simulink.LibraryDictionary.getInstanceOfDependencyInfo;
            libraryLinkedSLDD.clear();

            toolboxLibSLDDInfo=Simulink.LibraryDictionary.helperLoadOnDiscCacheFiles(Simulink.LibraryDictionary.getToolboxInternalPath);
            libraryLinkedSLDD.mergeGraphs(toolboxLibSLDDInfo);
            libraryLinkedSLDD.updateLibDDHashMapForAllNodes;
        end























        function serializeToolboxLibrarySLDDInfo(relativeDirPath)
            assert(~isempty(relativeDirPath));


            libDirFullPath=[matlabroot,filesep,relativeDirPath];
            if~isfolder(libDirFullPath)
                error(message('SLDD:sldd:InvalidToolboxLibraryPath',relativeDirPath));
            end



            dirSet=Simulink.data.internal.LibDictionaryDependencyInfo.readEligibleToolBoxDirectorySet();
            if~dirSet.isKey(libDirFullPath)
                dirListFile=[Simulink.LibraryDictionary.getToolboxInternalPath,filesep,'libddtoolboxdirs.txt'];
                error(message('Simulink:util:LibraryPathNotRegistered',relativeDirPath,dirListFile));
            end


            toolboxLibInfoCacheDir=Simulink.LibraryDictionary.getToolboxInternalPath;


            saveFileName=regexprep(relativeDirPath,filesep,'_');

            Simulink.LibraryDictionary.createToolboxLibrarySLDDInfoMATFile(libDirFullPath,toolboxLibInfoCacheDir,saveFileName);
        end
    end
end


