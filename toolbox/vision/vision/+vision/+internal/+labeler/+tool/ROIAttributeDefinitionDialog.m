

classdef ROIAttributeDefinitionDialog<vision.internal.uitools.OkCancelDlg

    properties
Name
        Type=attributeType.List;
        Value=[];
Description
        InvalidAttributeNames={};
AttributeTypeList
LogicalTypeList
    end

    properties(Access=private)
IsNewMode
NameEditBox
TypePopUpMenu
DescriptionTextBox
DescriptionEditBox
ValueTextBox
ValueEditBox
ListValueEditBox
ValuePopupForLogical
SessionROIAttributeSet
SupportedROIAttributeTypes
LabelName
SublabelName
    end


    methods

        function this=ROIAttributeDefinitionDialog(tool,data,supportedAttributeTypes,labelName,sublabelName,invalidNames)

            if nargin<6
                invalidNames={};
            end

            if isempty(sublabelName)
                dlgTitle=vision.getMessage('vision:labeler:AddNewROIAttributeForLabel',labelName);
            else
                dlgTitle=vision.getMessage('vision:labeler:AddNewROIAttributeForSublabel',labelName,sublabelName);
            end

            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);

            this.DlgSize=[420,310];
            this.LabelName=labelName;
            this.SublabelName=sublabelName;

            this.SupportedROIAttributeTypes=supportedAttributeTypes;

            createDialog(this);

            if isa(data,'vision.internal.labeler.ROIAttributeSet')
                this.IsNewMode=true;
            else
                this.IsNewMode=false;
            end

            if this.IsNewMode
                this.Name=char.empty;
                this.Description=char.empty;
                if isempty(data.DefinitionStruct)
                    this.Type=attributeType.List;
                else

                    this.Type=data.DefinitionStruct(end).Type;
                end
            else

                this.Name=data.Attribute;
                this.Description=data.Description;
                this.Type=data.ROI;
            end


            this.InvalidAttributeNames=invalidNames;

            addAttributeNameEditBox(this);
            addAttributeTypePopUpMenu(this);

            addValueEditBox(this);
            addDescriptionEditBox(this);
            attributeTypeChangeCallback(this);
            if this.IsNewMode
                this.SessionROIAttributeSet=data;


                if~useAppContainer
                    uicontrol(this.NameEditBox);
                else
                    focus(this.NameEditBox);
                end
            end
        end


        function data=getDialogData(this)
            data=vision.internal.labeler.ROIAttribute(this.LabelName,this.SublabelName,this.Name,this.Type,this.Value,this.Description);
        end
    end


    methods(Access=protected)

        function cellStr=multilineText2Cell(~,multilineStr)

            [r,~]=size(multilineStr);
            cellStr=cell(r,1);
            for i=1:r

                cellStr{i}=strtrim(multilineStr(i,:));
            end
        end


        function[val,isValid,errMsg]=getValueFromEditBox(this)
            if~useAppContainer
                val=this.ValueEditBox.String;
            else
                if this.Type==attributeType.List
                    val=this.ListValueEditBox.Value;
                else
                    val=this.ValueEditBox.Value;
                end
            end
            isValid=true;
            errMsg='';
            switch this.Type
            case attributeType.List
                if~useAppContainer
                    val=multilineText2Cell(this,val);
                end

                if isempty(val)||any(cellfun(@isempty,val))
                    isValid=false;
                    errMsg=vision.getMessage('vision:labeler:AttributeListValueInvalidDlgMsg');
                elseif length(unique(val))~=length(val)

                    isValid=false;
                    errMsg=vision.getMessage('vision:labeler:AttributeListValueNotUnique');
                end
            case attributeType.Numeric
                if isnumeric([])&&isempty(val)
                    val=[];
                    isValid=true;
                else
                    val=str2double(val);
                    isValid=~isnan(val);
                end

                errMsg=vision.getMessage('vision:labeler:AttributeNumValueInvalidDlgMsg');
            case attributeType.String
                val=string(val);
            end
        end


        function val=getValueFromPopup(this)

            if~useAppContainer
                selectedIndex=get(this.ValuePopupForLogical,'Value');
            else
                selectedItem=get(this.ValuePopupForLogical,'Value');
                selectedIndex=find(strcmp(this.LogicalTypeList,selectedItem));
            end


            if selectedIndex==1
                val=logical([]);
            elseif selectedIndex==2
                val=true;
            else
                val=false;
            end
        end


        function[val,isValid,errMsg]=getValue(this)
            if this.Type==attributeType.Logical
                isValid=true;
                errMsg='';
                val=getValueFromPopup(this);
            else
                [val,isValid,errMsg]=getValueFromEditBox(this);
            end
        end


        function onOK(this,~,~)



            drawnow;
            if~useAppContainer
                selectedIndex=get(this.TypePopUpMenu,'Value');
                this.Type=this.SupportedROIAttributeTypes(selectedIndex);

                this.Name=get(this.NameEditBox,'String');
                [this.Value,isValidValue,errMsg]=getValue(this);
                this.Description=get(this.DescriptionEditBox,'String');
            else
                selectedItem=get(this.TypePopUpMenu,'Value');
                selectedIndex=find(strcmp(this.AttributeTypeList,selectedItem));
                this.Type=this.SupportedROIAttributeTypes(selectedIndex);

                this.Name=get(this.NameEditBox,'Value');
                [this.Value,isValidValue,errMsg]=getValue(this);
                this.Description=get(this.DescriptionEditBox,'Value');
            end



            this.Description=vision.internal.labeler.retrieveNewLine(this.Description);

            isValidName=true;
            hFig=this.Dlg;
            if this.IsNewMode

                isValidName=this.SessionROIAttributeSet.validateAttributeName(this.LabelName,this.SublabelName,this.Name,hFig);


                badLabelNames=vision.internal.labeler.validation.invalidNames(this.Name);

                if isempty(this.SublabelName)
                    parentName=this.LabelName;
                else
                    parentName=this.SublabelName;
                end

                if isValidName&&ismember(this.Name,this.InvalidAttributeNames)

                    if isempty(this.SublabelName)
                        errStr=this.LabelName;
                    else
                        errStr=[this.LabelName,':',this.SublabelName];
                    end
                    msg=vision.getMessage('vision:labeler:LabelHierarchyInvalidDlgMsg',this.Name,errStr);
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    isValidName=false;
                elseif isValidName&&~isValidValue



                    title=vision.getMessage('vision:labeler:AttributeValueInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',errMsg,title);
                elseif isValidName&&~isempty(badLabelNames)

                    msg=vision.getMessage('vision:labeler:LabelNameIsReserved',this.Name);
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    isValidName=false;
                elseif strcmpi(this.Name,parentName)


                    msg=vision.getMessage('vision:labeler:LabelNameMatchParentName',this.Name);
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    isValidName=false;
                end
            end

            if isValidName&&isValidValue
                this.IsCanceled=false;
                close(this);
            end
        end


        function addAttributeNameEditBox(this)
            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[35,280,210,20],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROIAttributeNameEditBox'));

                this.NameEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String',this.Name,...
                'Units','pixels',...
                'Position',[35,260,192,20],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeNameEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');
            else
                uilabel('Parent',this.Dlg,...
                'Position',[35,280,210,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROIAttributeNameEditBox'));

                this.NameEditBox=uieditfield('Parent',this.Dlg,...
                'Value',this.Name,...
                'Position',[35,260,192,20],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeNameEditBox',...
                'FontAngle','normal',...
                'Enable','on');

                this.NameEditBox.ValueChangedFcn=@(src,evt)this.updateAttribName(src,evt);
                this.NameEditBox.ValueChangingFcn=@(src,evt)this.updatingAttribName(src,evt);
            end

            if~this.IsNewMode
                this.NameEditBox.Enable='off';
            end
        end


        function addValueEditBox(this)
            if~useAppContainer
                this.ValueTextBox=uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[35,230,420,20],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROIAttributeValueTB_list'));

                this.ValueEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'Max',5,...
                'String',this.Description,...
                'Units','pixels',...
                'Position',[35,150,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeValueEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');

                strList={'Empty','True','False'};

                this.ValuePopupForLogical=uicontrol('Parent',this.Dlg,'Style','popupmenu',...
                'Units','pixels',...
                'String',strList,...
                'Value',1,...
                'Tag','varAttributeLogicalPopup',...
                'Position',[35,150,350,80],...
                'Visible','off');


                if~this.IsNewMode
                    uicontrol(this.DescriptionEditBox);
                end




            else
                this.ValueTextBox=uilabel('Parent',this.Dlg,...
                'Position',[35,230,420,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROIAttributeValueTB_list'));

                this.ValueEditBox=uieditfield('Parent',this.Dlg,...
                'Value',this.Description,...
                'Position',[35,150,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeValueEditBox',...
                'FontAngle','normal',...
                'Enable','on',...
                'Visible','off',...
                'ValueChangedFcn',@(src,evt)this.updateValueAttribValue(src,evt),...
                'ValueChangingFcn',@(src,evt)this.updatingValueAttribValue(src,evt));

                this.ListValueEditBox=uitextarea('Parent',this.Dlg,...
                'Value',this.Description,...
                'Position',[35,150,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeListValueEditBox',...
                'FontAngle','normal',...
                'Enable','on',...
                'ValueChangedFcn',@(src,evt)this.updateListAttribValue(src,evt),...
                'ValueChangingFcn',@(src,evt)this.updatingListAttribValue(src,evt));

                strList={'Empty','True','False'};
                this.LogicalTypeList=strList;

                this.ValuePopupForLogical=uidropdown('Parent',this.Dlg,...
                'Items',strList,...
                'Value',strList{1},...
                'Tag','varAttributeLogicalPopup',...
                'Position',[35,200,350,25],...
                'Visible','off');


                if~this.IsNewMode
                    focus(this.DescriptionEditBox);
                end

            end

        end


        function addDescriptionEditBox(this)
            if~useAppContainer
                this.DescriptionTextBox=uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[35,120,280,20],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROIAttributeDescriptionEditBox'));

                this.DescriptionEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'Max',5,...
                'String',this.Description,...
                'Units','pixels',...
                'Position',[35,40,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeDescriptionEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');


                if~this.IsNewMode
                    uicontrol(this.DescriptionEditBox);
                end



                this.DescriptionEditBox.KeyPressFcn=@this.onEditBoxKeyPress;
            else
                this.DescriptionTextBox=uilabel('Parent',this.Dlg,...
                'Position',[35,120,280,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROIAttributeDescriptionEditBox'));

                this.DescriptionEditBox=uitextarea('Parent',this.Dlg,...
                'Value',this.Description,...
                'Position',[35,40,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeDescriptionEditBox',...
                'FontAngle','normal',...
                'Enable','on',...
                'WordWrap','on');


                if~this.IsNewMode
                    focus(this.DescriptionEditBox);
                end



                this.DescriptionEditBox.ValueChangedFcn=@(src,evt)this.updateEditBoxValue(src,evt);
                this.DescriptionEditBox.ValueChangedFcn=@(src,evt)this.updatingEditBoxValue(src,evt);
            end
        end


        function addAttributeTypePopUpMenu(this)



            attributeTypeChoices=this.SupportedROIAttributeTypes;

            strList=cell(numel(attributeTypeChoices),1);


            attribTypeIcons={...
            vision.getMessage('vision:labeler:attribNumericValue'),...
            vision.getMessage('vision:labeler:attribString'),...
            vision.getMessage('vision:labeler:attribLogical'),...
            vision.getMessage('vision:labeler:attribList')};

            for i=1:numel(attributeTypeChoices)
                strList{i}=attribTypeIcons{double(attributeTypeChoices(i))+1};
            end

            this.AttributeTypeList=strList;

            if~useAppContainer

                this.TypePopUpMenu=uicontrol('Parent',this.Dlg,'Style','popupmenu',...
                'Units','pixels',...
                'String',strList,...
                'Value',1,'Position',[235,240,155,40],...
                'Tag','varAttributeTypePopup',...
                'Callback',@this.attributeTypeChangeCallback);


                this.TypePopUpMenu.Value=find(this.SupportedROIAttributeTypes==this.Type);
            else
                this.TypePopUpMenu=uidropdown('Parent',this.Dlg,...
                'Items',strList,...
                'Value',strList{1},'Position',[235,259,155,23],...
                'Tag','varAttributeTypePopup',...
                'ValueChangedFcn',@this.attributeTypeChangeCallback);


                idx=find(this.SupportedROIAttributeTypes==this.Type);
                this.TypePopUpMenu.Value=this.AttributeTypeList(idx);
            end

            if~this.IsNewMode
                this.TypePopUpMenu.Enable='off';
            end


        end


        function attributeTypeChangeCallback(this,~,~)
...
...
...
...
...
...
...
...
            if~useAppContainer
                popupcondition=this.TypePopUpMenu.Value;
            else
                popupcondition=find(strcmp(this.AttributeTypeList,this.TypePopUpMenu.Value));

            end
            switch popupcondition
            case{1,2}
                if~useAppContainer
                    this.ValueEditBox.String=[];
                    this.ValueEditBox.Max=1;
                    if(this.TypePopUpMenu.Value==1)
                        this.ValueTextBox.String=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_Numeric');
                    else
                        this.ValueTextBox.String=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_String');
                    end
                else
                    this.ValueEditBox.Value='';
                    if(popupcondition==1)
                        this.ValueTextBox.Text=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_Numeric');
                    else
                        this.ValueTextBox.Text=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_String');
                    end
                    this.ListValueEditBox.Visible='off';
                end

                this.ValueEditBox.Visible='on';
                this.ValueEditBox.Position(2)=150+60;
                this.ValueEditBox.Position(4)=20;
                this.ValuePopupForLogical.Visible='off';
                this.DescriptionTextBox.Position(2)=120+60;
                this.DescriptionEditBox.Position(2)=40+60;

            case 3
                this.ValueEditBox.Visible='off';
                this.ValuePopupForLogical.Visible='on';
                this.DescriptionTextBox.Position(2)=120+60;
                this.DescriptionEditBox.Position(2)=40+60;
                if~useAppContainer
                    this.ValueTextBox.String=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_op');
                else
                    this.ValueTextBox.Text=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_op');
                    this.ListValueEditBox.Visible='off';
                end


            case 4
                if~useAppContainer
                    this.ValueEditBox.Max=5;
                    this.ValueTextBox.String=vision.getMessage('vision:labeler:ROIAttributeValueTB_list');
                    this.ValueEditBox.Visible='on';
                    this.ValueEditBox.Position(2)=150;
                    this.ValueEditBox.Position(4)=80;
                else
                    this.ValueTextBox.Text=vision.getMessage('vision:labeler:ROIAttributeValueTB_list');
                    this.ValueEditBox.Visible='off';
                    this.ListValueEditBox.Visible='on';
                    this.ListValueEditBox.Position(2)=150;
                    this.ListValueEditBox.Position(4)=80;
                end

                this.ValuePopupForLogical.Visible='off';
                this.DescriptionTextBox.Position(2)=120;
                this.DescriptionEditBox.Position(2)=40;

            end
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

        function updateAttrValue(this,~,evt)
            this.NameEditBox.Value=evt.Value;
        end

        function updatingAttrValue(this,~,evt)
            this.NameEditBox.Value=evt.Value;
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

        function updateAttribName(this,~,evt)
            this.NameEditBox.Value=evt.Value;
        end

        function updatingAttribName(this,~,evt)
            this.NameEditBox.Value=evt.Value;
        end

        function updateValueAttribValue(this,~,evt)
            this.ValueEditBox.Value=evt.Value;
        end

        function updatingValueAttribValue(this,~,evt)
            this.ValueEditBox.Value=evt.Value;
        end

        function updateListAttribValue(this,~,evt)
            this.ListValueEditBox.Value=evt.Value;
        end

        function updatingListAttribValue(this,~,evt)
            this.ListValueEditBox.Value=evt.Value;
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