

classdef ROISublabelDefinitionDialog<vision.internal.uitools.OkCancelDlg

    properties
SublabelName
Description
        Shape=labelType.Rectangle;
        InvalidSublabelNames={};

        NameChangedInEditMode=false;
        DescriptionChangedInEditMode=false;
        ColorChangedInEditMode=false;
        Color=[];
LabelTypeStrings
    end

    properties(Access=private)
IsNewMode
SublabelEditBox
ShapePopUpMenu
DescriptionEditBox
SessionROISublabelSet
SupportedROISublabelTypes
LabelName
ColorSelectPushButton
ColorSelected
    end


    methods
        function this=ROISublabelDefinitionDialog(tool,roiSublabelSetData,supportedSublabelTypes,labelName,roiSublabelData,invalidNames,color)

            dlgTitle=vision.getMessage('vision:labeler:AddNewROISublabel',labelName);
            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);
            this.IsNewMode=isempty(roiSublabelData);

            if~this.IsNewMode
                this.DlgTitle=['Edit sublabel ',roiSublabelData.Sublabel];
            end

            this.DlgSize=[410,200];
            this.LabelName=labelName;

            this.SupportedROISublabelTypes=supportedSublabelTypes;

            createDialog(this);


            if this.IsNewMode
                this.Dlg.Tag='New Subalbel Dialog';
            else
                this.Dlg.Tag='Edit Subalbel Dialog';
            end

            if this.IsNewMode
                this.SublabelName=char.empty;
                this.Description=char.empty;
                this.Color=color;

                if isempty(roiSublabelSetData.DefinitionStruct)
                    this.Shape=labelType.Rectangle;
                else

                    this.Shape=roiSublabelSetData.DefinitionStruct(end).Type;
                end
            else

                this.SublabelName=roiSublabelData.Sublabel;
                this.Description=roiSublabelData.Description;
                this.Shape=roiSublabelData.ROI;
                this.Color=roiSublabelData.Color;
            end

            addSublabelNameEditBox(this);
            addSublabelShapePopUpMenu(this);
            addColorSelectionOption(this);

            addDescriptionEditBox(this);


            this.InvalidSublabelNames=invalidNames;

            this.SessionROISublabelSet=roiSublabelSetData;


            if~useAppContainer
                uicontrol(this.SublabelEditBox);
            else
                focus(this.SublabelEditBox);
            end

        end

        function data=getDialogData(this)
            data=vision.internal.labeler.ROISublabel(this.LabelName,this.Shape,this.SublabelName,this.Description);
            data.Color=this.Color;
        end
    end


    methods(Access=protected)

        function onOK(this,~,~)



            drawnow;

            if~this.IsNewMode
                oldSublabelName=this.SublabelName;
                oldDescription=this.Description;
                oldColor=this.Color;
            end
            if~useAppContainer
                selectedIndex=get(this.ShapePopUpMenu,'Value');
                this.Shape=this.SupportedROISublabelTypes(selectedIndex);

                newSublabelName=get(this.SublabelEditBox,'String');
                newDescription=get(this.DescriptionEditBox,'String');
            else
                selectedItem=get(this.ShapePopUpMenu,'Value');
                selectedIndex=find(strcmp(this.LabelTypeStrings,selectedItem));
                this.Shape=this.SupportedROISublabelTypes(selectedIndex);

                newSublabelName=get(this.SublabelEditBox,'Value');
                newDescription=get(this.DescriptionEditBox,'Value');
            end

            if~isempty(this.ColorSelected)
                newColor=this.ColorSelected;
            else
                newColor=this.Color;
            end



            newDescription=vision.internal.labeler.retrieveNewLine(newDescription);

            IsValid=true;
            hFig=ancestor(this.Dlg,'figure');
            if this.IsNewMode||...
                (~this.IsNewMode&&~strcmp(oldSublabelName,newSublabelName))

                if(~this.IsNewMode&&strcmpi(oldSublabelName,newSublabelName))

                    IsValid=true;
                else

                    IsValid=this.SessionROISublabelSet.validateSublabelName(newSublabelName,this.LabelName,hFig);
                end


                badLabelNames=vision.internal.labeler.validation.invalidNames(newSublabelName);

                if strcmpi(newSublabelName,this.LabelName)


                    msg=vision.getMessage('vision:labeler:LabelNameMatchParentName',newSublabelName);
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    IsValid=false;
                elseif IsValid&&(~isempty(this.InvalidSublabelNames)&&...
                    ismember(newSublabelName,this.InvalidSublabelNames))


                    msg=vision.getMessage('vision:labeler:LabelHierarchyInvalidDlgMsg',newSublabelName,this.LabelName);
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    IsValid=false;
                elseif IsValid&&~isempty(badLabelNames)

                    msg=vision.getMessage('vision:labeler:LabelNameIsReserved',newSublabelName);
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    IsValid=false;
                end

            end

            if IsValid

                IsValid=this.SessionROISublabelSet.validateSublabelColor(newColor,hFig);
                if~IsValid
                    this.ColorSelected=[1,1,0.7];
                end
            end

            if IsValid
                if~this.IsNewMode
                    this.NameChangedInEditMode=~strcmp(oldSublabelName,newSublabelName);
                    this.DescriptionChangedInEditMode=~strcmp(oldDescription,newDescription);
                    if~isempty(newColor)
                        this.ColorChangedInEditMode=~isequal(oldColor,newColor);
                    end
                end

                this.SublabelName=newSublabelName;
                this.Description=newDescription;
                this.Color=newColor;

                this.IsCanceled=false;
                close(this);
            end
        end


        function addSublabelNameEditBox(this)
            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.1,0.85,0.5,0.1],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROISublabelNameEditBox'));

                this.SublabelEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String',this.SublabelName,...
                'Units','normalized',...
                'Position',[0.1,0.75,0.34,0.1],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varSublabelNameEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');



                this.SublabelEditBox.KeyPressFcn=@this.onKeyPress;
            else
                uilabel('Parent',this.Dlg,...
                'Position',[41,170,205,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROISublabelNameEditBox'));

                this.SublabelEditBox=uieditfield('Parent',this.Dlg,...
                'Value',this.SublabelName,...
                'Position',[41,150,139.4,20],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varSublabelNameEditBox',...
                'FontAngle','normal',...
                'Enable','on');



                this.SublabelEditBox.ValueChangedFcn=@(src,evt)this.updateSublblValChange(src,evt);
                this.SublabelEditBox.ValueChangingFcn=@(src,evt)this.updatingSublblValChange(src,evt);
            end
        end


        function addDescriptionEditBox(this)
            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.1,0.6,0.6,0.1],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROISublabelDescriptionEditBox'));

                this.DescriptionEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'Max',5,...
                'String',this.Description,...
                'Units','normalized',...
                'Position',[0.1,0.2,0.81,0.4],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varSublabelDescriptionEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');

                if~this.IsNewMode
                    uicontrol(this.DescriptionEditBox);
                end



                this.DescriptionEditBox.KeyPressFcn=@this.onEditBoxKeyPress;
            else
                uilabel('Parent',this.Dlg,...
                'Position',[41,120,246,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROISublabelDescriptionEditBox'));

                this.DescriptionEditBox=uitextarea('Parent',this.Dlg,...
                'Value',this.Description,...
                'Position',[41,40,332,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varSublabelDescriptionEditBox',...
                'FontAngle','normal',...
                'Enable','on',...
                'WordWrap','on');

                if~this.IsNewMode
                    focus(this.DescriptionEditBox);
                end



                this.DescriptionEditBox.ValueChangedFcn=@(src,evt)this.updateEditBoxValue(src,evt);
                this.DescriptionEditBox.ValueChangingFcn=@(src,evt)this.updatingEditBoxValue(src,evt);
            end

        end


        function addSublabelShapePopUpMenu(this)



            sublabelTypeChoices=this.SupportedROISublabelTypes;

            strList=cell(numel(sublabelTypeChoices),1);


            labeTypeIcons={...
            'Rectangle',...
            'Line',...
            'Scene',...
            'Custom',...
            'Pixel label',...
            'Cuboid',...
            'Projected cuboid',...
'Polygon'
            };

            for i=1:numel(sublabelTypeChoices)
                strList{i}=labeTypeIcons{double(sublabelTypeChoices(i))+1};
            end

            this.LabelTypeStrings=strList;

            if~useAppContainer
                this.ShapePopUpMenu=uicontrol('Parent',this.Dlg,'Style','popupmenu',...
                'Units','normalized',...
                'String',strList,...
                'Value',1,'Position',[0.46,0.75,0.33,0.1]);

                this.ShapePopUpMenu.Value=find(this.SupportedROISublabelTypes==this.Shape);
            else
                this.ShapePopUpMenu=uidropdown('Parent',this.Dlg,...
                'Items',strList,...
                'Value',strList{1},'Position',[188.6,150,135,20]);

                this.ShapePopUpMenu.Value=strList{find(this.SupportedROISublabelTypes==this.Shape)};
            end

            if~this.IsNewMode
                this.ShapePopUpMenu.Enable='off';
            end
        end


        function addColorSelectionOption(this)
            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.81,0.85,0.5,0.1],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:Color'));

                this.ColorSelectPushButton=uicontrol('Parent',this.Dlg,'Style','pushbutton',...
                'Units','normalized',...
                'Value',1,'Position',[0.81,0.75,0.1,0.1],...
                'Tag','ColorPush',...
                'BackgroundColor',this.Color,...
                'Callback',@this.colorMenu);
            else
                uilabel('Parent',this.Dlg,...
                'Position',[332,170,205,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:Color'));

                this.ColorSelectPushButton=uibutton('Parent',this.Dlg,...
                'Text','',...
                'Position',[332,150,42,20],...
                'Tag','ColorPush',...
                'BackgroundColor',this.Color,...
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


        function onKeyPress(this,~,evd)
            if useAppContainer

                if~validateKeyPressSupport(this,evd)
                    return;
                end
            end


            switch(evd.Key)
            case{'return'}
                onOK(this);
            case{'escape'}
                onCancel(this);
            end
        end


        function onEditBoxKeyPress(this,~,evd)
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


        function updatingSublblValChange(this,~,evt)
            this.SublabelEditBox.Value=evt.Value;
        end


        function updateSublblValChange(this,~,evt)
            this.SublabelEditBox.Value=evt.Value;
        end


        function updateEditBoxValue(this,~,evt)
            this.DescriptionEditBox.Value=evt.Value;
        end


        function updatingEditBoxValue(this,~,evt)
            this.DescriptionEditBox.Value=evt.Value;
        end

    end
end

function tf=useAppContainer
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end