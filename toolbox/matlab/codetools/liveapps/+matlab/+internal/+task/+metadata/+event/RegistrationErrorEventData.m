classdef(ConstructOnLoad)RegistrationErrorEventData<event.EventData


    properties
        RegistrationError MException
ErrorMessage
    end

    methods
        function data=RegistrationErrorEventData(registrationError)
            data.RegistrationError=registrationError;
            data.getErrorMessage();
        end

        function getErrorMessage(data)
            import matlab.internal.task.metadata.Constants
            switch(data.RegistrationError.identifier)
            case 'MATLAB:MKDIR:OSError'
                data.ErrorMessage=string(message([Constants.MessageCatalogPrefix,'NoWriteAccessErrorMsg']));
            otherwise
                data.ErrorMessage=data.RegistrationError.message;
            end
        end
    end
end

