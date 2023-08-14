classdef NewSessionDialog<images.internal.app.utilities.OkCancelDialog




    properties
SessionFolder
    end

    properties(Access=protected,Dependent)

CurrentPath

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

BrowseEditfield
BrowseButton
FoldernameEditField
ErrorMessage
MessageLabel
MessageIcon


DefaultPath
DataFolderName

    end

    properties(Access=protected,Constant)
        DefaultFolderName="MedicalLabelingSession";
    end

    events
BringAppToFront
    end

    methods

        function self=NewSessionDialog(loc)

            title=getString(message('medical:medicalLabeler:createSessionFolder'));
            self=self@images.internal.app.utilities.OkCancelDialog(loc,title);
            self.Size=[500,265];

            self.DefaultPath=userpath;
            if~isfolder(self.DefaultPath)
                self.DefaultPath=pwd;
            end

            self.create();

            self.layoutDialog();

            self.browserEditfieldChanged();

        end


        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            self.Cancel.Visible='off';

            btnWidth=120;
            btnHeight=22;
            self.Ok.Position=[self.Size(1)-self.ButtonSpace-btnWidth,self.ButtonSpace,btnWidth,btnHeight];
            self.Ok.Text=getString(message('medical:medicalLabeler:createSession'));

        end

    end

    methods(Access=protected)


        function okClicked(self)

            self.SessionFolder=self.CurrentPath;

            try

                mkdir(self.SessionFolder);

            catch ME

                self.ErrorMessage.Text=ME.message;
                self.ErrorMessage.Visible=true;
                self.Ok.Enable=false;
                return

            end


            self.Canceled=false;
            close(self);

        end


        function layoutDialog(self)

            border=5;
            topBorder=10;

            bottomStart=self.Ok.Position(2)+self.Ok.Position(4)+border;

            pos=[border,...
            bottomStart,...
            self.FigureHandle.Position(3)-2*border,...
            self.FigureHandle.Position(4)-bottomStart-topBorder];
            panel=uipanel('Parent',self.FigureHandle,...
            'Position',pos,...
            'BorderType','none',...
            'HandleVisibility','off');

            grid=uigridlayout('Parent',panel,...
            'RowHeight',{70,24,24,20},...
            'ColumnWidth',{'1x'},...
            'Padding',10,...
            'RowSpacing',20);

            msgGrid=uigridlayout('Parent',grid,...
            'RowHeight',{'1x'},...
            'ColumnWidth',{40,'1x'},...
            'Padding',0);
            msgGrid.Layout.Row=1;
            msgGrid.Layout.Column=1;

            iconFile=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','Autosave_24.png');
            self.MessageIcon=uiimage('Parent',msgGrid,...
            'ImageSource',iconFile,...
            'HandleVisibility','on');
            self.MessageIcon.Layout.Row=1;
            self.MessageIcon.Layout.Column=1;

            self.MessageLabel=uilabel('Parent',msgGrid,...
            'Text',getString(message('medical:medicalLabeler:newSessionDialogMessage')),...
            'WordWrap','on',...
            'HorizontalAlignment','left',...
            'Tag','LabelDataLocationMessage',...
            'HandleVisibility','off');
            self.MessageLabel.Layout.Row=1;
            self.MessageLabel.Layout.Column=2;
            self.MessageLabel.FontSize=self.MessageLabel.FontSize+1;

            browseGrid=uigridlayout('Parent',grid,...
            'RowHeight',{'1x'},...
            'ColumnWidth',{'1x',100},...
            'Padding',0);
            browseGrid.Layout.Row=2;
            browseGrid.Layout.Column=1;

            self.BrowseEditfield=uieditfield('Parent',browseGrid,...
            'Value',self.DefaultPath,...
            'Editable','on',...
            'Enable','on',...
            'Tag','browseEditfield',...
            'ValueChangedFcn',@(~,~)self.browserEditfieldChanged());
            self.BrowseEditfield.Layout.Row=1;
            self.BrowseEditfield.Layout.Column=1;

            self.BrowseButton=uibutton('Parent',browseGrid,...
            'Text',getString(message('medical:medicalLabeler:browse')),...
            'Enable','on',...
            'HandleVisibility','off',...
            'ButtonPushedFcn',@(~,~)self.browseClicked());
            self.BrowseButton.Layout.Row=1;
            self.BrowseButton.Layout.Column=2;

            folderGrid=uigridlayout('Parent',grid,...
            'RowHeight',{'1x'},...
            'ColumnWidth',{'fit','1x'},...
            'Padding',0);
            folderGrid.Layout.Row=3;
            folderGrid.Layout.Column=1;

            folderLabel=uilabel('Parent',folderGrid,...
            'Text',getString(message('medical:medicalLabeler:newSessionFolder')),...
            'WordWrap','off',...
            'HorizontalAlignment','left',...
            'Tag','LabelDataLocationMessage',...
            'HandleVisibility','off');
            folderLabel.Layout.Row=1;
            folderLabel.Layout.Column=1;

            self.FoldernameEditField=uieditfield('Parent',folderGrid,...
            'Value',self.getValidFolderName(),...
            'Editable','on',...
            'Enable','on',...
            'Tag','browseEditfield',...
            'ValueChangedFcn',@(~,~)self.folderNameChanged());
            self.FoldernameEditField.Layout.Row=1;
            self.FoldernameEditField.Layout.Column=2;

            self.ErrorMessage=uilabel('Parent',grid,...
            'FontColor',[1,0,0],...
            'Visible','off',...
            'Tag','LabelDataLocationMessage',...
            'HandleVisibility','off');
            self.ErrorMessage.Layout.Row=4;
            self.ErrorMessage.Layout.Column=1;

        end


        function browseClicked(self)

            title=getString(message('medical:medicalLabeler:newSessionLocation'));
            currentPath=self.BrowseEditfield.Value;
            selectedPath=uigetdir(currentPath,title);


            self.notify('BringAppToFront');

            figure(self.FigureHandle);

            if selectedPath~=0
                self.BrowseEditfield.Value=selectedPath;
                self.browserEditfieldChanged()
            end

        end


        function browserEditfieldChanged(self)

            selectedPath=self.BrowseEditfield.Value;

            if isfolder(selectedPath)

                if medical.internal.app.labeler.utils.hasWriteAccess(selectedPath)

                    if isfolder(self.CurrentPath)
                        self.FoldernameEditField.Value=medical.internal.app.labeler.utils.getUniqueFolderName(selectedPath,self.FoldernameEditField.Value);
                    end
                    self.ErrorMessage.Visible=false;

                    self.FoldernameEditField.Enable='on';
                    self.Ok.Enable=true;

                else
                    self.ErrorMessage.Text=getString(message('medical:medicalLabeler:noWritePermissionErrorMessage'));
                    self.ErrorMessage.Visible=true;

                    self.FoldernameEditField.Enable='off';

                    self.Ok.Enable=false;
                end

            else

                self.ErrorMessage.Text=getString(message('medical:medicalLabeler:invalidLocationErrorMessage'));
                self.ErrorMessage.Visible=true;

                self.FoldernameEditField.Enable='off';
                self.Ok.Enable=false;

            end

        end


        function folderNameChanged(self)

            folderName=self.FoldernameEditField.Value;

            if isempty(folderName)
                self.FoldernameEditField.Value=self.getValidFolderName();
                self.ErrorMessage.Visible=false;
                self.Ok.Enable=true;

            else

                path=fullfile(self.BrowseEditfield.Value,folderName);

                if isfolder(path)

                    self.ErrorMessage.Text=getString(message('medical:medicalLabeler:duplicateSessionDirErrorMessage'));
                    self.ErrorMessage.Visible=true;
                    self.Ok.Enable=false;

                else

                    self.ErrorMessage.Visible=false;
                    self.Ok.Enable=true;

                end

            end



        end


        function locationChanged(self)

            currPath=self.CurrentPath;

            if medical.internal.app.labeler.utils.hasWriteAccess(currPath)

                self.ErrorMessage.Visible=false;
                self.BrowseEditfield.Value=currPath;

                self.Ok.Enable=true;

            else

                self.ErrorMessage.Text=getString(message('medical:medicalLabeler:noWritePermissionErrorMessage'));
                self.ErrorMessage.Visible=true;

                self.Ok.Enable=false;

            end

        end


        function foldername=getValidFolderName(self)

            folderpath=self.BrowseEditfield.Value;
            if isfolder(folderpath)
                foldername=medical.internal.app.labeler.utils.getUniqueFolderName(folderpath,self.DefaultFolderName);
            else
                foldername=self.DefaultFolderName;
            end

        end

    end


    methods


        function currPath=get.CurrentPath(self)

            currPath='';

            if~isempty(self.FoldernameEditField.Value)
                currPath=string(fullfile(self.BrowseEditfield.Value,self.FoldernameEditField.Value));
            end

        end

    end

end
