classdef ROIAttributeDefinitionEditDialog<vision.internal.uitools.OkCancelDlg

    properties
Name
        Type=attributeType.List;
        Value=[];
Description
        InvalidAttributeNames={};
        NameChanged=false;
        ValueChanged=false;
        DescriptionChanged=false;
PixelFactor
AttributeTypeList
    end

    properties(Access=private)
NameEditBox
TypePopUpMenu
DescriptionTextBox
DescriptionEditBox
OldValueTextBox
NewValueTextBox
OldValueEditBox
NewValueEditBox
ValuePopupForLogical
SessionROIAttributeSet
SupportedROIAttributeTypes
LabelName
SublabelName
OldAttributeData
IsListAttribute
YOffset
    end


    methods

        function this=ROIAttributeDefinitionEditDialog(tool,attribSet,attributeData,invalidNames)

            labelName=attributeData.LabelName;
            sublabelName=attributeData.SublabelName;

            if isempty(sublabelName)
                dlgTitle=vision.getMessage('vision:labeler:EditROIAttributeForLabel',labelName);
            else
                dlgTitle=vision.getMessage('vision:labeler:EditROIAttributeForSublabel',labelName,sublabelName);
            end

            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);
            this.OldAttributeData=attributeData;

            this.IsListAttribute=(attributeType.List==attributeData.Type);
            if this.IsListAttribute
                this.YOffset=120;

            else
                this.YOffset=0;
            end
            this.DlgSize=[420,310+this.YOffset];
            this.LabelName=labelName;
            this.SublabelName=sublabelName;

            supportedAttributeTypes=[attributeType.Numeric,attributeType.String...
            ,attributeType.Logical,attributeType.List];
            this.SupportedROIAttributeTypes=supportedAttributeTypes;

            createDialog(this);
            this.Dlg.Tag='varEditAttributeDialog';
            this.PixelFactor=[this.DlgSize,this.DlgSize];


            this.Name=attributeData.Name;
            this.Description=attributeData.Description;
            if isprop(attributeData,'Type')
                this.Type=attributeData.Type;
            else
                this.Type=attributeData.ROI;
            end
            this.Value=attributeData.Value;


            this.InvalidAttributeNames=invalidNames;

            addAttributeNameEditBox(this);
            addAttributeTypePopUpMenu(this);

            if this.IsListAttribute
                addListValueEditBox(this);
            else
                addOtherValueEditBox(this);
            end
            addDescriptionEditBox(this);

            this.SessionROIAttributeSet=attribSet;
            if~this.IsListAttribute
                attributeTypeChangeCallback(this);
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


        function[val,isValid,valChanged]=getValueAndValidate(this)
            if~useAppContainer
                valOld=this.OldValueEditBox.String;
                valNew=this.NewValueEditBox.String;
                valChanged=~isempty(valNew);
            else
                valOld=this.OldValueEditBox.Value;
                valNew=this.NewValueEditBox.Value;
                valChanged=~all(cellfun(@isempty,valNew));
            end


            isValid=true;
            errMsg='';

            if~useAppContainer
                valNew=multilineText2Cell(this,valNew);
            end
            if valChanged

                if any(cellfun(@isempty,valNew))
                    isValid=false;
                    errMsg=vision.getMessage('vision:labeler:AttributeListValueInvalidDlgMsg');
                elseif length(unique(valNew))~=length(valNew)

                    isValid=false;
                    errMsg=vision.getMessage('vision:labeler:AttributeListValueNotUnique');
                elseif length(unique([valOld;valNew]))~=length([valOld;valNew])

                    isValid=false;
                    errMsg=vision.getMessage('vision:labeler:AttributeListValueRepeatsOld');
                end
            end
            if isValid
                val=[valOld;valNew];
            else
                val=valOld;
                title=vision.getMessage('vision:labeler:AttributeValueInvalidDlgName');
                vision.internal.labeler.handleAlert(this.Dlg,'errorWithModal',errMsg,title);
            end
        end


        function val=getValueFromPopup(this)

            if~useAppContainer
                selectedIndex=get(this.ValuePopupForLogical,'Value');

                if selectedIndex==1
                    val=logical([]);
                elseif selectedIndex==2
                    val=true;
                else
                    val=false;
                end
            else
                val=get(this.ValuePopupForLogical,'Value');
            end
        end


        function onOK(this,~,~)



            drawnow;


            [this.Name,isValidName,this.NameChanged]=getNameAndValidate(this);



            if this.IsListAttribute
                isValidValue=false;
                if isValidName
                    [this.Value,isValidValue,this.ValueChanged]=getValueAndValidate(this);

                end
            else
                isValidValue=true;
                this.ValueChanged=false;
            end



            if~useAppContainer
                this.Description=get(this.DescriptionEditBox,'String');
            else
                this.Description=get(this.DescriptionEditBox,'Value');
            end



            this.Description=vision.internal.labeler.retrieveNewLine(this.Description);

            this.DescriptionChanged=~strcmp(this.Description,this.OldAttributeData.Description);

            if isValidName&&isValidValue
                this.IsCanceled=false;
                close(this);
            end
        end


        function[newName,isValidName,nameChanged]=getNameAndValidate(this)

            oldName=this.OldAttributeData.Name;
            labelName=this.OldAttributeData.LabelName;
            sublabelName=this.OldAttributeData.SublabelName;

            if~useAppContainer
                newName=get(this.NameEditBox,'String');
            else
                newName=get(this.NameEditBox,'Value');
            end
            nameChanged=~strcmp(oldName,newName);

            isValidName=true;

            if nameChanged
                if isempty(sublabelName)
                    parentName=labelName;
                else
                    parentName=sublabelName;
                end

                isValidNameVar=this.SessionROIAttributeSet.validateAttributeName(labelName,sublabelName,newName,this.Dlg);


                badLabelNames=vision.internal.labeler.validation.invalidNames(newName);


                isValidName=validateName(this,isValidNameVar,labelName,sublabelName,newName,badLabelNames,parentName);
            end
        end


        function isValidName=validateName(this,isValidNameVar,labelName,sublabelName,newName,badLabelNames,parentName)

            isValidName=isValidNameVar;
            hFig=this.Dlg;
            if isValidNameVar&&ismember(newName,this.InvalidAttributeNames)

                if isempty(sublabelName)
                    errStr=labelName;
                else
                    errStr=[labelName,':',sublabelName];
                end
                msg=vision.getMessage('vision:labeler:LabelHierarchyInvalidDlgMsg',newName,errStr);
                title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                isValidName=false;
            elseif isValidNameVar&&~isempty(badLabelNames)

                title=vision.getMessage('vision:labeler:LabelNameIsReserved',newName);
                msg=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                isValidName=false;
            elseif strcmpi(newName,parentName)


                msg=vision.getMessage('vision:labeler:LabelNameMatchParentName',newName);
                title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                isValidName=false;
            end
        end


        function addAttributeNameEditBox(this)
            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[35,280+this.YOffset,210,20],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROIAttributeNameEditBox'));

                this.NameEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String',this.Name,...
                'Units','pixels',...
                'Position',[35,260+this.YOffset,192,20],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeNameEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');
            else
                uilabel('Parent',this.Dlg,...
                'Position',[35,280+this.YOffset,210,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROIAttributeNameEditBox'));

                this.NameEditBox=uieditfield('Parent',this.Dlg,...
                'Value',this.Name,...
                'Position',[35,260+this.YOffset,192,20],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeNameEditBox',...
                'FontAngle','normal',...
                'Enable','on',...
                'ValueChangedFcn',@(src,evt)updateOldAttribName(src,evt),...
                'ValueChangingFcn',@(src,evt)updatingOldAttribName(src,evt));
            end

        end


        function addOtherValueEditBox(this)
            if~useAppContainer
                this.OldValueTextBox=uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[35,230,420,20],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROIAttributeValueTB_list'));

                this.OldValueEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'Max',5,...
                'String','',...
                'Units','pixels',...
                'Position',[35,150,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeValueEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','off');

                strList={'Empty','True','False'};

                this.ValuePopupForLogical=uicontrol('Parent',this.Dlg,'Style','popupmenu',...
                'Units','pixels',...
                'String',strList,...
                'Value',1,...
                'Tag','varAttributeLogicalPopup',...
                'Position',[35,150,350,80],...
                'Enable','off',...
                'Visible','off');
            else
                this.OldValueTextBox=uilabel('Parent',this.Dlg,...
                'Position',[35,230,420,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROIAttributeValueTB_list'));

                this.OldValueEditBox=uitextarea('Parent',this.Dlg,...
                'Value',' ',...
                'Position',[35,150,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeValueEditBox',...
                'FontAngle','normal',...
                'Enable','off');

                strList={'Empty','True','False'};

                this.ValuePopupForLogical=uidropdown('Parent',this.Dlg,...
                'Items',strList,...
                'Value',strList{1},...
                'Tag','varAttributeLogicalPopup',...
                'Position',[35,200,350,25],...
                'Enable','off',...
                'Visible','off');

            end
        end


        function addListValueEditBox(this)
            if~useAppContainer
                this.OldValueTextBox=uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[35,230+this.YOffset,420,20],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:ROIAttributeListExisting'));

                this.OldValueEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'Max',5,...
                'String',this.Value,...
                'Units','pixels',...
                'Position',[35,150+this.YOffset,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeOldValueEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','off');

                this.NewValueTextBox=uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','pixels',...
                'Position',[35,110+125,420,20],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:AttributeListNewLine'));

                this.NewValueEditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'Max',5,...
                'String','',...
                'Units','pixels',...
                'Position',[35,155,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeNewValueEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');

...
...
...
...
...
...
...
...
...
...
...








            else
                this.OldValueTextBox=uilabel('Parent',this.Dlg,...
                'Position',[35,230+this.YOffset,420,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROIAttributeListExisting'));

                this.OldValueEditBox=uitextarea('Parent',this.Dlg,...
                'Value',this.Value,...
                'Position',[35,150+this.YOffset,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeOldValueEditBox',...
                'FontAngle','normal',...
                'Enable','off');

                this.NewValueTextBox=uilabel('Parent',this.Dlg,...
                'Position',[35,110+125,420,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:AttributeListNewLine'));

                this.NewValueEditBox=uitextarea('Parent',this.Dlg,...
                'Value','',...
                'Position',[35,155,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeNewValueEditBox',...
                'FontAngle','normal',...
                'Enable','on');
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
                'Position',[35,45,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeDescriptionEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');



                uicontrol(this.DescriptionEditBox);




                this.DescriptionEditBox.KeyPressFcn=@this.onEditBoxKeyPress;
            else
                this.DescriptionTextBox=uilabel('Parent',this.Dlg,...
                'Position',[35,120,280,20],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:ROIAttributeDescriptionEditBox'));

                this.DescriptionEditBox=uitextarea('Parent',this.Dlg,...
                'Value',this.Description,...
                'Position',[35,45,350,80],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varAttributeDescriptionEditBox',...
                'FontAngle','normal',...
                'Enable','on');



                focus(this.DescriptionEditBox);




                this.DescriptionEditBox.ValueChangedFcn=@(src,evt)this.updateDescription(src,evt);
                this.DescriptionEditBox.ValueChangingFcn=@(src,evt)this.updatingDescription(src,evt);
            end
        end


        function addAttributeTypePopUpMenu(this)



            attributeTypeChoices=this.SupportedROIAttributeTypes;

            strList=cell(numel(attributeTypeChoices),1);


            attribTypeIcons={...
            vision.getMessage('vision:labeler:attribNumericValue'),...
            vision.getMessage('vision:labeler:attribString'),...
            vision.getMessage('vision:labeler:attribLogical'),...
            vision.getMessage('vision:labeler:attribList')
            };

            for i=1:numel(attributeTypeChoices)
                strList{i}=attribTypeIcons{double(attributeTypeChoices(i))+1};
            end

            this.AttributeTypeList=strList;

            if~useAppContainer
                this.TypePopUpMenu=uicontrol('Parent',this.Dlg,'Style','popupmenu',...
                'Units','pixels',...
                'String',strList,...
                'Value',1,'Position',[235,240+this.YOffset,155,40],...
                'Tag','varAttributeTypePopup',...
                'Enable','off',...
                'Callback',@this.attributeTypeChangeCallback);


                this.TypePopUpMenu.Value=find(this.SupportedROIAttributeTypes==this.Type);
            else
                this.TypePopUpMenu=uidropdown('Parent',this.Dlg,...
                'Items',strList,...
                'Position',[235,240+this.YOffset+18,155,22],...
                'Tag','varAttributeTypePopup',...
                'Enable','off',...
                'ValueChangedFcn',@this.attributeTypeChangeCallback);


                idx=find(this.SupportedROIAttributeTypes==this.Type);
                this.TypePopUpMenu.Value=this.AttributeTypeList(idx);
            end


            this.TypePopUpMenu.Enable='off';


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
                    this.OldValueEditBox.String=this.Value;
                    this.OldValueEditBox.Max=1;
                    if(this.TypePopUpMenu.Value==1)
                        this.OldValueTextBox.String=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_Numeric');
                    else
                        this.OldValueTextBox.String=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_String');
                    end
                else
                    this.OldValueEditBox.Value=this.Value;
                    if(popupcondition==1)
                        this.OldValueTextBox.Text=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_Numeric');
                    else
                        this.OldValueTextBox.Text=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_String');
                    end
                end
                this.OldValueEditBox.Visible='on';
                this.OldValueEditBox.Position(2)=150+60;
                this.OldValueEditBox.Position(4)=20;

                this.ValuePopupForLogical.Visible='off';
                this.DescriptionTextBox.Position(2)=120+60;
                this.DescriptionEditBox.Position(2)=40+60;


            case 3
                this.OldValueEditBox.Visible='off';
                this.ValuePopupForLogical.Visible='on';

                this.DescriptionTextBox.Position(2)=120+60;
                this.DescriptionEditBox.Position(2)=40+60;
                if~useAppContainer
                    this.OldValueTextBox.String=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_op');
                    this.ValuePopupForLogical.Value=convertLogicalToPopupVal(this.Value);
                else
                    this.OldValueTextBox.Text=vision.getMessage('vision:labeler:ROIAttributeValueTB_def_op');
                    this.ValuePopupForLogical.Value=this.Value;
                end


            case 4

                this.OldValueEditBox.Visible='on';
                this.OldValueEditBox.Position(2)=150;
                this.OldValueEditBox.Position(4)=80;
                this.ValuePopupForLogical.Visible='off';
                this.DescriptionTextBox.Position(2)=120;
                this.DescriptionEditBox.Position(2)=40;
                if~useAppContainer
                    this.OldValueEditBox.Max=5;
                    this.OldValueTextBox.String=vision.getMessage('vision:labeler:ROIAttributeValueTB_list');
                else
                    this.OldValueTextBox.Text=vision.getMessage('vision:labeler:ROIAttributeValueTB_list');
                end
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

        function updateOldAttribName(this,~,evt)
            this.NameEditBox.Value=evt.Value;
        end

        function updatingOldAttribName(this,~,evt)
            this.NameEditBox.Value=evt.Value;
        end

        function updateDescription(this,~,evt)
            this.DescriptionEditBox.Value=evt.Value;
        end

        function updatingDescription(this,~,evt)
            this.DescriptionEditBox.Value=evt.Value;
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
    end
end


function val_popup=convertLogicalToPopupVal(val)
    if val==true
        val_popup=2;
    elseif val==false
        val_popup=3;
    else
        val_popup=1;
    end
end

function tf=useAppContainer
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
