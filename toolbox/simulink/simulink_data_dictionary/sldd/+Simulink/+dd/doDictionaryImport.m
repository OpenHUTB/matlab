function doDictionaryImport(ddConn,scope,sourceFile)





    bTestForConflicts=true;
    bOverwriteDuplicates=false;

    [importedList,existingList,conflictsList,unsupportedList]=ddConn.interactiveImport(bTestForConflicts,bOverwriteDuplicates,sourceFile,scope);
    clear tmp;

    if~isempty(conflictsList)
        bAllowOverwriteOption='on';
        dlg=Simulink.dd.DictionaryPreImport(ddConn,conflictsList,sourceFile,bAllowOverwriteOption,@continueImport,scope,conflictsList);
        DAStudio.Dialog(dlg,'','DLG_STANDALONE');
    else
        showResults(ddConn,importedList,existingList,unsupportedList,conflictsList,sourceFile);
    end
end

function continueImport(ddConn,sourceFile,bContinue,bOverwrite,varargin)
    if bContinue
        bTestForConflicts=false;
        scope=varargin{1};
        conflictsList=varargin{2};

        [importedList,existingList,~,unsupportedList]=ddConn.interactiveImport(bTestForConflicts,bOverwrite,sourceFile,scope);
        clear tmp;

        if bOverwrite
            conflictsList={};
        end
        showResults(ddConn,importedList,existingList,unsupportedList,conflictsList,sourceFile);
    end
end

function showResults(ddConn,importedList,existingList,unsupportedList,conflictsList,sourceFile)
    dlg=Simulink.dd.DictionaryPostImport(ddConn,importedList,{},existingList,unsupportedList,conflictsList,sourceFile);
    DAStudio.Dialog(dlg,'','DLG_STANDALONE');
end

