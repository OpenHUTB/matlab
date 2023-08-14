function importSpecialTypes(obj,updateLib)


    typesToImport=obj.TypesToImport;
    try
        if~isempty(typesToImport)

            dataDictName=obj.LibraryFileName+".sldd";
            dataDictNamePath=fullfile(obj.qualifiedSettings.OutputFolder,dataDictName);
            if~isfile(dataDictNamePath)




                Simulink.data.dictionary.closeAll(dataDictName,'-discard');
                Simulink.data.dictionary.create(dataDictNamePath);
            else
                if updateLib
                    libSLDD=Simulink.data.dictionary.open(dataDictNamePath);
                    slddDesignDataSection=libSLDD.getSection('Design Data');
                    slddEntries=find(slddDesignDataSection);
                    slddEntryNames=string({slddEntries.Name});
                    entriesToRemoveIdx=~ismember(slddEntryNames,typesToImport);
                    entriesToRemove=slddEntries(entriesToRemoveIdx);
                    arrayfun(@(x)deleteEntry(slddDesignDataSection,x.Name),...
                    entriesToRemove);
                    saveChanges(libSLDD);
                else


                    Simulink.data.dictionary.closeAll(dataDictName,'-discard');
                    delete(dataDictNamePath);
                    Simulink.data.dictionary.create(dataDictNamePath);
                end
            end


            Simulink.importExternalCTypes(obj.LibraryFileName,...
            'OutputDir',obj.qualifiedSettings.OutputFolder,...
            'DataDictionary',dataDictName,...
            'EnumClass','dynamic',...
            'Names',typesToImport);




            currentDir=cd(obj.qualifiedSettings.OutputFolder);
            cleanupObj=onCleanup(@()cd(currentDir));
            set_param(obj.LibraryFileName,'DataDictionary',dataDictName);
        end
    catch ME
        mainErr=MException(message('Simulink:CodeImporter:ImportSpecialTypesError'));
        mainErr=addCause(mainErr,ME);
        throw(mainErr);
    end
end
