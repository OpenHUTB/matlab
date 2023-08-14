




classdef SplitDicomFolderDlg<vision.internal.uitools.OkSkipDlg
    properties
        FolderPath;
    end

    properties(Access=private)
        Prompt;
        EditBox;
        FolderTextBox;
        BrowseButton;

        PromptX=10;
        PromptY=55;
        EditBoxX=170;
        BrowseX=210;

        CurrentlyBrowsing=false;
    end

    methods

        function this=SplitDicomFolderDlg(tool,previousPath)

            dlgTitle=vision.getMessage('vision:imageLabeler:dicomSplitDlgTitle');

            this=this@vision.internal.uitools.OkSkipDlg(tool,dlgTitle);

            this.FolderPath=previousPath;

            if isempty(this.FolderPath)
                this.FolderPath=pwd;
            end

            this.DlgSize=[300,200];
            createDialog(this);

            addDirectoryPrompt(this);
            addDirectoryBox(this);
            addBrowseButton(this);
        end
    end

    methods(Access=private)


        function addDirectoryBox(this)


            this.FolderTextBox=uicontrol('Parent',this.Dlg,...
            'Style','edit',...
            'Position',[this.PromptX,this.PromptY,190,25],...
            'String',this.FolderPath,...
            'HorizontalAlignment','left',...
            'BackgroundColor',[1,1,1],...
            'KeyPressFcn',@this.doLoadIfEntered,...
            'Tag','InputFolderTextBox');
        end


        function addBrowseButton(this)


            if isWebFigure(this)
                this.BrowseButton=uibutton('Parent',this.Dlg,...
                'Text',vision.getMessage('vision:labeler:Browse'),...
                'Position',[this.BrowseX,this.PromptY,80,25],...
                'ButtonPushedFcn',@this.doBrowse,...
                'Tag','BrowseButton');
            else
                this.BrowseButton=uicontrol('Parent',this.Dlg,...
                'Style','pushbutton',...
                'Position',[this.BrowseX,this.PromptY,80,25],...
                'Callback',@this.doBrowse,...
                'String',vision.getMessage('vision:labeler:Browse'),...
                'Tag','BrowseButton');
            end
        end


        function addDirectoryPrompt(this)
            uicontrol('Parent',this.Dlg,...
            'Style','text',...
            'Position',[this.PromptX,this.PromptY+30,280,90],...
            'HorizontalAlignment','left',...
            'String',vision.getMessage('vision:imageLabeler:dicomSplitFolderPrompt'));
        end


        function addTextBox(this)
            uicontrol('Parent',this.Dlg,...
            'Style','text',...
            'Position',[this.PromptX,40,280,40],...
            'HorizontalAlignment','left',...
            'String',vision.getMessage('vision:labeler:PixelExportMessage'));
        end
    end

    methods(Access=protected)

        function onOK(this,~,~)
            this.FolderPath=get(this.FolderTextBox,'String');

            if~isfolder(this.FolderPath)

                errorMessage=vision.getMessage('vision:labeler:InvalidFolder',this.FolderPath);
                dialogName=vision.getMessage('vision:labeler:InvalidFolderTitle');
                vision.internal.labeler.handleAlert(this.Dlg,'error',errorMessage,dialogName);
                return
            end

            this.IsSkipped=false;
            close(this);

        end


        function doLoadIfEntered(this,~,event)
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
            dirname=uigetdir(this.FolderTextBox.String,vision.getMessage('vision:labeler:TempDirectoryTitle'));

            if(dirname~=0)
                this.FolderPath=dirname;
                this.FolderTextBox.String=this.FolderPath;
            end
            this.CurrentlyBrowsing=false;
        end

    end

end


function tf=isWebFigure(this)
    tf=isa(getCanvas(this.Dlg),'matlab.graphics.primitive.canvas.HTMLCanvas');
end
