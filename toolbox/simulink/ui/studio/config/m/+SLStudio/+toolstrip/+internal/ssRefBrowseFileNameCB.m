function ssRefBrowseFileNameCB(cbinfo,~)

    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    currentModelName=get_param(block.handle,'ReferencedSubsystem');


    startingLocation=getStartingLocaton(currentModelName);


    [FileName,PathName,FilterIndex]=getFileFromUser(startingLocation);
    if isequal(FilterIndex,0)

        return
    end

    [~,subsystemBDWithoutExt,ext]=fileparts(FileName);


    checkFileTypePostChoose(FileName,ext);

    FileIsLoadedOrOnPath(PathName,FileName);


    setModelName(block.handle,subsystemBDWithoutExt);

end

function startingLocation=getStartingLocaton(currentModel)

    [~,fullModelName]=slInternal('getReferencedModelFileInformation',currentModel);

    startingLocation=which(fullModelName);

    if isempty(startingLocation)
        startingLocation=pwd;
    end

end

function[FileName,PathName,FilterIndex]=getFileFromUser(startingLocation)

    extstr={'*.slx';'*.mdl'};
    dialogTitle=DAStudio.message('Simulink:SubsystemReference:BrowseSubsystemFile');
    [FileName,PathName,FilterIndex]=uigetfile(extstr,dialogTitle,startingLocation);

end

function checkFileTypePostChoose(FileName,ext)

    if(~((strcmpi(ext,'.mdl'))||...
        (strcmpi(ext,'.slx'))))

        DAStudio.error('Simulink:SubsystemReference:InvalidFileSelected',...
        FileName)
    end
end

function FileIsLoadedOrOnPath(PathName,FileName)

    if ispc
        platformPathCompare=@strcmpi;
    else
        platformPathCompare=@strcmp;
    end

    fullFileName=fullfile(PathName,FileName);




    [isLoaded,loadedFilePath]=findLoadedFile(FileName);

    ifFileisLoaded(platformPathCompare,isLoaded,loadedFilePath,FileName,fullFileName);

    filePaths=getFilesOnPathMatchingSelectedFile(FileName);

    if isempty(filePaths)


        isCancel=resolvePathIssueForAFile(PathName,FileName);
        if(isCancel)
            return
        end

    else
        ifFilePathIsNotEmpty(platformPathCompare,fullFileName,FileName,filePaths,isLoaded);
    end
end

function ifFileisLoaded(platformPathCompare,isLoaded,loadedFilePath,FileName,fullFileName)

    if isLoaded

        isLoadedAndSelectedFileSame=platformPathCompare(loadedFilePath,fullFileName);
        if~isLoadedAndSelectedFileSame

            if~isempty(loadedFilePath)

                [~,otherFileName,otherFileExt]=fileparts(loadedFilePath);
                DAStudio.error(SelectedFileHasLowerPrecedence,FileName,...
                fullFileName,[otherFileName,otherFileExt],loadedFilePath)
            else

                DAStudio.error('Simulink:modelReference:selectedModelHasLowerPrecedenceDirty',...
                FileName,fullFileName)
            end
        end
    end
end

function ifFilePathIsNotEmpty(platformPathCompare,fullFileName,FileName,filePaths,isLoaded)




    isSelectedFileOnPath=any(cellfun(@(x)platformPathCompare(x,fullFileName),which('-all',FileName)));

    doTheCheck=false;
    if isSelectedFileOnPath





        if(length(filePaths)>1)
            if(~isLoaded)




                isSelectedFileFirstOnPath=platformPathCompare(filePaths{1},fullFileName);
                doTheCheck=~isSelectedFileFirstOnPath;
            else




                [~,otherFileName,otherFileExt]=fileparts(filePaths{2});
                isCancel=warnAboutPossiblePrecedenceIssue(FileName,...
                fullFileName,...
                [otherFileName,otherFileExt],...
                filePaths{2});
                if(isCancel)
                    return
                end
            end
        end
    else
        isAnyModelOnPathInCurrDir=any(cellfun(@(x)platformPathCompare(fileparts(x),pwd),filePaths));



        if~isAnyModelOnPathInCurrDir


            isCancel=resolvePathIssueForMultipleModels(PathName,FileName);
            if(isCancel)
                return
            end
        else



            doTheCheck=true;
        end
    end

    if doTheCheck
        doTheCheckNow(isLoaded,filePaths,FileName,fullFileName);
    end
end

function doTheCheckNow(isLoaded,filePaths,FileName,fullFileName)

    if~isLoaded


        [~,otherFileName,otherFileExt]=fileparts(filePaths{1});
        DAStudio.error(SelectedFileHasLowerPrecedence,...
        FileName,fullFileName,[otherFileName,otherFileExt],...
        filePaths{1})
    else












        [~,otherFileName,otherFileExt]=fileparts(filePaths{2});
        isCancel=resolvePrecedenceIssue(FileName,...
        fullFileName,...
        [otherFileName,otherFileExt],...
        filePaths{2});
        if(isCancel)
            return
        end
    end
end

function isCancel=resolvePathIssueForAFile(PathName,FileName)

    isCancel=false;

    questDlgMsg=DAStudio.message('Simulink:SubsystemReference:SelectedSubsystemNotOnPath',fullfile(PathName,FileName));
    questDlgTitle=DAStudio.message('Simulink:SubsystemReference:SelectedSubsystemPathIssueTitle');
    addPathMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathAddCurrentSession');
    doNotAddPathMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathDoNotAdd');
    cancelMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathCancel');

    choice=questdlg(questDlgMsg,questDlgTitle,...
    addPathMsg,doNotAddPathMsg,cancelMsg,...
    cancelMsg);

    if strcmp(choice,addPathMsg)

        addpath(PathName)
    elseif strcmp(choice,cancelMsg)||isempty(choice)

        isCancel=true;
    end
end

function isCancel=warnAboutPossiblePrecedenceIssue(selFileName,...
    selFullFileName,otherFileName,otherFullFileName)





    isCancel=false;

    questDlgMsg=DAStudio.message('Simulink:modelReference:selectedFileIsLoadedWithMultipleFilesOnPath',...
    selFileName,selFullFileName,otherFileName,otherFullFileName);
    questDlgTitle=DAStudio.message('Simulink:modelReference:selectedMdlPrecedenceIssueTitle');
    continueMsg=DAStudio.message('Simulink:modelReference:selectedMdlPrecedenceIssueContinue');
    cancelMsg=DAStudio.message('Simulink:modelReference:selectedMdlPrecedenceIssueCancel');

    choice=questdlg(questDlgMsg,questDlgTitle,...
    continueMsg,cancelMsg,...
    cancelMsg);

    if strcmp(choice,cancelMsg)||isempty(choice)

        isCancel=true;
    end
end

function isCancel=resolvePathIssueForMultipleModels(PathName,FileName)







    isCancel=false;

    questDlgMsg=DAStudio.message('Simulink:modelReference:selectedMdlExistsOnPathQString',fullfile(PathName,FileName));
    questDlgTitle=DAStudio.message('Simulink:SubsystemReference:SelectedSubsystemPathIssueTitle');
    addPathMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathAddCurrentSession');
    doNotAddPathMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathDoNotAdd');
    cancelMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathCancel');

    choice=questdlg(questDlgMsg,questDlgTitle,...
    addPathMsg,doNotAddPathMsg,cancelMsg,...
    cancelMsg);

    if strcmp(choice,addPathMsg)

        addpath(PathName)
    elseif strcmp(choice,cancelMsg)||isempty(choice)

        isCancel=true;
    end
end

function isCancel=resolvePrecedenceIssue(...
    selFileName,selFullFileName,otherFileName,otherFullFileName)





    isCancel=false;

    questDlgMsg=DAStudio.message('Simulink:modelReference:selectedModelHasHigherPrecedenceTemporarily',...
    selFileName,selFullFileName,otherFileName,otherFullFileName);
    questDlgTitle=DAStudio.message('Simulink:modelReference:selectedMdlPrecedenceIssueTitle');
    continueMsg=DAStudio.message('Simulink:modelReference:selectedMdlPrecedenceIssueContinue');
    cancelMsg=DAStudio.message('Simulink:modelReference:selectedMdlPrecedenceIssueCancel');

    choice=questdlg(questDlgMsg,questDlgTitle,...
    continueMsg,cancelMsg,...
    cancelMsg);

    if strcmp(choice,cancelMsg)||isempty(choice)

        isCancel=true;
    end
end


function files=getFilesOnPathMatchingSelectedFile(fileName)
    [~,modelNameWithoutExt]=fileparts(fileName);



    filePaths=which('-all',modelNameWithoutExt);

    if slInternal('hasUnprotectedSimulinkExtension',fileName)
        filterFcn='hasUnprotectedSimulinkExtension';
    else
        filterFcn='hasProtectedSimulinkExtension';
    end

    simulinkFiles=cellfun(@(x)slInternal(filterFcn,x),filePaths);
    files=filePaths(simulinkFiles);
end

function[isLoaded,loadedModelPath]=findLoadedFile(fileName)

    [~,modelNameWithoutExt,~]=fileparts(fileName);
    loadedModelPath=[];

    loadedModel=find_system('Type','block_diagram','Name',modelNameWithoutExt);
    isLoaded=~isempty(loadedModel);
    if isLoaded

        loadedModelPath=get_param(loadedModel{1},'FileName');
    end
end


function setModelName(blockHandle,modelName)
    set_param(blockHandle,'ReferencedSubsystem',modelName);
end
