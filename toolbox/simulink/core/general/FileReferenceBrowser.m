




classdef FileReferenceBrowser



    properties(GetAccess=protected,SetAccess=private,Abstract,Dependent)
Extensions


BrowseFileRefsName
SelectedFileNotOnPathQString
SelectedFilePathIssueTitle
SelectedFileNotOnPathAddCurrentSession
SelectedFileNotOnPathDoNotAdd
SelectedFileNotOnPathCancel
SelectedFileExistsOnPathQString

SelectedFileHasLowerPrecedence
SelectedFileHasLowerPrecedenceDirty
SelectedFileHasHigherPrecedenceTemporarily
SelectedFilePrecedenceIssueTitle
SelectedFilePrecedenceIssueContinue
SelectedFilePrecedenceIssueCancel
SelectedFileIsLoadedWithMultipleFilesOnPath
    end

    methods
        function browse(obj,dialogH,tag,isSlimDialog,varargin)



            assert((nargin==4)||(nargin==7))

            if nargin==4
                extstr=obj.Extensions;
                currentFileName=dialogH.getWidgetValue(tag);
                startingLocation=obj.startingLocationForBrowseButton(currentFileName);

                dialogTitle=DAStudio.message(obj.BrowseFileRefsName);
                [FileName,PathName,FilterIndex]=obj.chooseFile(extstr,dialogTitle,startingLocation);
            else
                FileName=varargin{1};
                PathName=varargin{2};
                FilterIndex=varargin{3};
            end

            if isequal(FilterIndex,0)

                return
            end

            if isempty(dialogH)
                return
            end

            obj.postChooseFile(PathName,FileName);



            if ispc
                platformPathCompare=@strcmpi;
            else
                platformPathCompare=@strcmp;
            end

            fullFileName=fullfile(PathName,FileName);



            [isLoaded,loadedFilePath]=obj.findLoadedFile(FileName);
            if isLoaded

                isLoadedAndSelectedFileSame=platformPathCompare(loadedFilePath,fullFileName);
                if~isLoadedAndSelectedFileSame

                    if~isempty(loadedFilePath)

                        [~,otherFileName,otherFileExt]=fileparts(loadedFilePath);
                        DAStudio.error(obj.SelectedFileHasLowerPrecedence,FileName,fullFileName,[otherFileName,otherFileExt],loadedFilePath)
                    else

                        DAStudio.error(obj.SelectedFileHasLowerPrecedenceDirty,...
                        FileName,fullFileName)
                    end
                end
            end




            filePaths=obj.getFilesOnPathMatchingSelectedFile(FileName);

            if isempty(filePaths)


                isCancel=obj.resolvePathIssueForAUniqueFile(PathName,FileName);
                if(isCancel)
                    return
                end
            else




                isSelectedFileOnPath=any(cellfun(@(x)platformPathCompare(x,fullFileName),which('-all',FileName)));

                doTheCheck=false;
                if isSelectedFileOnPath





                    if(length(filePaths)>1)
                        if(~isLoaded)




                            isSelectedFileFirstOnPath=platformPathCompare(filePaths{1},fullFileName);
                            doTheCheck=~isSelectedFileFirstOnPath;
                        else




                            [~,otherFileName,otherFileExt]=fileparts(filePaths{2});
                            isCancel=obj.warnAboutPossiblePrecedenceIssue(FileName,...
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


                        isCancel=obj.resolvePathIssueForMultipleModels(PathName,FileName);
                        if(isCancel)
                            return
                        end
                    else



                        doTheCheck=true;
                    end
                end

                if doTheCheck
                    if~isLoaded


                        [~,otherFileName,otherFileExt]=fileparts(filePaths{1});
                        DAStudio.error(obj.SelectedFileHasLowerPrecedence,...
                        FileName,fullFileName,[otherFileName,otherFileExt],...
                        filePaths{1})
                    else












                        [~,otherFileName,otherFileExt]=fileparts(filePaths{2});
                        isCancel=obj.resolvePrecedenceIssue(FileName,...
                        fullFileName,...
                        [otherFileName,otherFileExt],...
                        filePaths{2});
                        if(isCancel)
                            return
                        end
                    end
                end
            end


            value=obj.getValueForWidget(FileName);

            if isSlimDialog
                set_param(dialogH.getDialogSource.getBlock.Handle,tag,value);
            else
                dialogH.setWidgetValue(tag,value);
            end
        end
    end

    methods(Access=protected)
        function isCancel=resolvePathIssueForAUniqueFile(obj,PathName,FileName)





            isCancel=false;

            questDlgMsg=DAStudio.message(obj.SelectedFileNotOnPathQString,fullfile(PathName,FileName));
            questDlgTitle=DAStudio.message(obj.SelectedFilePathIssueTitle);
            addPathMsg=DAStudio.message(obj.SelectedFileNotOnPathAddCurrentSession);
            doNotAddPathMsg=DAStudio.message(obj.SelectedFileNotOnPathDoNotAdd);
            cancelMsg=DAStudio.message(obj.SelectedFileNotOnPathCancel);

            choice=questdlg(questDlgMsg,questDlgTitle,...
            addPathMsg,doNotAddPathMsg,cancelMsg,...
            cancelMsg);

            if strcmp(choice,addPathMsg)

                addpath(PathName)
            elseif strcmp(choice,cancelMsg)||isempty(choice)

                isCancel=true;
            end
        end

        function isCancel=resolvePathIssueForMultipleModels(obj,PathName,FileName)







            isCancel=false;

            questDlgMsg=DAStudio.message(obj.SelectedFileExistsOnPathQString,fullfile(PathName,FileName));
            questDlgTitle=DAStudio.message(obj.SelectedFilePathIssueTitle);
            addPathMsg=DAStudio.message(obj.SelectedFileNotOnPathAddCurrentSession);
            doNotAddPathMsg=DAStudio.message(obj.SelectedFileNotOnPathDoNotAdd);
            cancelMsg=DAStudio.message(obj.SelectedFileNotOnPathCancel);

            choice=questdlg(questDlgMsg,questDlgTitle,...
            addPathMsg,doNotAddPathMsg,cancelMsg,...
            cancelMsg);

            if strcmp(choice,addPathMsg)

                addpath(PathName)
            elseif strcmp(choice,cancelMsg)||isempty(choice)

                isCancel=true;
            end
        end

        function isCancel=resolvePrecedenceIssue(obj,...
            selFileName,selFullFileName,otherFileName,otherFullFileName)





            isCancel=false;

            questDlgMsg=DAStudio.message(obj.SelectedFileHasHigherPrecedenceTemporarily,...
            selFileName,selFullFileName,otherFileName,otherFullFileName);
            questDlgTitle=DAStudio.message(obj.SelectedFilePrecedenceIssueTitle);
            continueMsg=DAStudio.message(obj.SelectedFilePrecedenceIssueContinue);
            cancelMsg=DAStudio.message(obj.SelectedFilePrecedenceIssueCancel);

            choice=questdlg(questDlgMsg,questDlgTitle,...
            continueMsg,cancelMsg,...
            cancelMsg);

            if strcmp(choice,cancelMsg)||isempty(choice)

                isCancel=true;
            end
        end




        function isCancel=warnAboutPossiblePrecedenceIssue(obj,...
            selFileName,selFullFileName,otherFileName,otherFullFileName)





            isCancel=false;

            questDlgMsg=DAStudio.message(obj.SelectedFileIsLoadedWithMultipleFilesOnPath,...
            selFileName,selFullFileName,otherFileName,otherFullFileName);
            questDlgTitle=DAStudio.message(obj.SelectedFilePrecedenceIssueTitle);
            continueMsg=DAStudio.message(obj.SelectedFilePrecedenceIssueContinue);
            cancelMsg=DAStudio.message(obj.SelectedFilePrecedenceIssueCancel);

            choice=questdlg(questDlgMsg,questDlgTitle,...
            continueMsg,cancelMsg,...
            cancelMsg);

            if strcmp(choice,cancelMsg)||isempty(choice)

                isCancel=true;
            end
        end
    end

    methods(Access=protected,Abstract)
        startingLocation=startingLocationForBrowseButton(obj,currentFileName)





        [fileName,pathName,filterIndex]=chooseFile(obj,extstr,dialogTitle,startingLocation);





        postChooseFile(obj,pathName,fileName)






        [isLoaded,loadedFilePath]=findLoadedFile(obj,fileName)







        value=getValueForWidget(obj,fileName)






        files=getFilesOnPathMatchingSelectedFile(obj,fileName)




    end

end

