



classdef ROILabelDefinitionDialog<vision.internal.labeler.tool.LabelDefinitionDialog

    properties
        Shape=labelType.Rectangle
LabelTypeStrings
    end

    properties(Access=private)

SublabelNames
OldData
    end

    properties(Access=protected)
SupportedROILabelTypes
ShapePopUpMenu

        HasCuboid=false;
    end


    methods

        function this=ROILabelDefinitionDialog(tool,roiLabelSet,...
            secondaryLabelSet,supportedLabelTypes,labelAddMode,...
            roiLabelData,sublabelNames)

            dlgTitle=vision.getMessage('vision:labeler:AddNewROILabel');
            this=this@vision.internal.labeler.tool.LabelDefinitionDialog(tool,dlgTitle);

            this.LabelAddMode=labelAddMode;

            if nargin>6
                this.SublabelNames=sublabelNames;
            else
                this.SublabelNames='';
            end

            this.HasCuboid=~isempty(ismember(supportedLabelTypes==labelType.Cuboid,1));

            if~this.LabelAddMode
                this.DlgTitle=[vision.getMessage('vision:labeler:ContextMenuEditLabel'),' ',roiLabelData.Label];
            end

            setDislogSize(this);

            this.SupportedROILabelTypes=supportedLabelTypes;

            createDialog(this);

            if this.LabelAddMode
                this.LabelName=char.empty;
                this.Description=char.empty;
                this.Color=squeeze(roiLabelSet.colorLookup(1,roiLabelSet.ColorCounter+1,:));
                if isempty(roiLabelSet.DefinitionStruct)
                    this.Shape=labelType.Rectangle;
                else

                    this.Shape=roiLabelSet.DefinitionStruct(end).Type;
                end
                this.Dlg.Tag='varCreateLabelDefDlg';
            else

                this.LabelName=roiLabelData.Label;
                this.Description=roiLabelData.Description;
                this.Shape=roiLabelData.ROI;
                this.Group=roiLabelData.Group;
                this.Color=roiLabelData.Color;
                this.Dlg.Tag='varEditLabelDefDlg';
            end

            addLabelNameEditBox(this);
            addLabelShapePopUpMenu(this,roiLabelSet);
            addColorSelectionOption(this);
            addLabelGroupPopupMenu(this,roiLabelSet);

            addDescriptionEditBox(this);

            this.SessionLabelSet=roiLabelSet;
            this.SessionSecondaryLabelSet=secondaryLabelSet;


            if~useAppContainer
                uicontrol(this.LabelEditBox);
            else
                focus(this.LabelEditBox);
            end

        end


        function data=getDialogData(this)
            data.Label=lidar.internal.labeler.ROILabel(this.Shape,...
            this.LabelName,this.Description,this.Group);
            data.Label.Color=this.Color;
            data.Label.IsRectCuboid=this.HasCuboid;
            data.IsNewGroup=this.IsNewGroup;
        end
    end


    methods(Access=protected)

        function onOK(this,~,~)



            drawnow;
            pause(1);

            if~this.LabelAddMode
                oldLabelName=this.LabelName;
                oldDescription=this.Description;
                oldGroupName=this.Group;
                oldColor=this.Color;
            end



            if isempty(this.ColorSelected)
                this.ColorSelected=this.Color;
            end

            newColor=this.ColorSelected;

            if~useAppContainer
                selectedIndex=get(this.ShapePopUpMenu,'Value');
                this.Shape=this.SupportedROILabelTypes{selectedIndex};
                newLabelName=get(this.LabelEditBox,'String');
                newDescription=get(this.DescriptionEditBox,'String');
            else
                selectedItem=get(this.ShapePopUpMenu,'Value');
                selectedIndex=find(strcmp(this.LabelTypeStrings,selectedItem));
                this.Shape=this.SupportedROILabelTypes{selectedIndex};
                newLabelName=get(this.LabelEditBox,'Value');
                newDescription=get(this.DescriptionEditBox,'Value');
            end



            newDescription=vision.internal.labeler.retrieveNewLine(newDescription);

            isValid=true;
            hFig=ancestor(this.Dlg,'figure');
            if this.LabelAddMode||...
                (~this.LabelAddMode&&~strcmp(oldLabelName,newLabelName))

                if(~this.LabelAddMode&&strcmpi(oldLabelName,newLabelName))

                    isValid=true;
                else
                    isValid=this.SessionLabelSet.validateLabelName(newLabelName,hFig)...
                    &&this.SessionSecondaryLabelSet.validateLabelName(newLabelName,hFig);
                end


                badLabelNames=lidar.internal.labeler.validation.invalidNames(newLabelName);

                if isValid&&~isempty(badLabelNames)
                    msg=vision.getMessage('vision:labeler:LabelNameIsReserved',newLabelName);
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    isValid=false;
                end

            end



            if isValid
                if this.LabelAddMode||...
                    (~this.LabelAddMode&&~isequal(oldColor,newColor))
                    isValid=this.SessionLabelSet.validateLabelColor(newColor,hFig);
                    if~isValid
                        this.ColorSelected=[1,1,0.7];
                    end
                end
            end

            if isValid
                isValid=getGroupInfo(this);
            end

            if isValid
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


        function addLabelShapePopUpMenu(this,roiLabelSet)








            strList{1}=vision.getMessage('lidar:labeler:Cuboid');
            strList{2}=vision.getMessage('lidar:labeler:Line');
            strList{3}=vision.getMessage('lidar:labeler:Voxel');

            this.LabelTypeStrings=strList;



            defaultLabelType=findLabelTypeIndex(this.SupportedROILabelTypes,this.Shape);

            if defaultLabelType==3&&this.LabelAddMode



                voxelColorLookUpTable=squeeze(lidar.internal.labeler.getColorMap('Voxel'));
                if~isempty(voxelColorLookUpTable(roiLabelSet.getNextVoxelLabel,:))





                    this.Color=voxelColorLookUpTable(roiLabelSet.getNextVoxelLabel,:);
                end
            end



            if~useAppContainer
                this.ShapePopUpMenu=uicontrol('Parent',this.Dlg,'Style','popupmenu',...
                'Units','normalized',...
                'String',strList,...
                'Value',defaultLabelType,'Position',[0.5,0.78,0.275,0.08],...
                'Callback',@(varargin)this.labelTypeChangeCallback(roiLabelSet),...
                'Tag','ShapePopup');

                this.ShapePopUpMenu.Value=findLabelTypeIndex(this.SupportedROILabelTypes,this.Shape);

            else

                this.ShapePopUpMenu=uidropdown('Parent',this.Dlg,...
                'Items',strList,...
                'Position',[0.5,0.78,0.275,0.08].*[this.DlgSize,this.DlgSize],...
                'BackgroundColor',[1,1,1],...
                'ValueChangedFcn',@(varargin)this.labelTypeChangeCallback(roiLabelSet),...
                'Tag','ShapePopup');


                this.ShapePopUpMenu.Value=strList{1};
            end

            if~this.LabelAddMode
                this.ShapePopUpMenu.Enable='off';
            end
        end

        function labelTypeChangeCallback(this,roiLabelSet)



            if~useAppContainer
                condition=this.ShapePopUpMenu.Value==3;
            else
                condition=strcmp(this.ShapePopUpMenu.Value,'Voxel');
            end
            if condition
                voxelColorLookUpTable=squeeze(lidar.internal.labeler.getColorMap('Voxel'));
                this.Color=voxelColorLookUpTable(roiLabelSet.getNextVoxelLabel,:)';
            else
                this.Color=squeeze(roiLabelSet.colorLookup(1,roiLabelSet.ColorCounter+1,:));
            end
            this.ColorSelected=this.Color';
            this.ColorSelectPushButton.BackgroundColor=this.Color';
        end
    end


    methods(Access=private)

        function setDislogSize(this)
            if this.HasCuboid
                this.DlgSize=[520,250];
            end
        end
    end
end

function idx=findLabelTypeIndex(labelTypeChoicesEnum,label)
    for i=1:numel(labelTypeChoicesEnum)
        if labelTypeChoicesEnum{i}==label
            idx=i;
            return;
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
