function configData=RtmModelRegistry_config




    persistent fConfigData;

    if isempty(fConfigData)

        internalErrorPfx='physmod:pm_sli:RTM:RtmModelRegistry:error:internal:';
        Error.MultiplyRegisteredModel_templ_msgid=[internalErrorPfx,'ModelMultiplyRegistered'];
        Error.MultiplyRegisteredBlock_templ_msgid=[internalErrorPfx,'BlockMultiplyRegistered'];

        userErrorPfx='physmod:pm_sli:RTM:RtmModelRegistry:error:user:';
        Error.ModelNotRegistered_templ_msgid=[userErrorPfx,'ModelNotRegistered'];
        Error.BlockDataExists_templ_msgid=[userErrorPfx,'BlockDataExists'];

        fConfigData.Error=Error;

    end

    configData=fConfigData;



