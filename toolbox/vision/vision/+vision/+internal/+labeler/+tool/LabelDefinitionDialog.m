classdef LabelDefinitionDialog<vision.internal.uitools.OkCancelDlg

    properties
LabelName
Description
Group
        IsNewGroup=false
        InvalidLabelNames={}

Color
        NameChangedInEditMode=false;
        DescriptionChangedInEditMode=false;
        GroupChangedInEditMode=false;
        ColorChangedInEditMode=false;
PixelFactor
    end

    properties(Access=protected)


        LabelAddMode;

        LabelEditBox;
        DescriptionEditBox;
        SessionLabelSet;
        SessionSecondaryLabelSet;
        GroupMenu;
        NewGroupEditBox;
        NewGroupText=vision.getMessage('vision:labeler:NewGroup');
ColorSelectPushButton
ColorPanel

ColorSelected
    end

    methods

        function this=LabelDefinitionDialog(tool,dlgTitle)
            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);
        end
    end

    methods(Access=protected)

        function addLabelNameEditBox(this)
            this.PixelFactor=[this.DlgSize,this.DlgSize];
            if~(isequal(class(this),'vision.internal.labeler.tool.FrameLabelDefinitionDialog'))
                width=0.35;
            else
                width=0.45;
            end

            if~useAppContainer

                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.1,0.88,0.5,0.08],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROILabelNameEditBox'));

                this.LabelEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String',this.LabelName,...
                'Units','normalized',...
                'Position',[0.1,0.78,width,0.08],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varLabelNameEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');



                this.LabelEditBox.KeyPressFcn=@this.onKeyPress;

            else

                uilabel('Parent',this.Dlg,...
                'Text',vision.getMessage('vision:labeler:ROILabelNameEditBox'),...
                'Position',[0.1,0.88,0.5,0.08].*this.PixelFactor,...
                'HorizontalAlignment','left');

                this.LabelEditBox=uieditfield('Parent',this.Dlg,...
                'BackgroundColor',[1,1,1],...
                'Value',this.LabelName,'HorizontalAlignment','left',...
                'Position',[0.1,0.78,width,0.08].*this.PixelFactor,...
                'Tag','varLabelNameEditBox',...
                'FontAngle','normal',...
                'Editable','on',...
                'Enable','on');

                this.LabelEditBox.ValueChangedFcn=@(src,evt)this.updateEditBoxValue(src,evt);
                this.LabelEditBox.ValueChangingFcn=@(src,evt)this.updatingEditBoxValue(src,evt);
            end


        end


        function addColorSelectionOption(this)
            this.PixelFactor=[this.DlgSize,this.DlgSize];
            if~(isequal(class(this),'vision.internal.labeler.tool.FrameLabelDefinitionDialog'))
                leftSpacing=0.8;
            else
                leftSpacing=0.6;
            end

            if~useAppContainer

                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[leftSpacing,0.88,0.5,0.08],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:Color'));

                this.ColorSelectPushButton=uicontrol('Parent',this.Dlg,'Style','pushbutton',...
                'Units','normalized',...
                'Value',1,'Position',[leftSpacing,0.78,0.1,0.08],...
                'BackgroundColor',this.Color,...
                'Tag','ColorPush',...
                'Callback',@this.colorMenu);
            else

                uilabel('Parent',this.Dlg,...
                'Position',[leftSpacing,0.88,0.5,0.08].*this.PixelFactor,...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:Color'));

                this.ColorSelectPushButton=uibutton('Parent',this.Dlg,...
                'Text','',...
                'Position',[leftSpacing,0.78,0.1,0.08].*this.PixelFactor,...
                'BackgroundColor',this.Color,...
                'Tag','ColorPush',...
                'ButtonPushedFcn',@this.colorMenu);
            end

        end


        function colorMenu(this,~,~)


            if isempty(this.ColorSelected)
                this.ColorSelected=uisetcolor(this.Color,'Select color');
            else
                this.ColorSelected=uisetcolor(this.ColorSelected,'Select color');
            end
            this.ColorSelectPushButton.BackgroundColor=this.ColorSelected;
        end


        function addLabelGroupPopupMenu(this,data)
            this.PixelFactor=[this.DlgSize,this.DlgSize];
            definitionStruct=data.DefinitionStruct;
            defaultGroup={'None'};
            newGroup={this.NewGroupText};

            if~isempty(definitionStruct)
                currentGroups=[defaultGroup,{definitionStruct.Group}];
                uniqueGroups=unique(currentGroups,'stable');
                uniqueGroups=[uniqueGroups,newGroup];
            else
                uniqueGroups=[defaultGroup,newGroup];
            end

            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.1,0.67,0.5,0.08],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:LabelGroupEditBox'));

                this.GroupMenu=uicontrol('Parent',this.Dlg,'Style','popupmenu',...
                'Units','normalized',...
                'String',uniqueGroups,...
                'Value',1,'Position',[0.1,0.58,0.45,0.08],...
                'Callback',@this.groupMenuChangeCallback,...
                'Tag','GroupPopup');

                this.NewGroupEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String','',...
                'Units','normalized',...
                'Position',[0.6,0.58,0.3,0.08],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varNewGroupEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Visible','off');
            else
                uilabel('Parent',this.Dlg,...
                'Position',[0.1,0.67,0.5,0.08].*this.PixelFactor,...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:LabelGroupEditBox'));

                this.GroupMenu=uidropdown('Parent',this.Dlg,...
                'Items',uniqueGroups,...
                'Position',[0.1,0.58,0.45,0.08].*this.PixelFactor,...
                'ValueChangedFcn',@this.groupMenuChangeCallback,...
                'Tag','GroupPopup');
                this.GroupMenu.Value=uniqueGroups{1};

                this.NewGroupEditBox=uieditfield('Parent',this.Dlg,...
                'Value','',...
                'Position',[0.6,0.58,0.3,0.08].*this.PixelFactor,...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varNewGroupEditBox',...
                'FontAngle','normal',...
                'Visible','off');
            end

            if~isempty(definitionStruct)
                if this.LabelAddMode
                    groupValue=definitionStruct(end).Group;
                else
                    groupValue=this.Group;
                end

                if~useAppContainer
                    this.GroupMenu.Value=find(strcmp(this.GroupMenu.String,...
                    groupValue));
                else
                    idx=find(strcmp(this.GroupMenu.Items,...
                    groupValue));
                    this.GroupMenu.Value=uniqueGroups{idx};
                end
            end
        end


        function groupMenuChangeCallback(this,~,~)
            if~useAppContainer()
                currentSelection=this.GroupMenu.String(this.GroupMenu.Value);
            else
                currentSelection=this.GroupMenu.Value;
            end
            if strcmp(currentSelection,this.NewGroupText)
                this.NewGroupEditBox.Visible='on';
            else
                this.NewGroupEditBox.Visible='off';
            end
        end


        function addDescriptionEditBox(this)
            this.PixelFactor=[this.DlgSize,this.DlgSize];

            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.1,0.45,0.6,0.1],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROILabelDescriptionEditBox'));

                this.DescriptionEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'Max',5,...
                'String',this.Description,...
                'Units','normalized',...
                'Position',[0.1,0.16,0.8,0.3],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varLabelDescriptionEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');


                if~this.LabelAddMode
                    uicontrol(this.DescriptionEditBox);
                end



                this.DescriptionEditBox.KeyPressFcn=@this.onEditBoxKeyPress;
            else
                uilabel('Parent',this.Dlg,...
                'Position',[0.1,0.45,0.6,0.1].*this.PixelFactor,...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROILabelDescriptionEditBox'));

                this.DescriptionEditBox=uitextarea('Parent',this.Dlg,...
                'Value',this.Description,...
                'Position',[0.1,0.16,0.8,0.3].*this.PixelFactor,...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varLabelDescriptionEditBox',...
                'FontAngle','normal',...
                'Enable','on','WordWrap','on');


                if~this.LabelAddMode
                    focus(this.DescriptionEditBox);
                end



                this.DescriptionEditBox.ValueChangedFcn=@(src,evt)this.updateDescriptionValue(src,evt);
                this.DescriptionEditBox.ValueChangingFcn=@(src,evt)this.updatingDescriptionValue(src,evt);
            end
        end


        function onKeyPress(this,~,evd)


            if useAppContainer

                if strcmp(class(evd.Source.CurrentObject),{...
                    'matlab.ui.control.TextArea'})
                    return;
                end
            end

            drawnow;
            switch(evd.Key)
            case{'return'}
                onOK(this);
            case{'escape'}
                onCancel(this);
            end

        end

        function updatingEditBoxValue(this,src,~)
            this.LabelEditBox.Value=src.Value;
        end

        function updateEditBoxValue(this,src,~)
            this.LabelEditBox.Value=src.Value;
        end



        function onEditBoxKeyPress(this,~,evd)
            if~useAppContainer
                if~isempty(evd.Modifier)
                    modifierKeys={'control','command'};

                    if(any(strcmp(evd.Modifier,modifierKeys{ismac()+1}))&&strcmp(evd.Key,'return'))
                        onOK(this);
                    end
                else
                    if strcmp(evd.Key,'escape')
                        onCancel(this);
                    end
                end
            end
        end

        function updateDescriptionValue(this,~,evt)
            this.DescriptionEditBox.Value=evt.Value;
        end

        function updatingDescriptionValue(this,~,evt)
            this.DescriptionEditBox.Value=evt.Value;
        end


        function isValidName=getGroupInfo(this)
            if~useAppContainer
                currentGroup=this.GroupMenu.String{this.GroupMenu.Value};
            else
                currentGroup=this.GroupMenu.Value;
            end
            isValidName=true;
            defaultGroupStr='None';

            if strcmp(currentGroup,this.NewGroupText)
                if~useAppContainer
                    groupName=get(this.NewGroupEditBox,'String');
                else
                    groupName=get(this.NewGroupEditBox,'Value');
                end



                if isvarname(groupName)

                    if strcmpi(groupName,defaultGroupStr)


                        msg=vision.getMessage('vision:labeler:GroupNameReservedError',groupName);
                        title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                        vision.internal.labeler.handleAlert(this.Dlg,'errorWithModal',msg,title);
                        isValidName=false;
                    else

                        definitionStruct=this.SessionLabelSet.DefinitionStruct;
                        currentGroups=[{defaultGroupStr},{definitionStruct.Group}];
                        existingGroup=unique(currentGroups,'stable');

                        if any(strcmpi(existingGroup,groupName))

                            msg=vision.getMessage('vision:labeler:GroupNameExistsError',groupName);
                            title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                            vision.internal.labeler.handleAlert(this.Dlg,'errorWithModal',msg,title);

                            isValidName=false;

                        else
                            this.Group=groupName;
                            this.IsNewGroup=true;
                        end
                    end
                else
                    msg=vision.getMessage('vision:labeler:GroupNameInvalid');
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(this.Dlg,'errorWithModal',msg,title);

                    isValidName=false;
                end
            else
                this.Group=currentGroup;
                if strcmpi(currentGroup,defaultGroupStr)
                    definitionStruct=this.SessionLabelSet.DefinitionStruct;
                    currentGroups={definitionStruct.Group};
                    existingGroup=unique(currentGroups,'stable');
                    if~any(strcmpi(existingGroup,currentGroup))
                        this.IsNewGroup=true;
                    end

                end
            end
        end
    end

    methods(Abstract)
        getDialogData(this)
    end
end
function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end