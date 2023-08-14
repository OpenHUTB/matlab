








classdef EditTab<handle

    properties(SetAccess=private,Hidden,Transient)

Tab
    end

    properties(SetAccess=private,GetAccess={?lidartest.apps.lidarViewer.LidarViewerAppTester})
        AlgorithmSection lidar.internal.lidarViewer.view.section.AlgorithmSection
    end

    properties(Access=private)
        ColorSection lidar.internal.lidarViewer.view.section.ColorSection

        VisualizeSection lidar.internal.lidarViewer.view.section.VisualizeSection

        FinalizeSection lidar.internal.lidarViewer.view.section.FinalizeSection
    end

    properties

SpatialEditNames

TemporalEditNames

CustomSpatialFuncNames

CustomTemporalFuncNames

    end

    properties
BackGroundColor

        CustomColormapSettings lidar.internal.lidarViewer.view.CustomColormapSettings

    end

    properties(Access=private)
ColorVariationPrev
    end

    methods



        function this=EditTab()

            this.Tab=matlab.ui.internal.toolstrip.Tab(...
            getString(message('lidar:lidarViewer:EditTab')));
            this.Tab.Tag='editTab';
            createTab(this);

        end


        function close(this)


            delete(this.AlgorithmSection.EditsGallery);
        end


        function enable(this)
            isColorSelected=~this.ColorSection.ColormapValDropDown.Enabled;
            this.Tab.enableAll();
            if isColorSelected


                this.ColorSection.ColormapValDropDown.Enabled=false;
                this.ColorSection.ColorVariationDropDown.Enabled=false;
            end
        end


        function disable(this)
            this.Tab.disableAll();
        end
    end




    methods
        function setEditTabOptions(this,isDataEdited)




            this.enable();

            this.FinalizeSection.AcceptEditButton.Enabled=isDataEdited;
        end


        function disableAlgorithmAndFinalizeSection(this)


            this.AlgorithmSection.CustomEditDropDown.Enabled=false;
            this.AlgorithmSection.EditsGallery.Enabled=false;
            this.FinalizeSection.AcceptEditButton.Enabled=false;
            this.FinalizeSection.DiscardEditButton.Enabled=false;
        end


        function updateEditsGallery(this)


            import matlab.ui.internal.toolstrip.*
            import matlab.ui.internal.toolstrip.Icon.*;



            editSpatialTags=cell(numel(this.SpatialEditNames)+numel(this.CustomSpatialFuncNames),1);
            for i=1:numel(this.SpatialEditNames)
                metaClass=meta.class.fromName(this.SpatialEditNames{i});
                editSpatialTags{i}=strcat(getAlgorithmName(metaClass),'Btn');
            end


            for i=1:numel(this.CustomSpatialFuncNames)
                [~,name,~]=fileparts(this.CustomSpatialFuncNames{i});
                editSpatialTags{numel(this.SpatialEditNames)+i}=strcat(name,'Btn');
            end


            editAlgorithmList=this.AlgorithmSection.SpatialEditsCategory.Children;

            if~isempty(editAlgorithmList)
                for i=1:numel(editAlgorithmList)
                    if~(strcmp(editAlgorithmList(i).Tag,editSpatialTags))
                        remove(this.AlgorithmSection.SpatialEditsCategory,editAlgorithmList(i));
                    end
                end
            end


            for i=1:numel(this.SpatialEditNames)
                metaClass=meta.class.fromName(this.SpatialEditNames{i});

                try

                    item=getChildByTag(this.AlgorithmSection.SpatialEditsCategory,editSpatialTags{i});

                    item.Text=getAlgorithmName(metaClass);
                    item.Description=getAlgorithmDescription(metaClass);
                    item.Icon=getAlgorithmIcon(metaClass);
                    item.ItemPushedFcn=@(~,~)this.editAlgorithmSelected(i,false);

                catch



                    galleryItem=GalleryItem(getAlgorithmName(metaClass),getAlgorithmIcon(metaClass));
                    galleryItem.Description=getAlgorithmDescription(metaClass);
                    galleryItem.ItemPushedFcn=@(~,~)this.editAlgorithmSelected(i,false);
                    galleryItem.Tag=strcat(getAlgorithmName(metaClass),'Btn');
                    this.AlgorithmSection.SpatialEditsCategory.add(galleryItem);
                end
            end


            for i=1:numel(this.CustomSpatialFuncNames)
                try

                    item=getChildByTag(this.AlgorithmSection.SpatialEditsCategory,editSpatialTags{numel(this.SpatialEditNames)+i});
                    [~,name,~]=fileparts(this.CustomSpatialFuncNames{i});
                    item.Text=name;
                    item.ItemPushedFcn=@(~,~)this.customEditFuncSelected(i,false);

                catch



                    icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
                    '+internal','+lidarViewer','+view','+icons','customFunctionEdit_24.png');
                    [~,name,~]=fileparts(this.CustomSpatialFuncNames{i});
                    galleryItem=GalleryItem(name,icon);
                    galleryItem.ItemPushedFcn=@(~,~)this.customEditFuncSelected(i,false);
                    galleryItem.Tag=strcat(name,'Btn');
                    this.AlgorithmSection.SpatialEditsCategory.add(galleryItem);
                end
            end



            editTemporalTags=cell(numel(this.TemporalEditNames),1);
            for i=1:numel(this.TemporalEditNames)
                metaClass=meta.class.fromName(this.TemporalEditNames{i});
                editTemporalTags{i}=strcat(getAlgorithmName(metaClass),'Btn');
            end


            for i=1:numel(this.CustomTemporalFuncNames)
                [~,name,~]=fileparts(this.CustomTemporalFuncNames{i});
                editTemporalTags{numel(this.TemporalEditNames)+i}=strcat(name,'Btn');
            end


            editAlgorithmList=this.AlgorithmSection.TemporalEditsCategory.Children;

            if~isempty(editAlgorithmList)
                for i=1:numel(editAlgorithmList)
                    if~(strcmp(editAlgorithmList(i).Tag,editTemporalTags))
                        remove(this.AlgorithmSection.TemporalEditsCategory,editAlgorithmList(i));
                    end
                end
            end


            for i=1:numel(this.TemporalEditNames)
                metaClass=meta.class.fromName(this.TemporalEditNames{i});

                try

                    item=getChildByTag(this.AlgorithmSection.TemporalEditsCategory,editTemporalTags{i});

                    item.Text=getAlgorithmName(metaClass);
                    item.Description=getAlgorithmDescription(metaClass);
                    item.Icon=getAlgorithmIcon(metaClass);
                    item.ItemPushedFcn=@(~,~)this.editAlgorithmSelected(i,true);

                catch



                    galleryItem=GalleryItem(getAlgorithmName(metaClass),getAlgorithmIcon(metaClass));
                    galleryItem.Description=getAlgorithmDescription(metaClass);
                    galleryItem.ItemPushedFcn=@(~,~)this.editAlgorithmSelected(i,true);
                    galleryItem.Tag=strcat(getAlgorithmName(metaClass),'Btn');
                    this.AlgorithmSection.TemporalEditsCategory.add(galleryItem);
                end
            end


            for i=1:numel(this.CustomTemporalFuncNames)
                try

                    item=getChildByTag(this.AlgorithmSection.TemporalEditsCategory,editTemporalTags{numel(this.TemporalEditNames)+i});
                    [~,name,~]=fileparts(this.CustomTemporalFuncNames{i});
                    item.Text=name;
                    item.ItemPushedFcn=@(~,~)this.customEditFuncSelected(i,true);

                catch



                    icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
                    '+internal','+lidarViewer','+view','+icons','customFunctionEdit_24.png');
                    [~,name,~]=fileparts(this.CustomTemporalFuncNames{i});
                    galleryItem=GalleryItem(name,icon);
                    galleryItem.ItemPushedFcn=@(~,~)this.customEditFuncSelected(i,true);
                    galleryItem.Tag=strcat(name,'Btn');
                    this.AlgorithmSection.TemporalEditsCategory.add(galleryItem);
                end
            end

        end


        function setColormapValText(this,text)

            this.ColorSection.ColormapValDropDown.Text=text;
        end


        function setColormapText(this,text)



            this.ColorSection.ColormapDropDown.Text=text;
            this.ColorSection.ColormapValDropDown.Enabled=true;
            this.ColorSection.ColorVariationDropDown.Enabled=true;
        end


        function addColorInColormap(this)


            setColormapPopUp(this);

            popup=this.ColorSection.ColormapDropDown.Popup;
            colorMapList=this.getColormapList();
            idx=numel(colorMapList)+1;
            dropDownEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:Color')),@(~,~)this.changeColorMap(idx),'colorItem');
            popup.add(dropDownEntry);

            this.ColorSection.ColormapDropDown.Popup=popup;
        end


        function setColormapPopUp(this)




            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();

            colorMapList=this.getColormapList();
            tag={'redBlueWhiteItem','parulaItem','jetItem','springItem','hotItem'};

            for i=1:numel(colorMapList)
                dropDownEntry=this.createListItemHelper(...
                colorMapList{i},@(~,~)this.changeColorMap(i),tag{i});
                popup.add(dropDownEntry);
            end
            this.ColorSection.ColormapDropDown.Popup=popup;
        end
    end




    methods(Access=private)
        function createTab(this)



            tab=this.Tab;

            this.ColorSection=lidar.internal.lidarViewer.view.section.ColorSection(tab,false);
            this.VisualizeSection=lidar.internal.lidarViewer.view.section.VisualizeSection(tab,false);
            this.AlgorithmSection=lidar.internal.lidarViewer.view.section.AlgorithmSection(tab);
            this.FinalizeSection=lidar.internal.lidarViewer.view.section.FinalizeSection(tab);
            this.CustomColormapSettings=lidar.internal.lidarViewer.view.CustomColormapSettings();


            this.intallListeners();

            this.setEditTabOptions(false);

        end
    end




    methods(Access=private)
        function intallListeners(this)


            this.installColorSectionListeners();

            this.installVisualizeSectionListeners();

            this.installAlgorithmSectionListeners();

            this.installFinalizeSectionListeners();
        end


        function installColorSectionListeners(this)


            this.ColorSection.ColormapDropDown.DynamicPopupFcn=...
            @(~,~)getColormapPopUp(this);

            this.ColorSection.ColormapValDropDown.DynamicPopupFcn=...
            @(~,~)getColormapValPopUp(this);

            this.ColorSection.ColorVariationDropDown.DynamicPopupFcn=...
            @(~,~)getColorVariationPopUp(this);

            this.ColorSection.BackgroundColorButton.ButtonPushedFcn=...
            @(~,~)requestToChangeBackgroundColor(this);

            this.ColorSection.PointSizeSpinner.ValueChangedFcn=...
            @(~,~)changePointSizeValue(this);

            addlistener(this,'BackgroundColorChangeRequest',...
            @(~,evt)setBackGroundColor(this));

            addlistener(this.CustomColormapSettings,'CustomColormapRequest',@(~,evt)customVariationRequest(this,evt));

        end


        function installVisualizeSectionListeners(this)


            this.VisualizeSection.XYSliceView.ButtonPushedFcn=...
            @(~,~)doPlanarViewView(this,1);

            this.VisualizeSection.YZSliceView.ButtonPushedFcn=...
            @(~,~)doPlanarViewView(this,2);

            this.VisualizeSection.XZSliceView.ButtonPushedFcn=...
            @(~,~)doPlanarViewView(this,3);

            this.VisualizeSection.RestoreView.ButtonPushedFcn=...
            @(~,~)doDefaultView(this);

        end


        function installAlgorithmSectionListeners(this)


            this.AlgorithmSection.CustomEditDropDown.DynamicPopupFcn=...
            @(~,~)this.getCustomEditPopup();
        end


        function installFinalizeSectionListeners(this)


            this.FinalizeSection.AcceptEditButton.ButtonPushedFcn=...
            @(~,~)this.exitEditMode(true);

            this.FinalizeSection.DiscardEditButton.ButtonPushedFcn=...
            @(~,~)this.exitEditMode(false);
        end
    end




    events
RequestToEditSignals
RequestToExitEditMode
RequestToUpdateEdits
RequestToEditDataWithCustomFunction
ColorChangeRequest
BackgroundColorChangeRequest
PointSizeChangeRequest
PlanarViewChangeRequest
DefaultViewChangeRequest
ExternalTrigger
CustomColormapRequest
    end




    methods(Access=private)




        function popup=getCustomEditPopup(this)
            if isempty(this.AlgorithmSection.CustomEditDropDown.Popup)
                this.setCustomEditsPopup();
            end
            popup=this.AlgorithmSection.CustomEditDropDown.Popup;
        end


        function editAlgorithmSelected(this,i,isTemporal)
            if~isTemporal
                metaClass=meta.class.fromName(this.SpatialEditNames{i});
            else
                metaClass=meta.class.fromName(this.TemporalEditNames{i});
            end
            selectededitName=eval([metaClass.Name,'.EditName']);
            evt=lidar.internal.lidarViewer.events.EditRequestEventData(...
            selectededitName,isTemporal);
            notify(this,'RequestToEditSignals',evt);
        end


        function customEditFuncSelected(this,i,isTemporal)
            if~isTemporal
                selectededitName=this.CustomSpatialFuncNames{i};
            else
                selectededitName=this.CustomTemporalFuncNames{i};
            end
            evt=lidar.internal.lidarViewer.events.EditRequestEventData(...
            selectededitName,isTemporal);

            notify(this,'RequestToEditDataWithCustomFunction',evt);
        end


        function refreshCustomEditList(this)
            evt=lidar.internal.lidarViewer.events.CustomEditOperationEvenData(1,false,true);
            notify(this,'RequestToUpdateEdits',evt);
        end


        function importEdit(this,isTemporal,isClassBased)
            evt=lidar.internal.lidarViewer.events.CustomEditOperationEvenData(2,isTemporal,isClassBased);
            notify(this,'RequestToUpdateEdits',evt);
        end


        function createCustomEdits(this,isTemporal,isClassBased)
            evt=lidar.internal.lidarViewer.events.CustomEditOperationEvenData(3,isTemporal,isClassBased);
            notify(this,'RequestToUpdateEdits',evt);
        end




        function exitEditMode(this,TF)

            evt=lidar.internal.lidarViewer.events.ExitEditModeEventData(TF);
            notify(this,'RequestToExitEditMode',evt);
            this.setEditTabOptions(false)
        end




        function changeColorMap(this,index)

            colorMapList=this.getColormapList(index);
            this.ColorSection.ColormapDropDown.Text=...
            colorMapList{index};
            evt=lidar.internal.lidarViewer.events.ColorChangeEventData(...
            index,0);
            notify(this,'ColorChangeRequest',evt);



            TF=index==6;
            if TF&&strcmp(this.ColorSection.ColormapDropDown.Text,getString(message('lidar:lidarViewer:Color')))
                this.ColorSection.ColormapValDropDown.Enabled=~TF;
                this.ColorSection.ColorVariationDropDown.Enabled=~TF;
            else
                this.ColorSection.ColormapValDropDown.Enabled=true;
                this.ColorSection.ColorVariationDropDown.Enabled=true;
            end
        end


        function changeColorVariation(this,index)

            this.ColorVariationPrev=this.ColorSection.ColorVariationDropDown.Text;
            colorVariationList=this.getColorVariationList();
            this.ColorSection.ColorVariationDropDown.Text=...
            colorVariationList{index};
            if index==2

                this.ColorSection.ColormapDropDown.Enabled=false;
                this.ColorSection.ColormapValDropDown.Enabled=false;
            else
                this.CustomColormapSettings.resetSettings();


                this.ColorSection.ColormapDropDown.Enabled=true;
                this.ColorSection.ColormapValDropDown.Enabled=true;
            end
            evt=lidar.internal.lidarViewer.events.ColorChangeEventData(...
            0,0,index);
            notify(this,'ColorChangeRequest',evt);
        end


        function requestToChangeBackgroundColor(this)

            backgroundColor=uisetcolor(this.BackGroundColor,...
            getString(message('lidar:lidarViewer:SelectBackgroundColor')));


            lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,'bringToFront');

            this.ColorSection.BackgroundColorButton.Icon=...
            constructColorIconFromRGB(backgroundColor);

            this.BackGroundColor=backgroundColor;

            evt=lidar.internal.lidarViewer.events.BackgroundColorChangeEventData(backgroundColor);
            notify(this,'BackgroundColorChangeRequest',evt);
        end


        function changeColormapValue(this,index,src)



            this.ColorSection.ColormapValDropDown.Text=...
            src.Text;

            evt=lidar.internal.lidarViewer.events.ColorChangeEventData(...
            0,index);
            notify(this,'ColorChangeRequest',evt);
        end


        function popUp=getColormapValPopUp(this)

            if isempty(this.ColorSection.ColormapValDropDown.Popup)
                this.setColormapValPopUp();
            end
            popUp=this.ColorSection.ColormapValDropDown.Popup;
        end



        function setColormapValPopUp(this)


            standardColorOption={getString(message('lidar:lidarViewer:ColormapValueZ'));
            getString(message('lidar:lidarViewer:ColormapValueRadial'));
            getString(message('lidar:lidarViewer:ColormapValueIntensity'))};

            tag={'zHeightItem','radialItem','intensityItem'};
            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();


            for i=1:numel(standardColorOption)
                dropDownEntry=this.createListItemHelper(...
                standardColorOption{i},@(src,~)this.changeColormapValue(i,src),tag{i});
                popup.add(dropDownEntry);
            end

            this.ColorSection.ColormapValDropDown.Popup=popup;
        end


        function setBackGroundColor(this)
            this.ColorSection.BackgroundColorButton.Icon=constructColorIconFromRGBTriplet(this.BackGroundColor,[16,16]);
        end


        function popUp=getColormapPopUp(this)

            if isempty(this.ColorSection.ColormapDropDown.Popup)
                this.setColormapPopUp();
            end
            popUp=this.ColorSection.ColormapDropDown.Popup;
        end


        function popUp=getColorVariationPopUp(this)

            if isempty(this.ColorSection.ColorVariationDropDown.Popup)
                this.setColorVariationPopUp();
            end
            popUp=this.ColorSection.ColorVariationDropDown.Popup;
        end


        function setColorVariationPopUp(this)
            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();

            colorVariationList=this.getColorVariationList();
            tag={'linearItem','customItem'};

            for i=1:numel(colorVariationList)
                dropDownEntry=this.createListItemHelper(...
                colorVariationList{i},@(~,~)this.changeColorVariation(i),tag{i});
                popup.add(dropDownEntry);
            end
            this.ColorSection.ColorVariationDropDown.Popup=popup;
        end


        function changePointSizeValue(this)



            pointSizeVal=round(this.ColorSection.PointSizeSpinner.Value);
            this.ColorSection.PointSizeSpinner.Value=pointSizeVal;
            this.ColorSection.PointSizeSpinner.Description=...
            getString(message('lidar:lidarViewer:PointSizeVal',...
            num2str(pointSizeVal)));
            evt=lidar.internal.lidarViewer.events.PointSizeChangeEventData(pointSizeVal);
            notify(this,'PointSizeChangeRequest',evt);
        end


        function doPlanarViewView(this,viewVal)

            evt=lidar.internal.lidarViewer.events.StandardViewChangedEventData(viewVal);
            notify(this,'PlanarViewChangeRequest',evt);
        end


        function doDefaultView(this)
            notify(this,'DefaultViewChangeRequest');
        end
    end




    methods(Static,Access=private)
        function dropDownEntry=createListItemHelper(text,funcHandle,tag,icon)

            if nargin>3
                dropDownEntry=matlab.ui.internal.toolstrip.ListItem(text,icon);
            else
                dropDownEntry=matlab.ui.internal.toolstrip.ListItem(text);
            end
            dropDownEntry.Tag=tag;
            dropDownEntry.ItemPushedFcn=funcHandle;
        end

        function dropDownEntry=createListItemWithPopupHelper(text,tag,icon)
            if nargin>2
                dropDownEntry=matlab.ui.internal.toolstrip.ListItemWithPopup(text,icon);
            else
                dropDownEntry=matlab.ui.internal.toolstrip.ListItemWithPopup(text);
            end
            dropDownEntry.Tag=tag;
        end


        function colorMapList=getColormapList(varargin)


            colorMapList={getString(message('lidar:lidarViewer:ColormapRedWhiteBlue'));...
            getString(message('lidar:lidarViewer:ColormapParula'));...
            getString(message('lidar:lidarViewer:ColormapJet'));...
            getString(message('lidar:lidarViewer:ColormapSpring'));...
            getString(message('lidar:lidarViewer:ColormapHot'))};
            if nargin==1&&varargin{1}==6
                colorMapList{end+1}=getString(message('lidar:lidarViewer:Color'));
            end
        end


        function colorMapList=getColorVariationList()

            colorMapList={getString(message('lidar:lidarViewer:Linear'));...
            getString(message('lidar:lidarViewer:Custom'))};
        end
    end

    methods
        function customVariationRequest(this,evt)
            if evt.DialogState==3

                this.ColorSection.ColormapDropDown.Enabled=true;
                this.ColorSection.ColormapValDropDown.Enabled=true;

                this.ColorSection.ColorVariationDropDown.Text=this.ColorVariationPrev;
                if strcmp(this.ColorVariationPrev,getString(message('lidar:lidarViewer:Linear')))
                    this.CustomColormapSettings.resetSettings();
                    evt=lidar.internal.lidarViewer.events.ColorChangeEventData(...
                    0,0,1);
                    notify(this,'ColorChangeRequest',evt);
                    return;
                end

                lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,...
                'bringToFront')
            elseif evt.DialogState==2
                this.ColorSection.ColormapDropDown.Enabled=true;
                this.ColorSection.ColormapValDropDown.Enabled=true;

                lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,...
                'bringToFront')
            end
            notify(this,'CustomColormapRequest',evt)
        end

        function[colormapText,colormapValText]=getColormapAndColormapValText(this)
            colormapText=this.ColorSection.ColormapDropDown.Text;
            colormapValText=this.ColorSection.ColormapValDropDown.Text;
        end
    end



    methods
        function stateInfo=getState(this)



            stateInfo=struct();

            stateInfo.ColormapValText=this.ColorSection.ColormapValDropDown.Text;
            stateInfo.ColormapValDropDownEnabled=this.ColorSection.ColormapValDropDown.Enabled;
            stateInfo.CustomColorVariationDropDownEnabled=this.ColorSection.ColorVariationDropDown.Enabled;
            stateInfo.ColormapText=this.ColorSection.ColormapDropDown.Text;
            stateInfo.ColorVariationText=this.ColorSection.ColorVariationDropDown.Text;
            stateInfo.CustomColormapSettings.ColorMapFunction=this.CustomColormapSettings.ColorMapFunction;
            stateInfo.PointSizeVal=this.ColorSection.PointSizeSpinner.Value;
            stateInfo.BackgroundColor=this.ColorSection.BackgroundColorButton.Icon;


        end


        function setState(this,state)



            this.ColorSection.ColormapDropDown.Text=state.ColormapText;
            this.ColorSection.ColorVariationDropDown.Text=state.ColorVariationText;
            this.CustomColormapSettings.ColorMapFunction=state.CustomColormapSettings.ColorMapFunction;

            this.ColorSection.ColormapValDropDown.Enabled=state.ColormapValDropDownEnabled;
            this.ColorSection.ColorVariationDropDown.Enabled=state.CustomColorVariationDropDownEnabled;
            this.ColorSection.PointSizeSpinner.Value=state.PointSizeVal;
            this.ColorSection.PointSizeSpinner.Description=getString(message('lidar:lidarViewer:PointSizeVal',...
            num2str(state.PointSizeVal)));
            this.ColorSection.BackgroundColorButton.Icon=state.BackgroundColor;


        end


        function setCustomEditsPopup(this)


            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();


            label=matlab.ui.internal.toolstrip.PopupListHeader(...
            getString(message('lidar:lidarViewer:SpatialAlgorithms')));
            popup.add(label);



            icon=NEW_16;
            dropDownEntry=this.createListItemWithPopupHelper(...
            getString(message('lidar:lidarViewer:New')),'newSpatialListItem',icon);
            newPopup=PopupList();

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','classTemplate_16.png');
            popupEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:ClassTemplate'))...
            ,@(~,~)this.createCustomEdits(false,true),'spatialClassTemplate',icon);
            newPopup.add(popupEntry);

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','functionTemplate_16.png');
            popupEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:FunctionTemplate'))...
            ,@(~,~)this.createCustomEdits(false,false),'spatialFunctionTemplate',icon);
            newPopup.add(popupEntry);

            dropDownEntry.Popup=newPopup;
            popup.add(dropDownEntry);



            icon=IMPORT_16;
            dropDownEntry=this.createListItemWithPopupHelper(...
            getString(message('lidar:lidarViewer:ImportFromFile')),...
            'fromFileSpatialListItem',icon);
            newPopup=PopupList();

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','classTemplate_16.png');
            popupEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:ImportClass'))...
            ,@(~,~)this.importEdit(false,true),'itemImportSpatialClass',icon);
            newPopup.add(popupEntry);

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','functionTemplate_16.png');
            popupEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:ImportFunction'))...
            ,@(~,~)this.importEdit(false,false),'itemImportSpatialFunction',icon);
            newPopup.add(popupEntry);

            dropDownEntry.Popup=newPopup;
            popup.add(dropDownEntry);



            label=matlab.ui.internal.toolstrip.PopupListHeader(...
            getString(message('lidar:lidarViewer:TemporalAlgorithms')));
            popup.add(label);

            import matlab.ui.internal.toolstrip.Icon.*;


            icon=NEW_16;
            dropDownEntry=this.createListItemWithPopupHelper(...
            getString(message('lidar:lidarViewer:New')),'newTemporalListItem',...
            icon);
            newPopup=PopupList();

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','classTemplate_16.png');
            popupEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:ClassTemplate'))...
            ,@(~,~)this.createCustomEdits(true,true),'temporalClassTemplate',icon);
            newPopup.add(popupEntry);

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','functionTemplate_16.png');
            popupEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:FunctionTemplate'))...
            ,@(~,~)this.createCustomEdits(true,false),'temporalFunctionTemplate',icon);
            newPopup.add(popupEntry);

            dropDownEntry.Popup=newPopup;
            popup.add(dropDownEntry);



            icon=IMPORT_16;
            dropDownEntry=this.createListItemWithPopupHelper(...
            getString(message('lidar:lidarViewer:ImportFromFile')),'fromFileTemporalListItem',icon);
            newPopup=PopupList();

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','classTemplate_16.png');
            popupEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:ImportClass'))...
            ,@(~,~)this.importEdit(true,true),'itemImportTemporalClass',icon);
            newPopup.add(popupEntry);

            icon=fullfile(matlabroot,'toolbox','lidar','lidar','+lidar',...
            '+internal','+lidarViewer','+view','+icons','functionTemplate_16.png');
            popupEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:ImportFunction'))...
            ,@(~,~)this.importEdit(true,false),'itemImportTemporalFunction',icon);
            newPopup.add(popupEntry);

            dropDownEntry.Popup=newPopup;
            popup.add(dropDownEntry);



            label=matlab.ui.internal.toolstrip.PopupListHeader(...
            'Refresh');
            popup.add(label);
            dropDownEntry=this.createListItemHelper(...
            getString(message('lidar:lidarViewer:RefreshList')),...
            @(~,~)this.refreshCustomEditList(),'itemRefreshList');
            popup.add(dropDownEntry);

            this.AlgorithmSection.CustomEditDropDown.Popup=popup;
        end


        function set.BackGroundColor(this,newColor)
            this.BackGroundColor=newColor;
            evt=lidar.internal.lidarViewer.events.BackgroundColorChangeEventData(newColor);
            notify(this,'BackgroundColorChangeRequest',evt);
        end
    end
end

function icon=constructColorIconFromRGB(rgbColor)

    iconImage=zeros(24,24,3);
    iconImage(:,:,1)=rgbColor(1);
    iconImage(:,:,2)=rgbColor(2);
    iconImage(:,:,3)=rgbColor(3);
    icon=matlab.ui.internal.toolstrip.Icon(im2uint8(iconImage));

end

function icon=constructColorIconFromRGBTriplet(rgbColor,iconSize)

    img=zeros([iconSize,3]);
    img(:,:,1)=rgbColor(1);
    img(:,:,2)=rgbColor(2);
    img(:,:,3)=rgbColor(3);

    icon=matlab.ui.internal.toolstrip.Icon(im2uint8(img));
end



function name=getAlgorithmName(metaClass)
    try
        name=eval([metaClass.Name,'.EditName']);
        TF=ischar(name)||isstring(name);
    catch
        TF=false;
    end

    if~TF
        name='Custom Edit Algorithm';
    end
end


function desc=getAlgorithmDescription(metaClass)
    try
        desc=eval([metaClass.Name,'.Description']);
        TF=ischar(desc)||isstring(desc);
    catch
        TF=false;
    end

    if~TF
        desc='Set the Description property of the custom edit algorithm to provide details of the algorithm';
    end
end


function icon=getAlgorithmIcon(metaClass)
    try
        icon=eval([metaClass.Name,'.Icon']);

        if isnumeric(icon)

            icon=matlab.ui.internal.toolstrip.Icon(im2uint8(icon));
        elseif~isa(icon,'matlab.ui.internal.toolstrip.Icon')


            icon=matlab.ui.internal.toolstrip.Icon(icon);
        end
        TF=true;
    catch

        TF=false;
    end

    if~TF
        icon=matlab.ui.internal.toolstrip.Icon.MATLAB_24;
    end
end


