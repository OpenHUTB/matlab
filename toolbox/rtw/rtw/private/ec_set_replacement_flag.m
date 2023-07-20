function ec_set_replacement_flag(modelName)

















    try
        informationMissing=false;

        cs=getActiveConfigSet(modelName);

        isERT=get_param(cs,'IsERTTarget');
        isERTOff=strcmp(isERT,'off');
        modelRefSIMTarget=get_param(modelName,'ModelReferenceTargetType');
        isSimTarget=strcmp(modelRefSIMTarget,'SIM');
        ecoderInstalled=~ecoderinstalled(modelName);
    catch
        informationMissing=true;
    end


    if(feature('RTWReplacementTypes')==1)&&~informationMissing
        try
            isReplacementOn=true;


            if isSimTarget
                isReplacementOn=false;
            elseif isERTOff||ecoderInstalled
                isReplacementOn=false;
            else
                EnableRep=get_param(cs,'EnableUserReplacementTypes');

                if strcmp(EnableRep,'off')||...
                    isempty(ec_get_replacetype_mapping_list(modelName))
                    isReplacementOn=false;
                end
            end
        catch

            isReplacementOn=false;
        end
    else
        isReplacementOn=false;
    end
    rtwprivate('rtwattic','AtticData','isReplacementOn',isReplacementOn);

    if~informationMissing
        if isSimTarget
            isLimitsReplacementOn=false;
        elseif isERTOff||ecoderInstalled
            isLimitsReplacementOn=false;
        else
            isLimitsReplacementOn=true;
        end
    else
        isLimitsReplacementOn=false;
    end
    rtwprivate('rtwattic','AtticData','isLimitsReplacementOn',isLimitsReplacementOn);




