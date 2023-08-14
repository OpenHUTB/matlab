function linkToDictionary(modelName,dictionaryFile)






















    autosar.api.Utils.autosarlicensed(true);

    narginchk(2,2);


    modelName=convertStringsToChars(modelName);
    modelName=get_param(modelName,'Name');
    dictionaryFile=convertStringsToChars(dictionaryFile);


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


        [isSharedDict,otherDictFiles]=autosar.api.Utils.isUsingSharedAutosarDictionary(modelName);
        if isSharedDict
            assert(numel(otherDictFiles)==1,'Expected model to be linked to a single shared AUTOSAR dictionary.');
            otherDictFile=otherDictFiles{1};
            if~strcmp(dictionaryFile,otherDictFile)
                DAStudio.error('autosarstandard:dictionary:ModelIsLinkedToAnotherDictionary',...
                modelName,otherDictFile);
            end
        end




        saveState=true;
        uiCleanUpObj=autosar.ui.utils.closeUIAndApp(modelName,saveState);%#ok<NASGU>

        [~,dictName,dictExt]=fileparts(dictionaryFile);
        assert(strcmp(dictExt,'.sldd'),'Only sldd files supported for shared dictionary');


        if~exist(dictionaryFile,'file')
            ddConn=Simulink.dd.create(dictionaryFile);
            ddNeedsSaving=true;
        else
            ddConn=Simulink.dd.open(dictionaryFile);
            ddNeedsSaving=false;
        end



        isInterfaceDict=sl.interface.dict.api.isInterfaceDictionary(dictionaryFile);
        if isInterfaceDict
            interfaceDictAPI=Simulink.interface.dictionary.open(dictionaryFile);
            if~interfaceDictAPI.hasPlatformMapping('AUTOSARClassic')
                interfaceDictAPI.addPlatformMapping('AUTOSARClassic');
            end
        end




        if~isInterfaceDict
            Simulink.AutosarDictionary.ModelRegistry.linkToDD(modelName,ddConn.filespec());
        end


        dictNoPath=[dictName,dictExt];
        set_param(modelName,'DataDictionary',dictNoPath);


        autosar.dictionary.internal.LinkUtils.linkModelDictM3IModels(modelName,dictNoPath);

        if ddNeedsSaving
            ddConn.saveChanges();
        end
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end

end



