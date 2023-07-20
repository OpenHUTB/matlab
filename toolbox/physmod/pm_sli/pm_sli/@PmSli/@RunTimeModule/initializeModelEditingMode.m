function initializeModelEditingMode(this,hBlock)








    if pm.simscape.internal.isSimscapeComponentDependent(hBlock)
        return
    end

    mdl=getBlockModel(hBlock);

    if this.isModelRegistered(mdl)||this.isExaminingModel(mdl)
        return
    end

    fallbackCC=[];

    isExamining=this.isExaminingModel(mdl);
    this.setExaminingModel(mdl,true);

    this.loadRtmModelData(mdl);


    isAuthoringModeInMdlFile=strcmp(this.getModelEditingMode(mdl),EDITMODE_AUTHORING);


    isPreferenceUsingMode=strcmp(this.getPreferredLoadMode,LOAD_USING_MODE);


    isMdlInAuthoringMode=isAuthoringModeInMdlFile;


    isPreRtmModel=this.isModelPreRtm(mdl);



    if isPreferenceUsingMode&&isAuthoringModeInMdlFile


        configData=RunTimeModule_config;

        [isMdlInAuthoringMode,fallbackCC]=fallBackToUsingMode(this,mdl,pm_message(configData.Warning.PreferencesRequestRestrictedLoadAlways_msgid));

    end








    if isMdlInAuthoringMode

        modelProducts=this.getModelProducts(mdl);

        try

            this.getProductLicenses(modelProducts)

        catch exception



            errorData=exception;
            [isMdlInAuthoringMode,fallbackCC]=fallBackToUsingMode(this,mdl,errorData);

        end
    else



        try
            this.getProductLicenses({pmsl_defaultproduct});
        catch exception
            errorData=exception;
            [isMdlInAuthoringMode,fallbackCC]=fallBackToUsingMode(this,mdl,errorData);
        end
    end



    if~isempty(fallbackCC)

        configData=RunTimeModule_config;
        fallbackCC.set(configData.EditingMode.PropertyName,EDITMODE_USING);
    end







    if isPreRtmModel&&~isMdlInAuthoringMode
        this.enterRestrictedMode(mdl);
    end

    this.setExaminingModel(mdl,isExamining);
    this.registerModel(mdl);


    function[isAuthoringMode,newCC]=fallBackToUsingMode(this,mdl,errorData)



        configData=RunTimeModule_config;
        newCC=this.cloneConfigSet(mdl);
        isAuthoringMode=false;

        if isa(errorData,'MException')
            if strcmp(errorData.identifier,configData.Error.NoPlatformProductLicense_msgid)
                pm_warning(configData.Error.NoPlatformProductLicense_msgid)
            else
                pm_warning(configData.Warning.ModelLoadedInRestrictedMode_templ_msgid,errorData.message);
            end
        else
            pm_warning(configData.Warning.ModelLoadedInRestrictedMode_templ_msgid,errorData);
        end



