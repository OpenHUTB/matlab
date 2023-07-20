
classdef BatchProcessorGUI<handle&matlab.mixin.SetGetExactNames


    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)
AppName


App


ImageBatchDS


        DataBrowserFigPanel=[];
        DataBrowserFigHandle=[];


        InputImageDocumentGroup=[];
        OutputImageDocumentGroup=[];
        InputImageFigDocument=[];
        InputImageHandle=[];









        OutputImageFigDocList=table.empty();



        ResultsFigPanel=[];




        ResultsFigPanelFigHandle=[];





        ResultsDisplayUIPanel=[];



ImageResultsShowBtn


        AppStatusBar=[];
        ProgressStatusBar=[];
        ProgressStatusLabel=[];




        LeftBottomStatusLabel=[];


TabGroup
MainTab


ImportSection
ImportButton


BatchFunctionSection
BatchFunctionNameDropDown
BatchFunctionCreateButton
BatchFunctionOpenInEditorButton
BatchFunctionOpenButton


ParallelSection
ProcessInParallelLabel
ProcessInParallelToggleButton


ProcessPanel
ProcessSection
ProcessStartButton
ProcessStopButton


LinkAxesSection
LinkAxesCheckBox


LayoutSection
DefaultLayoutButton


ExportSection
ExportButton


ImportImagesDlg
ToWkspaceDlg
FileExportDlg
GenFcnDlg



        ImageStrip=[];
        ImageStripImageChangedListener;
    end


    properties(Access=private)

BatchFunctionName
BatchFunctionFullFile
BatchFunctionHandle
BatchProcessorObj


        BatchFcnCreatedDocs=[];



        BatchFcnCreatedSaveTimer;


        CurrAppState='notReady';
        SelectedImgInds=[];
        IsCurrentlyProcessing=false;
        IsCurrentlyClosing=false;
        IsStopRequested=false;




        IsImageImportDone=true;

        NumTodoImages=0;
        NumQueuedImages=0;
        NumSuccessfulImages=0;
        NumErroredImages=0;

        SettingsObj;
        MaxMemory=5;
        TemporaryResultsFolder;

        IsResultsExistToExport=false;
        IsExistUnexportedResults=false;
        LastProcessedIdx=[];






        FieldsSelectedForWS={};



        IsFileNameFieldSelected=false;






        FieldsSelectedForFileSave=table.empty();


        FileSaveOutputDir='';
    end

    properties(Access=private,Constant)
        InputImageDocumentGroupTag='InputImageDocumentGroupTag';
        OutputImageDocumentGroupTag='OutputImageDocumentGroupTag';




        LeftRightPanelWidthPct=0.25;


        MinFigSizeForResize=30;
    end

    properties(Access=public)




        IsPopupConfirmDialogUponShutdown=true;
    end


    methods
        function tool=BatchProcessorGUI()


            narginchk(0,2);

            imageslib.internal.apputil.manageToolInstances('add','imageBatchProcessor',tool);
            tool.SettingsObj=settings;




            tool.AppName=getString(message('images:imageBatchProcessor:appName'));


            appOptions.Product="Image Processing Toolbox";
            appOptions.Scope=getString(message('images:imageBatchProcessor:appName'));
            appOptions.Title=getString(message('images:imageBatchProcessor:appName'));
            appOptions.Icon=fullfile(matlabroot,'toolbox','images','icons','imageBatchProcessor_AppIcon_24.png');
            tool.App=matlab.ui.container.internal.AppContainer(appOptions);



            tool.TabGroup=matlab.ui.internal.toolstrip.TabGroup();
            tool.TabGroup.Tag='GlobalToolstripTag';
            tool.App.add(tool.TabGroup);



            tool.MainTab=matlab.ui.internal.toolstrip.Tab(...
            getString(message('images:imageBatchProcessor:mainTabName')));
            tool.MainTab.Tag='MainTab';
            tool.TabGroup.add(tool.MainTab);

            tool.App.CanCloseFcn=@tool.userClosed;


            tool.ImportSection=tool.MainTab.addSection(...
            getString(message('images:imageBatchProcessor:importSectionLabel')));
            tool.ImportSection.Tag='Import';
            tool.layoutImportSection();


            tool.BatchFunctionSection=tool.MainTab.addSection(...
            getString(message('images:imageBatchProcessor:batchFunctionSectionLabel')));
            tool.BatchFunctionSection.Tag='BatchFunction';
            tool.layoutBatchFunctionSection();



            tool.BatchFcnCreatedSaveTimer=timer('Name','BatchFcnCreatedSaveTimer',...
            'TimerFcn',@(~,~)checkIfUserBatchFunctionWasSaved(tool),...
            'ObjectVisibility','off',...
            'Period',2,...
            'ExecutionMode','fixedSpacing');


            if matlab.internal.parallel.isPCTInstalled()
                tool.ParallelSection=tool.MainTab.addSection(...
                getString(message('images:imageBatchProcessor:processInParallelLabel')));
                tool.ParallelSection.Tag='Parallel';
                tool.layoutParallelSection();
            else
                tool.ProcessInParallelToggleButton.Value=false;
            end


            tool.ProcessSection=tool.MainTab.addSection(...
            getString(message('images:imageBatchProcessor:processSectionLabel')));
            tool.ProcessSection.Tag='Process';
            tool.layoutProcessSection();


            tool.LinkAxesSection=tool.MainTab.addSection(...
            getString(message('images:imageBatchProcessor:linkAxes')));
            tool.LinkAxesSection.Tag='Zoom';
            tool.layoutLinkAxesSection();


            tool.LayoutSection=tool.MainTab.addSection(...
            getString(message('images:commonUIString:layout')));
            tool.LayoutSection.Tag='Layout';
            tool.layoutLayoutSection();


            tool.ExportSection=tool.MainTab.addSection(...
            getString(message('images:imageBatchProcessor:exportSectionLabel')));
            tool.ExportSection.Tag='Export';
            tool.layoutExportSection();




            tool.AppStatusBar=matlab.ui.internal.statusbar.StatusBar();
            tool.AppStatusBar.Tag="AppStatusBar";
            tool.App.add(tool.AppStatusBar);




            tool.ProgressStatusBar=matlab.ui.internal.statusbar.StatusProgressBar();
            tool.ProgressStatusBar.Tag='progressLabel';
            tool.ProgressStatusBar.Region='right';
            tool.ProgressStatusBar.Value=0;
            tool.App.add(tool.ProgressStatusBar);



            progressBarAnimation=matlab.ui.container.internal.appcontainer.ContextDefinition();
            progressBarAnimation.Tag="progressBarAnimation";
            progressBarAnimation.StatusComponentTags={tool.ProgressStatusBar.Tag};

            tool.ProgressStatusLabel=matlab.ui.internal.statusbar.StatusLabel();
            tool.ProgressStatusLabel.Tag='progressStatusLabel';
            tool.ProgressStatusLabel.Region='right';
            tool.ProgressStatusLabel.Text='Status Label';
            tool.App.add(tool.ProgressStatusLabel);


            progressLabelAnimation=matlab.ui.container.internal.appcontainer.ContextDefinition();
            progressLabelAnimation.Tag="progressLabelAnimation";
            progressLabelAnimation.StatusComponentTags={tool.ProgressStatusLabel.Tag};



            tool.LeftBottomStatusLabel=matlab.ui.internal.statusbar.StatusLabel();
            tool.LeftBottomStatusLabel.Tag='leftBottomStatusLabel';
            tool.LeftBottomStatusLabel.Region='left';
            tool.LeftBottomStatusLabel.Text='';
            tool.App.add(tool.LeftBottomStatusLabel);



            imagesLoadAnimation=matlab.ui.container.internal.appcontainer.ContextDefinition();
            imagesLoadAnimation.Tag="imagesLoadAnimation";
            imagesLoadAnimation.StatusComponentTags=tool.LeftBottomStatusLabel.Tag;



            parallelPoolAnimation=matlab.ui.container.internal.appcontainer.ContextDefinition();
            parallelPoolAnimation.Tag="parallelPoolAnimation";
            parallelPoolAnimation.StatusComponentTags=tool.LeftBottomStatusLabel.Tag;

            tool.App.Contexts={progressBarAnimation,...
            progressLabelAnimation,...
            imagesLoadAnimation,...
            parallelPoolAnimation};

            imageslib.internal.app.utilities.ScreenUtilities.setInitialToolPosition(tool.App);






            qabbtn=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            qabbtn.ButtonPushedFcn=@(varargin)doc('imageBatchProcessor');
            tool.App.add(qabbtn);


            tool.TemporaryResultsFolder=tempname;
            tool.createDirOrDie(tool.TemporaryResultsFolder);




            tool.OutputImageFigDocList=table('Size',[0,2],...
            'VariableTypes',{'matlab.ui.internal.FigureDocument',...
            'matlab.graphics.GraphicsPlaceholder'},...
            'VariableNames',{'FigDocHandle','OutputImageHandle'});

            tool.setState('notReady');

            tool.App.Visible=true;



            if tool.App.State~=...
                matlab.ui.container.internal.appcontainer.AppState.RUNNING
                waitfor(tool.App,'State');
            end

            if~isvalid(tool.App)||...
                tool.App.State==...
                matlab.ui.container.internal.appcontainer.AppState.TERMINATED
                return;
            end
        end

        function importImages(tool,pathToImageDir,isRecurse)



            tool.importImagesFromFolder(pathToImageDir,isRecurse,false);
        end

        function setBatchFunction(tool,fullFunctionFileName)
            assert(exist(fullFunctionFileName,'file')==2);
            [~,fileName]=fileparts(fullFunctionFileName);
            tool.tryToUpdateBatchFunction(fullFunctionFileName,fileName);
        end

        function delete(tool)
            imageslib.internal.apputil.manageToolInstances('remove','imageBatchProcessor',tool);
            tool.IsCurrentlyClosing=true;
            tool.cleanUpTemporaryResults();

            tool.cleanupAppComponents()

            delete(tool.App);
        end

    end


    methods(Access=private)
        function createDirOrDie(tool,newDirName)
            [dirCreated,creationMessage]=mkdir(newDirName);
            if(~dirCreated)

                tool.delete();
                error(message('images:imageBatchProcessor:unableToCreateDir',...
                newDirName,...
                creationMessage));
            end
        end

        function tf=userClosed(tool,varargin)



            tf=true;
            if~isvalid(tool)


                return;
            end



            if~tool.IsImageImportDone
                tf=false;
                return;
            end

            tf=tool.checkAndClose();
        end

        function canClose=checkAndClose(tool,varargin)
            if~isvalid(tool)||tool.IsCurrentlyClosing


                canClose=true;
            else


                if tool.IsCurrentlyProcessing
                    if tool.IsPopupConfirmDialogUponShutdown
                        noStr=getString(message('images:commonUIString:no'));
                        yesStr=getString(message('images:commonUIString:yes'));

                        selectedStr=uiconfirm(tool.App,...
                        getString(message('images:imageBatchProcessor:closeWhenRunning')),...
                        getString(message('images:imageBatchProcessor:closeWhenRunningTitle')),...
                        'Options',{yesStr,noStr},...
                        'DefaultOption',yesStr,...
                        'CancelOption',noStr);


                        canClose=~strcmp(selectedStr,noStr);
                    else
                        canClose=true;
                    end





                    if canClose
                        tool.stopProcessing();
                    end
                else






                    canClose=tool.unexportedResultsDialog();
                end
            end

            if canClose

                tool.cleanupAppComponents();



                tool.IsCurrentlyClosing=true;


                imageslib.internal.apputil.manageToolInstances('remove','imageBatchProcessor',tool);
            end
        end

        function canContinue=unexportedResultsDialog(tool)
            canContinue=true;
            if tool.IsExistUnexportedResults
                noStr=getString(message('images:commonUIString:no'));
                yesStr=getString(message('images:commonUIString:yes'));
                selectedStr=uiconfirm(tool.App,...
                getString(message('images:imageBatchProcessor:unexportedResults')),...
                getString(message('images:imageBatchProcessor:unexportedResultsTitle')),...
                'Options',{yesStr,noStr},...
                'DefaultOption',yesStr,...
                'CancelOption',noStr);
                canContinue=strcmpi(selectedStr,yesStr);
            end
        end

        function cleanUpTemporaryResults(tool)
            if isempty(tool.TemporaryResultsFolder)
                return;
            end
            [isCleanedUp,failMessage]=rmdir(tool.TemporaryResultsFolder,'s');
            if~isCleanedUp
                warning(message('images:imageBatchProcessor:failedToCleanUp',...
                tool.TemporaryResultsFolder,...
                failMessage));
            end
        end

        function cleanupAppComponents(tool)
            delete(tool.ImageStrip);


            if isvalid(tool.BatchFcnCreatedSaveTimer)
                stop(tool.BatchFcnCreatedSaveTimer);
                delete(tool.BatchFcnCreatedSaveTimer);
            end
        end
    end




    methods(Access=private)
        function layoutImportSection(tool)
            import matlab.ui.internal.toolstrip.*



            loadSectionColumn=tool.ImportSection.addColumn();

            tool.ImportButton=Button(...
            getString(message('images:imageBatchProcessor:importButtonText')),...
            Icon.IMPORT_24);
            tool.ImportButton.Tag='ImportButton';


            tool.ImportButton.Description=...
            getString(message('images:imageBatchProcessor:importButtonTextToolTip'));

            addlistener(tool.ImportButton,'ButtonPushed',@tool.importFolder);

            loadSectionColumn.add(tool.ImportButton);
        end

        function importFolder(tool,varargin)
            previousLocations=tool.SettingsObj.images.imagebatchprocessingtool.BatchLocations.ActiveValue;






            if isempty(previousLocations)||isempty(previousLocations{1})
                folderAbsolutePath=pwd;
            else

                folderAbsolutePath=previousLocations{1};
            end

            tool.importImagesFromFolder(folderAbsolutePath,...
            true,...
            true);
        end
    end


    methods(Access=private)
        function layoutBatchFunctionSection(tool)
            import matlab.ui.internal.toolstrip.*








            batchFunctionSelectionColumn=tool.BatchFunctionSection.addColumn();


            dummyLabel=Label('');
            batchFunctionSelectionColumn.add(dummyLabel);


            batchLabel=Label(getString(message('images:imageBatchProcessor:batchFunctionLabel')));
            batchFunctionSelectionColumn.add(batchLabel);


            tool.BatchFunctionNameDropDown=DropDown();
            tool.BatchFunctionNameDropDown.Tag='BatchFunctionName';
            tool.BatchFunctionNameDropDown.Editable=true;

            tool.BatchFunctionNameDropDown.ValueChangedFcn=@tool.batchNameInTextBoxChanged;

            batchFunctionSelectionColumn.add(tool.BatchFunctionNameDropDown);


            batchFunctionCreateOpenColumn=tool.BatchFunctionSection.addColumn();


            tool.BatchFunctionCreateButton=Button(...
            getString(message('images:imageBatchProcessor:createLabel')),...
            Icon.ADD_16);
            tool.BatchFunctionCreateButton.Tag='CreateBatchFunctionButton';


            tool.BatchFunctionCreateButton.Description=...
            getString(message('images:imageBatchProcessor:createToolTip'));

            addlistener(tool.BatchFunctionCreateButton,'ButtonPushed',...
            @tool.createBatchFunctionInEditor);

            batchFunctionCreateOpenColumn.add(tool.BatchFunctionCreateButton);


            tool.BatchFunctionOpenInEditorButton=Button(...
            getString(message('images:imageBatchProcessor:openInEditorLabel')),...
            images.internal.app.Icon.EDIT_16);
            tool.BatchFunctionOpenInEditorButton.Tag='OpenInEditorButton';


            tool.BatchFunctionOpenInEditorButton.Description=...
            getString(message('images:imageBatchProcessor:openInEditorToolTip'));

            addlistener(tool.BatchFunctionOpenInEditorButton,'ButtonPushed',...
            @tool.openBatchFunctionInEditor);

            batchFunctionCreateOpenColumn.add(tool.BatchFunctionOpenInEditorButton);


            tool.BatchFunctionOpenButton=Button(...
            getString(message('images:imageBatchProcessor:batchFunctionOpenLabel')),...
            Icon.OPEN_16);
            tool.BatchFunctionOpenButton.Tag='FunctionOpenButton';


            tool.BatchFunctionOpenButton.Description=...
            getString(message('images:imageBatchProcessor:batchFunctionOpenAddToolTip'));

            addlistener(tool.BatchFunctionOpenButton,'ButtonPushed',...
            @tool.batchFileOpen);

            batchFunctionCreateOpenColumn.add(tool.BatchFunctionOpenButton);


            tool.updateBatchFunctionDropDownFromHistory();
        end

        function batchNameInTextBoxChanged(tool,varargin)
            selectedText=tool.BatchFunctionNameDropDown.Value;

            if~tool.unexportedResultsDialog()

                tool.batchFunctionInvalid(selectedText);
                return;
            end

            if strcmp(selectedText,...
                getString(message('images:imageBatchProcessor:batchFunctionInitialText')))

                return;
            end

            if any(filesep==selectedText)

                fullFcnFile=selectedText;

                [~,fileName]=fileparts(fullFcnFile);
            else
                fileName=selectedText;
                fullFcnFile=tool.findPathGivenFunctionFileName(fileName);
            end

            tool.tryToUpdateBatchFunction(fullFcnFile,fileName);
        end

        function fullFcnFile=findPathGivenFunctionFileName(tool,fileName)
            fullFcnFile='';


            fullFcnPaths=tool.SettingsObj.images.imagebatchprocessingtool.BatchFunctions.ActiveValue;
            for ind=numel(fullFcnPaths):-1:1
                [~,rFileName]=fileparts(fullFcnPaths{ind});
                if strcmp(fileName,rFileName)
                    fullFcnFile=fullFcnPaths{ind};
                    break;
                end
            end



            if isempty(fullFcnFile)

                try
                    fullFcnFile=which(fileName);
                catch ALL %#ok<NASGU>

                    fullFcnFile='';
                end

                if isempty(fullFcnFile)

                    fullFcnFile=fileName;
                end
            end
        end

        function batchFileOpen(tool,varargin)
            if~tool.unexportedResultsDialog()
                return;
            end
            [fileName,filePath]=uigetfile('*.m',...
            getString(message('images:imageBatchProcessor:selectBatchFunction')));
            if fileName==0
                return;
            end
            tool.tryToUpdateBatchFunction(fullfile(filePath,fileName),fileName);
        end

        function tryToUpdateBatchFunction(tool,fullFcnFile,fileName)
            if~tool.isBatchFunctionValid(fullFcnFile,fileName)
                return;
            end
            tool.validBatchFunctionPathDefined(fullFcnFile);
        end







        function isValid=isBatchFunctionValid(tool,fullFcnFile,fileName)

            isValid=false;

            [fcnPath,localFileName,fcnExt]=fileparts(fullFcnFile);
            if nargin==2
                fileName=localFileName;
            end

            if~strcmpi(fcnExt,'.m')||~exist(fullFcnFile,'file')
                if~tool.App.Visible
                    figHandle=uifigure;
                else
                    figHandle=tool.App;
                end

                if strcmpi(fcnExt,'.mlx')
                    uialert(figHandle,...
                    getString(message('images:imageBatchProcessor:mlxUnsupported',fullFcnFile)),...
                    getString(message('images:imageBatchProcessor:mlxUnsupportedTitle')),...
                    'Icon','error');
                else
                    uialert(figHandle,...
                    getString(message('images:imageBatchProcessor:invalidFunctionFile',fullFcnFile)),...
                    getString(message('images:imageBatchProcessor:invalidFunctionFileTitle')),...
                    'Icon','error');
                end

                if~tool.App.Visible
                    close(figHandle);
                end

                tool.batchFunctionInvalid(fullFcnFile);
                return;
            end



            fid=fopen(fullFcnFile,'r');
            closeFile=onCleanup(@()fclose(fid));
            fullFcnFile=fopen(fid);
            clear closeFile;

            if isempty(fcnPath)
                if~tool.App.Visible
                    figHandle=uifigure;
                else
                    figHandle=tool.App;
                end
                uialert(figHandle,...
                getString(message('images:imageBatchProcessor:pathNotFoundError',fullFcnFile)),...
                getString(message('images:imageBatchProcessor:pathNotFoundTitle')),...
                'Icon','error');

                if~tool.App.Visible
                    close(figHandle);
                end

                tool.batchFunctionInvalid(fullFcnFile);
                return;
            end


            whichPath=which(fileName);

            if isempty(whichPath)

                cancelStr=getString(message('images:commonUIString:cancel'));
                addToPathStr=getString(message('images:imageBatchProcessor:addToPath'));
                cdStr=getString(message('images:imageBatchProcessor:cdFolder'));

                if~tool.App.Visible
                    figHandle=uifigure;
                else
                    figHandle=tool.App;
                end
                selectedStr=uiconfirm(figHandle,...
                getString(message('images:imageBatchProcessor:notOnPathQuestion',fcnPath)),...
                getString(message('images:imageBatchProcessor:notOnPathTitle')),...
                'Options',{cdStr,addToPathStr,cancelStr},...
                'DefaultOption',cdStr,...
                'CancelOption',cancelStr);

                if~tool.App.Visible
                    close(figHandle);
                end

                switch selectedStr
                case cdStr
                    cd(fcnPath);
                case addToPathStr
                    addpath(fcnPath);
                otherwise

                    tool.batchFunctionInvalid(fullFcnFile);
                    return
                end
            elseif~strcmpi(whichPath,fullFcnFile)

                if~tool.App.Visible
                    figHandle=uifigure;
                else
                    figHandle=tool.App;
                end

                uialert(figHandle,...
                getString(message('images:imageBatchProcessor:nameClash',fileName,whichPath)),...
                getString(message('images:imageBatchProcessor:nameClashTitle')),...
                'Icon','error');

                if~tool.App.Visible
                    close(figHandle);
                end

                tool.batchFunctionInvalid(fullFcnFile);
                return;
            end


            isValid=true;
        end

        function validBatchFunctionPathDefined(tool,fullFcnFile)
            [~,fcnName]=fileparts(fullFcnFile);

            if(strcmpi(fullFcnFile,tool.BatchFunctionFullFile)...
                &&strcmpi(fcnName,tool.BatchFunctionNameDropDown.Value))

                return;
            end

            tool.BatchFunctionFullFile=fullFcnFile;
            tool.BatchFunctionName=fcnName;

            tool.BatchFunctionHandle=str2func(tool.BatchFunctionName);

            tool.rememberBatchFunction();
            tool.updateBatchFunctionDropDownFromHistory();









            try
                numOutArgs=nargout(fcnName);
                if numOutArgs~=1
                    if tool.App.Visible
                        uialert(tool.App,...
                        getString(message('images:imageBatchProcessor:batchFcnIncorrectNumOutputArgsMessage')),...
                        getString(message('images:imageBatchProcessor:batchFcnIncorrectNumOutputArgs')),...
                        'Icon','warning');
                    end
                end
            catch ME



            end



            tool.refreshStateOnFunctionChange();


            tool.FieldsSelectedForWS={};
            tool.FieldsSelectedForFileSave=table.empty();

            tool.setReadyIfPossible();
        end

        function rememberBatchFunction(tool)
            fullFcnPaths=tool.SettingsObj.images.imagebatchprocessingtool.BatchFunctions.ActiveValue;
            if(isempty(fullFcnPaths)||isempty(fullFcnPaths{1}))
                fullFcnPaths={};
            end

            inds=strcmp(tool.BatchFunctionFullFile,fullFcnPaths);
            if(any(inds))

                fullFcnPaths=[{tool.BatchFunctionFullFile},fullFcnPaths];
                lind=find(inds);
                fullFcnPaths(lind+1)=[];
            else

                numNewFunctions=min(tool.MaxMemory,numel(fullFcnPaths)+1);
                newFunctions=cell(1,numNewFunctions);
                newFunctions(1:numel(fullFcnPaths))=fullFcnPaths;

                newFunctions(2:end)=newFunctions(1:end-1);
                newFunctions{1}=tool.BatchFunctionFullFile;
                fullFcnPaths=newFunctions;
            end
            curMemory=min(tool.MaxMemory,numel(fullFcnPaths));
            functionNamesToSave=fullFcnPaths(1:curMemory);
            tool.SettingsObj.images.imagebatchprocessingtool.BatchFunctions.PersonalValue=functionNamesToSave;
        end

        function updateBatchFunctionDropDownFromHistory(tool)
            functionNames=tool.SettingsObj.images.imagebatchprocessingtool.BatchFunctions.ActiveValue;

            if(isempty(functionNames)||isempty(functionNames{1}))

                if isempty(tool.BatchFunctionNameDropDown.Items)
                    tool.BatchFunctionNameDropDown.addItem(...
                    getString(message('images:imageBatchProcessor:batchFunctionInitialText')));
                    tool.BatchFunctionNameDropDown.SelectedIndex=1;
                else





                    tool.BatchFunctionNameDropDown.Value='';
                end
                tool.BatchFunctionNameDropDown.Description=...
                getString(message('images:imageBatchProcessor:batchFunctionNameToolTip'));
            else

                itemsInDropDown=cell(numel(functionNames),2);
                for ind=1:numel(functionNames)
                    [~,fcnName]=fileparts(functionNames{ind});
                    itemsInDropDown(ind,:)={fcnName,fcnName};
                end

                tool.BatchFunctionNameDropDown.replaceAllItems(itemsInDropDown);

                tool.BatchFunctionNameDropDown.SelectedIndex=1;
                tool.BatchFunctionNameDropDown.Description=functionNames{1};
                tool.BatchFunctionOpenInEditorButton.Enabled=true;

                if tool.isBatchFunctionValid(functionNames{1})
                    tool.validBatchFunctionPathDefined(functionNames{1});
                end
            end
        end

        function batchFunctionInvalid(tool,fullFcnFile)

            previousFunctions=tool.SettingsObj.images.imagebatchprocessingtool.BatchFunctions.ActiveValue;
            badIndex=strcmp(fullFcnFile,previousFunctions);
            previousFunctions(badIndex)=[];
            tool.SettingsObj.images.imagebatchprocessingtool.BatchFunctions.PersonalValue=previousFunctions;




            if isempty(previousFunctions)||...
                (numel(previousFunctions)==1&&isempty(previousFunctions{1}))
                tool.BatchFunctionNameDropDown.replaceAllItems({});
            end

            tool.updateBatchFunctionDropDownFromHistory();



            drawnow;
        end

        function createBatchFunctionInEditor(tool,varargin)
            if~tool.unexportedResultsDialog()
                return;
            end
            templateFile=fullfile(matlabroot,'toolbox','images',...
            'imuitools','+images','+internal',...
            '+app','+batchProcessor',...
            'userBatchFunction.template');
            codeString=fileread(templateFile);



            if isempty(tool.BatchFcnCreatedDocs)
                tool.BatchFcnCreatedDocs=...
                matlab.desktop.editor.newDocument(codeString);
            else
                tool.BatchFcnCreatedDocs(end+1)=...
                matlab.desktop.editor.newDocument(codeString);
            end


            if~strcmpi(tool.BatchFcnCreatedSaveTimer.Running,'on')
                start(tool.BatchFcnCreatedSaveTimer);
            end
        end

        function checkIfUserBatchFunctionWasSaved(tool)

            if isvalid(tool)&&~isempty(tool.BatchFcnCreatedDocs)


                docsOpened=[tool.BatchFcnCreatedDocs.Opened];
                tool.BatchFcnCreatedDocs=tool.BatchFcnCreatedDocs(docsOpened);











                if isempty(tool.BatchFcnCreatedDocs)
                    tool.doAfterAllCreatedDocsClosed();
                    return;
                end



                isDocsSaved=~[tool.BatchFcnCreatedDocs.Modified];



                fileNamesSaved={tool.BatchFcnCreatedDocs(isDocsSaved).Filename};
                for cnt=1:numel(fileNamesSaved)
                    fullFcnPath=fileNamesSaved{cnt};
                    [~,fileName]=fileparts(fullFcnPath);
                    tool.tryToUpdateBatchFunction(fullFcnPath,fileName);
                end





                tool.BatchFcnCreatedDocs=tool.BatchFcnCreatedDocs(~isDocsSaved);



                tool.BatchFunctionNameDropDown.Enabled=false;


                tool.BatchFunctionNameDropDown.Description=...
                getString(message('images:imageBatchProcessor:saveGeneratedUserBatchCode'));
            else


                tool.doAfterAllCreatedDocsClosed();
            end
        end

        function doAfterAllCreatedDocsClosed(tool)


            tool.BatchFunctionNameDropDown.Enabled=true;

            tool.BatchFcnCreatedDocs=[];



            if isvalid(tool.BatchFcnCreatedSaveTimer)
                stop(tool.BatchFcnCreatedSaveTimer);
            end

            tool.updateBatchFunctionDropDownFromHistory();
        end

        function openBatchFunctionInEditor(tool,varargin)
            matlab.desktop.editor.openDocument(tool.BatchFunctionFullFile);
        end
    end


    methods(Access=private)
        function layoutParallelSection(tool)
            import matlab.ui.internal.toolstrip.*;




            parallelSectionColumn=tool.ParallelSection.addColumn();

            parallelIcon=Icon(fullfile(matlabroot,'toolbox/images/icons/desktop_parallel_large.png'));
            tool.ProcessInParallelToggleButton=ToggleButton(...
            getString(message('images:imageBatchProcessor:useParallelLabel')),...
            parallelIcon);
            tool.ProcessInParallelToggleButton.Tag='ParallelModeToggleButton';

            tool.ProcessInParallelToggleButton.Description=...
            getString(message('images:imageBatchProcessor:processInParallelToolTip'));

            tool.ProcessInParallelToggleButton.Enabled=false;
            addlistener(tool.ProcessInParallelToggleButton,'ValueChanged',...
            @tool.toggleParallelProcessing);

            parallelSectionColumn.add(tool.ProcessInParallelToggleButton);
        end

        function toggleParallelProcessing(tool,varargin)
            if tool.ProcessInParallelToggleButton.Value


                prevDefLayoutButtonStatus=tool.DefaultLayoutButton.Enabled;
                prevAppState=tool.CurrAppState;
                tool.setState('locked');

                poolStatus=getString(message('images:imageBatchProcessor:connectingToPoolStatus'));
                tool.LeftBottomStatusLabel.Text=poolStatus;
                tool.updateActiveContexts("parallelPoolAnimation");

                tool.ProcessInParallelToggleButton.Text=...
                getString(message('images:imageBatchProcessor:connecting'));

                ppool=tool.connectToALocalCluster();

                if isempty(ppool)

                    tool.ProcessInParallelToggleButton.Value=false;
                end

                tool.LeftBottomStatusLabel.Text='';
                tool.updateActiveContexts("parallelPoolAnimation","remove");
                unLockApp(tool,prevAppState);


                tool.DefaultLayoutButton.Enabled=prevDefLayoutButtonStatus;
            end


            if~isempty(tool.BatchProcessorObj)
                tool.BatchProcessorObj.UseParallel=tool.ProcessInParallelToggleButton.Value;
            end
        end

        function unLockApp(tool,newState)

            if isempty(gcp('nocreate'))
                tool.ProcessInParallelToggleButton.Value=false;
            end

            tool.ProcessInParallelToggleButton.Text=...
            getString(message('images:imageBatchProcessor:useParallelLabel'));
            tool.setState(newState);
        end

        function ppool=connectToALocalCluster(tool)
            ppool=gcp('nocreate');
            if(isempty(ppool))
                ppool=tool.tryToCreateLocalPool();
            else



                if(~isa(ppool,'parallel.ProcessPool'))
                    ppool=[];
                    uialert(tool.App,...
                    getString(message('images:imageBatchProcessor:poolNotLocalString')),...
                    getString(message('images:imageBatchProcessor:poolNotLocalTitle')),...
                    'Icon','error');
                end
            end
        end

        function ppool=tryToCreateLocalPool(tool)
            defaultProfile=...
            parallel.internal.settings.ProfileExpander.getClusterType(parallel.defaultProfile());

            if defaultProfile==parallel.internal.types.SchedulerType.Local

                noStr=getString(message('images:commonUIString:no'));
                yesStr=getString(message('images:commonUIString:yes'));
                selectedStr=uiconfirm(tool.App,...
                getString(message('images:imageBatchProcessor:createParallelPool')),...
                getString(message('images:imageBatchProcessor:createParallelPoolTitle')),...
                'Options',{yesStr,noStr},...
                'DefaultOption',yesStr,...
                'CancelOption',noStr);

                if strcmp(selectedStr,noStr)
                    ppool=[];
                else

                    tool.App.Busy=true;
                    ppool=parpool;
                    tool.App.Busy=false;
                    if isempty(ppool)
                        uialert(tool.App,...
                        getString(message('images:imageBatchProcessor:nopoolString')),...
                        getString(message('images:imageBatchProcessor:nopoolTitle')),...
                        'Icon','error');
                    end
                end
            else

                ppool=[];
                uialert(tool.App,...
                getString(message('images:imageBatchProcessor:profileNotLocalString',parallel.defaultProfile())),...
                getString(message('images:imageBatchProcessor:poolNotLocalTitle')),...
                'Icon','error');
            end
        end

    end


    methods(Access=private)
        function layoutProcessSection(tool)
            import matlab.ui.internal.toolstrip.*







            processStartColumn=tool.ProcessSection.addColumn();


            tool.ProcessStartButton=SplitButton(...
            getString(message('images:imageBatchProcessor:processSelectedButton')),...
            Icon.RUN_24);
            tool.ProcessStartButton.Tag='ProcessStartButton';


            tool.ProcessStartButton.Description=...
            getString(message('images:imageBatchProcessor:processSelectedToolTip'));


            addlistener(tool.ProcessStartButton,'ButtonPushed',@tool.processSelected);



            tool.ProcessStartButton.DynamicPopupFcn=@(~,~)tool.getProcessStartButtonOptions();

            processStartColumn.add(tool.ProcessStartButton);


            processStopColumn=tool.ProcessSection.addColumn();


            tool.ProcessStopButton=Button(...
            getString(message('images:imageBatchProcessor:stopButton')),...
            Icon.END_24);
            tool.ProcessStopButton.Tag='ProcessStopButton';


            tool.ProcessStopButton.Description=...
            getString(message('images:imageBatchProcessor:stopButtonToolTip'));

            addlistener(tool.ProcessStopButton,'ButtonPushed',...
            @tool.stopProcessing);

            processStopColumn.add(tool.ProcessStopButton);
        end

        function items=getProcessStartButtonOptions(tool,~,~)


            import matlab.ui.internal.toolstrip.*


            items=PopupList();



            entry=ListItem(getString(message('images:imageBatchProcessor:processSelectedDropDownEntry')),...
            Icon.RUN_16);
            entry.Description='';
            entry.ShowDescription=false;
            entry.Tag='ProcessSelectedItem';
            addlistener(entry,'ItemPushed',@tool.processSelected);
            items.add(entry);


            entry=ListItem(getString(message('images:imageBatchProcessor:processAllButton')),...
            Icon.RUN_16);
            entry.Description='';
            entry.ShowDescription=false;
            entry.Tag='ProcessAllItem';
            addlistener(entry,'ItemPushed',@tool.processAll);
            items.add(entry);
        end

        function processSelected(tool,varargin)
            tool.processDelegate(tool.SelectedImgInds,"selected");
        end

        function processAll(tool,varargin)
            tool.processDelegate(1:tool.ImageBatchDS.NumImages,"all");
        end

        function processDelegate(tool,processInds,processType)
            if tool.IsCurrentlyProcessing||tool.IsStopRequested

                return;
            end

            if tool.ProcessInParallelToggleButton.Value

                if isempty(tool.connectToALocalCluster())
                    tool.ProcessInParallelToggleButton.Value=false;
                    return;
                end
            end

            if processType=="all"
                tool.ProcessStartButton.Text=...
                getString(message('images:imageBatchProcessor:processAllButton'));
            end

            delegateOc=onCleanup(@()processStartBtnTxtRestoreFcn(tool,processType));

            function processStartBtnTxtRestoreFcn(tool,pType)
                if~isvalid(tool)||tool.IsCurrentlyClosing
                    return;
                end

                if pType=="all"
                    tool.ProcessStartButton.Text=...
                    getString(message('images:imageBatchProcessor:processSelectedButton'));
                end
            end

            tool.ImageBatchDS.WriteLocation=...
            tool.TemporaryResultsFolder;

            tool.IsCurrentlyProcessing=true;
            tool.setState('processing');

            tool.NumTodoImages=numel(processInds);

            tool.NumQueuedImages=0;
            tool.NumSuccessfulImages=0;
            tool.NumErroredImages=0;

            tool.indicateProgress();

            tool.BatchProcessorObj.UseParallel=...
            tool.ProcessInParallelToggleButton.Value;



            tool.ImageStrip.updateBadge(processInds,"waiting");

            try


                setDoneWhenDone=onCleanup(@()tool.doneProcessing);
                tool.BatchProcessorObj.processSelected(processInds);




                clear setDoneWhenDone;
            catch ALL

                rethrow(ALL);
            end
        end

        function doneProcessing(tool)
            if~isvalid(tool)

                return;
            end

            if tool.NumSuccessfulImages

                tool.IsResultsExistToExport=true;
                tool.IsExistUnexportedResults=true;
            else


                tool.IsResultsExistToExport=false;
            end

            tool.setState('ready');
            tool.updateActiveContexts("progressBarAnimation","remove");
            tool.IsCurrentlyProcessing=false;
            tool.IsStopRequested=false;
        end

        function stopProcessing(tool,varargin)
            if tool.IsCurrentlyProcessing
                tool.IsStopRequested=true;
            end
        end

    end


    methods(Access=private)
        function layoutLinkAxesSection(tool)
            import matlab.ui.internal.toolstrip.*



            linkAxesSectionColumn=tool.LinkAxesSection.addColumn();


            tool.LinkAxesCheckBox=CheckBox(getString(message('images:imageBatchProcessor:linkAxes')),true);
            tool.LinkAxesCheckBox.Tag='LinkAxes';
            tool.LinkAxesCheckBox.Enabled=true;


            tool.LinkAxesCheckBox.Description=...
            getString(message('images:imageBatchProcessor:linkAxesToolTip'));

            addlistener(tool.LinkAxesCheckBox,'ValueChanged',@(varargin)tool.updateAllFigures);

            linkAxesSectionColumn.add(tool.LinkAxesCheckBox);


        end
    end


    methods(Access=private)
        function layoutLayoutSection(tool)
            import matlab.ui.internal.toolstrip.*



            layoutSectionColumn=tool.LayoutSection.addColumn();
            tool.DefaultLayoutButton=Button(...
            getString(message('images:commonUIString:defaultLayout')),...
            Icon.LAYOUT_24);
            tool.DefaultLayoutButton.Tag='btnDefaultLayout';


            tool.DefaultLayoutButton.Description=...
            getString(message('images:commonUIString:defaultLayoutTooltip'));

            addlistener(tool.DefaultLayoutButton,'ButtonPushed',@tool.resetToDefaultLayout);

            layoutSectionColumn.add(tool.DefaultLayoutButton);
        end

        function resetToDefaultLayout(tool,varargin)

            tool.App.WindowMaximized=false;


            if~isempty(tool.DataBrowserFigPanel)
                tool.DataBrowserFigPanel.Maximized=false;


                tool.App.Layout.panelLayout.left.freeDimension=...
                floor(tool.LeftRightPanelWidthPct*tool.App.WindowBounds(3));
            end


            if~isempty(tool.InputImageFigDocument)
                tool.InputImageFigDocument.Maximized=false;
            end


            if~isempty(tool.ResultsFigPanel)
                tool.ResultsFigPanel.Maximized=false;


                tool.App.Layout.panelLayout.right.freeDimension=...
                floor(tool.LeftRightPanelWidthPct*tool.App.WindowBounds(3));
            end


            while height(tool.OutputImageFigDocList)>0

                figDocHdl=tool.OutputImageFigDocList{:,"FigDocHandle"};
                for cnt=1:numel(figDocHdl)
                    close(figDocHdl(cnt));
                end
            end

            tool.updateAllFigures();
        end
    end


    methods(Access=private)
        function layoutExportSection(tool)
            import matlab.ui.internal.toolstrip.*


            exportSectionColumn=tool.ExportSection.addColumn();

            tool.ExportButton=SplitButton(...
            getString(message('images:imageBatchProcessor:exportButtonLabel')),...
            Icon.CONFIRM_24);
            tool.ExportButton.Tag='ExportButton';


            tool.ExportButton.Description=...
            getString(message('images:imageBatchProcessor:exportButtonToolTip'));


            addlistener(tool.ExportButton,'ButtonPushed',@(hobj,evt)tool.exportResultsToWorkspaceUI());



            tool.ExportButton.DynamicPopupFcn=@(~,~)tool.getExportOptions();

            exportSectionColumn.add(tool.ExportButton);
        end

        function items=getExportOptions(tool,~,~)


            import matlab.ui.internal.toolstrip.*

            exportDataIcon=Icon.EXPORT_16;
            exportFunctionIcon=Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/GenerateMATLABScript_Icon_16px.png'));


            items=PopupList();



            entry=ListItem(getString(message('images:imageBatchProcessor:exportToWorkSpace')),...
            exportDataIcon);
            entry.Description='';
            entry.ShowDescription=false;
            entry.Tag='ExportToWorkspaceItem';
            addlistener(entry,'ItemPushed',@tool.exportResultsToWorkspaceUI);
            items.add(entry);


            entry=ListItem(getString(message('images:imageBatchProcessor:exportToFiles')),...
            exportDataIcon);
            entry.Description='';
            entry.ShowDescription=false;
            entry.Tag='ExportToFilesItem';
            addlistener(entry,'ItemPushed',@tool.exportResultsToFilesUI);
            items.add(entry);


            entry=ListItem(getString(message('images:imageBatchProcessor:generateFunction')),...
            exportFunctionIcon);
            entry.Description='';
            entry.ShowDescription=false;
            entry.Tag='GenerateFcnItem';
            addlistener(entry,'ItemPushed',@tool.generateFunctionUI);
            items.add(entry);
        end
    end


    methods(Access=private)
        function refreshImageStripAndAppState(tool)


            tool.createDataBrowserAndInputImageFigures();

            fileList=tool.ImageBatchDS.FileList;
            if isempty(tool.ImageStrip)

                tool.ImageStrip=...
                images.internal.app.batchProcessor.ThumbnailBrowser(...
                tool.DataBrowserFigHandle,...
                fileList);

                addlistener(tool.ImageStrip,...
                'ImageSelected',...
                @tool.imageStripClicked);
            else

                tool.ImageStrip.updateFileList(fileList);
            end


            tool.DefaultLayoutButton.Enabled=true;


            tool.cleanUpTemporaryResults();


            tool.TemporaryResultsFolder=tempname;
            tool.createDirOrDie(tool.TemporaryResultsFolder);


            tool.IsResultsExistToExport=false;
            tool.IsExistUnexportedResults=false;


            loadedStatus=getString(message('images:imageBatchProcessor:MLoaded',...
            num2str(tool.ImageBatchDS.NumImages)));
            tool.LeftBottomStatusLabel.Text=loadedStatus;
            tool.updateActiveContexts("imagesLoadAnimation");

            if~isempty(tool.BatchProcessorObj)
                tool.BatchProcessorObj.resetState();
            end

            tool.resetToDefaultLayout();


            tool.ImageStrip.selectFirstImage();
        end

        function refreshStateOnFunctionChange(tool)
            if~isempty(tool.ImageStrip)

                tool.refreshImageStripAndAppState();
            end
        end

        function imageStripClicked(tool,~,evt)
            if~isvalid(tool)
                return;
            end


            tool.SelectedImgInds=evt.SelectedImageIdx';


            selectionStatus=getString(message('images:imageBatchProcessor:NofMSelected',...
            num2str(numel(tool.SelectedImgInds)),num2str(tool.ImageBatchDS.NumImages)));
            tool.LeftBottomStatusLabel.Text=selectionStatus;

            tool.updateActiveContexts("imagesLoadAnimation");

            tool.updateAllFigures();
        end

        function createDataBrowserAndInputImageFigures(tool)










            currWMState=tool.App.WindowMaximized;
            wmStateRestoreOc=onCleanup(@()set(tool.App,'WindowMaximized',currWMState));
            if isempty(tool.DataBrowserFigPanel)

                [~,leafFolder]=fileparts(tool.ImageBatchDS.ReadLocation);
                dataBrowserFigPanelOptions.Title=leafFolder;
                dataBrowserFigPanelOptions.Tag='DataBrowser';
                dataBrowserFigPanelOptions.Region='left';
                tool.DataBrowserFigPanel=matlab.ui.internal.FigurePanel(dataBrowserFigPanelOptions);
                tool.DataBrowserFigHandle=tool.DataBrowserFigPanel.Figure;
                tool.DataBrowserFigHandle.AutoResizeChildren='off';
                tool.DataBrowserFigHandle.Scrollable=false;
                tool.DataBrowserFigHandle.Tag='DataBrowserFigHandle';
                tool.DataBrowserFigHandle.HandleVisibility='callback';

                tool.App.add(tool.DataBrowserFigPanel);
            end









            if isempty(tool.InputImageDocumentGroup)




                tool.InputImageDocumentGroup=matlab.ui.internal.FigureDocumentGroup();
                tool.InputImageDocumentGroup.Title=getString(message('images:commonUIString:inputImage'));
                tool.InputImageDocumentGroup.Tag=tool.InputImageDocumentGroupTag;
                tool.App.add(tool.InputImageDocumentGroup);
            end

            if isempty(tool.OutputImageDocumentGroup)




                tool.OutputImageDocumentGroup=matlab.ui.internal.FigureDocumentGroup();
                tool.OutputImageDocumentGroup.Tag=tool.OutputImageDocumentGroupTag;
                tool.App.add(tool.OutputImageDocumentGroup);
            end




            if isempty(tool.InputImageFigDocument)

                inputImageDocumentOptions.Title=getString(message('images:commonUIString:inputImage'));
                inputImageDocumentOptions.Tag='InputImageFigDocument';
                inputImageDocumentOptions.DocumentGroupTag=tool.InputImageDocumentGroup.Tag;
                tool.InputImageFigDocument=matlab.ui.internal.FigureDocument(inputImageDocumentOptions);
                tool.InputImageFigDocument.Closable=false;
                tool.InputImageFigDocument.Figure.AutoResizeChildren='off';
                tool.InputImageFigDocument.Figure.SizeChangedFcn=@tool.imagePanelSizeChangeFcnCB;
                tool.InputImageFigDocument.Figure.Tag='InputImageFigure';

                tool.App.add(tool.InputImageFigDocument);
            end
        end

        function createResultsPanel(tool)



            currWMState=tool.App.WindowMaximized;
            wmStateRestoreOc=onCleanup(@()set(tool.App,'WindowMaximized',currWMState));

            if isempty(tool.ResultsFigPanel)
                resultsPanelOptions.Title=getString(message('images:imageBatchProcessor:results'));
                resultsPanelOptions.Tag='ResultsFigPanel';
                resultsPanelOptions.Region='right';
                tool.ResultsFigPanel=matlab.ui.internal.FigurePanel(resultsPanelOptions);
                tool.App.add(tool.ResultsFigPanel);

                tool.ResultsFigPanelFigHandle=tool.ResultsFigPanel.Figure;
                tool.ResultsFigPanelFigHandle.Scrollable='on';
                tool.ResultsFigPanelFigHandle.AutoResizeChildren='off';
                tool.ResultsFigPanelFigHandle.Color=[0.94,0.94,0.94];
            end
        end

        function updateAllFigures(tool)
            tool.updateInputImage();
            tool.updateResultsPanel();
            tool.updateAllOutputImages();
            tool.updateImageAxisLinking();
        end

        function updateImageAxisLinking(tool)
            if tool.LinkAxesCheckBox.Value

                option='xy';
            else
                option='off';
            end



            hImageAxes=matlab.graphics.GraphicsPlaceholder.empty();


            hFigList=tool.InputImageFigDocument.Figure;

            if~isempty(tool.OutputImageFigDocList)


                hFigList=[hFigList,...
                [tool.OutputImageFigDocList.FigDocHandle.Figure]];
            end

            for hFig=hFigList
                if isvalid(hFig)
                    hax=findobj(hFig,'Type','Axes');
                    if~isempty(hax)&&isvalid(hax)
                        hImageAxes(end+1)=hax;
                    end
                end
            end

            if numel(hImageAxes)>1
                try
                    linkaxes(hImageAxes,option);
                catch ALL %#ok<NASGU>


                end
            end
        end

        function updateInputImage(tool)
            if~isempty(tool.InputImageFigDocument)
                try


                    if isempty(tool.SelectedImgInds)
                        return;
                    end
                    imgInd=tool.SelectedImgInds(1);

                    [~,fileName,ext]=fileparts(tool.ImageBatchDS.getInputImageName(imgInd));






                    if isempty(tool.InputImageHandle)
                        delete(tool.InputImageFigDocument.Figure.Children)
                    end

                    tool.InputImageHandle=...
                    displayImageWithTitle(tool.App,...
                    tool.InputImageFigDocument.Figure,...
                    tool.InputImageHandle,...
                    tool.ImageBatchDS.readPreview(imgInd),...
                    [fileName,ext],'im');
                    tool.InputImageHandle.Tag='InputImageHandle';
                    if isvalid(tool.InputImageHandle)


                        images.internal.utils.customAxesInteraction(tool.InputImageHandle.Parent);
                    end









                    if~tool.ProcessStopButton.Enabled&&...
                        ~isempty(tool.BatchProcessorObj)
                        tool.ProcessStartButton.Enabled=~isempty(tool.BatchFunctionHandle);
                    end
                catch ALL


                    if~isempty(tool.InputImageHandle)
                        delete(tool.InputImageFigDocument.Figure.Children);
                        tool.InputImageHandle=[];
                    end


                    tool.ProcessStartButton.Enabled=false;
                    displayException(tool.InputImageFigDocument.Figure,ALL);
                end
            end
        end

        function resultsPanelSizeChangeFcnCB(tool,src,~)











            if any(src.Position(3:4)<tool.MinFigSizeForResize)
                return;
            end



            children=src.Children;

            if numel(children)==1&&...
                strcmpi(children(1).Tag,'ResultsDisplayMainPanel')

                resPanel=children(1);
                resPanel.Position=src.Position;

            elseif numel(children)==1&&...
                strcmpi(children(1).Tag,'msgTxtLabelTag')
                msgTxtLabel=children(1);
                msgTxtLabelPosition=computeMsgLabelPosition(src.Position);
                msgTxtLabel.Position=msgTxtLabelPosition;

            elseif numel(children)==2

                repositionExceptionDisplay(src);

            elseif numel(children)==0


            else
                assert(false,"Invalid number of elements displayed in the result panel");
            end
        end

        function imagePanelSizeChangeFcnCB(tool,src,~)



            if any(src.Position(3:4)<tool.MinFigSizeForResize)
                return;
            end


            imageAxes=findall(src,'Type','axes');
            if isempty(imageAxes)


                if numel(src.Children)==2
                    repositionExceptionDisplay(src);
                else

                end
                return;
            end

            currImagePosition=src.Position;


            imageHorizBorderSpace=5;
            imageVertBorderSpace=20;



            displayHeight=currImagePosition(4)-2*imageVertBorderSpace;
            displayWidth=currImagePosition(3)-2*imageHorizBorderSpace;

            imageAxes.Position=[imageHorizBorderSpace,imageVertBorderSpace...
            ,displayWidth,displayHeight];
        end

        function updateResultsPanel(tool)





            if isempty(tool.SelectedImgInds)


                return;
            end



            imgInd=tool.SelectedImgInds(1);

            isImageProcessed=~isempty(tool.BatchProcessorObj)...
            &&tool.BatchProcessorObj.visited(imgInd);

            if isempty(tool.ResultsFigPanel)&&~isImageProcessed

                return;
            end



            tool.resetResultPanel();


            if isempty(tool.ResultsFigPanel)
                tool.createResultsPanel();
            end



            if isImageProcessed
                try
                    if tool.BatchProcessorObj.errored(imgInd)
                        exceptionObj=tool.BatchProcessorObj.getException(imgInd);
                        displayException(tool.ResultsFigPanelFigHandle,exceptionObj);
                    else
                        tool.displayResults(imgInd);
                    end
                catch ALL
                    displayException(tool.ResultsFigPanelFigHandle,ALL);
                end
            else
                displayMessageText(tool.ResultsFigPanelFigHandle,...
                getString(message('images:imageBatchProcessor:notProcessed')));
            end

            tool.ResultsFigPanelFigHandle.SizeChangedFcn=...
            @tool.resultsPanelSizeChangeFcnCB;
        end

        function resetResultPanel(tool)




            if isempty(tool.ResultsFigPanel)||tool.ResultsFigPanel.Collapsed
                return;
            end


            tool.ResultsFigPanelFigHandle.SizeChangedFcn=[];

            delete(tool.ResultsFigPanelFigHandle.Children);
        end

        function displayResults(tool,imgInd)
            resultSummaries=tool.ImageBatchDS.resultSummary(imgInd);
            resultNames=fieldnames(resultSummaries);
            numResults=numel(resultNames);

            rowDimsUG=zeros(numResults,1);

            isResultAnImage=structfun(@(x)images.internal.app.batchProcessor.isImage(x),...
            resultSummaries);



            rowDimsUG(isResultAnImage)=185;


            rowDimsUG(~isResultAnImage)=100;


            resultsMainUP=uipanel(tool.ResultsFigPanelFigHandle,...
            'Position',tool.ResultsFigPanelFigHandle.Position,...
            'Scrollable','off',...
            'BorderType','none',...
            'Tag','ResultsDisplayMainPanel');

            resultsMainUG=uigridlayout(resultsMainUP,...
            [numResults,1],...
            'Scrollable','on',...
            'Tag','ResultsGrid',...
            'RowSpacing',5,...
            'ColumnSpacing',5,...
            'RowHeight',rowDimsUG,...
            'ColumnWidth',{'1x'});




            tool.ImageResultsShowBtn=gobjects(numel(find(isResultAnImage)),1);




            numImageResults=1;
            for cnt=1:numResults
                currResultName=resultNames{cnt};
                currResult=resultSummaries.(currResultName);



                if images.internal.app.batchProcessor.isImage(currResult)





                    imageResultPanel=uipanel(resultsMainUG,...
                    'Tag',sprintf('%sResPanel',currResultName),...
                    'BorderType','line',...
                    'BackgroundColor',[1,1,1],...
                    'BorderType','line',...
                    'Visible','on');
                    imageResultPanel.Layout.Row=cnt;
                    imageResultPanel.Layout.Column=1;

                    imageResUG=uigridlayout(imageResultPanel,[2,2],...
                    'RowHeight',{20,'1x'},...
                    'ColumnWidth',{'1x',60},...
                    'RowSpacing',5,...
                    'ColumnSpacing',5,...
                    'Padding',[1,1,1,1]);


                    resNameLabel=uilabel(imageResUG,...
                    'Text',currResultName,...
                    'FontName','Helvetica',...
                    'FontSize',12,...
                    'FontWeight','bold',...
                    'BackgroundColor',resultsMainUG.BackgroundColor,...
                    'Tag',sprintf('%sResName',currResultName),...
                    'Visible','on');
                    resNameLabel.Layout.Row=1;
                    resNameLabel.Layout.Column=1;


                    tool.ImageResultsShowBtn(numImageResults)=...
                    uibutton(imageResUG,...
                    'Text',getString(message('images:imageBatchProcessor:show')),...
                    'FontName','Helvetica',...
                    'FontSize',12,...
                    'Tooltip',getString(message('images:imageBatchProcessor:showToolTip')),...
                    'ButtonPushedFcn',@(varargin)...
                    tool.showThisImageResultInOutput(currResultName),...
                    'Tag',sprintf('%sShowResBtn',currResultName),...
                    'Visible','on');
                    numImageResults=numImageResults+1;
                    resShowBtn.Layout.Row=1;
                    resShowBtn.Layout.Column=2;


                    resAxes=axes(imageResUG,...
                    'Units','pixels',...
                    'Tag',sprintf('%sResThumbnailTag',currResultName),...
                    'Visible','on');
                    resAxes.Color=[1,1,1];
                    resAxes.Layout.Row=2;
                    resAxes.Layout.Column=[1,2];
                    himage=imshow(currResult,'Parent',resAxes,...
                    'InitialMagnification','fit');
                    resAxes.Toolbar.Visible='off';
                    himage.ButtonDownFcn=@tool.showThisResultImageIfThumbnailIsDoubleClicked;

                else






                    nonImageResultPanel=uipanel(resultsMainUG,...
                    'Tag',sprintf('%sResPanel',currResultName),...
                    'BorderType','line',...
                    'BackgroundColor',[1,1,1],...
                    'Visible','on');
                    nonImageResultPanel.Layout.Row=cnt;
                    nonImageResultPanel.Layout.Column=1;

                    nonImageResUG=uigridlayout(nonImageResultPanel,[2,1],...
                    'RowHeight',{20,'1x'},...
                    'ColumnWidth',{'1x'},...
                    'Padding',[1,1,1,1]);


                    resNameLabel=uilabel(nonImageResUG,...
                    'Text',currResultName,...
                    'FontName','Helvetica',...
                    'FontSize',12,...
                    'FontWeight','bold',...
                    'BackgroundColor',resultsMainUG.BackgroundColor,...
                    'Tag',sprintf('%sResName',currResultName),...
                    'Visible','on');
                    resNameLabel.Layout.Row=1;
                    resNameLabel.Layout.Column=1;


                    resValueLabel=uilabel(nonImageResUG,...
                    'Text',currResult,...
                    'FontName','Helvetica',...
                    'FontSize',12,...
                    'Tag',sprintf('%sResValue',currResultName),...
                    'WordWrap','on',...
                    'Visible','on');
                    resValueLabel.Layout.Row=2;
                    resValueLabel.Layout.Column=1;

                end
            end
        end

        function showThisImageResultInOutput(tool,resName)

            if isempty(tool.SelectedImgInds)||nargin==1
                return;
            end



            imgInd=tool.SelectedImgInds(1);





            if~ismember(resName,tool.OutputImageFigDocList.Properties.RowNames)





                outputImageDocumentOptions.Title=resName;
                outputImageDocumentOptions.Tag=sprintf('%sOutputImageDocTag',resName);
                outputImageDocumentOptions.DocumentGroupTag=tool.OutputImageDocumentGroup.Tag;

                outputImageDocument=matlab.ui.internal.FigureDocument(outputImageDocumentOptions);
                outputImageDocument.CanCloseFcn=@tool.closeOutputImageFigDoc;
                tool.App.add(outputImageDocument);


                tool.OutputImageFigDocList(resName,:)=...
                {outputImageDocument,gobjects};



                tool.App.DocumentLayout=tool.getIOImageDisplayDocumentLayout();

                outputImageDocument.Figure.AutoResizeChildren='off';
                outputImageDocument.Figure.SizeChangedFcn=@tool.imagePanelSizeChangeFcnCB;
            else


            end


            outputImageDocument=tool.OutputImageFigDocList.FigDocHandle(resName);
            outputImageFigDocFigHandle=outputImageDocument.Figure;
            outputImageHandle=tool.OutputImageFigDocList.OutputImageHandle(resName);
















            isImageProcessed=~isempty(tool.BatchProcessorObj)&&...
            tool.BatchProcessorObj.visited(imgInd);



            isImageErrored=tool.BatchProcessorObj.errored(imgInd);

            if isImageProcessed&&~isImageErrored
                if isa(outputImageHandle,'matlab.graphics.GraphicsPlaceholder')





                    delete(outputImageFigDocFigHandle.Children)
                else



                end


                outputImageHandle=...
                displayImageWithTitle(...
                tool.App,...
                outputImageFigDocFigHandle,...
                outputImageHandle,...
                tool.ImageBatchDS.loadOneResultField(imgInd,resName),...
                resName,resName);

                outputImageHandle.Tag=sprintf('%sOutputImageHandle',resName);
                if isvalid(outputImageHandle)
                    images.internal.utils.customAxesInteraction(outputImageHandle.Parent);
                end
                tool.OutputImageFigDocList.OutputImageHandle(resName)=outputImageHandle;


                tool.updateImageAxisLinking();
            else



                if isa(outputImageHandle,'matlab.graphics.primitive.Image')

                    delete(outputImageFigDocFigHandle.Children);
                    displayMessageText(outputImageFigDocFigHandle,...
                    getString(message('images:imageBatchProcessor:outputNotAvailable')));


                    tool.OutputImageFigDocList.OutputImageHandle(resName)=gobjects(1);
                else



                end
            end



            outputImageDocument.Selected=true;
            outputImageDocument.Showing=true;
        end

        function tf=closeOutputImageFigDoc(tool,src)
            if~isvalid(tool)||isempty(tool.OutputImageFigDocList)
                tf=true;
                return;
            end

            resName=erase(src.Tag,'OutputImageDocTag');


            tool.OutputImageFigDocList(resName,:)=[];



            tool.App.DocumentLayout=tool.getIOImageDisplayDocumentLayout();

            tf=true;
        end

        function showThisResultImageIfThumbnailIsDoubleClicked(tool,src,~)
            hfig=ancestor(src,'Figure');
            if strcmp(hfig.SelectionType,'open')

                currResultName=erase(src.Parent.Tag,'ResThumbnailTag');
                tool.showThisImageResultInOutput(currResultName)
            end
        end

        function updateAllOutputImages(tool)

            if isempty(tool.SelectedImgInds)
                return;
            end

            imagesCurrentlyDisplayed=tool.OutputImageFigDocList.Row;
            for cnt=1:numel(imagesCurrentlyDisplayed)
                tool.showThisImageResultInOutput(imagesCurrentlyDisplayed{cnt});
            end

        end

        function documentLayout=getIOImageDisplayDocumentLayout(tool)
            documentLayout=struct;







            gridDimensions.w=1;
            gridDimensions.h=2;
            documentLayout.gridDimensions=gridDimensions;

            documentLayout.tileCount=2;

            tileCoverage=[1,2];
            documentLayout.tileCoverage=tileCoverage;



            rowWeights=[0.5,0.5];
            documentLayout.rowWeights=rowWeights;


            inputImage.children.id=tool.InputImageDocumentGroupTag+...
            "_"+...
            tool.InputImageFigDocument.Tag;



            outputImages.children=[];
            for cnt=1:height(tool.OutputImageFigDocList)
                outputImageFigDoc=tool.OutputImageFigDocList{cnt,1};
                if isvalid(outputImageFigDoc)
                    outputImages.children(end+1).id=...
                    tool.OutputImageDocumentGroupTag+...
                    "_"+...
                    outputImageFigDoc.Tag;
                end
            end

            tileOccupancy=[inputImage,...
            outputImages];

            documentLayout.tileOccupancy=tileOccupancy;
        end
    end


    methods(Access=private)
        function importImagesFromFolder(tool,fullPathToImages,...
            isRecurse,isImportUsingUI)




            if~tool.unexportedResultsDialog()
                return;
            end





            tool.App.Busy=true;
            restoreAppOc=onCleanup(@()set(tool.App,'Busy',false));

            tool.IsImageImportDone=false;
            restoreImageImportDoneOc=onCleanup(@()set(tool,'IsImageImportDone',true));

            if isImportUsingUI
                newBatchDS=tool.importImagesFromFolderUI(fullPathToImages);



                if isempty(newBatchDS)
                    return;
                end
            else
                newBatchDS=importInputImages(fullPathToImages,isRecurse);





                if newBatchDS.NumImages==0
                    tool.displayNoImagesInFolderDlg(fullPathToImages);
                    return;
                end


                tool.SettingsObj.images.imagebatchprocessingtool.BatchLocations.PersonalValue={char(fullPathToImages)};
            end

            tool.removeAllActiveContexts();
            tool.ImageBatchDS=newBatchDS;
            tool.refreshImageStripAndAppState();
            tool.setReadyIfPossible();
        end

        function imbds=importImagesFromFolderUI(tool,folderAbsolutePath)


            isNoImagesInFolder=true;
            while isNoImagesInFolder

                importFolderDlgSize=...
                images.internal.app.batchProcessor.ImportFolderUI.DialogSize;
                importFolderLoc=...
                imageslib.internal.app.utilities.ScreenUtilities.getModalDialogPos(tool.App,...
                importFolderDlgSize);

                tool.ImportImagesDlg=...
                images.internal.app.batchProcessor.ImportFolderUI(...
                importFolderLoc(1:2),...
                folderAbsolutePath);





                addlistener(tool.ImportImagesDlg,...
                'OpenFolderDialogClosed',...
                @(~,~)tool.App.bringToFront());




                tool.ImportImagesDlg.create();

                uiwait(tool.ImportImagesDlg.FigureHandle);

                if tool.ImportImagesDlg.Canceled
                    imbds=[];
                    break;
                end


                userSelectedFolder=tool.ImportImagesDlg.InputDir;
                isRecurse=tool.ImportImagesDlg.IsRecursiveDirLoad;

                [imbds,isNoImagesInFolder]=importInputImages(userSelectedFolder,isRecurse);




                if isNoImagesInFolder
                    tool.displayNoImagesInFolderDlg(userSelectedFolder);
                else

                    tool.SettingsObj.images.imagebatchprocessingtool.BatchLocations.PersonalValue={userSelectedFolder};
                end
            end
        end

        function displayNoImagesInFolderDlg(tool,userSelectedFolder)
            tool.App.Busy=false;
            toEnsureDlgBlocksML=uiconfirm(tool.App,...
            getString(message('images:imageBatchProcessor:noImagesFoundDetail',...
            userSelectedFolder)),...
            getString(message('images:imageBatchProcessor:noImagesFound')),...
            'Icon','error',...
            'Options',{getString(message('MATLAB:uistring:popupdialogs:OK'))});
            tool.App.Busy=true;
        end
    end


    methods(Access=private)
        function exportResultsToWorkspaceUI(tool,varargin)

            resultSummaries=tool.ImageBatchDS.resultSummary(tool.LastProcessedIdx);
            allFields=fieldnames(resultSummaries);


            tool.App.Busy=true;
            restoreAppOc=onCleanup(@()set(tool.App,'Busy',false));



            wkspaceExportDialogSize=...
            images.internal.app.batchProcessor.WorkspaceExportUI.DialogSize;
            wkspaceExportDlgLoc=...
            imageslib.internal.app.utilities.ScreenUtilities.getModalDialogPos(tool.App,...
            wkspaceExportDialogSize);

            tool.ToWkspaceDlg=images.internal.app.batchProcessor.WorkspaceExportUI(wkspaceExportDlgLoc(1:2),...
            allFields,...
            tool.FieldsSelectedForWS,...
            tool.IsFileNameFieldSelected);

            uiwait(tool.ToWkspaceDlg.FigureHandle);



            if tool.ToWkspaceDlg.Canceled
                return;
            end

            tool.FieldsSelectedForWS=tool.ToWkspaceDlg.ResultsToExport;
            tool.IsFileNameFieldSelected=tool.ToWkspaceDlg.IsFileNameExported;

            resultToExport=tool.ImageBatchDS.loadAllResults(...
            tool.FieldsSelectedForWS,...
            tool.IsFileNameFieldSelected);

            if strcmpi(tool.ToWkspaceDlg.ResultsType,'table')
                resultToExport=struct2table(resultToExport,'AsArray',true);
            end

            assignin('base',tool.ToWkspaceDlg.ResultsVarName,resultToExport);
            evalin('base',['disp(',tool.ToWkspaceDlg.ResultsVarName,')']);

            tool.IsExistUnexportedResults=false;
        end

        function exportResultsToFilesUI(tool,varargin)


            resultSummaries=tool.ImageBatchDS.resultSummary(tool.LastProcessedIdx);
            resultNames=fieldnames(resultSummaries);
            imageResultNames=resultNames(...
            structfun(@(x)images.internal.app.batchProcessor.isImage(x),...
            resultSummaries));




            numImageOutputs=numel(imageResultNames);

            if isempty(tool.FieldsSelectedForFileSave)||...
                ~all(strcmp(imageResultNames,tool.FieldsSelectedForFileSave.Row))

                tool.FieldsSelectedForFileSave=table(...
                repmat({''},[numImageOutputs,1]),...
                'VariableNames',{'OutputImageFileTypes'},...
                'RowNames',imageResultNames);
            end

            if isempty(tool.FileSaveOutputDir)
                tool.FileSaveOutputDir=pwd;
            end


            tool.App.Busy=true;
            restoreAppOc=onCleanup(@()set(tool.App,'Busy',false));



            fileExportDlgSize=...
            images.internal.app.batchProcessor.FileExportUI.DialogSize;

            fileExportLoc=...
            imageslib.internal.app.utilities.ScreenUtilities.getModalDialogPos(tool.App,...
            fileExportDlgSize);

            tool.FileExportDlg=images.internal.app.batchProcessor.FileExportUI(...
            fileExportLoc(1:2),...
            tool.FieldsSelectedForFileSave,...
            tool.FileSaveOutputDir);

            uiwait(tool.FileExportDlg.FigureHandle);
            if tool.FileExportDlg.Canceled
                return;
            end

            tool.FieldsSelectedForFileSave=tool.FileExportDlg.OutputImageExportSelection;
            tool.FileSaveOutputDir=tool.FileExportDlg.OutputImageDir;


            finalFieldsSelectedForSave=...
            tool.FieldsSelectedForFileSave(...
            ~cellfun(@(x)isempty(x),...
            tool.FieldsSelectedForFileSave.OutputImageFileTypes),:);
            failed=tool.ImageBatchDS.copyAllResultsToFiles(...
            tool.FileSaveOutputDir,...
            finalFieldsSelectedForSave,...
            tool.BatchProcessorObj.UseParallel);

            if failed
                uialert(tool.App,...
                getString(message('images:imageBatchProcessor:failedToExportAllToFilesMessage')),...
                getString(message('images:imageBatchProcessor:failedToExportAllToFilesName')),...
                'Icon','warning',...
                'Modal',false);


                commandwindow;
            else
                tool.IsExistUnexportedResults=false;
            end
        end

        function generateFunctionUI(tool,varargin)


            tool.App.Busy=true;
            restoreAppOc=onCleanup(@()set(tool.App,'Busy',false));



            genFcnDialogSize=...
            images.internal.app.batchProcessor.GenerateFcnUI.DialogSize;
            genFcnDlgLoc=...
            imageslib.internal.app.utilities.ScreenUtilities.getModalDialogPos(tool.App,...
            genFcnDialogSize);

            tool.GenFcnDlg=images.internal.app.batchProcessor.GenerateFcnUI(genFcnDlgLoc(1:2),...
            tool.ImageBatchDS.resultSummary(tool.LastProcessedIdx));

            uiwait(tool.GenFcnDlg.FigureHandle);
            if tool.GenFcnDlg.Canceled
                return;
            end

            outputExportSelection=tool.GenFcnDlg.OutputExportSelection;
            wkspaceExportType=tool.GenFcnDlg.WkspaceExportType;


            codeGenerator=iptui.internal.CodeGenerator();
            templateFile=fullfile(matlabroot,'toolbox','images',...
            'imuitools','+images','+internal','+app','+batchProcessor',...
            'generatedBatchFunction.template');
            codeString=fileread(templateFile);





            fields=outputExportSelection.Properties.RowNames;

            functionCallStr='oneResult = <FUNCTION>(im);';
            if numel(fields)==1&&strcmp(fields,'output')


                functionCallStr='oneResult = struct();oneResult.output = <FUNCTION>(im);';
            end

            codeString=strrep(codeString,'<FUNCTIONCALL>',functionCallStr);



            codeString=strrep(codeString,'<FUNCTION>',tool.BatchFunctionName);


            inDir=replace(tool.ImageBatchDS.ReadLocation,...
            '''','''''');
            codeString=replace(codeString,'<DEFAULTINPUT>',inDir);

            if tool.ImageBatchDS.IsIncludeSubFolders
                codeString=replace(codeString,'<INCLUDESUBDIRECTORIES>','true');
            else
                codeString=replace(codeString,'<INCLUDESUBDIRECTORIES>','false');
            end


            fieldsSelectedForWS={outputExportSelection.Row{...
            strcmpi(outputExportSelection.OutputFileTypes,...
            'wkspace'),:}};

            wsFieldsComent=sprintf('%%    %s\n',fieldsSelectedForWS{:});
            codeString=strrep(codeString,'<COMMENT_WORKSPACEFIELDS>',wsFieldsComent);




            codeString=strrep(codeString,'<DATE>',date);


            wsFieldsCode=sprintf('''%s'',',fieldsSelectedForWS{:});
            if~isempty(wsFieldsCode)
                wsFieldsCode(end)=[];
            end
            codeString=strrep(codeString,'<WORKSPACEFIELDS>',wsFieldsCode);


            fileFieldsComment='';
            fieldsSelectedForFileSave=outputExportSelection(...
            ~strcmpi(outputExportSelection.OutputFileTypes,...
            'wkspace'),:);
            for cnt=1:numel(fieldsSelectedForFileSave)
                fileFieldsComment=[fileFieldsComment,'%    ',...
                fieldsSelectedForFileSave.Row{cnt},' saved as ',...
                fieldsSelectedForFileSave{cnt,1}{1},' format'];%#ok<*AGROW>
                fileFieldsComment=[fileFieldsComment,newline];
            end
            if~isempty(fileFieldsComment)
                fileFieldsComment(end)=[];
            end
            codeString=replace(codeString,'<COMMENT_FILEFIELDSWITHFORMAT>',fileFieldsComment);


            fileFieldsCode='';
            for cnt=1:numel(fieldsSelectedForFileSave)
                fileFieldsCode=[fileFieldsCode,'{''',...
                fieldsSelectedForFileSave.Row{cnt},''',  ''',...
                fieldsSelectedForFileSave{cnt,1}{1},'''}'];%#ok<*AGROW>
                fileFieldsCode=[fileFieldsCode,newline];
            end
            if~isempty(fileFieldsCode)
                fileFieldsCode(end)=[];
            end
            codeString=replace(codeString,'<FILEFIELDSWITHFORMAT>',fileFieldsCode);

            if tool.ProcessInParallelToggleButton.Value
                codeString=strrep(codeString,'<FOR>','parfor');
            else
                codeString=strrep(codeString,'<FOR>','for');
            end

            codeString=strrep(codeString,'<DATE>',date);

            if strcmp(wkspaceExportType,'table')

                codeString=replace(codeString,'<TABLEORSTRUCTARRAY>','table');
                codeString=replace(codeString,'<STRUCT2TABLEIFNEEDED>','result = struct2table(result,''AsArray'',true);');
            else

                codeString=replace(codeString,'<TABLEORSTRUCTARRAY>','struct array');
                codeString=replace(codeString,'<STRUCT2TABLEIFNEEDED>','');
            end

            codeGenerator.addLineWithoutWhitespace(codeString);
            codeGenerator.putCodeInEditor();
        end
    end


    methods(Access=private)
        function setState(tool,state)
            if~isvalid(tool)||tool.IsCurrentlyClosing
                return;
            end
            tool.CurrAppState=state;

            switch state
            case 'notReady'
                tool.ImportButton.Enabled=true;
                tool.BatchFunctionNameDropDown.Enabled=true;
                tool.BatchFunctionOpenButton.Enabled=true;
                tool.BatchFunctionOpenInEditorButton.Enabled=~isempty(tool.BatchFunctionName);
                tool.BatchFunctionCreateButton.Enabled=true;
                tool.ProcessInParallelToggleButton.Enabled=true;
                tool.ProcessStartButton.Enabled=false;
                tool.ProcessStopButton.Enabled=false;
                tool.LinkAxesCheckBox.Enabled=false;
                tool.DefaultLayoutButton.Enabled=false;
                tool.ExportButton.Enabled=false;

            case 'ready'
                tool.ImportButton.Enabled=true;
                tool.BatchFunctionNameDropDown.Enabled=true;
                tool.BatchFunctionOpenButton.Enabled=true;
                tool.BatchFunctionOpenInEditorButton.Enabled=true;
                tool.BatchFunctionCreateButton.Enabled=true;
                tool.ProcessInParallelToggleButton.Enabled=true;
                tool.ProcessStartButton.Enabled=true;
                tool.ProcessStopButton.Enabled=false;
                tool.LinkAxesCheckBox.Enabled=true;
                tool.DefaultLayoutButton.Enabled=true;
                tool.ExportButton.Enabled=tool.IsResultsExistToExport;


                tool.ProcessStopButton.Text=getString(message('images:imageBatchProcessor:stopButton'));

            case 'processing'
                tool.ImportButton.Enabled=false;
                tool.BatchFunctionNameDropDown.Enabled=false;
                tool.BatchFunctionOpenButton.Enabled=false;
                tool.BatchFunctionOpenInEditorButton.Enabled=false;
                tool.BatchFunctionCreateButton.Enabled=false;
                tool.ProcessInParallelToggleButton.Enabled=false;
                tool.ProcessStartButton.Enabled=false;
                tool.ProcessStopButton.Enabled=true;
                tool.DefaultLayoutButton.Enabled=true;
                tool.ExportButton.Enabled=false;

            case 'locked'
                tool.ImportButton.Enabled=false;
                tool.BatchFunctionNameDropDown.Enabled=false;
                tool.BatchFunctionOpenButton.Enabled=false;
                tool.BatchFunctionOpenInEditorButton.Enabled=false;
                tool.BatchFunctionCreateButton.Enabled=false;
                tool.ProcessInParallelToggleButton.Enabled=false;
                tool.ProcessStartButton.Enabled=false;
                tool.ProcessStopButton.Enabled=false;
                tool.LinkAxesCheckBox.Enabled=false;
                tool.DefaultLayoutButton.Enabled=false;
                tool.ExportButton.Enabled=false;

            otherwise
                assert(false,'unknown state requested');
            end
        end

        function setReadyIfPossible(tool)
            if~isempty(tool.ImageBatchDS)&&~isempty(tool.BatchFunctionHandle)

                tool.BatchProcessorObj=images.internal.app.batchProcessor.BatchProcessor(...
                tool.ImageBatchDS,tool.BatchFunctionHandle);


                tool.BatchProcessorObj.BeginFcn=@tool.indicateImageBeginning;
                tool.BatchProcessorObj.DoneFcn=@tool.indicateImageDone;
                tool.BatchProcessorObj.CleanupFcn=@tool.cleanupProcessing;
                tool.BatchProcessorObj.IsStopReqFcn=@tool.checkIfStopRequested;

                tool.setState('ready');
            end
        end
    end


    methods(Access=private)
        function indicateImageBeginning(tool,numNewImagesQueued)
            tool.NumQueuedImages=tool.NumQueuedImages+numNewImagesQueued;
            tool.indicateProgress();
        end

        function indicateImageDone(tool,imgInd)


            if~isvalid(tool)||tool.IsCurrentlyClosing
                return
            end


            isImageProcError=arrayfun(@(x)tool.BatchProcessorObj.errored(x),imgInd);
            errorImageIndx=imgInd(isImageProcError);
            successImageIndx=imgInd(~isImageProcError);


            tool.ImageStrip.updateBadge(errorImageIndx,"error");
            tool.NumErroredImages=tool.NumErroredImages+numel(errorImageIndx);


            tool.ImageStrip.updateBadge(successImageIndx,"done");
            tool.NumSuccessfulImages=tool.NumSuccessfulImages+numel(successImageIndx);
            if~isempty(successImageIndx)
                tool.LastProcessedIdx=successImageIndx(end);
            end

            if~isempty(tool.SelectedImgInds)&&...
                imgInd(1)==tool.SelectedImgInds(1)

                tool.updateAllFigures();
            end

            tool.indicateProgress();
        end

        function indicateProgress(tool)



            numImagesProcessed=tool.NumSuccessfulImages+tool.NumErroredImages;
            if tool.ProcessInParallelToggleButton.Value
                progressStateString=getString(message('images:imageBatchProcessor:queued',...
                num2str(tool.NumQueuedImages)));

                progressStateString=[progressStateString,' ',...
                getString(message('images:imageBatchProcessor:doneOf',...
                num2str(numImagesProcessed),...
                num2str(tool.NumTodoImages)))];
            else
                progressStateString=getString(message('images:imageBatchProcessor:doneOf',...
                num2str(numImagesProcessed),...
                num2str(tool.NumTodoImages)));
            end

            if tool.NumSuccessfulImages~=0
                progressStateString=[progressStateString,' ',...
                getString(message('images:imageBatchProcessor:successful',...
                num2str(tool.NumSuccessfulImages)))];
            end

            if tool.NumErroredImages~=0
                progressStateString=[progressStateString,' ',...
                getString(message('images:imageBatchProcessor:errored',...
                num2str(tool.NumErroredImages)))];
            end

            tool.ProgressStatusLabel.Text=progressStateString;
            tool.updateActiveContexts("progressBarAnimation");
            tool.updateActiveContexts("progressLabelAnimation");


            tool.ProgressStatusBar.Value=...
            ceil(numImagesProcessed/tool.NumTodoImages*100);
        end

        function cleanupProcessing(tool,imageIndxCancelled)


            if~isvalid(tool)||tool.IsCurrentlyClosing
                return;
            end

            tool.ImageStrip.updateBadge(imageIndxCancelled,"none");
        end

        function stopnow=checkIfStopRequested(tool)
            if~isvalid(tool)

                stopnow=true;
                return
            end


            drawnow;

            stopnow=tool.IsStopRequested;
            if stopnow
                tool.ProcessStopButton.Text=getString(message('images:imageBatchProcessor:stoppingButton'));
                tool.ProcessStopButton.Enabled=false;
            end
        end

    end


    methods(Access=private)
        function updateActiveContexts(tool,activeContext,op)
            if tool.IsCurrentlyClosing
                return;
            end

            if nargin==2
                op="add";
            end

            currActiveContexts=string(tool.App.ActiveContexts);
            if op=="add"
                if isempty(currActiveContexts)||...
                    ~ismember(activeContext,currActiveContexts)
                    currActiveContexts(end+1)=activeContext;
                    tool.App.ActiveContexts=currActiveContexts;
                end
            else
                ctxLoc=ismember(currActiveContexts,activeContext);
                if any(ctxLoc)
                    currActiveContexts(ctxLoc)=[];
                    tool.App.ActiveContexts=currActiveContexts;
                end
            end
        end

        function removeAllActiveContexts(tool)
            currActiveContexts=string(tool.App.ActiveContexts);
            if isempty(currActiveContexts)
                return;
            end

            for ac=currActiveContexts
                tool.updateActiveContexts(ac,"remove");
            end
        end
    end
end


function displayException(hObj,exceptionObj)






    panelSize=hObj.Position;

    [errHdrLabelPos,errMsgLabelPos]=computeErrorLabelPositions(panelSize);

    uilabel(hObj,...
    'Text',getString(message('images:imageBatchProcessor:exceptionHeaderInfo')),...
    'Position',errHdrLabelPos,...
    'Tag','ErrorHdrLbl',...
    'FontName','Helvetica',...
    'FontSize',20,...
    'FontWeight','bold',...
    'BackgroundColor',[0.94,0.94,0.94],...
    'VerticalAlignment','top',...
    'HorizontalAlignment','left',...
    'Visible','on');


    errMessage=exceptionObj.message;


    errMessage=replace(errMessage,'\','\\');

    uilabel(hObj,...
    'Text',errMessage,...
    'Position',errMsgLabelPos,...
    'Tag','ErrMsgLbl',...
    'FontName','FixedWidth',...
    'FontSize',14,...
    'FontWeight','bold',...
    'FontColor',[1,0,0],...
    'BackgroundColor',[0.94,0.94,0.94],...
    'WordWrap','on',...
    'Interpreter','html',...
    'VerticalAlignment','top',...
    'HorizontalAlignment','left',...
    'Visible','on');
end

function[errHdrLabelPos,errMsgLabelPos]=computeErrorLabelPositions(panelSize)





    leftMarginSize=10;
    rightMarginSize=5;
    topMarginSize=20;
    bottomMarginSize=10;
    spaceBetweenLabels=5;
    errHdrLabelHeight=30;

    panelWidth=panelSize(3);
    panelHeight=panelSize(4);


    errHdrLabelPos=[leftMarginSize,...
    panelHeight-topMarginSize-errHdrLabelHeight,...
    panelWidth-leftMarginSize-rightMarginSize,...
    errHdrLabelHeight];


    errMsgLabelPos=[leftMarginSize,...
    bottomMarginSize,...
    panelWidth-leftMarginSize-rightMarginSize,...
    panelHeight-topMarginSize-errHdrLabelHeight...
    -spaceBetweenLabels-bottomMarginSize];
end

function repositionExceptionDisplay(parentHandle)


    children=parentHandle.Children;


    [errHdrLabelPos,errMsgLabelPos]=computeErrorLabelPositions(parentHandle.Position);

    errHdrLabelChildIndx=strcmp({children(1).Tag,children(2).Tag},...
    'ErrorHdrLbl');

    errHdrLabel=children(errHdrLabelChildIndx);
    errHdrLabel.Position=errHdrLabelPos;

    errMsgLabel=children(~errHdrLabelChildIndx);
    errMsgLabel.Position=errMsgLabelPos;
end



function displayMessageText(hObj,msgToDisplay)




    panelSize=hObj.Position;
    msgTextLabelPosition=computeMsgLabelPosition(panelSize);

    uilabel('Parent',hObj,...
    'BackgroundColor',[1,1,1],...
    'Tag','msgTxtLabelTag',...
    'Position',msgTextLabelPosition,...
    'Text',msgToDisplay,...
    'FontName','Helvetica',...
    'FontSize',20,...
    'FontWeight','bold',...
    'VerticalAlignment','top',...
    'HorizontalAlignment','left',...
    'BackgroundColor',[0.94,0.94,0.94],...
    'Visible','on');
end

function msgTxtLabelPosition=computeMsgLabelPosition(panelSize)

    leftMarginSize=10;
    rightMarginSize=10;
    topMarginSize=20;
    labelHeight=50;

    panelWidth=panelSize(3);
    panelHeight=panelSize(4);

    msgTxtLabelPosition=[leftMarginSize,...
    panelHeight-topMarginSize-labelHeight,...
    panelWidth-leftMarginSize-rightMarginSize,...
    labelHeight];
end

function hImage=displayImageWithTitle(app,hFigure,hImage,im,caption,varName)

    if~isvalid(hFigure)
        return;
    end



    if islogical(im)&&size(im,3)>1
        im=uint8(im);
        im(im==1)=intmax('uint8');
    end

    if ndims(im)>3||(size(im,3)~=1&&size(im,3)~=3)



        im=im(:,:,1);
    end

    if~ismember(class(im),{'logical','uint8'})

        range=[min(im(:)),max(im(:))];

        if range(1)==range(2)
            range=getrangefromclass(im);
        end
    else

        range=getrangefromclass(im);
    end

    warnState=warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
    resetWarnObj=onCleanup(@()warning(warnState));




    if isempty(hImage)||isa(hImage,'matlab.graphics.GraphicsPlaceholder')





        currImagePosition=hFigure.Position;


        imageHorizBorderSpace=5;
        imageVertBorderSpace=20;



        displayHeight=currImagePosition(4)-2*imageVertBorderSpace;
        displayWidth=currImagePosition(3)-2*imageHorizBorderSpace;

        ax=axes(hFigure,...
        'Units','pixels',...
        'Position',[imageHorizBorderSpace,imageVertBorderSpace...
        ,displayWidth,displayHeight],...
        'Tag','ImageAxes',...
        'Visible','off');


        hImage=imshow(im,'Parent',ax,...
        'InitialMagnification','fit',...
        'DisplayRange',range,...
        'Border','tight');
    else









        isNewColorMapGrayscale=(size(im,3)~=size(hImage.CData,3))&&...
        size(im,3)==1;
        ax=hImage.Parent;
        hImage.CData=im;
        ax.XLim=[.5,size(im,2)+.5];
        ax.YLim=[.5,size(im,1)+.5];
        ax.CLim=range;

        if isNewColorMapGrayscale
            ax.Colormap=gray(256);
        end

        if ismatrix(im)
            hImage.CDataMapping='scaled';
        else
            hImage.CDataMapping='direct';
        end
    end

    title(ax,caption,...
    'FontWeight','normal',...
    'FontName','FixedWidth',...
    'FontSize',12,...
    'Interpreter','None');

    clear resetWarnObj;
    installSaveToWorkSpaceContextMenu(app,hImage,caption,varName);
end

function installSaveToWorkSpaceContextMenu(app,hImage,varLabel,varName)






    parent=hImage;
    while~isa(parent,'matlab.ui.Figure')
        parent=parent.Parent;
    end
    contextMenu=uicontextmenu('Parent',parent);

    uimenu(contextMenu,...
    'Label',getString(message('images:commonUIString:exportImageToWS')),...
    'Tag','exportImageToWorkspace',...
    'MenuSelectedFcn',@(varargin)saveImageToWS(app,hImage,varLabel,varName));

    hImage.ContextMenu=contextMenu;
end

function saveImageToWS(app,hImage,varLabel,varName)
    saveToWSDialogSize=[200,100];
    saveToWSDialogLoc=...
    imageslib.internal.app.utilities.ScreenUtilities.getModalDialogPos(app,...
    saveToWSDialogSize);



    hImage.UserData=...
    images.internal.app.utilities.ExportToWorkspaceDialog(saveToWSDialogLoc(1:2),...
    getString(message('images:commonUIString:exportImageToWS')),...
    string(varName),string(varLabel));

    wait(hImage.UserData);

    if hImage.UserData.Canceled
        return;
    end

    if hImage.UserData.VariableSelected
        assignin('base',hImage.UserData.VariableName,hImage.CData);
    end

end


function[imbds,isNoImagesInFolder]=importInputImages(inputLoc,...
    isRecurse)

    imbds=images.internal.app.batchProcessor.ImageBatchDataStore(...
    inputLoc,isRecurse);

    isNoImagesInFolder=imbds.NumImages==0;
end
