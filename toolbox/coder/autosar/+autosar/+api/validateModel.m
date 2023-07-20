function validateModel(mdlName)
























    autosar.api.Utils.autosarlicensed(true);






    msgStream=autosar.api.Utils.initMessageStreamHandler();
    if~autosar.utils.Debug.showStackTrace()
        disableQueuingObj=msgStream.enableQueuing();%#ok<*NASGU>
        flushMsgsObj=onCleanup(@()msgStream.clear());
    end


    if nargin>0
        mdlName=convertStringsToChars(mdlName);
    end

    if autosar.api.Utils.isMappedToComposition(mdlName)
        DAStudio.error('autosarstandard:api:CompositionValidationNotSupported',mdlName);
    end
    [isMappedToSubComponent,~]=Simulink.CodeMapping.isMappedToAutosarSubComponent(mdlName);
    if isMappedToSubComponent
        DAStudio.error('autosarstandard:api:subComponentNotSupported');
    end
    validator=autosar.validation.Validator();
    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();

        dispatchValidation(validator,mdlName);

        if~autosar.utils.Debug.showStackTrace()
            msgStream.flush('autosarstandard:validation:ValidationError');
            disableQueuingObj.delete();
        end
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end

end

function dispatchValidation(validator,mdlName)

    try
        validator.verify(get_param(mdlName,'Handle'));


        if strcmp(autosar.validation.Validator.getValidationLevel(),'partial')
            autosar.mm.util.MessageReporter.print(...
            message('RTW:autosar:ValidatePartialSucceedAPI').getString());
        end
    catch ME

        autosar.validation.Validator.logError(ME.identifier,ME);
    end
end


