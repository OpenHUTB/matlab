function isValid=requestCredentials(manager,dialog)












    isValid=false;

    while~isValid


        credentials=dialog.requestCredentials();

        if~dialog.IsSubmitRequest


            break
        elseif dialog.areFieldsEmpty()

            m=driving.internal.heremaps.DataServiceManager.getInstance();
            dialog.setInvalidStatus(...
            getString(message("driving:heremaps:Empty"+m.DataServiceName+"AppCredentials")));
        else

            dialog.setValidatingStatus();



            if dialog.Save.Value
                [isValid,err]=manager.setPersistentCredentials(credentials);
            else
                [isValid,err]=manager.setTemporaryCredentials(credentials);
            end


            if~isValid
                dialog.throwValidationErrors(err);
            end

        end

    end

end