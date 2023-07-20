classdef MandatoryDirectoryDialogFigure<vision.internal.imageLabeler.tool.dialogs.DialogFigure






    properties(GetAccess=public,SetAccess=protected)

Accept
Browse
DirTextbox

Directory

    end

    properties(Access=private)

FolderAbsolutePath
GroupName
CurrentlyBrowsing

PreviousLocations

    end

    methods

        function self=MandatoryDirectoryDialogFigure(dlgSize,dlgCenter,groupName)

            dlgTitle=vision.getMessage('vision:labeler:TempDirectoryTitle');
            self=self@vision.internal.imageLabeler.tool.dialogs.DialogFigure(dlgCenter,dlgTitle);

            self.Size=dlgSize;
            self.GroupName=groupName;

            setup(self);
            create(self);
            self.FigureHandle.CloseRequestFcn=@(~,~)images.roi.internal.emptyCallback();
        end

        function create(self)

            create@vision.internal.imageLabeler.tool.dialogs.DialogFigure(self);

            self.addBrowse();
            self.addAccept();

        end

    end

    methods(Access=private)

        function setup(self)




            if(isempty(self.PreviousLocations)||isempty(self.PreviousLocations{1}))
                folderAbsolutePath=pwd;
            else

                folderAbsolutePath=self.PreviousLocations{1};
            end

            self.FolderAbsolutePath=folderAbsolutePath;
        end

        function addBrowse(self)

            pos=[self.ButtonSpace,3*self.ButtonSpace+self.ButtonSize(2),...
            self.Size(1)-3*self.ButtonSpace-self.ButtonSize(1),self.ButtonSize(2)];
            self.DirTextbox=uicontrol('style','edit',...
            'Parent',self.FigureHandle,...
            'HorizontalAlignment','left',...
            'Tag','InputFolderTextBox',...
            'String',self.FolderAbsolutePath,...
            'FontSize',11,...
            'Position',pos,...
            'KeyPressFcn',@self.doAcceptIfEntered);

            pos=[self.Size(1)-self.ButtonSpace-self.ButtonSize(1),...
            3*self.ButtonSpace+self.ButtonSize(2),self.ButtonSize];
            self.Browse=uicontrol('style','pushbutton',...
            'Parent',self.FigureHandle,...
            'Callback',@(~,~)browseClicked(self),...
            'FontSize',11,...
            'Position',pos,...
            'String',vision.getMessage('vision:labeler:Browse'),...
            'Tag','BrowseButton');


        end

        function addAccept(self)

            self.Accept=uicontrol('style','pushbutton',...
            'Parent',self.FigureHandle,...
            'Callback',@(~,~)acceptClicked(self),...
            'FontSize',11,...
            'Position',[self.Size(1)-self.ButtonSpace-self.ButtonSize(1),self.ButtonSpace,self.ButtonSize],...
            'String',vision.getMessage('vision:labeler:Accept'),...
            'Tag','Accept');

        end

    end


    methods(Access=protected)

        function doAcceptIfEntered(self,~,event)
            if(strcmp(event.Key,'return')&&strcmp(self.Accept.Enable,'on'))
                self.acceptClicked();
            end
        end

        function acceptClicked(self)

            drawnow;
            self.FolderAbsolutePath=self.DirTextbox.String;
            self.FolderAbsolutePath=strtrim(self.FolderAbsolutePath);

            if(isfolder(self.FolderAbsolutePath))
                tempDirectory=fullfile(self.FolderAbsolutePath,['Labeler_',self.GroupName]);
                status=mkdir(tempDirectory);
                if status

                    self.PreviousLocations={self.FolderAbsolutePath};
                    self.Directory=tempDirectory;
                else
                    errorMessage=vision.getMessage('vision:labeler:UnableToWrite',self.FolderAbsolutePath);
                    dialogName=vision.getMessage('vision:labeler:UnableToWriteTitle');
                    errordlg(errorMessage,dialogName);
                    return
                end

            else
                errorMessage=vision.getMessage('vision:labeler:InvalidFolder',self.FolderAbsolutePath);
                dialogName=vision.getMessage('vision:labeler:InvalidFolderTitle');
                errordlg(errorMessage,dialogName);
            end

            delete(self.FigureHandle);
            close(self);

        end

        function browseClicked(self)

            if(self.CurrentlyBrowsing)
                return;
            end
            self.CurrentlyBrowsing=true;

            dirname=uigetdir(self.DirTextbox.String,vision.getMessage('vision:labeler:TempDirectoryTitle'));
            if(dirname~=0)
                self.FolderAbsolutePath=dirname;
                self.DirTextbox.String=self.FolderAbsolutePath;
            end

            self.CurrentlyBrowsing=false;

        end

        function keyPress(self,evt)

            switch(evt.Key)
            case{'return','space'}
                acceptClicked(self);
            end

        end

    end

end