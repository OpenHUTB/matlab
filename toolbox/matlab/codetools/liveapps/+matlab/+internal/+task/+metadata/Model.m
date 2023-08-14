classdef Model<handle




    properties(Access=private)
Directory
RegisteredTaskList
Name
TaskClassName
TaskMetadata
Metadata
PackagePrefix
DirectoryWithPackages
SchemaUtils
IsValid
    end

    methods(Access=public)

        function obj=Model(filePath)





            obj.SchemaUtils=matlab.internal.task.metadata.SchemaUtils();


            obj.parseFilePath(filePath);



            obj.updateModel();
        end



        function directory=getDirectory(obj)
            directory=obj.Directory;
        end

        function taskMetadata=getTaskMetadata(obj)
            taskMetadata=obj.TaskMetadata;
        end

        function isValid=getModelValidity(obj)
            isValid=obj.IsValid;
        end



        function updateTask(obj,taskMetadata)


            metadata=obj.Metadata;
            taskClassName=taskMetadata.taskClassName;
            oldMetadata=metadata.(taskClassName);
            mergedMetadata=obj.mergeMetadata(oldMetadata,taskMetadata);
            mergedMetadata=rmfield(mergedMetadata,'taskClassName');
            metadata.(taskClassName)=mergedMetadata;

            if strcmp(metadata.(taskClassName).icon,'')
                metadata.(taskClassName)=rmfield(metadata.(taskClassName),"icon");
            end


            obj.Metadata=metadata;


            obj.serializeMetadata();
        end

        function registerTask(obj,taskMetadata)


            import matlab.internal.task.metadata.Constants

            metadata=obj.Metadata;

            taskClassName=taskMetadata.taskClassName;
            taskMetadata=rmfield(taskMetadata,'taskClassName');
            metadata.(taskClassName)=taskMetadata;

            if strcmp(metadata.(taskClassName).icon,'')
                metadata.(taskClassName)=rmfield(metadata.(taskClassName),"icon");
            end


            obj.Metadata=metadata;


            obj.serializeMetadata();
        end

        function deRegisterTask(obj)



            metadata=obj.Metadata;


            if~isfield(obj.Metadata,obj.TaskClassName)
                return;
            end

            metadata=rmfield(metadata,obj.TaskClassName);


            obj.Metadata=metadata;


            obj.serializeMetadata();
        end
    end

    methods(Access=private)
        function parseFilePath(obj,filePath)



            [fullDirectoryPath,fileName,~]=fileparts(filePath);
            packagePrefix='';
            import matlab.internal.task.metadata.Constants

            directory=fullDirectoryPath;
            taskClassName=fileName;

            if contains(directory,Constants.PackagePrefix)
                directory=strip(strtok(fullDirectoryPath,Constants.PackagePrefix),'right',filesep);
                directoryPathPart=strsplit(fullDirectoryPath,Constants.PackagePrefix);
                directoryPathPart=strtok({directoryPathPart{2:end}},filesep);
                packagePrefix=strjoin(directoryPathPart,Constants.PackageSeperator);
                taskClassName=[packagePrefix,Constants.PackageSeperator,fileName];
            end


            obj.Directory=directory;

            obj.Name=fileName;
            obj.TaskClassName=taskClassName;


            obj.DirectoryWithPackages=fullDirectoryPath;


            obj.PackagePrefix=packagePrefix;
        end

        function updateModel(obj)






            [obj.IsValid,obj.RegisteredTaskList,obj.Metadata]=obj.parseMetadataFile(obj.Directory);


            obj.setTaskMetadata();
        end

        function serializeMetadata(obj)


            import matlab.internal.task.metadata.Constants


            try
                if~exist(fullfile(obj.Directory,Constants.MetadataDir),'dir')
                    mkdir(fullfile(obj.Directory,Constants.MetadataDir))
                end
            catch me
                rethrow(me);
            end


            metadataFilePath=fullfile(obj.Directory,Constants.MetadataDir,Constants.MetadataFile);
            fid=fopen(metadataFilePath,'w');
            fprintf(fid,'%s',jsonencode(obj.Metadata,'PrettyPrint',true));
            fclose(fid);



            obj.updateCache();


            obj.updateModel();
        end

        function[isValid,registeredTasks,metadata]=parseMetadataFile(obj,directory)


            import matlab.internal.task.metadata.Constants
            registeredTasks=struct;
            isValid=true;
            metadata=struct;


            metadataFilePath=fullfile(directory,Constants.MetadataDir,Constants.MetadataFile);
            me=[];
            if exist(metadataFilePath,'file')
                try
                    metadata=jsondecode(fileread(metadataFilePath));
                catch me
                    throw(me);
                end

                try
                    [isValid,metadata]=obj.SchemaUtils.validateMetadata(metadata);
                    if isValid
                        registeredTasks=metadata;
                    end
                catch me
                    isValid=false;
                end
            end


            if~isempty(me)
                return;
            end
        end

        function name=getRegisteredName(obj,task)


            taskClassNameParts=strsplit(task.taskClassName,'.');
            name=taskClassNameParts{end};
        end

        function setTaskMetadata(obj)




            import matlab.internal.task.metadata.Constants

            taskMetadata=struct(Constants.Status,Constants.NotRegistered,...
            Constants.TaskClassName,obj.TaskClassName,...
            Constants.Name,obj.Name);


            registeredTasks=fields(obj.RegisteredTaskList);
            for taskIndex=1:length(registeredTasks)
                registeredTaskMetadata=obj.RegisteredTaskList.(registeredTasks{1});
                if strcmp(registeredTasks{taskIndex},obj.TaskClassName)
                    taskMetadata.status=Constants.Registered;
                    taskMetadata=obj.mergeMetadata(taskMetadata,registeredTaskMetadata);
                end
            end

            obj.TaskMetadata=taskMetadata;
        end

        function mergedMetadata=mergeMetadata(obj,oldMetadata,newMetadata)





            mergedMetadata=oldMetadata;
            fields=fieldnames(newMetadata);
            for filedIndex=1:length(fields)
                mergedMetadata.(fields{filedIndex})=newMetadata.(fields{filedIndex});
            end
        end

        function updateCache(obj)



            import matlab.internal.task.metadata.Constants



            matlab.internal.regfwk.unregisterResources(obj.Directory);
            matlab.internal.regfwk.disableResources(obj.Directory)


            if contains(path,obj.Directory)
                matlab.internal.regfwk.enableResources(obj.Directory);
            end
        end
    end
end
