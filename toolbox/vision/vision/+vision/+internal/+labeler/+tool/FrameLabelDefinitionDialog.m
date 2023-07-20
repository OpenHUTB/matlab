

classdef FrameLabelDefinitionDialog<vision.internal.labeler.tool.LabelDefinitionDialog


    methods
        function this=FrameLabelDefinitionDialog(tool,frameLabelSet,...
            secondaryLabelSet,frameLabel)

            dlgTitle=vision.getMessage('vision:labeler:AddNewFrameLabel');

            this=this@vision.internal.labeler.tool.LabelDefinitionDialog(tool,dlgTitle);

            this.DlgSize=[300,250];

            createDialog(this);

            if nargin==4
                this.LabelAddMode=false;
            else
                this.LabelAddMode=true;
            end

            if this.LabelAddMode
                this.LabelName=char.empty;
                this.Description=char.empty;
                this.Color=squeeze(frameLabelSet.colorLookup(1,frameLabelSet.ColorCounter+1,:));
            else
                this.LabelName=frameLabel.Label;
                this.Description=frameLabel.Description;
                this.Group=frameLabel.Group;
                this.Color=frameLabel.Color;
            end

            addLabelNameEditBox(this);
            addLabelGroupPopupMenu(this,frameLabelSet);
            addColorSelectionOption(this);
            addDescriptionEditBox(this);

            this.SessionLabelSet=frameLabelSet;
            this.SessionSecondaryLabelSet=secondaryLabelSet;


            if~useAppContainer
                uicontrol(this.LabelEditBox);
            else
                focus(this.LabelEditBox);
            end

        end

        function data=getDialogData(this)
            data.Label=vision.internal.labeler.FrameLabel(this.LabelName,...
            this.Description,this.Group);
            data.Label.Color=this.Color;
            data.IsNewGroup=this.IsNewGroup;
            data.IsColorChange=this.ColorChangedInEditMode;
        end
    end


    methods(Access=protected)
        function onOK(this,~,~)



            drawnow;

            if~this.LabelAddMode
                oldLabelName=this.LabelName;
                oldDescription=this.Description;
                oldGroupName=this.Group;
                oldColor=this.Color;
            end

            if~useAppContainer
                newLabelName=get(this.LabelEditBox,'String');
                newDescription=get(this.DescriptionEditBox,'String');
            else
                newLabelName=get(this.LabelEditBox,'Value');
                newDescription=get(this.DescriptionEditBox,'Value');
            end



            newDescription=vision.internal.labeler.retrieveNewLine(newDescription);
            newColor=this.ColorSelected;

            isValidName=true;
            hFig=ancestor(this.Dlg,'figure');
            if this.LabelAddMode||...
                (~this.LabelAddMode&&~strcmp(oldLabelName,newLabelName))

                if(~this.LabelAddMode&&strcmpi(oldLabelName,newLabelName))

                    isValidName=true;
                else

                    isValidName=this.SessionLabelSet.validateLabelName(newLabelName,hFig)...
                    &&this.SessionSecondaryLabelSet.validateLabelName(newLabelName,hFig);

                    if isValidName&&ismember(newLabelName,this.InvalidLabelNames)
                        msg=vision.getMessage('vision:labeler:LabelNameInvalidDlgMsg',this.LabelName);
                        title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                        vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                        isValidName=false;
                    end
                end


                badLabelNames=vision.internal.labeler.validation.invalidNames(newLabelName);

                if isValidName&&~isempty(badLabelNames)
                    msg=vision.getMessage('vision:labeler:LabelNameIsReserved',newLabelName);
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    isValidName=false;
                end
            end

            if isValidName
                isValidName=getGroupInfo(this);
            end

            if isValidName
                if~this.LabelAddMode
                    this.NameChangedInEditMode=~strcmp(oldLabelName,newLabelName);
                    this.DescriptionChangedInEditMode=~strcmp(oldDescription,newDescription);
                    this.GroupChangedInEditMode=~strcmp(oldGroupName,this.Group);
                    this.ColorChangedInEditMode=~isequal(oldColor,newColor);
                end

                this.LabelName=newLabelName;
                this.Description=newDescription;
                this.Color=this.ColorSelected;

                this.IsCanceled=false;
                close(this);
            end
        end
    end
end

function tf=useAppContainer
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end