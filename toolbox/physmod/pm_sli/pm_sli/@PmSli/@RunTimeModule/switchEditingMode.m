function success=switchEditingMode(this,hModel,currentMode,requestedMode,checkOnly)









    if nargin<5
        checkOnly=false;
    end



    success=false;

    if this.isExaminingModel(hModel)









    else

        switch currentMode

        case EDITMODE_USING

            switch requestedMode

            case EDITMODE_USING

                success=true;

            case EDITMODE_AUTHORING




                checkForUnappliedDialogChanges();




                this.validateLibraryLinks(hModel);

                modelProducts=this.getModelProducts(hModel);
                this.getProductLicenses(modelProducts);
                if checkOnly
                    success=true;
                else
                    success=this.restoreModelFromSnapshot(hModel,true);
                end


            end

        case EDITMODE_AUTHORING

            switch requestedMode

            case EDITMODE_AUTHORING

                success=true;

            case EDITMODE_USING




                checkForUnappliedDialogChanges();




                this.validateLibraryLinks(hModel);

                if checkOnly
                    success=true;
                else

                    success=this.enterRestrictedMode(hModel);

                end

            end

        end

    end


    function checkForUnappliedDialogChanges()





        culprits={};
        pmOpenDialogs=this.getOpenDialogs(hModel);
        for idx=1:numel(pmOpenDialogs)
            if pmOpenDialogs(idx).Dialog.hasUnappliedChanges()
                culprits{end+1}=['''',pmsl_sanitizename(getfullname(pmOpenDialogs(idx).Block.Handle)),''''];
            end
        end




        if~isempty(culprits)
            culprits=strcat(culprits,', \n');
            culpritsText=sprintf([culprits{:}]);
            configData=RunTimeModule_config;
            thisError=configData.Error.UnappliedDialogChanges_templ_msgid;
            pm_error(thisError,culpritsText);
        end

    end


end




