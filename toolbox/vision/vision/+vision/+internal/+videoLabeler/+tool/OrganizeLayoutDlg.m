



classdef OrganizeLayoutDlg<vision.internal.uitools.OkCancelDlg

    properties(Access=protected)
DeleteButton
RenameButton
CloseButton
ListBox
ListBoxText
EditBox
EditBoxText
LayoutFullFileNames
        LayoutPopupNeedsRefresh=false;
    end

    methods
        function this=OrganizeLayoutDlg(tool,layouts)

            dlgTitle=vision.getMessage('vision:labeler:OrganizeLayout');

            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);
            this.DlgSize=[300,170];

            createDialog(this);

            this.LayoutFullFileNames=layouts;

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

                layoutFileNames=cell(numel(this.LayoutFullFileNames),1);
                for i=1:numel(this.LayoutFullFileNames)
                    [~,layoutFileNames{i},~]=fileparts(this.LayoutFullFileNames{i});
                end

                this.ListBoxText=uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[31,100,225,25],...
                'HorizontalAlignment','left',...
                'Tag','orgLayoutListBoxText',...
                'String',vision.getMessage('vision:labeler:SavedLayoutsDlgText'));

                this.ListBox=uicontrol('Parent',this.Dlg,'Style','listbox',...
                'String',layoutFileNames,...
                'Units','pixels',...
                'Position',[31,12,210,85],...
                'HorizontalAlignment','left',...
                'Tag','orgLayoutListBox',...
                'Enable','on');
            else
                this.DeleteButton=uibutton('Parent',this.Dlg,'ButtonPushedFcn',@this.onDelete,...
                'Position',[40,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontSize',10,'Text',...
                getString(message('vision:labeler:ContextMenuDelete')));

                this.RenameButton=uibutton('Parent',this.Dlg,'ButtonPushedFcn',@this.onRename,...
                'Position',[120,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontSize',10,'Text',...
                getString(message('vision:labeler:Rename')));

                this.CloseButton=uibutton('Parent',this.Dlg,'ButtonPishedFcn',@this.onCancel,...
                'Position',[200,buttonYLoc,okButtonPos(3),okButtonPos(4)],...
                'FontSize',10,'Text',...
                getString(message('vision:labeler:Close')));

                layoutFileNames=cell(numel(this.LayoutFullFileNames),1);
                for i=1:numel(this.LayoutFullFileNames)
                    [~,layoutFileNames{i},~]=fileparts(this.LayoutFullFileNames{i});
                end

                this.ListBoxText=uilabel('Parent',this.Dlg,...
                'Position',[31,100,225,25],...
                'HorizontalAlignment','left',...
                'Tag','orgLayoutListBoxText',...
                'Text',vision.getMessage('vision:labeler:SavedLayoutsDlgText'));

                this.ListBox=uilistbox('Parent',this.Dlg,...
                'Items',layoutFileNames,...
                'Position',[31,12,210,85],...
                'HorizontalAlignment','left',...
                'Tag','orgLayoutListBox',...
                'Enable','on');
            end
        end

        function TF=getRefreshFlag(this)
            TF=this.LayoutPopupNeedsRefresh;
        end

        function setRefreshFlag(this,flag)
            this.LayoutPopupNeedsRefresh=flag;
        end
    end

    methods(Access=protected)


        function onDelete(this,~,~)


            layoutFileNames=this.ListBox.String;
            selected=this.ListBox.Value;

            if~isempty(layoutFileNames)
                displayMessage=vision.getMessage('vision:labeler:LayoutDeleteWarning',string(layoutFileNames(selected)));
                dialogName=vision.getMessage('vision:labeler:DeletionDefinitionWarningTitle');
                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

                selection=vision.internal.labeler.handleAlert(this.Dlg,'questionWithWaitDlg',displayMessage,dialogName,...
                this.App,yes,no,yes);

                if strcmpi(selection,yes)


                    if exist(string(this.LayoutFullFileNames(selected)),'file')
                        delete(string(this.LayoutFullFileNames(selected)));
                    else
                        errorMessage=vision.getMessage('vision:labeler:LayoutRenameError',layoutFileNames{selected});
                        dialogName=getString(message('vision:labeler:LayoutDeleteErrorTitle'));
                        vision.internal.labeler.handleAlert(this.Dlg,'errorWithWaitDlg',errorMessage,dialogName,...
                        this.App);
                    end


                    layoutFileNames(selected)=[];


                    this.LayoutFullFileNames(selected)=[];
                    this.ListBox.String=layoutFileNames;

                    if numel(this.ListBox.String)<selected
                        this.ListBox.Value=numel(this.ListBox.String);
                    end

                    this.LayoutPopupNeedsRefresh=true;

                    if isempty(this.ListBox.String)
                        this.DeleteButton.Enable='off';
                        this.RenameButton.Enable='off';
                    end
                end
            end
        end


        function onRename(this,~,~)

            selected=this.ListBox.Value;
            layoutFileNames=this.ListBox.String;

            if~isempty(layoutFileNames)

                editLayoutName=this.ListBox.String(selected);


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
                    'Tag','orgLayoutEditBoxText',...
                    'String',['Rename layout ',editLayoutName{:}]);

                    this.EditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                    'String','',...
                    'Units','normalized',...
                    'Position',[0.1,0.40,0.7,0.25],...
                    'HorizontalAlignment','left',...
                    'BackgroundColor',[1,1,1],...
                    'Tag','orgLayoutEditBox',...
                    'FontAngle','normal',...
                    'ForegroundColor',[0,0,0],...
                    'Enable','on');



                    this.OkButton.Visible='on';
                    this.CancelButton.Visible='on';

                    this.OkButton.String=vision.getMessage('vision:labeler:Accept');

                    this.CancelButton.String=vision.getMessage('vision:labeler:Back');
                    this.CancelButton.Callback=@this.onRenameCancel;
                else
                    this.EditBoxText=uilabel('Parent',this.Dlg,...
                    'Position',[0.1,0.55,0.75,0.35].*[this.DlgSize,this.DlgSize],...
                    'HorizontalAlignment','left',...
                    'Tag','orgLayoutEditBoxText',...
                    'Text',['Rename layout ',editLayoutName{:}]);

                    this.EditBox=uieditfield('Parent',this.Dlg,...
                    'Value','',...
                    'Position',[0.1,0.40,0.7,0.25].*[this.DlgSize,this.DlgSize],...
                    'HorizontalAlignment','left',...
                    'BackgroundColor',[1,1,1],...
                    'Tag','orgLayoutEditBox',...
                    'FontAngle','normal',...
                    'Enable','on');



                    this.OkButton.Visible='on';
                    this.CancelButton.Visible='on';

                    this.OkButton.Text=vision.getMessage('vision:labeler:Accept');

                    this.CancelButton.Text=vision.getMessage('vision:labeler:Back');
                    this.CancelButton.ButtonPushedFcn=@this.onRenameCancel;
                end
            end

        end


        function onOK(this,~,~)

            newLayoutName=get(this.EditBox,'String');

            if~isvarname(newLayoutName)
                errorMessage=vision.getMessage('vision:labeler:InvalidLayoutName',newLayoutName);
                dialogName=getString(message('vision:labeler:InvalidLayoutNameTitle'));
                vision.internal.labeler.handleAlert(this.Dlg,'errorWithWaitDlg',errorMessage,dialogName,...
                this.App);
                return
            end

            selected=this.ListBox.Value;
            fullFileName=this.LayoutFullFileNames(selected);

            [path,layoutName,ext]=fileparts(fullFileName{:});


            newFullFileName=fullfile(path,newLayoutName);
            newFullFileName=[newFullFileName,ext];

            layoutFileNames=this.ListBox.String;


            layoutIdx=find(ismember(this.ListBox.String,{newLayoutName}));

            if~isempty(layoutIdx)
                errorMessage=vision.getMessage('vision:labeler:LayoutExists',newLayoutName);
                dialogName=getString(message('vision:labeler:LayoutExistsTitle'));
                vision.internal.labeler.handleAlert(this.Dlg,'errorWithWaitDlg',errorMessage,dialogName,...
                this.App);
                return
            end


            success=movefile(fullFileName{:},newFullFileName,'f');

            if success

                this.LayoutFullFileNames(selected)={newFullFileName};


                layoutFileNames(selected)={newLayoutName};
                this.ListBox.String=layoutFileNames;
            else
                errorMessage=vision.getMessage('vision:labeler:LayoutRenameError',layoutName);
                dialogName=getString(message('vision:labeler:LayoutRenameErrorTitle'));
                vision.internal.labeler.handleAlert(this.Dlg,'errorWithWaitDlg',errorMessage,dialogName,...
                this.App);
            end

            this.LayoutPopupNeedsRefresh=true;

            restoreOldDlg(this);
        end

        function onRenameCancel(this,~,~)
            restoreOldDlg(this);
        end


        function onKeyPress(this,~,evd)

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
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end