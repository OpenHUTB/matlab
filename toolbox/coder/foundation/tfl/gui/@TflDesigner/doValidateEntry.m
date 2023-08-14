function isInValidEntry=doValidateEntry(entryElement,fireChangeForWarnError)
    isInValidEntry=false;
    currEnt=entryElement.object;
    lastwarn('');
    warnFlag=warning('off');
    try
        entryElement.isValid=currEnt.isValid;
        entryElement.errLog='';
    catch ME
        entryElement.isValid=false;
        entryElement.errLog=ME.message;
        isInValidEntry=true;
        if fireChangeForWarnError
            entryElement.firepropertychanged;
        end
    end
    warning(warnFlag);
    validationWarning=lastwarn();
    if(~isempty(validationWarning))
        entryElement.errLog=validationWarning;
        if fireChangeForWarnError
            entryElement.firepropertychanged;
        end
    end
end