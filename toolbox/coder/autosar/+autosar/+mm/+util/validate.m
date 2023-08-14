function[validationStatus,msg]=validate(modelName,mode)






    if nargin>0
        modelName=convertStringsToChars(modelName);
    end

    if nargin>1
        mode=convertStringsToChars(mode);
    end
    mAllExceptions=[];
    msg='';

    activeMapping=autosar.api.Utils.modelMapping(modelName);

    if isempty(activeMapping)
        autosar.validation.AutosarUtils.reportErrorWithFixit(...
        'Simulink:Engine:RTWCGAutosarEmptyConfigurationError',modelName);
    end

    if strcmp(mode,'interactive')

        lastValueForShowHiddenH=get(0,'ShowHiddenHandles');
        set(0,'ShowHiddenHandles','on');
        prevH=get(0,'Children');
        for ii=1:length(prevH)
            name=get(prevH(ii),'Name');
            if strcmp(name,autosar.ui.configuration.PackageString.ValAutosar)
                delete(prevH(ii));
            end
        end
        set(0,'ShowHiddenHandles',lastValueForShowHiddenH);



        validationLevel=autosar.validation.Validator.getValidationLevel();
        if strcmp(validationLevel,'partial')


            waitMsg=[autosar.ui.configuration.PackageString.WaitMsg,newline,newline];
        else
            waitMsg=autosar.ui.configuration.PackageString.WaitMsg;
        end
        h=waitbar(0,waitMsg,'Name',autosar.ui.configuration.PackageString.ValAutosar);
    end


    validationStatus=1;
    try





        msgStream=autosar.api.Utils.initMessageStreamHandler();
        if~autosar.utils.Debug.showStackTrace()
            disableQueuingObj=msgStream.enableQueuing();%#ok<*NASGU>
            flushMsgsObj=onCleanup(@()msgStream.clear());
        end

        try
            validator=autosar.validation.Validator();
            validator.verify(get_param(modelName,'Handle'));
        catch ME

            autosar.validation.Validator.logError(ME.identifier,ME);
        end
        if~autosar.utils.Debug.showStackTrace()
            msgStream.flush('autosarstandard:validation:ValidationError');
            disableQueuingObj.delete();
        end

    catch mException
        validationStatus=0;
        if strcmp(mode,'interactive')

            sldiagviewer.reportError(mException);
        elseif strcmp(mode,'cmdline')
            mAllExceptions=mException;
        else
            rethrow(mException);
        end
    end

    if strcmp(mode,'interactive')
        if validationStatus
            if strcmp(validationLevel,'partial')
                validationMsg=autosar.ui.configuration.PackageString.ValidatePartialSucceed;
            else
                validationMsg=autosar.ui.configuration.PackageString.ValidateSucceed;
            end
            waitbar(100,h,validationMsg);
        else
            close(h);

        end
    elseif strcmp(mode,'cmdline')
        if~isempty(mAllExceptions)
            throw(mAllExceptions);
        end
    end


end


