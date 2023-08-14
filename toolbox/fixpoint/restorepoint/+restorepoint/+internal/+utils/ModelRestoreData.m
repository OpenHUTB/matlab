classdef ModelRestoreData<handle




    properties(GetAccess=public,SetAccess=?fxpRestorepoint.ModelRestoreDataTester)

        OriginalModel char
        SessionID=restorepoint.internal.utils.SessionInformationManager.getSessionIdentifier
        RestorePaths=restorepoint.internal.utils.SessionInformationManager.getRestorePointPaths
        Data containers.Map
        ModelDir char
        FileName char
        NodeName char
    end

    properties(GetAccess=public,SetAccess=?restorepoint.internal.create.CalculatePathStrategy)

        RestoreDirectory cell
        ExistingRestoreDir char
    end

    properties(GetAccess=public,SetAccess=?restorepoint.internal.create.FileDependencyStrategy)

        OriginalFiles cell
        OriginalMissingFiles cell
        OriginalDirtyFiles cell
        OriginalNumDependencies double
    end

    properties(GetAccess=public,SetAccess=?restorepoint.internal.create.VariableDependencyStrategy)

        OriginalWorkspaceVariables cell
    end

    properties(GetAccess=public,SetAccess=?restorepoint.internal.create.StoreElementsStrategy)

        currentModelRestorePointPath char
        WorkspaceFile char
    end

    methods
        function obj=ModelRestoreData(model)
            obj.Data=containers.Map;
            obj.OriginalModel=model;
            [obj.FileName,obj.ModelDir]=restorepoint.internal.utils.getFilePathForModel(model);
            sessionID=restorepoint.internal.utils.SessionInformationManager.getSessionIdentifier;
            obj.NodeName=sessionID.NodeName;
        end

        function setOriginalFiles(obj,files)
            obj.OriginalFiles=files;
        end

        function keyOut=makeKeyForData(~,keyIn)
            keyOut=keyIn;
        end

        function populateModelStateInfo(obj)
            for depIdx=1:obj.OriginalNumDependencies
                curDep=obj.OriginalFiles{depIdx};
                s.newFile='';
                s.checkSum=Simulink.getFileChecksum(curDep);
                s=obj.addModelStateInfo(s,curDep);
                key=obj.makeKeyForData(curDep);
                obj.Data(key)=s;
            end
        end

        function addNewFile(obj,originalFile,newFile)
            key=obj.makeKeyForData(originalFile);
            assert(obj.Data.isKey(key));
            s=obj.Data(key);
            s.newFile=newFile;
            obj.Data(key)=s;
        end

        function data=getDataForFile(obj,originalFile)
            data=[];
            key=obj.makeKeyForData(originalFile);
            if obj.Data.isKey(key)
                data=obj.Data(key);
            end
        end

        function setDataForFile(obj,originalFile,data)
            key=obj.makeKeyForData(originalFile);
            obj.Data(key)=data;
        end

        function originalFiles=getOriginalFiles(obj)
            originalFiles=(obj.OriginalFiles)';
        end

        function renameRestoreDirectory(obj,newName)
            obj.NodeName=newName;
            [path,~]=fileparts(obj.RestoreDirectory{1});
            obj.RestoreDirectory{1}=fullfile(path,newName);
            [path,~]=fileparts(obj.ExistingRestoreDir);
            if~isempty(path)
                obj.ExistingRestoreDir=fullfile(path,newName);
            end
            fileNames=keys(obj.Data);
            files=values(obj.Data);
            for idx=1:numel(files)
                fileData=files{idx};
                [~,name,ext]=fileparts(fileData.newFile);
                fileData.newFile=...
                fullfile(obj.RestoreDirectory{1},[name,ext]);
                obj.Data(fileNames{idx})=fileData;
            end
        end
    end

    methods(Static=true,Access=private)

        function dataStruct=addModelStateInfo(dataStruct,fullFile)
            [~,currentFileName,fileExtension]=fileparts(fullFile);
            if strcmpi(fileExtension,'.slx')||strcmpi(fileExtension,'.mdl')
                if bdIsLoaded(currentFileName)
                    dataStruct.loadRestoredModel=true;
                    if strcmpi('on',get_param(currentFileName,'Shown'))
                        dataStruct.openRestoredModel=true;
                    else
                        dataStruct.openRestoredModel=false;
                    end
                else
                    dataStruct.loadRestoredModel=false;
                    dataStruct.openRestoredModel=false;
                end
            end
        end

    end

end


