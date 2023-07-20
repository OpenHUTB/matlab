classdef CRCSArtifactsMgr<handle




    properties(Access=private)
    end
    methods(Access=private)
        function newObj=CRCSArtifactsMgr()
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                obj=cosimcompileutils.CRCSArtifactsMgr();
                uniqueInstance=obj;
            else
                obj=uniqueInstance;
            end
        end
    end

    methods(Access=public)
        function hdl=getCachedHarnessModel(~,wrapperModel)
            try
                hdl=load_system(wrapperModel);
            catch
                hdl=inf;
            end
        end

        function folderPath=getReusablePath(~,modelPath,currFolder,blockPathHash)
            fileInfo=dir(modelPath);
            fileName=regexp(fileInfo.name,'\<.*?\>','match');
            if isempty(fileName)
                fileName='';
            else
                fileName=fileName{1};
            end

            folderName=[blockPathHash,'_',fileName];

            folderPath=fullfile(currFolder,'slprj','cosim',folderName);
            fileMD5=slprivate('file2md5hash',modelPath);
            validationFile=fullfile(folderPath,'cache_validation.mat');
            if exist(folderPath,'dir')==7
                needsRebuild=true;
                if exist(validationFile,'file')==2
                    fileLoad=load(validationFile,'fileMD5');
                    if fileLoad.fileMD5==fileMD5
                        needsRebuild=false;
                    end
                end
                if needsRebuild
                    delete([folderPath,filesep,'*']);
                    save(validationFile,'fileInfo','fileMD5');
                end
            else
                mkdir(folderPath);
                save(validationFile,'fileInfo','fileMD5');
            end

        end
    end
end
