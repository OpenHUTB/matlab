function[customReaderFunctionHandle,sourceName,timestamps,userCancelled]=loadCustomReaderDialog(varargin)



    narginchk(0,2);

    if(nargin==2)
        isVideoLabeler=varargin{1};
        groupName=varargin{2};
        argumentPassed=1;
    elseif nargin==1
        isVideoLabeler=varargin{1};
        isVideoLabeler=true;
        argumentPassed=0;
    else
        isVideoLabeler=true;
        argumentPassed=0;
    end

    customReaderFunctionHandle=[];
    sourceName=[];
    timestamps=[];
    userCancelled=false;

    absolutePathFileName=[];
    timestampsVar=[];
    timestampsStr='';

    currentlyLoading=false;

    persistent previousFunctionName;
    persistent previousSourceName;


    needToInitPath=isempty(previousFunctionName);
    if needToInitPath
        previousFunctionName='';
    end

    needToInitSourceName=isempty(previousSourceName);
    if needToInitSourceName
        previousSourceName='';
    end

    functionName=previousFunctionName;
    sourceName=previousSourceName;

    dlgWidth=90;
    dlgHeight=18;


    if~useAppContainer
        loadDirDialog=dialog(...
        'Name',vision.getMessage('vision:labeler:LoadCustomReaderTitle'),...
        'Units','char',...
        'Position',[0,0,dlgWidth,dlgHeight],...
        'Visible','off',...
        'Tag','LoadDirDialog');
        loadDirDialog.CloseRequestFcn=@doCancel;
        movegui(loadDirDialog,'center');

        uicontrol('Parent',loadDirDialog,...
        'Style','text',...
        'Units','char',...
        'Position',[2,dlgHeight-3,dlgWidth-5,1.5],...
        'HorizontalAlignment','left',...
        'String',vision.getMessage('vision:labeler:SpecifyCustomReaderFunction'));


        editBoxWidth=50;
        hCustomReaderTextBox=uicontrol('Parent',loadDirDialog,...
        'Style','edit',...
        'Units','char',...
        'Position',[32,dlgHeight-3,editBoxWidth,1.5],...
        'String',functionName,...
        'HorizontalAlignment','left',...
        'Callback',@customFunctionCallback,...
        'Tag','CustomReaderTextBox');


        uicontrol('Parent',loadDirDialog,...
        'Style','text',...
        'Units','char',...
        'Position',[2,dlgHeight-5,dlgWidth-5,1.5],...
        'HorizontalAlignment','left',...
        'String',vision.getMessage('vision:labeler:SpecifySourceName'));


        hDataSourceNameTextBox=uicontrol('Parent',loadDirDialog,...
        'Style','edit',...
        'Units','char',...
        'Position',[32,dlgHeight-5,editBoxWidth,1.5],...
        'String',sourceName,...
        'HorizontalAlignment','left',...
        'Callback',@customSourceCallback,...
        'Tag','DataSourceNameTextBox');


        hImportButton=uicontrol('Parent',loadDirDialog,...
        'Style','pushbutton',...
        'Callback',@doImport,...
        'Units','char',...
        'Position',[2,dlgHeight-9,40,3],...
        'String',vision.getMessage('vision:labeler:ImportTS'),...
        'HorizontalAlignment','left',...
        'Tag','ImportButton');


        hTimestampsStrTextBox=uicontrol('Parent',loadDirDialog,...
        'Style','text',...
        'Units','char',...
        'Position',[47,dlgHeight-9,40,2],...
        'String',timestampsStr,...
        'FontWeight','bold',...
        'HorizontalAlignment','left',...
        'Tag','TimestampTextBox');

        hTextPanel=uipanel('Parent',loadDirDialog,...
        'Units','char',...
        'Position',[2,dlgHeight-15,40,3],...
        'BorderType','none');


        uicontrol('Parent',hTextPanel,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0,0,1,1],...
        'ForegroundColor',[0,0,1],...
        'String',vision.getMessage('vision:labeler:CustomReaderHelpText'),...
        'Enable','inactive',...
        'ButtonDown',@launchURL,...
        'HorizontalAlignment','left');


        hCancelButton=uicontrol('Parent',loadDirDialog,...
        'Style','pushbutton',...
        'Callback',@doCancel,...
        'Units','char',...
        'Position',[67,1,14,1.5],...
        'String',vision.getMessage('vision:labeler:Cancel'),...
        'Tag','CancelButton');


        hLoadButton=uicontrol('Parent',loadDirDialog,...
        'Style','pushbutton',...
        'Callback',@doLoad,...
        'Units','char',...
        'Position',[47,1,16,1.5],...
        'String',vision.getMessage('vision:labeler:Load'),...
        'Enable','off',...
        'Tag','LoadButton');

    else
        loadDirDialog=uifigure(...
        'Name',vision.getMessage('vision:labeler:LoadCustomReaderTitle'),...
        'Position',[455,275,630,288],...
        'Visible','on',...
        'Tag','LoadDirDialog',...
        'Resize','off');
        loadDirDialog.CloseRequestFcn=@doCancel;

        uilabel('Parent',loadDirDialog,...
        'Position',[2,dlgHeight-3,dlgWidth-5,1.5].*[6,14,6,14],...
        'HorizontalAlignment','left',...
        'Text',vision.getMessage('vision:labeler:SpecifyCustomReaderFunction'));


        editBoxWidth=50;
        hCustomReaderTextBox=uieditfield('Parent',loadDirDialog,...
        'Position',[32,dlgHeight-3,editBoxWidth,1.5].*[6,14,6,14],...
        'Value',functionName,...
        'HorizontalAlignment','left',...
        'ValueChangedFcn',@customFunctionCallback,...
        'Tag','CustomReaderTextBox');


        uilabel('Parent',loadDirDialog,...
        'Position',[2,dlgHeight-5,dlgWidth-5,1.5].*[6,14,6,14],...
        'HorizontalAlignment','left',...
        'Text',vision.getMessage('vision:labeler:SpecifySourceName'));


        hDataSourceNameTextBox=uieditfield('Parent',loadDirDialog,...
        'Position',[32,dlgHeight-5,editBoxWidth,1.5].*[6,14,6,14],...
        'Value',sourceName,...
        'HorizontalAlignment','left',...
        'ValueChangedFcn',@customSourceCallback,...
        'Tag','DataSourceNameTextBox');


        hImportButton=uibutton('Parent',loadDirDialog,...
        'ButtonPushedFcn',@doImport,...
        'Position',[2,dlgHeight-9,40,3].*[6,14,6,14],...
        'Text',vision.getMessage('vision:labeler:ImportTS'),...
        'Tag','ImportButton');


        hTimestampsStrTextBox=uilabel('Parent',loadDirDialog,...
        'Position',[47,dlgHeight-9,40,2].*[6,14,6,14],...
        'Text',timestampsStr,...
        'FontWeight','bold',...
        'HorizontalAlignment','left',...
        'Tag','TimestampTextBox');

        hTextPanel=uipanel('Parent',loadDirDialog,...
        'Units','pixels',...
        'Position',[2,dlgHeight-15,40,3].*[6,14,6,14],...
        'BorderType','none');
        hLink=uihyperlink('Parent',hTextPanel,...
        'HyperlinkClickedFcn',@(src,evt)helpview(fullfile(docroot,'toolbox','vision','vision.map'),'customReader'),...
        'Text',vision.getMessage('vision:labeler:CustomReaderHelpText'),...
        'Enable','on',...
        'HorizontalAlignment','left',...
        'FontColor','b');
        textLen=numel(hLink.Text);
        hLink.Position=[6,1,textLen*14,20];


        hCancelButton=uibutton('Parent',loadDirDialog,...
        'ButtonPushedFcn',@doCancel,...
        'Position',[67,1,14,1.5].*[6,14,6,14],...
        'Text',vision.getMessage('vision:labeler:Cancel'),...
        'Tag','CancelButton');


        hLoadButton=uibutton('Parent',loadDirDialog,...
        'ButtonPushedFcn',@doLoad,...
        'Position',[47,1,16,1.5].*[6,14,6,14],...
        'Text',vision.getMessage('vision:labeler:Load'),...
        'Enable','off',...
        'Tag','LoadButton');
    end



    function customFunctionCallback(~,~)
        drawnow;
        if~useAppContainer
            cond1=~isempty(strtrim(hTimestampsStrTextBox.String));
            cond2=~isempty(strtrim(hCustomReaderTextBox.String));
            cond3=~isempty(strtrim(hDataSourceNameTextBox.String));
        else
            cond1=~isempty(strtrim(hTimestampsStrTextBox.Text));
            cond2=~isempty(strtrim(hCustomReaderTextBox.Value));
            cond3=~isempty(strtrim(hDataSourceNameTextBox.Value));
        end
        if cond1&&cond2&&cond3

            hLoadButton.Enable='on';
        else
            hLoadButton.Enable='off';
        end
        drawnow;
    end

    function customSourceCallback(~,~)
        drawnow;
        if~useAppContainer
            cond1=~isempty(strtrim(hTimestampsStrTextBox.String));
            cond2=~isempty(strtrim(hCustomReaderTextBox.String));
            cond3=~isempty(strtrim(hDataSourceNameTextBox.String));
        else
            cond1=~isempty(strtrim(hTimestampsStrTextBox.Text));
            cond2=~isempty(strtrim(hCustomReaderTextBox.Value));
            cond3=~isempty(strtrim(hDataSourceNameTextBox.Value));
        end
        if cond1&&cond2&&cond3

            hLoadButton.Enable='on';
        else
            hLoadButton.Enable='off';
        end

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
                cond=~isempty(strtrim(hCustomReaderTextBox.String))&&~isempty(strtrim(hDataSourceNameTextBox.String));
            else
                set(hTimestampsStrTextBox,'Text',timestampsStr);
                cond=~isempty(strtrim(hCustomReaderTextBox.Value))&&~isempty(strtrim(hDataSourceNameTextBox.Value));
            end
            if cond

                hLoadButton.Enable='on';
            else
                hLoadButton.Enable='off';
            end
            drawnow;
        end
    end

    function launchURL(varargin)
        helpview(fullfile(docroot,'toolbox','vision','vision.map'),'customReader');
    end

    function doCancel(varargin)
        userCancelled=true;

        customReaderFunctionHandle=[];
        sourceName=[];
        timestamps=[];

        if(~currentlyLoading)
            delete(loadDirDialog);
        end
    end

    function doLoad(varargin)
        drawnow;
        if~useAppContainer
            functionName=hCustomReaderTextBox.String;
            sourceName=hDataSourceNameTextBox.String;
        else
            functionName=hCustomReaderTextBox.Value;
            sourceName=hDataSourceNameTextBox.Value;
        end

        functionName=strtrim(functionName);
        sourceName=strtrim(sourceName);

        import vision.internal.videoLabeler.validation.*

        absolutePathFileName=which(functionName);

        if(isempty(absolutePathFileName))
            errorMessage=vision.getMessage('vision:labeler:pathNotFound',functionName);
            dialogName=vision.getMessage('vision:labeler:pathNotFoundTitle');
            vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
            enableControls();

            return;
        end

        [~,fileName,fileExt]=fileparts(absolutePathFileName);

        if(exist(fileName,'file')&&strcmpi(fileExt,'.m'))
            disableControls();


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
                errorMessage=ME.message;
                dialogName=vision.getMessage('vision:labeler:InvalidTimestampsTitle');
                vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
                enableControls();
                return;
            end


            try
                customReaderFunctionHandle=str2func(fileName);
                vision.internal.labeler.validation.validateCustomReaderFunction(customReaderFunctionHandle,sourceName,timestamps)
            catch ME
                customReaderFunctionHandle=[];
                errorMessage=ME.message;
                dialogName=vision.getMessage('vision:labeler:InvalidCustomReaderTitle');
                vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
                enableControls();

                return;
            end


            previousFunctionName=functionName;
            previousSourceName=sourceName;

            delete(loadDirDialog);

        else
            errorMessage=vision.getMessage('vision:labeler:CustomReaderNotValid',functionName);
            dialogName=vision.getMessage('vision:labeler:CustomReaderNotValidTitle');
            vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
        end
    end

    function enableControls()

        if~useAppContainer
            hLoadButton.String=vision.getMessage('vision:labeler:Load');
        else
            hLoadButton.Text=vision.getMessage('vision:labeler:Load');
        end
        hLoadButton.Enable='on';
        hCancelButton.Enable='on';
        hCustomReaderTextBox.Enable='on';
        hImportButton.Enable='on';
        hTimestampsStrTextBox.Enable='on';
        hDataSourceNameTextBox.Enable='on';
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
        hCustomReaderTextBox.Enable='off';
        hImportButton.Enable='off';
        hTimestampsStrTextBox.Enable='off';
        hDataSourceNameTextBox.Enable='off';
        currentlyLoading=true;
        drawnow;
    end

    loadDirDialog.Units='pixels';
    if(nargin==1)

        if~useAppContainer
            loadDirDialog.Position=imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(...
            groupName,loadDirDialog.Position(3:4));
            movegui(loadDirDialog,'onscreen');
        end
    end

    loadDirDialog.Visible='on';
    uiwait(loadDirDialog);
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end