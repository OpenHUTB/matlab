




function err=i_copyBDAndLoad(bdFileWithPath,redBDFullName,rManager)
    err=[];
    try
        [~,redBDName,~]=fileparts(redBDFullName);
        if~bdIsLoaded(redBDName)
            copyfile(bdFileWithPath,redBDFullName,'f');


            fileattrib(redBDFullName,'+w');
        else
            errid='Simulink:Variants:ErrRedMdlIsOpen';
            errmsg=message(errid,redBDName,get_param(redBDName,'FileName'));
            err=MException(errmsg);
            return;
        end




        withCallbacks=false;
        Simulink.variant.reducer.utils.loadSystem(redBDFullName,withCallbacks);

        [redModelPath,redModelName]=fileparts(redBDFullName);
        [~,origModelName]=fileparts(bdFileWithPath);

        if strcmp(origModelName,rManager.ReductionOptions.TopModelOrigName)
            rManager.DataDictionaryRenameManager.initializeDDNameAssociatedOrigModelNamesMap(origModelName);
        end

        dataDictionaryNameOrig=get_param(redModelName,'DataDictionary');
        if~isempty(dataDictionaryNameOrig)&&~bdIsLibrary(redModelName)


            dataDictionaryFileOrig=Simulink.variant.utils.getDataDictionaryForModel(redModelName);
            dataDictionaryNameOrig=get_param(redModelName,'DataDictionary');



            err=rManager.DataDictionaryRenameManager.renameReducedDataDictionarySemantically(dataDictionaryNameOrig,dataDictionaryFileOrig,redModelPath,origModelName,redModelName);
            if~isempty(err)
                return;
            end
        end
        if(slfeature('SLModelAllowedBaseWorkspaceAccess'))>0
            isLibrary=bdIsLibrary(origModelName);
            if isLibrary
                oldLockStatus=get_param(redModelName,'Lock');
                set_param(redModelName,'Lock','off');
                resetLock=onCleanup(@()set_param(redModelName,'Lock',oldLockStatus));
            end
            set_param(redModelName,'EnableAccessToBaseWorkspace',...
            get_param(origModelName,'EnableAccessToBaseWorkspace'))
        end
%#ok<*AGROW>











    catch err
    end
end


