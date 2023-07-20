




classdef OrganizeCameraViewDlg<vision.internal.uitools.OkCancelDlg

    properties(Access=protected)
DeleteButton
RenameButton
CloseButton
ListBox
ListBoxText
EditBox
EditBoxText
SavedCameraViewNames
        PopupNeedsRefresh=false;
        UserAction={};
    end

    properties
ContainerObj
    end

    methods
        function this=OrganizeCameraViewDlg(tool,savedCameraViews)

            dlgTitle=vision.getMessage('lidar:labeler:SaveCamViewOrg');

            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);
            this.DlgSize=[300,170];

            this.ContainerObj=tool;

            createDialog(this);

            this.SavedCameraViewNames=savedCameraViews;

            cameraViewNames=cell(numel(this.SavedCameraViewNames),1);
            for i=1:numel(this.SavedCameraViewNames)
                cameraViewNames{i}=this.SavedCameraViewNames{i};
            end

            this.OkButton.Visible='off';
            this.CancelButton.Visible='off';

            okButtonPos=this.OkButton.Position;
            buttonYLoc=140;

            if~useAppContainer
                this.DeleteButton=uicontrol('Parent',this.Dlg,'Callback',@this.onDelete,...
                'Position',[40,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:ContextMenuDelete')));

                this.RenameButton=uicontrol('Parent',this.Dlg,'Callback',@this.onRename,...
                'Position',[120,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:Rename')));

                this.CloseButton=uicontrol('Parent',this.Dlg,'Callback',@this.onCancel,...
                'Position',[200,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:Close')));

                this.ListBoxText=uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[40,100,225,25],...
                'HorizontalAlignment','left',...
                'Tag','orgCamViewListBoxText',...
                'String',vision.getMessage('lidar:labeler:SavedCamViewDlgText'));



                this.ListBox=uicontrol('Parent',this.Dlg,'Style','listbox',...
                'String',cameraViewNames,...
                'Units','pixels',...
                'Position',[40,12,160+okButtonPos(3),85],...
                'HorizontalAlignment','left',...
                'Tag','orgCamViewListBox',...
                'Enable','on');
            else

                this.DeleteButton=uibutton('Parent',this.Dlg,'ButtonPushedFcn',@this.onDelete,...
                'Position',[40,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontSize',11,'Text',...
                getString(message('vision:labeler:ContextMenuDelete')));

                this.RenameButton=uibutton('Parent',this.Dlg,'ButtonPushedFcn',@this.onRename,...
                'Position',[120,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontSize',11,'Text',...
                getString(message('vision:labeler:Rename')));

                this.CloseButton=uibutton('Parent',this.Dlg,'ButtonPushedFcn',@this.onCancel,...
                'Position',[200,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontSize',11,'Text',...
                getString(message('vision:labeler:Close')));

                this.ListBoxText=uilabel('Parent',this.Dlg,...
                'Position',[40,100,225,25],...
                'HorizontalAlignment','left',...
                'Tag','orgCamViewListBoxText',...
                'Text',vision.getMessage('lidar:labeler:SavedCamViewDlgText'));



                this.ListBox=uilistbox('Parent',this.Dlg,...
                'Items',cameraViewNames,...
                'Position',[40,12,160+okButtonPos(3),85],...
                'Tag','orgCamViewListBox',...
                'Enable','on');
            end
        end


        function TF=getRefreshFlag(this)
            TF=this.PopupNeedsRefresh;
        end


        function setRefreshFlag(this,flag)
            this.PopupNeedsRefresh=flag;
        end


        function userAction=getUserAction(this)

            userAction=this.UserAction;
        end

    end

    methods(Access=protected)


        function onDelete(this,~,~)

            if~useAppContainer
                cameraViewNames=this.ListBox.String;
                selected=this.ListBox.Value;
                selectedItem=string(cameraViewNames(selected));
            else
                cameraViewNames=this.ListBox.Items;
                selectedItem=this.ListBox.Value;
                selected=find(strcmp(cameraViewNames,selectedItem));
            end

            if~isempty(cameraViewNames)
                displayMessage=vision.getMessage('lidar:labeler:CameraViewDeleteWarning',selectedItem);
                dialogName=vision.getMessage('vision:labeler:DeletionDefinitionWarningTitle');
                yes=vision.getMessage('vision:uitools:Yes');
                no=vision.getMessage('vision:uitools:No');
                selection=vision.internal.labeler.handleAlert(this.Dlg,'questionWithWaitDlg',displayMessage,dialogName,...
                this.ContainerObj,yes,no);

                if strcmp(selection,yes)



                    userAction=this.createUserAction...
                    ('delete',selected);
                    this.UserAction{end+1}=userAction;



                    cameraViewNames(selected)=[];


                    this.SavedCameraViewNames(selected)=[];

                    if~useAppContainer
                        this.ListBox.String=cameraViewNames;

                        if numel(this.ListBox.String)<selected
                            this.ListBox.Value=numel(this.ListBox.String);
                        end
                    else
                        this.ListBox.Items=cameraViewNames;

                        if numel(this.ListBox.Items)<selected
                            if numel(this.ListBox.Items)>0
                                this.ListBox.Value=cameraViewNames(end);
                            else
                                this.ListBox.Value={};
                            end
                        end
                    end

                    this.PopupNeedsRefresh=true;

                    if~useAppContainer
                        condition=isempty(this.ListBox.String);
                    else
                        condition=isempty(this.ListBox.Items);
                    end
                    if condition
                        this.DeleteButton.Enable='off';
                        this.RenameButton.Enable='off';
                    end
                end
            end
        end


        function onRename(this,~,~)

            if~useAppContainer
                selected=this.ListBox.Value;
                cameraViewNames=this.ListBox.String;
            else
                selectedItem=this.ListBox.Value;
                cameraViewNames=this.ListBox.Items;
                selected=find(strcmp(cameraViewNames,selectedItem));
            end

            if~isempty(cameraViewNames)

                if~useAppContainer
                    editCameraViewName=this.ListBox.String(selected);
                else
                    editCameraViewName=this.ListBox.Value;
                end


                this.DeleteButton.Visible='off';
                this.RenameButton.Visible='off';
                this.CloseButton.Visible='off';
                this.ListBox.Visible='off';
                this.ListBoxText.Visible='off';

                if~useAppContainer
                    this.EditBoxText=uicontrol('Parent',this.Dlg,'Style','text',...
                    'Units','normalized',...
                    'Position',[0.1,0.55,0.75,0.35],...
                    'HorizontalAlignment','left',...
                    'Tag','orgCamViewEditBoxText',...
                    'String',['Rename camera view ',editCameraViewName{:}]);

                    this.EditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                    'String','',...
                    'Units','normalized',...
                    'Position',[0.1,0.40,0.7,0.25],...
                    'HorizontalAlignment','left',...
                    'BackgroundColor',[1,1,1],...
                    'Tag','orgCamViewEditBox',...
                    'FontAngle','normal',...
                    'ForegroundColor',[0,0,0],...
                    'Enable','on');
                else
                    this.EditBoxText=uilabel('Parent',this.Dlg,...
                    'Position',[30,93.5,225,59.5],...
                    'HorizontalAlignment','left',...
                    'Tag','orgCamViewEditBoxText',...
                    'Text',['Rename camera view ',editCameraViewName]);

                    this.EditBox=uieditfield('Parent',this.Dlg,...
                    'Value','',...
                    'Position',[30,68,210,42.5],...
                    'HorizontalAlignment','left',...
                    'BackgroundColor',[1,1,1],...
                    'Tag','orgCamViewEditBox',...
                    'FontAngle','normal',...
                    'Enable','on');
                end



                this.OkButton.Visible='on';
                this.CancelButton.Visible='on';

                if~useAppContainer
                    this.OkButton.String=vision.getMessage('vision:labeler:Accept');

                    this.CancelButton.String=vision.getMessage('vision:labeler:Back');
                    this.CancelButton.Callback=@this.onRenameCancel;
                else
                    this.OkButton.Text=vision.getMessage('vision:labeler:Accept');

                    this.CancelButton.Text=vision.getMessage('vision:labeler:Back');
                    this.CancelButton.ButtonPushedFcn=@this.onRenameCancel;
                end
            end

        end


        function onOK(this,~,~)

            if~useAppContainer
                newCameraViewName=get(this.EditBox,'String');
            else
                newCameraViewName=get(this.EditBox,'Value');
            end

            if~isvarname(newCameraViewName)
                errorMessage=vision.getMessage('lidar:labeler:InvalidViewName',newCameraViewName);
                dialogName=getString(message('lidar:labeler:InvalidViewNameTitle'));
                vision.internal.labeler.handleAlert(this.Dlg,'errorWithWait',errorMessage,dialogName,this.ContainerObj);
                return
            end

            if~useAppContainer
                selected=this.ListBox.Value;
                cameraViewNames=this.ListBox.String;


                camViewIdx=find(ismember(this.ListBox.String,{newCameraViewName}));
            else
                selectedItem=this.ListBox.Value;
                cameraViewNames=this.ListBox.Items;
                selected=find(strcmp(cameraViewNames,selectedItem));


                camViewIdx=find(ismember(this.ListBox.Items,{newCameraViewName}));
            end

            if~isempty(camViewIdx)
                errorMessage=vision.getMessage('lidar:labeler:CameraViewExists',newCameraViewName);
                dialogName=getString(message('lidar:labeler:CameraViewExistsTitle'));
                vision.internal.labeler.handleAlert(this.Dlg,'errorWithWait',errorMessage,dialogName,this.ContainerObj);
                return
            end


            userAction=this.createUserAction...
            ('rename',selected,newCameraViewName);

            this.UserAction{end+1}=userAction;

            cameraViewNames(selected)={newCameraViewName};

            if~useAppContainer()
                this.ListBox.String=cameraViewNames;
            else
                this.ListBox.Items=cameraViewNames;
            end

            this.PopupNeedsRefresh=true;
            restoreOldDlg(this);
        end


        function onRenameCancel(this,~,~)
            restoreOldDlg(this);
        end
    end

    methods(Access=private)

        function restoreOldDlg(this)
            delete(this.EditBox);
            delete(this.EditBoxText);

            this.OkButton.Visible='off';
            this.CancelButton.Visible='off';

            this.DeleteButton.Visible='on';
            this.RenameButton.Visible='on';
            this.CloseButton.Visible='on';
            this.ListBox.Visible='on';
            this.ListBoxText.Visible='on';
        end

        function userInfo=createUserAction(this,op,index,newName)


            userInfo=cell(1,2);
            userInfo{1,1}=op;
            if strcmp(op,'delete')
                userInfo{1,2}={index};
            else
                userInfo{1,2}={index;newName};
            end
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end