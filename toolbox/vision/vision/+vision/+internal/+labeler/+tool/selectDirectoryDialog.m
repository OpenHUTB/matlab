function[imgDirectory,gTruthFilename,userCancelled]=selectDirectoryDialog(groupName)




    imgDirectory=[];
    gTruthFilename=[];
    userCancelled=false;

    currentlyLoading=false;

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

    dlgHeight=12;
    loadDirDialog=dialog(...
    'Name',vision.getMessage('vision:labeler:TempDirectoryTitle'),...
    'Units','char',...
    'Position',[0,0,100,dlgHeight],...
    'Visible','off',...
    'Tag','LoadDirDialog');
    loadDirDialog.CloseRequestFcn=@doCancel;
    movegui(loadDirDialog,'center');

    if~useAppContainer

        uicontrol('Parent',loadDirDialog,...
        'Style','text',...
        'Units','char',...
        'Position',[1,dlgHeight-2,100,1.5],...
        'HorizontalAlignment','left',...
        'String',vision.getMessage('vision:labeler:TempDirectoryDialog'));


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
        'String',vision.getMessage('vision:labeler:Accept'),...
        'Enable','on',...
        'Tag','LoadButton');
    else


        uilabel('Parent',loadDirDialog,...
        'Position',[6,140,600,21],...
        'HorizontalAlignment','left',...
        'Text',vision.getMessage('vision:labeler:TempDirectoryDialog'));


        hFolderTextBox=uieditfield('Parent',loadDirDialog,...
        'Position',[6,112,480,21],...
        'Value',folderAbsolutePath,...
        'HorizontalAlignment','left',...
        'ValueChangingFcn',@doLoadIfEntered,...
        'Tag','InputFolderTextBox');


        currentlyBrowsing=false;
        hBrowseButton=uibutton('Parent',loadDirDialog,...
        'Position',[510,112,84,21],...
        'ButtonPushedFcn',@doBrowse,...
        'Text',vision.getMessage('vision:labeler:Browse'),...
        'Tag','BrowseButton');


        hCancelButton=uibutton('Parent',loadDirDialog,...
        'ButtonPushedFcn',@doCancel,...
        'Position',[510,14,84,21],...
        'Text',vision.getMessage('vision:labeler:Cancel'),...
        'Tag','CancelButton');


        hLoadButton=uibutton('Parent',loadDirDialog,...
        'ButtonPushedFcn',@doLoad,...
        'Position',[390,14,96,21],...
        'Text',vision.getMessage('vision:labeler:Accept'),...
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
        dirname=uigetdir(hFolderTextBox.String,vision.getMessage('vision:labeler:TempDirectoryTitle'));
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


    function doCancel(varargin)
        userCancelled=true;

        imgDirectory=[];

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

        if(isdir(folderAbsolutePath))
            tempDirectory=fullfile(folderAbsolutePath,['Labeler_',groupName]);
            status=mkdir(tempDirectory);
            if status

                previousLocations={folderAbsolutePath};
                imgDirectory=tempDirectory;
                delete(loadDirDialog);
            else
                errorMessage=vision.getMessage('vision:labeler:UnableToWrite',folderAbsolutePath);
                dialogName=vision.getMessage('vision:labeler:UnableToWriteTitle');
                vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
            end

        else
            errorMessage=vision.getMessage('vision:labeler:InvalidFolder',folderAbsolutePath);
            dialogName=vision.getMessage('vision:labeler:InvalidFolderTitle');
            vision.internal.labeler.handleAlert(loadDirDialog,'error',errorMessage,dialogName);
        end
    end

    loadDirDialog.Units='pixels';
    loadDirDialog.Visible='on';
    uiwait(loadDirDialog);
end

function tf=useAppContainer
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end