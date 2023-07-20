




classdef ExportPixelLabelDlg<vision.internal.uitools.OkCancelDlg
    properties
        VarName;
        VarPath;
        CreatedDirectory;
    end

    properties(Access=private)
        Prompt;
        EditBox;
        FolderTextBox;
        BrowseButton;

        ToFile;

        PromptX=10;
        EditBoxX=170;
        BrowseX=210;

        CurrentlyBrowsing=false;
    end

    methods

        function this=ExportPixelLabelDlg(tool,paramsVarName,dlgTitle,previousPath,toFile)

            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);

            this.VarPath=previousPath;

            if isempty(this.VarPath)
                this.VarPath=pwd;
            end

            this.ToFile=toFile;

            this.VarName=paramsVarName;
            if this.ToFile
                this.Prompt=getString(message('vision:labeler:ExportDirectoryGroundTruthFile'));
            else
                this.Prompt=getString(message('vision:uitools:ExportPrompt'));
            end

            this.DlgSize=[300,200];
            createDialog(this);

            addParamsVarPrompt(this);
            addParamsVarEditBox(this);
            addDirectoryPrompt(this);
            addHelpTextForPixel(this);
            addDirectoryBox(this);
            addBrowseButton(this);

            if this.ToFile
                addTextBox(this);
            end
        end
    end

    methods(Access=private)

        function addParamsVarPrompt(this)
            if~useAppContainer()
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Position',[this.PromptX,87,220,20],...
                'HorizontalAlignment','left',...
                'String',this.Prompt,...
                'ToolTipString',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            else
                uilabel('Parent',this.Dlg,...
                'Position',[this.PromptX,87,220,20],...
                'HorizontalAlignment','left',...
                'Text',this.Prompt,...
                'ToolTip',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            end

        end


        function addParamsVarEditBox(this)
            if~useAppContainer()
                this.EditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String',this.VarName,...
                'Position',[this.EditBoxX,87,120,25],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varEditBox',...
                'ToolTipString',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            else
                this.EditBox=uieditfield('Parent',this.Dlg,...
                'Value',this.VarName,...
                'Position',[this.EditBoxX,87,120,25],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varEditBox',...
                'ToolTip',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            end

        end


        function addDirectoryBox(this)

            if~useAppContainer()
                this.FolderTextBox=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'Position',[this.PromptX,140,190,25],...
                'String',this.VarPath,...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'KeyPressFcn',@this.doKeyPress,...
                'Tag','InputFolderTextBox');
            else
                this.FolderTextBox=uieditfield('Parent',this.Dlg,...
                'Position',[this.PromptX,140,190,25],...
                'Value',this.VarPath,...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','InputFolderTextBox');
            end

        end


        function addBrowseButton(this)

            if useAppContainer()
                this.BrowseButton=uibutton('Parent',this.Dlg,...
                'Text',vision.getMessage('vision:labeler:Browse'),...
                'Position',[this.BrowseX,140,80,25],...
                'ButtonPushedFcn',@this.doBrowse,...
                'Tag','BrowseButton');
            else
                this.BrowseButton=uicontrol('Parent',this.Dlg,...
                'Style','pushbutton',...
                'Position',[this.BrowseX,140,80,25],...
                'Callback',@this.doBrowse,...
                'String',vision.getMessage('vision:labeler:Browse'),...
                'Tag','BrowseButton');
            end
        end


        function addDirectoryPrompt(this)
            if~useAppContainer()
                uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'Position',[this.PromptX,160,280,30],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ExportPixelDirectoryDialog'));
            else
                uilabel('Parent',this.Dlg,...
                'Position',[this.PromptX,160,280,30],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ExportPixelDirectoryDialog'));
            end

        end


        function addHelpTextForPixel(this)
            if useAppContainer
                hLink=matlab.ui.control.Hyperlink('Parent',this.Dlg);
                hLink.Position=[this.PromptX,110,280,25];
                hLink.FontColor=[0,0,1];
                hLink.Text=vision.getMessage('vision:labeler:PixelDirectoryHelpText');
                hLink.HyperlinkClickedFcn=@(src,event)web(fullfile(docroot,'vision/ug/labeler-pixel-label-data-storage.html'));
            else
                uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'Position',[this.PromptX,110,280,25],...
                'ForegroundColor',[0,0,1],...
                'ButtonDown',@launchURL,...
                'Enable','inactive',...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:PixelDirectoryHelpText'));
            end


            function launchURL(varargin)
                helpview(fullfile(docroot,'toolbox','vision','vision.map'),'categoricalLabelMatrix');
            end
        end


        function addTextBox(this)
            if~useAppContainer
                uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'Position',[this.PromptX,40,280,40],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:PixelExportMessage'));
            else
                uilabel('Parent',this.Dlg,...
                'Position',[this.PromptX,40,280,40],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:PixelExportMessage'));
            end
        end
    end

    methods(Access=protected)

        function onOK(this,~,~)
            if~useAppContainer
                this.VarName=get(this.EditBox,'String');
                this.VarPath=get(this.FolderTextBox,'String');
            else
                this.VarName=get(this.EditBox,'Value');
                this.VarPath=get(this.FolderTextBox,'Value');
            end

            if~isvarname(this.VarName)
                if~this.ToFile

                    msg=getString(message('vision:uitools:invalidExportVariable'));
                    title=getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle'));
                    vision.internal.labeler.handleAlert(this.Dlg,'error',msg,title);
                    return
                end
            elseif~isfolder(this.VarPath)

                errorMessage=vision.getMessage('vision:labeler:InvalidFolder',this.VarPath);
                dialogName=vision.getMessage('vision:labeler:InvalidFolderTitle');
                vision.internal.labeler.handleAlert(this.Dlg,'error',errorMessage,dialogName);
                return
            end

            if this.ToFile

                varAlreadyExists=exist([fullfile(this.VarPath,this.VarName),'.mat'],'file')==2;
            else

                varAlreadyExists=false;
            end

            if varAlreadyExists

                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
                cancel=vision.getMessage('MATLAB:uistring:popupdialogs:Cancel');

                selection=askToOverwrite(this);

                switch selection
                case yes

                case no
                    return;
                case cancel
                    this.IsCanceled=true;
                    onCancel(this);
                    return;
                end

            end


            tempDirectory=fullfile(this.VarPath,'PixelLabelData');
            idx=1;

            while isfolder(tempDirectory)

                tempDirectory=fullfile(this.VarPath,['PixelLabelData_',num2str(idx)]);
                idx=idx+1;
            end

            status=mkdir(tempDirectory);

            if status
                this.CreatedDirectory=tempDirectory;
                this.IsCanceled=false;
                close(this);
            else
                errorMessage=vision.getMessage('vision:labeler:UnableToWrite',this.VarPath);
                dialogName=vision.getMessage('vision:labeler:UnableToWriteTitle');
                vision.internal.labeler.handleAlert(this.Dlg,'error',errorMessage,dialogName);
            end
        end


        function onKeyPress(this,~,event)
            if(strcmp(event.Key,'return')&&strcmp(this.OkButton.Enable,'on'))
                drawnow;
                this.onOK();
            end
        end


        function doBrowse(this,varargin)
            if(this.CurrentlyBrowsing)
                return;
            end
            this.CurrentlyBrowsing=true;
            if~useAppContainer
                folderText=this.FolderTextBox.String;
            else
                folderText=this.FolderTextBox.Value;
            end

            dirname=uigetdir(folderText,vision.getMessage('vision:labeler:TempDirectoryTitle'));

            if(dirname~=0)
                this.VarPath=dirname;
                if~useAppContainer
                    this.FolderTextBox.String=this.VarPath;
                else
                    this.FolderTextBox.Value=this.VarPath;
                end
            end
            this.CurrentlyBrowsing=false;
        end


        function selection=askToOverwrite(this)

            yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
            cancel=vision.getMessage('MATLAB:uistring:popupdialogs:Cancel');

            selection=vision.internal.labeler.handleAlert(this.Dlg,'question',vision.getMessage...
            ('vision:uitools:ExportOverwrite',this.VarName),...
            vision.getMessage('vision:uitools:ExportOverwriteTitle'),...
            yes,no,cancel,yes);

            if isempty(selection)
                selection=cancel;
            end
        end

    end

end

function tf=useAppContainer
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end
