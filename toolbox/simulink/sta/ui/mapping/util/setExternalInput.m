function setExternalInput(modelName,inputString)



    if(~strcmp(get_param(modelName,'ExternalInput'),inputString))
        set_param(modelName,'LoadExternalInput','on');
        set_param(modelName,'ExternalInput',inputString);
    end
