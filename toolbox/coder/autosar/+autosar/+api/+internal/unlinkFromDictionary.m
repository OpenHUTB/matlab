function unlinkFromDictionary(modelName)






















    autosar.api.Utils.autosarlicensed(true);

    if nargin>0
        modelName=convertStringsToChars(modelName);
        modelName=get_param(modelName,'Name');
    end


    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
    end


    isCompliant=strcmp(get_param(modelName,'AutosarCompliant'),'on');
    if~isCompliant
        DAStudio.error('RTW:autosar:nonAutosarCompliant');
    end

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

        autosar.dictionary.internal.LinkUtils.copySharedElementsToModelAndUnlink(modelName);
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end


