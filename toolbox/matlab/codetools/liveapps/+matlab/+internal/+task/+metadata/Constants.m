classdef(Abstract)Constants<handle


    properties(Constant)
        UpdateModelEvent='UpdateModelEvent'
        CleanUpAppEvent='CleanUpAppEvent'
        RegistrationErrorEvent='RegistrationErrorEvent'
        RegistrationSuccessEvent='RegistrationSuccessEvent'

        Register='Register'
        Update='Update'
        Status='status'

        PackagePrefix='+'
        PackageSeperator='.'

        Name='name'
        TaskClassName='taskClassName'

        MetadataDir='resources'
        MetadataFile='liveTasks.json'

        UserTaskSuperclass='matlab.task.LiveTask'
        TempDir='TaskMetadata'

        Registered='Registered'
        NotRegistered='Not Registered'

        Ok=string(message('rich_text_component:liveApps:OkLabel'))
        Cancel=string(message('rich_text_component:liveApps:CancelLabel'))

        UserTaskPackagePath={'toolbox','matlab','codetools','liveapps','+matlab','+internal','+task','+metadata'}
        SchemaFileName='liveTasksSchema.json'

        MessageCatalogPrefix='rich_text_component:liveApps:'
        MaxFilePathLength=76;

        DefaultTaskIcon='default_task_icon.png'
        FolderIcon='folder_24.png'
        HelpIcon='help.svg'
        Schema='schema'

        TaskLibIconSize=[24,24]
    end
end