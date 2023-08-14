classdef MandatoryDirectoryDialog<images.internal.app.utilities.Dialog




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

        function self=MandatoryDirectoryDialog(dlgSize,dlgCenter,groupName)

            dlgTitle=vision.getMessage('vision:labeler:TempDirectoryTitle');
            self=self@images.internal.app.utilities.Dialog(dlgCenter,dlgTitle);

            self.Size=dlgSize;
            self.GroupName=groupName;

            setup(self);
            create(self);
            self.FigureHandle.CloseRequestFcn=@(~,~)images.roi.internal.emptyCallback();
        end

        function create(self)

            create@images.internal.app.utilities.Dialog(self);

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
            self.DirTextbox=uieditfield('text',...
            'Parent',self.FigureHandle,...
            'HorizontalAlignment','left',...
            'Tag','InputFolderTextBox',...
            'Value',self.FolderAbsolutePath,...
            'FontSize',12,...
            'Position',pos,...
            'ValueChangedFcn',@(~,~)acceptClicked(self));

            pos=[self.Size(1)-self.ButtonSpace-self.ButtonSize(1),...
            3*self.ButtonSpace+self.ButtonSize(2),self.ButtonSize];
            self.Browse=uibutton('Parent',self.FigureHandle,...
            'ButtonPushedFcn',@(~,~)browseClicked(self),...
            'FontSize',12,...
            'Position',pos,...
            'Text',vision.getMessage('vision:labeler:Browse'),...
            'Tag','BrowseButton');


        end

        function addAccept(self)

            self.Accept=uibutton('Parent',self.FigureHandle,...
            'ButtonPushedFcn',@(~,~)acceptClicked(self),...
            'FontSize',12,...
            'Position',[self.Size(1)-self.ButtonSpace-self.ButtonSize(1),self.ButtonSpace,self.ButtonSize],...
            'Text',vision.getMessage('vision:labeler:Accept'),...
            'Tag','Accept');

        end

    end


    methods(Access=protected)

        function acceptClicked(self)

            drawnow;
            self.FolderAbsolutePath=self.DirTextbox.Value;
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

            dirname=uigetdir(self.DirTextbox.Value,vision.getMessage('vision:labeler:TempDirectoryTitle'));
            if(dirname~=0)
                self.FolderAbsolutePath=dirname;
                self.DirTextbox.Value=self.FolderAbsolutePath;
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