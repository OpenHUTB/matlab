function[imgDatastore,timestamps,userCancelled]=loadImageSequenceDialog(groupName)



    if(nargin==1)
        argumentPassed=1;
    else
        argumentPassed=0;
    end

    imgDatastore=[];
    timestamps=[];
    userCancelled=false;

    timestampsVar=[];
    timestampsStr='';

    currentlyLoading=false;
    importTimestampsFlag=false;

    persistent previousLocations;


    needToInitPath=isempty(previousLocations);
    if needToInitPath
        previousLocations='';
    end




    if(isempty(previousLocations)||isempty(previousLocations{1}))
        folderAbsolutePath=pwd;
    else

        folderAbsolutePath=previousLocations{1};
    end

    dlgHeight=16;

    if~useAppContainer
        loadDirDialog=dialog(...
        'Name',vision.getMessage('vision:labeler:LoadImageSequenceTitle'),...
        'Units','char',...
        'Position',[0,0,100,dlgHeight],...
        'Visible','off',...
        'Tag','LoadDirDialog');
        loadDirDialog.CloseRequestFcn=@doCancel;
        movegui(loadDirDialog,'center');



        uicontrol('Parent',loadDirDialog,...
        'Style','text',...
        'Units','char',...
        'Position',[1,dlgHeight-2,100,1.5],...
        'HorizontalAlignment','left',...
        'String',vision.getMessage('vision:labeler:LoadImageSequenceFrom'));


        hFolderTextBox=uicontrol('Parent',loadDirDialog,...
        'Style','edit',...
        'Units','char',...
        'Position',[1,dlgHeight-4,80,1.5],...
        'String',folderAbsolutePath,...
        'HorizontalAlignment','left',...
        'KeyPressFcn',@doLoadIfEntered,...
        'Tag','InputFolderTextBox');


        currentlyBrowsing=false;
        hBrowseButton=uicontrol('Parent',loadDirDialog,...
        'Style','pushbutton',...
        'Units','char',...
        'Position',[85,dlgHeight-4,14,1.5],...
        'Callback',@doBrowse,...
        'String',vision.getMessage('vision:labeler:Browse'),...
        'Tag','BrowseButton');


        hButtonGroup=uibuttongroup('Parent',loadDirDialog,...
        'Visible','on',...
        'Position',[0,0,1,0.75],...
        'BorderType','none',...
        'SelectionChangedFcn',@selectTimestampsSource);


        hImportFromWSRadioButton=uicontrol('Parent',hButtonGroup,...
        'Style','radiobutton',...
        'String',vision.getMessage('vision:labeler:ImportTimeStampsFromWS'),...
        'Units','char',...
        'Position',[1,dlgHeight-8,100,2],...
        'HandleVisibility','off',...
        'Value',false,...
        'Tag','ImportFromWSRadioButton');


        hImportButton=uicontrol('Parent',hButtonGroup,...
        'Style','pushbutton',...
        'Callback',@doImport,...
        'Units','char',...
        'Position',[1,dlgHeight-10,20,1.5],...
        'String',vision.getMessage('vision:labeler:Import'),...
        'Enable','off',...
        'Tag','ImportButton');


        hTimestampsStrTextBox=uicontrol('Parent',hButtonGroup,...
        'Style','text',...
        'Units','char',...
        'Position',[25,dlgHeight-10,60,1.5],...
        'String',timestampsStr,...
        'HorizontalAlignment','left',...
        'FontWeight','bold',...
        'Enable','off',...
        'Tag','TimestampTextBox');

        hDefaultRadioButton=uicontrol('Parent',hButtonGroup,...
        'Style','radiobutton',...
        'String',vision.getMessage('vision:labeler:UseDefaultTimestamps'),...
        'Units','char',...
        'Position',[1,dlgHeight-12,100,2],...
        'HandleVisibility','off',...
        'Value',true,...
        'Tag','DefaultTSRadioButton');


        hCancelButton=uicontrol('Parent',loadDirDialog,...
        'Style','pushbutton',...
        'Callback',@doCancel,...
        'Units','char',...
        'Position',[85,1,14,1.5],...
        'String',vision.getMessage('vision:labeler:Cancel'),...
        'Tag','CancelButton');


        hLoadButton=uicontrol('Parent',loadDirDialog,...
        'Style','pushbutton',...
        'Callback',@doLoad,...
        'Units','char',...
        'Position',[65,1,16,1.5],...
        'String',vision.getMessage('vision:labeler:Load'),...
        'Enable','on',...
        'Tag','LoadButton');
    else

        loadDirDialog=uifigure(...
        'Name',vision.getMessage('vision:labeler:LoadImageSequenceTitle'),...
        'Position',[455,275,630,288],...
        'Visible','on',...
        'Resize','off',...
        'Tag','LoadDirDialog',...
        'WindowKeyPressFcn',@(src,evt)doLoadIfEntered(src,evt));
        loadDirDialog.CloseRequestFcn=@doCancel;


        uilabel('Parent',loadDirDialog,...
        'Position',[1,dlgHeight-2,100,1.5].*[6,14,6,14],...
        'HorizontalAlignment','left',...
        'Text',vision.getMessage('vision:labeler:LoadImageSequenceFrom'));


        hFolderTextBox=uieditfield('Parent',loadDirDialog,...
        'Position',[1,dlgHeight-4,80,1.5].*[6,14,6,14],...
        'Value',folderAbsolutePath,...
        'HorizontalAlignment','left',...
        'ValueChangedFcn',@(src,evt)updateFolderValue(src,evt),...
        'ValueChangingFcn',@(src,evt)updatingFolderValue(src,evt),...
        'Tag','InputFolderTextBox');


        currentlyBrowsing=false;
        hBrowseButton=uibutton('Parent',loadDirDialog,...
        'Position',[85,dlgHeight-4,14,1.5].*[6,14,6,14],...
        'ButtonPushedFcn',@doBrowse,...
        'Text',vision.getMessage('vision:labeler:Browse'),...
        'Tag','BrowseButton');


        hButtonGroup=uibuttongroup('Parent',loadDirDialog,...
        'Visible','on',...
        'Position',[1,1,630,150],...
        'BorderType','none',...
        'SelectionChangedFcn',@selectTimestampsSource);


        hImportFromWSRadioButton=uiradiobutton('Parent',hButtonGroup,...
        'Text',vision.getMessage('vision:labeler:ImportTimeStampsFromWS'),...
        'Position',[1,dlgHeight-8,100,2].*[6,14,6,14],...
        'HandleVisibility','off',...
        'Value',false,...
        'Tag','ImportFromWSRadioButton');


        hImportButton=uibutton('Parent',hButtonGroup,...
        'ButtonPushedFcn',@doImport,...
        'Position',[1,dlgHeight-10,20,1.5].*[6,14,6,14],...
        'Text',vision.getMessage('vision:labeler:Import'),...
        'Enable','off',...
        'Tag','ImportButton');


        hTimestampsStrTextBox=uilabel('Parent',hButtonGroup,...
        'Position',[25,dlgHeight-10,60,1.5].*[6,14,6,14],...
        'Text',timestampsStr,...
        'HorizontalAlignment','left',...
        'FontWeight','bold',...
        'Enable','off',...
        'Tag','TimestampTextBox');

        hDefaultRadioButton=uiradiobutton('Parent',hButtonGroup,...
        'Text',vision.getMessage('vision:labeler:UseDefaultTimestamps'),...
        'Position',[1,dlgHeight-12,100,2].*[6,14,6,14],...
        'HandleVisibility','off',...
        'Value',true,...
        'Tag','DefaultTSRadioButton');


        hCancelButton=uibutton('Parent',loadDirDialog,...
        'ButtonPushedFcn',@doCancel,...
        'Position',[85,1,14,1.5].*[6,14,6,14],...
        'Text',vision.getMessage('vision:labeler:Cancel'),...
        'Tag','CancelButton');


        hLoadButton=uibutton('Parent',loadDirDialog,...
        'ButtonPushedFcn',@doLoad,...
        'Position',[65,1,16,1.5].*[6,14,6,14],...
        'Text',vision.getMessage('vision:labeler:Load'),...
        'Enable','on',...
        'Tag','LoadButton');
    end


    function doLoadIfEntered(~,event)
        if(strcmp(event.Key,'return')&&strcmp(hLoadButton.Enable,'on'))
            doLoad();
        end
    end

    function doBrowse(varargin)
        if(currentlyBrowsing)
            return;
        end
        currentlyBrowsing=true;

        if~useAppContainer
            path=hFolderTextBox.String;
        else
            path=hFolderTextBox.Value;
        end

        dirname=uigetdir(path,vision.getMessage('vision:labeler:SelectFolder'));
        if(dirname~=0)
            folderAbsolutePath=dirname;
            if~useAppContainer
                hFolderTextBox.String=folderAbsolutePath;
            else
                hFolderTextBox.Value=folderAbsolutePath;
            end
        end
        currentlyBrowsing=false;
    end

    function doImport(varargin)
        variableTypes={'duration'};
        variableDisp={'duration'};
        [timestampsVarDlg,timestampsStrDlg,isCanceled]=vision.internal.uitools.getVariablesFromWS(variableTypes,variableDisp);
        if(~isCanceled)
            timestampsStr=timestampsStrDlg;
            timestampsVar=timestampsVarDlg;
            if~useAppContainer
                set(hTimestampsStrTextBox,'String',timestampsStr);
            else
                set(hTimestampsStrTextBox,'Value',timestampsStr);
            end

            hLoadButton.Enable='on';
        end
    end

    function selectTimestampsSource(~,callbackdata)
        switch get(callbackdata.NewValue,'Tag')
        case 'DefaultTSRadioButton'
            importTimestampsFlag=false;
            hImportButton.Enable='off';
            hTimestampsStrTextBox.Enable='off';
            hLoadButton.Enable='on';
        case 'ImportFromWSRadioButton'
            importTimestampsFlag=true;
            hImportButton.Enable='on';
            hTimestampsStrTextBox.Enable='on';

            if~isempty(timestampsStr)
                hLoadButton.Enable='on';
            else
                hLoadButton.Enable='off';
            end
        end
    end

    function doCancel(varargin)
        userCancelled=true;

        imgDatastore=[];
        timestamps=[];

        if(~currentlyLoading)
            delete(loadDirDialog);
        end
    end

    function doLoad(varargin)
        drawnow;
        if~useAppContainer
            folderAbsolutePath=hFolderTextBox.String;
        else
            folderAbsolutePath=hFolderTextBox.Value;
        end
        folderAbsolutePath=strtrim(folderAbsolutePath);

        import vision.internal.videoLabeler.validation.*

        if(isdir(folderAbsolutePath))
            disableControls();

            try
                imgDatastore=imageDatastore(folderAbsolutePath);
            catch
                errorMessage=vision.getMessage('vision:labeler:NoImageSequenceFound',folderAbsolutePath);
                dialogName=vision.getMessage('vision:labeler:NoImageSequenceFoundTitle');
                vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
                enableControls();

                return;
            end



            if isempty(imgDatastore.Files)
                msg=vision.getMessage('vision:labeler:NoImageSequenceFound',folderAbsolutePath);
                title=vision.getMessage('vision:labeler:NoImageSequenceFoundTitle');
                vision.internal.labeler.handleAlert(loadDirDialog,'warndlg',msg,title)
                imgDatastore=[];
                enableControls();

                return;
            end

            try
                vision.internal.labeler.validation.validateImageSequence(imgDatastore);
            catch ME
                errorMessage=vision.getMessage(ME.identifier);
                dialogName=vision.getMessage('vision:labeler:InvalidImageSequenceTitle');
                vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
                enableControls();

                return;
            end


            previousLocations={folderAbsolutePath};

            if~importTimestampsFlag

                numImages=numel(imgDatastore.Files);
                timestamps=seconds((0:numImages-1)');
            else

                if isempty(timestampsVar)
                    timestamps=[];
                    errorMessage=vision.getMessage('vision:labeler:ImportTimeStampsFirst');
                    dialogName=vision.getMessage('vision:labeler:ImportTimeStampsFirstTitle');
                    vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
                    enableControls();
                    return;
                end

                timestamps=timestampsVar;

                try
                    vision.internal.labeler.validation.validateTimestamps(timestamps);
                catch ME
                    timestamps=[];
                    errorMessage=vision.getMessage(ME.identifier);
                    dialogName=vision.getMessage('vision:labeler:InvalidTimestampsTitle');
                    vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
                    enableControls();
                    return;
                end

                try
                    vision.internal.labeler.validation.checkImageSequenceAndTimestampsAgreement(imgDatastore,timestamps)
                catch ME
                    errorMessage=vision.getMessage(ME.identifier);
                    dialogName=vision.getMessage('vision:labeler:TimestampsMismatchTitle');
                    vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
                    enableControls();
                    return;
                end
            end

            delete(loadDirDialog);

        else
            errorMessage=vision.getMessage('vision:labeler:InvalidFolder',folderAbsolutePath);
            dialogName=vision.getMessage('vision:labeler:InvalidFolderTitle');
            vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
        end
    end
    function updateFolderValue(src,evt)

    end
    function updatingFolderValue(src,evt)

    end
    function enableControls()

        if~useAppContainer
            hLoadButton.String=vision.getMessage('vision:labeler:Load');
        else
            hLoadButton.Value=vision.getMessage('vision:labeler:Load');
        end
        hLoadButton.Enable='on';
        hCancelButton.Enable='on';
        hFolderTextBox.Enable='on';
        hBrowseButton.Enable='on';


        if importTimestampsFlag
            hImportButton.Enable='on';
            hTimestampsStrTextBox.Enable='on';
        end
        hImportFromWSRadioButton.Enable='on';
        hDefaultRadioButton.Enable='on';
        currentlyLoading=false;
        drawnow;
    end

    function disableControls()

        if~useAppContainer
            hLoadButton.String=vision.getMessage('vision:labeler:Loading');
        else
            hLoadButton.Text=vision.getMessage('vision:labeler:Loading');
        end
        hLoadButton.Enable='off';
        hCancelButton.Enable='off';
        hFolderTextBox.Enable='off';
        hBrowseButton.Enable='off';
        hDefaultRadioButton.Enable='off';
        hImportFromWSRadioButton.Enable='off';
        hImportButton.Enable='off';
        hTimestampsStrTextBox.Enable='off';
        currentlyLoading=true;
        drawnow;
    end

    loadDirDialog.Units='pixels';
    if(nargin==1)

        loadDirDialog.Position=imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(...
        groupName,loadDirDialog.Position(3:4));
        movegui(loadDirDialog,'onscreen');
    end


    uiwait(loadDirDialog);
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end