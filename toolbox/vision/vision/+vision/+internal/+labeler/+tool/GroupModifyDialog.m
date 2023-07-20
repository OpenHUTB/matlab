
classdef GroupModifyDialog<vision.internal.uitools.OkCancelDlg


    properties(Access=private)
Group
GroupNameEditBox

        GroupNameChanged=false;

SessionLabelSet
    end

    methods

        function this=GroupModifyDialog(tool,currentGroupName,labelSet,hFig)

            dlgTitle=vision.getMessage('vision:labeler:ContextMenuRenameGroup');

            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);

            if strcmpi(currentGroupName,'None')
                msg=vision.getMessage('vision:labeler:GroupNameNoneCannotChange');
                title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                return;
            end

            this.Group=currentGroupName;
            this.SessionLabelSet=labelSet;

            this.DlgSize=[250,150];

            createDialog(this);
            addGroupNameEditBox(this);
        end


        function data=getDialogData(this)
            data.Group=this.Group;
            data.GroupNameChanged=this.GroupNameChanged;
        end
    end

    methods(Access=protected)

        function addGroupNameEditBox(this)
            if useAppContainer
                uilabel('Parent',this.Dlg,...
                'Position',[0.1,0.7,0.5,0.2].*[this.DlgSize,this.DlgSize],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:GroupNameEditBox'));

                this.GroupNameEditBox=uieditfield('Parent',this.Dlg,...
                'Value',this.Group,...
                'Position',[0.1,0.5,0.45,0.2].*[this.DlgSize,this.DlgSize],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varLabelNameEditBox',...
                'FontAngle','normal',...
                'Enable','on',...
                'ValueChangedFcn',@(src,evt)this.updateGroupName(src,evt),...
                'ValueChangingFcn',@(src,evt)this.updatingGroupName(src,evt));
            else
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.1,0.7,0.5,0.2],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:GroupNameEditBox'));

                this.GroupNameEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String',this.Group,...
                'Units','normalized',...
                'Position',[0.1,0.5,0.45,0.2],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varLabelNameEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');



                this.GroupNameEditBox.KeyPressFcn=@this.onKeyPress;
            end
        end


        function onKeyPress(this,~,evd)




            switch(evd.Key)
            case{'return'}
                onOK(this);
            case{'escape'}
                onCancel(this);
            end
        end

        function onOK(this,~,~)


            drawnow;

            defaultGroupStr='None';

            oldName=this.Group;

            if~useAppContainer
                newName=get(this.GroupNameEditBox,'String');
            else
                newName=get(this.GroupNameEditBox,'Value');
            end


            this.GroupNameChanged=~strcmp(oldName,newName);
            hFig=ancestor(this.Dlg,'figure');
            if this.GroupNameChanged


                if isvarname(newName)

                    if strcmpi(newName,defaultGroupStr)


                        msg=vision.getMessage('vision:labeler:GroupNameReservedError',newName);
                        title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                        vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                        this.GroupNameChanged=false;
                    else
                        definitionStruct=this.SessionLabelSet.DefinitionStruct;
                        currentGroups=[{defaultGroupStr},{definitionStruct.Group}];
                        existingGroup=unique(currentGroups,'stable');

                        existingGroup(strcmp(existingGroup,oldName))=[];

                        if any(strcmpi(existingGroup,newName))

                            msg=vision.getMessage('vision:labeler:GroupNameExistsError',newName);
                            title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                            vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                            this.GroupNameChanged=false;
                        else
                            this.Group=newName;
                            this.IsCanceled=false;
                            close(this);
                        end
                    end
                else
                    msg=vision.getMessage('vision:labeler:GroupNameInvalid');
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    this.GroupNameChanged=false;
                end
            end
        end

        function updateGroupName(this,src,evt)
            this.GroupNameEditBox.Value=evt.Value;
        end

        function updatingGroupName(this,src,evt)
            this.GroupNameEditBox.Value=evt.Value;
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end