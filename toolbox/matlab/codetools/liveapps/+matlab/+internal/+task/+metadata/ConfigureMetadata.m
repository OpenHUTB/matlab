classdef ConfigureMetadata<handle


    properties(Access=private)
        Model matlab.internal.task.metadata.Model
        MetadataUIViewModel matlab.internal.task.metadata.MetadataUIViewModel
UpdateModelEventListener
CleanUpAppEventListener
    end

    methods(Access=public)
        function obj=ConfigureMetadata(userTaskFilePath)

            import matlab.internal.task.metadata.Constants


            obj.Model=matlab.internal.task.metadata.Model(userTaskFilePath);


            payload=struct();
            payload.Metadata=obj.Model.getTaskMetadata();
            payload.Directory=obj.Model.getDirectory();
            payload.ModelValidity=obj.Model.getModelValidity();
            payload.FilePath=userTaskFilePath;

            obj.MetadataUIViewModel=matlab.internal.task.metadata.MetadataUIViewModel(payload);


            obj.UpdateModelEventListener=addlistener(obj.MetadataUIViewModel,Constants.UpdateModelEvent,@obj.updateModel);
            obj.CleanUpAppEventListener=addlistener(obj.MetadataUIViewModel,Constants.CleanUpAppEvent,@obj.cleanUpApp);


            matlab.internal.task.metadata.MetadataUI(obj.MetadataUIViewModel);
        end
    end

    methods(Access=private)

        function updateModel(obj,~,eventData)



            import matlab.internal.task.metadata.Constants

            metadata=eventData.Metadata;


            try
                switch eventData.UpdateType
                case Constants.Register
                    obj.Model.registerTask(metadata);
                case Constants.Update
                    obj.Model.updateTask(metadata);
                end
                obj.MetadataUIViewModel.handleRegistrationSuccess();
            catch me
                obj.MetadataUIViewModel.handleRegistrationError(me);
            end
        end

        function cleanUpApp(obj,~,~)



            delete(obj.UpdateModelEventListener);
            delete(obj.CleanUpAppEventListener);
            delete(obj.Model);
            delete(obj.MetadataUIViewModel);
        end
    end
end
