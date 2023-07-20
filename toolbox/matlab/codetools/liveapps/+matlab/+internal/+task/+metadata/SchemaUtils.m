classdef SchemaUtils<handle



    properties(Access=private)
Schema
    end

    methods(Access=public)
        function obj=SchemaUtils()


            obj.loadSchema();
        end

        function[isValid,metadata]=validateMetadata(obj,metadata)


            import matlab.internal.task.metadata.Constants;
            isValid=false;


            if~isstruct(metadata)
                return;
            end


            metadata=obj.validateTasks(metadata);

            isValid=true;
        end
    end

    methods(Access=private)
        function loadSchema(obj)


            import matlab.internal.task.metadata.Constants;
            dirPath=strjoin(Constants.UserTaskPackagePath,filesep);
            schemaPath=fullfile(matlabroot,dirPath,Constants.SchemaFileName);
            obj.Schema=jsondecode(fileread(schemaPath));
        end


        function tasks=validateTasks(obj,tasks)






            taskClassNames=fields(tasks);
            for taskIndex=1:length(taskClassNames)
                task=tasks.(taskClassNames{1});


                keyDiff=setdiff(obj.Schema.required,fieldnames(task));


                if~isempty(keyDiff)
                    properties=obj.Schema.properties;
                    for keyIndex=1:length(keyDiff)
                        key=keyDiff{keyIndex};
                        task.(key)=properties.(key).default;
                    end
                    tasks.(taskClassNames{1})=task;
                end
            end
        end
    end
end

