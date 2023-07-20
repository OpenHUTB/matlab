








classdef HomeTab<handle

    properties(SetAccess=private,Hidden,Transient)

Tab

    end

    properties(Access=private)
        FileSection lidar.internal.lidarViewer.view.section.FileSection

        ColorSection lidar.internal.lidarViewer.view.section.ColorSection

        VisualizeSection lidar.internal.lidarViewer.view.section.VisualizeSection

        EditSection lidar.internal.lidarViewer.view.section.EditSection

        LayoutSection lidar.internal.lidarViewer.view.section.LayoutSection

        ExportSection lidar.internal.lidarViewer.view.section.ExportSection

        MeasurementButtonSection lidar.internal.lidarViewer.view.section.MeasurementButtonSection

    end

    properties(Access=protected)

        WasEgoLastUsed=true;
    end

    properties
BackGroundColor

        GroundSettings lidar.internal.lidarViewer.view.GroundSettings

        ClusterSettings lidar.internal.lidarViewer.view.ClusterSettings

        ClusterVisualizationState=false;

        ViewGroundData=false;

        CustomColormapSettings lidar.internal.lidarViewer.view.CustomColormapSettings

    end

    properties(Access=private)
ColorVariationPrev

ColorPresent
    end

    properties(Dependent)
EgoDirection
    end

    methods




        function this=HomeTab()

            this.Tab=matlab.ui.internal.toolstrip.Tab(...
            getString(message('lidar:lidarViewer:HomeTab')));
            this.Tab.Tag='homeTab';
            createTab(this);

        end


        function enable(this)
            isHideGroundEnabled=this.VisualizeSection.HideGround.Value;
            isClusterDataEnabled=this.VisualizeSection.ClusterData.Value;
            this.Tab.enableAll();
            if this.ViewGroundData||isClusterDataEnabled
                this.ColorSection.ColormapDropDown.Enabled=false;
                this.ColorSection.ColormapValDropDown.Enabled=false;
                this.ColorSection.ColorVariationDropDown.Enabled=false;
            end

            if isHideGroundEnabled
                this.VisualizeSection.HideGround.Value=true;
                this.VisualizeSection.HideGroundSettings.Enabled=...
                this.VisualizeSection.HideGround.Value;
            else
                this.VisualizeSection.HideGroundSettings.Enabled=...
                this.VisualizeSection.HideGround.Value;
            end
            if isClusterDataEnabled
                this.VisualizeSection.ClusterData.Value=true;
                this.VisualizeSection.ClusterSettingsButton.Enabled=...
                this.VisualizeSection.ClusterData.Value;
            else
                this.VisualizeSection.ClusterSettingsButton.Enabled=...
                this.VisualizeSection.ClusterData.Value;
            end
            this.VisualizeSection.EgoDirection.Enabled=false;
            this.EgoDirection=false;
            if strcmp(this.ColorSection.ColormapDropDown.Text,getString(message('lidar:lidarViewer:Color')))


                this.ColorSection.ColormapValDropDown.Enabled=false;
                this.ColorSection.ColorVariationDropDown.Enabled=false;
            end
        end


        function disable(this)
            isHideGroundEnabled=this.VisualizeSection.HideGround.Value;
            isClusterEnabled=this.VisualizeSection.ClusterData.Value;
            this.Tab.disableAll();
            if this.ViewGroundData||isClusterEnabled
                this.ColorSection.ColormapDropDown.Enabled=false;
                this.ColorSection.ColormapValDropDown.Enabled=false;
                this.ColorSection.ColorVariationDropDown.Enabled=false;
            end

            if isHideGroundEnabled
                this.VisualizeSection.HideGround.Value=isHideGroundEnabled;
            end
            if isClusterEnabled
                this.VisualizeSection.ClusterData.Value=isClusterEnabled;
            end
        end


        function resetHideGround(this)
            this.VisualizeSection.HideGround.Value=false;
            this.VisualizeSection.HideGroundSettings.Enabled=false;
        end


        function disableGroundAndClusterSettings(this)
            this.VisualizeSection.ClusterData.Value=false;
            this.VisualizeSection.ClusterSettingsButton.Enabled=...
            this.VisualizeSection.ClusterData.Value;
            this.VisualizeSection.HideGround.Value=false;
            this.VisualizeSection.HideGroundSettings.Enabled=...
            this.VisualizeSection.HideGround.Value;
        end
    end




    methods

        function setNewSessionState(this,TF)

            this.FileSection.NewSessionButton.Enabled=TF;
        end


        function setVisualizeSection(this,TF)

            this.ColorSection.ColormapDropDown.Enabled=TF;
            this.ColorSection.ColormapValDropDown.Enabled=TF;
            this.ColorSection.ColorVariationDropDown.Enabled=TF;
            if TF&&strcmp(this.ColorSection.ColormapDropDown.Text,getString(message('lidar:lidarViewer:Color')))
                this.ColorSection.ColormapValDropDown.Enabled=~TF;
                this.ColorSection.ColorVariationDropDown.Enabled=~TF;
            else
                this.ColorSection.ColormapValDropDown.Enabled=TF;
                this.ColorSection.ColorVariationDropDown.Enabled=TF;
            end
            this.ColorSection.BackgroundColorButton.Enabled=TF;
            this.ColorSection.PointSizeSpinner.Enabled=TF;
            this.VisualizeSection.XYSliceView.Enabled=TF;
            this.VisualizeSection.YZSliceView.Enabled=TF;
            this.VisualizeSection.XZSliceView.Enabled=TF;
            this.VisualizeSection.CustomCameraViewButton.Enabled=TF;
            this.VisualizeSection.BirdsEyeView.Enabled=TF;
            this.VisualizeSection.ChaseView.Enabled=TF;
            this.VisualizeSection.EgoView.Enabled=TF;
            this.VisualizeSection.EgoDirection.Enabled=false;
            this.VisualizeSection.RestoreView.Enabled=TF;
            this.VisualizeSection.HideGround.Enabled=TF;
            this.VisualizeSection.HideGroundSettings.Enabled=...
            this.VisualizeSection.HideGround.Value;
            this.VisualizeSection.ClusterData.Enabled=TF;
            this.VisualizeSection.ClusterSettingsButton.Enabled=...
            this.VisualizeSection.ClusterData.Value;

            this.MeasurementButtonSection.MeasurementButton.Enabled=TF;
            this.EgoDirection(false);
        end


        function setViews(this,TF)
            this.VisualizeSection.BirdsEyeView.Enabled=TF;
            this.VisualizeSection.ChaseView.Enabled=TF;
            this.VisualizeSection.EgoView.Enabled=TF;
        end


        function setExportSection(this,TF)

            this.ExportSection.ExportButton.Enabled=TF;
        end


        function setEditSection(this,TF)

            this.EditSection.EditButton.Enabled=TF;
        end


        function setMeasurementSection(this,TF)


            this.MeasurementButtonSection.MeasurementButton.Enabled=TF;
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
            this.ColorPresent=false;
        end


        function setColormapValPopUp(this,colorOptions)


            standardColorOption={getString(message('lidar:lidarViewer:ColormapValueZ'));
            getString(message('lidar:lidarViewer:ColormapValueRadial'));
            getString(message('lidar:lidarViewer:ColormapValueIntensity'))};

            tag={'zHeightItem','radialItem','intensityItem',...
            'ClassificationItem','LaserReturnItem','ScanAngleItem',...
            'GPSTimeStampItem','NearIRItem'};
            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();


            for i=1:numel(standardColorOption)
                dropDownEntry=this.createListItemHelper(...
                standardColorOption{i},@(src,~)this.changeColormapValue(i,src),tag{i});
                popup.add(dropDownEntry);
            end



            if nargin==2&&~isempty(colorOptions)
                for i=1:numel(colorOptions)
                    dropDownEntry=this.createListItemHelper(...
                    colorOptions{i},@(src,~)this.changeColormapValue(...
                    i+numel(standardColorOption),src),strcat(colorOptions{i},'Item'));
                    popup.add(dropDownEntry);
                end
            end
            this.ColorSection.ColormapValDropDown.Popup=popup;
        end


        function setCachedCmapValPopup(this,popup)

            this.ColorSection.ColormapValDropDown.Popup=popup;
        end


        function setBackGroundColor(this)
            this.ColorSection.BackgroundColorButton.Icon=constructColorIconFromRGBTriplet(this.BackGroundColor,[16,16]);
        end


        function setCustomCameraPopUp(this,savedViews)

            controlOptions={getString(message('lidar:lidarViewer:SaveCameraView'));
            getString(message('lidar:lidarViewer:OrgCameraView'))};

            tag={'saveCameraViewItem','orgCameraViewItem'};
            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();
            ICON=matlab.ui.internal.toolstrip.Icon.SETTINGS_16;
            for i=1:numel(controlOptions)
                dropDownEntry=this.createListItemHelper(...
                controlOptions{i},@(~,~)this.requestCustomCameraOperation(i),...
                tag{i},ICON);
                popup.add(dropDownEntry);
            end
            popup.getChildByIndex(2).Enabled=false;

            if(nargin>1)

                if~isempty(savedViews)

                    label=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('lidar:lidarViewer:SavedCameraViews')));
                    popup.add(label);
                    popup.getChildByIndex(2).Enabled=true;
                end
                for i=1:numel(savedViews)
                    icon=fullfile(toolboxdir('lidar'),'lidar','+lidar',...
                    '+internal','+labeler','+tool','+icons','customCameraViewIcon_16.png');
                    dropDownEntry=this.createListItemHelper(...
                    savedViews{i},@(~,~)this.requestCustomCameraOperation(...
                    i+numel(controlOptions)),strcat(savedViews{i},'Item'),icon);
                    popup.add(dropDownEntry);
                end
            end
            this.VisualizeSection.CustomCameraViewButton.Popup=popup;
        end


        function setDefaultVisualizationSection(this)


            this.ColorSection.PointSizeSpinner.Limits=[1,100];
            this.ColorSection.PointSizeSpinner.Value=1;
            this.ColorSection.ColormapValDropDown.Text=...
            getString(message('lidar:lidarViewer:ColormapValueZ'));
            this.ColorSection.ColormapDropDown.Text=...
            getString(message('lidar:lidarViewer:ColormapRedWhiteBlue'));
            this.ColorSection.ColorVariationDropDown.Text=...
            getString(message('lidar:lidarViewer:Linear'));
            this.setCustomCameraPopUp();
            this.CustomColormapSettings.ColorMapFunction=getString(message('lidar:lidarViewer:Linear'));
        end


        function setColormapValText(this,text)

            this.ColorSection.ColormapValDropDown.Text=text;
        end


        function setColormapText(this,text)




            this.ColorSection.ColormapDropDown.Text=text;
            if~this.VisualizeSection.ClusterData.Value&&~this.VisualizeSection.HideGround.Value
                this.ColorSection.ColormapValDropDown.Enabled=true;
                this.ColorSection.ColorVariationDropDown.Enabled=true;
            end
        end


        function setImportButtonPopUp(this)
            importButtonOptions={getString(message('lidar:lidarViewer:ImportFromFile'));...
            getString(message('lidar:lidarViewer:FromWorkspace'))};

            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;
            popup=PopupList();


            importFromFile=ListItemWithPopup(importButtonOptions{1});
            importFromFile.Tag='importFromFileItem';
            importFromFile.Icon=ADD_16;
            popup.add(importFromFile);

            icon=fullfile(toolboxdir('vision'),'vision','+vision',...
            '+internal','+labeler','+tool','+icons','LoadImageSequence.png');


            dropDownEntry=this.createListItemHelper(...
            importButtonOptions{2},@(~,~)this.importSignalFromWS(),...
            'importFromWorkspaceItem',icon);
            popup.add(dropDownEntry);

            this.FileSection.ImportButton.Popup=popup;




            sourceFile={getString(message('lidar:lidarViewer:PCDSequence')),...
            getString(message('lidar:lidarViewer:PCAP')),...
            getString(message('lidar:lidarViewer:LASFile')),...
            getString(message('lidar:lidarViewer:Rosbag')),...
            getString(message('lidar:lidarViewer:CustomFile'))};
            tag={'pcdSequenceItem','pcapItem','lasFileItem','rosbagItem','customReader'};

            popup=PopupList();
            for i=1:numel(sourceFile)
                dropDownEntry=this.createListItemHelper(...
                sourceFile{i},@(~,~)this.importSignals(sourceFile{i}),tag{i});
                popup.add(dropDownEntry);
            end
            importFromFile.Popup=popup;
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
            this.ColorPresent=true;
        end
    end




    methods(Access=private)
        function createTab(this)



            tab=this.Tab;

            this.FileSection=lidar.internal.lidarViewer.view.section.FileSection(tab);
            this.ColorSection=lidar.internal.lidarViewer.view.section.ColorSection(tab,true);
            this.VisualizeSection=lidar.internal.lidarViewer.view.section.VisualizeSection(tab,true);
            this.MeasurementButtonSection=lidar.internal.lidarViewer.view.section.MeasurementButtonSection(tab);
            this.EditSection=lidar.internal.lidarViewer.view.section.EditSection(tab);
            this.LayoutSection=lidar.internal.lidarViewer.view.section.LayoutSection(tab);
            this.ExportSection=lidar.internal.lidarViewer.view.section.ExportSection(tab);
            this.GroundSettings=lidar.internal.lidarViewer.view.GroundSettings();
            this.ClusterSettings=lidar.internal.lidarViewer.view.ClusterSettings();
            this.CustomColormapSettings=lidar.internal.lidarViewer.view.CustomColormapSettings();


            this.intallListeners();


            this.setNewSessionState(false);


            this.setVisualizeSection(false);


            this.setEditSection(false);





            this.setExportSection(false);


            this.BackGroundColor=[0,0,40/255];

        end
    end




    methods(Access=private)

        function intallListeners(this)


            this.installFileSectionListeners();

            this.installColorSectionListeners();

            this.installVisualizeSectionListeners();

            this.installEditSectionListeners();

            this.installMeasurementSectionListeners();

            this.installLayoutSectionListeners();

            this.installExportSectionListeners();

        end


        function installFileSectionListeners(this)

            this.FileSection.NewSessionButton.ButtonPushedFcn=...
            @(~,~)newSession(this);

            this.FileSection.ImportButton.DynamicPopupFcn=...
            @(~,~)getImportButtonPopup(this);

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

            addlistener(this.CustomColormapSettings,...
            'CustomColormapRequest',@(~,evt)customVariationRequest(this,evt));

        end


        function installVisualizeSectionListeners(this)
            this.VisualizeSection.XYSliceView.ButtonPushedFcn=...
            @(~,evt)doPlanarViewView(this,1);

            this.VisualizeSection.YZSliceView.ButtonPushedFcn=...
            @(~,evt)doPlanarViewView(this,2);

            this.VisualizeSection.XZSliceView.ButtonPushedFcn=...
            @(~,evt)doPlanarViewView(this,3);

            this.VisualizeSection.CustomCameraViewButton.DynamicPopupFcn=...
            @(~,~)getCustomCameraPopup(this);

            this.VisualizeSection.BirdsEyeView.ButtonPushedFcn=...
            @(~,~)doBirdsEyeView(this);

            this.VisualizeSection.ChaseView.ButtonPushedFcn=...
            @(~,~)doChaseView(this);

            this.VisualizeSection.EgoView.ButtonPushedFcn=...
            @(~,~)doEgoView(this);

            this.VisualizeSection.EgoDirection.ValueChangedFcn=...
            @(~,~)doEgoDirection(this);

            this.VisualizeSection.RestoreView.ButtonPushedFcn=...
            @(~,~)doDefaultView(this);

            this.VisualizeSection.HideGround.ValueChangedFcn=...
            @(~,~)doHideGround(this);

            this.VisualizeSection.HideGroundSettings.ButtonPushedFcn=...
            @(~,~)doHideGroundSettings(this);

            addlistener(this.GroundSettings,...
            'GroundSettingsChanged',@this.doHideGroundChanged);

            addlistener(this.GroundSettings,...
            'ViewGroundDataRequest',@(~,~)viewGroundDataRequest(this));

            addlistener(this.GroundSettings,...
            'StopViewGroundDataRequest',@(~,~)stopViewGroundDataRequest(this));

            this.VisualizeSection.ClusterData.ValueChangedFcn=...
            @(~,~)doClusterData(this);

            this.VisualizeSection.ClusterSettingsButton.ButtonPushedFcn=...
            @(~,~)doClusterSettings(this);

            addlistener(this.ClusterSettings,...
            'ClusterSettingsChanged',@this.doClusterChanged);

            addlistener(this.ClusterSettings,...
            'StartColoringByClusters',@(~,~)startColoringByClusters(this));

            addlistener(this.ClusterSettings,...
            'StopColoringByClusters',@(~,~)stopColoringByClusters(this));

            addlistener(this.ClusterSettings,...
            'ClusterSettingsCloseRequest',@(~,~)clusterSettingsCloseRequest(this));

            addlistener(this.GroundSettings,...
            'GroundSettingsCloseRequest',@(~,~)groundSettingsCloseRequest(this));
        end


        function installEditSectionListeners(this)


            this.EditSection.EditButton.ButtonPushedFcn=...
            @(~,~)editModeRequest(this);
        end


        function installMeasurementSectionListeners(this)


            this.MeasurementButtonSection.MeasurementButton.ButtonPushedFcn=...
            @(~,~)measurementModeRequest(this);
        end


        function installLayoutSectionListeners(this)


            this.LayoutSection.DefaultLayoutButton.ButtonPushedFcn=...
            @(~,~)defaultLayout(this);
        end


        function installExportSectionListeners(this)


            this.ExportSection.ExportButton.ButtonPushedFcn=...
            @(~,~)this.exportSignals();
        end

    end




    events
RequestForNewSession
RequestToImportSignals
ColorChangeRequest
BackgroundColorChangeRequest
PointSizeChangeRequest
EditModeRequest
MeasurementModeRequest
RequestForDefaultLayout
PlanarViewChangeRequest
RequestForCustomCameraOperation
RequestToExportSignals
CameraViewChangeRequest
DefaultViewChangeRequest
ExternalTrigger
HideGroundChanged
ClusterSettingsChanged
ClusterDataChanged
StartColoringByClusters
StopColoringByClusters
ClusterSettingsRequest
ViewGroundDataRequest
StopViewGroundDataRequest
ClusteringStatusRequest
HideGroundDataRequest
CustomColormapRequest
ClusterSettingsCloseRequest
GroundSettingsCloseRequest

RequestForMeasurementTools
    end




    methods(Access=private)



        function newSession(this)

            notify(this','RequestForNewSession');
        end


        function importSignals(this,srcType)


            evt=lidar.internal.lidarViewer.events.ImportRequestEventData(srcType,1);
            notify(this,'RequestToImportSignals',evt);


            if evt.IsImportSuccess

                resetSettingsParameters(this);
                disableGroundAndClusterSettings(this);
            end
        end


        function importSignalFromWS(this)


            this.VisualizeSection.HideGround.Value=false;
            evt=lidar.internal.lidarViewer.events.ImportRequestEventData(...
            getString(message('lidar:lidarViewer:FromWorkspace')),1);
            notify(this,'RequestToImportSignals',evt);


            if evt.IsImportSuccess

                resetSettingsParameters(this);
                disableGroundAndClusterSettings(this);
            end
        end


        function popup=getImportButtonPopup(this)

            if isempty(this.FileSection.ImportButton.Popup)
                this.setImportButtonPopUp();
            end
            popup=this.FileSection.ImportButton.Popup;
        end


        function exportSignals(this)

            notify(this,'RequestToExportSignals');
        end




        function changeColorMap(this,index)

            colorMapList=this.getColormapList(index);
            this.ColorSection.ColormapDropDown.Text=...
            colorMapList{index};
            evt=lidar.internal.lidarViewer.events.ColorChangeEventData(...
            index,0);
            notify(this,'ColorChangeRequest',evt);



            TF=index==6;
            if strcmp(this.ColorSection.ColormapDropDown.Text,getString(message('lidar:lidarViewer:Color')))
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
                this.VisualizeSection.HideGround.Enabled=false;
                this.VisualizeSection.ClusterData.Enabled=false;
            else
                this.CustomColormapSettings.resetSettings();
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
            this.VisualizeSection.EgoDirection.Enabled=false;
            this.EgoDirection=false;
            evt=lidar.internal.lidarViewer.events.StandardViewChangedEventData(viewVal);
            notify(this,'PlanarViewChangeRequest',evt);
        end


        function doDefaultView(this)
            this.VisualizeSection.EgoDirection.Enabled=false;
            this.EgoDirection=false;
            notify(this,'DefaultViewChangeRequest');
        end


        function popUp=getCustomCameraPopup(this)
            this.VisualizeSection.EgoDirection.Enabled=false;
            this.EgoDirection=false;

            if isempty(this.VisualizeSection.CustomCameraViewButton.Popup)
                this.setCustomCameraPopUp();
            end
            popUp=this.VisualizeSection.CustomCameraViewButton.Popup;
        end


        function requestCustomCameraOperation(this,operation)

            switch operation
            case 1
                evt=lidar.internal.lidarViewer.events.CustomCameraOperationEventData(1);
            case 2
                evt=lidar.internal.lidarViewer.events.CustomCameraOperationEventData(2);
            otherwise
                evt=lidar.internal.lidarViewer.events.CustomCameraOperationEventData(3,operation-2);
            end
            notify(this,'RequestForCustomCameraOperation',evt);
        end


        function doBirdsEyeView(this)
            this.VisualizeSection.EgoDirection.Enabled=false;
            this.EgoDirection=false;

            evtData=lidar.internal.lidarViewer.events.LidarViewerCameraViewEventData('BirdsEyeView');
            notify(this,'CameraViewChangeRequest',evtData);
        end


        function doChaseView(this)
            this.VisualizeSection.EgoDirection.Enabled=true;
            this.EgoDirection=true;
            this.WasEgoLastUsed=false;

            egoDir=this.VisualizeSection.EgoDirection.SelectedIndex;

            evtData=lidar.internal.lidarViewer.events.LidarViewerCameraViewEventData('ChaseView',egoDir);
            notify(this,'CameraViewChangeRequest',evtData);
        end


        function doEgoView(this)
            this.VisualizeSection.EgoDirection.Enabled=true;
            this.EgoDirection=true;
            this.WasEgoLastUsed=true;

            egoDir=this.VisualizeSection.EgoDirection.SelectedIndex;

            evtData=lidar.internal.lidarViewer.events.LidarViewerCameraViewEventData('EgoView',egoDir);
            notify(this,'CameraViewChangeRequest',evtData);
        end


        function doEgoDirection(this)





            if this.WasEgoLastUsed
                doEgoView(this);
            else
                doChaseView(this);
            end
        end


        function doHideGround(this)

            this.VisualizeSection.EgoDirection.Enabled=false;
            this.EgoDirection=false;
            this.GroundSettings.HideGround=this.VisualizeSection.HideGround.Value;
            enableGroundSettings(this.VisualizeSection);
            if this.VisualizeSection.ClusterData.Value
                this.ColorSection.ColormapDropDown.Enabled=false;
                this.ColorSection.ColormapValDropDown.Enabled=false;
                this.ColorSection.ColorVariationDropDown.Enabled=false;
            elseif~this.VisualizeSection.HideGround.Value
                this.ColorSection.ColormapDropDown.Enabled=true;
                if~strcmp(this.ColorSection.ColormapDropDown.Text,getString(message('lidar:lidarViewer:Color')))
                    this.ColorSection.ColormapValDropDown.Enabled=true;
                    this.ColorSection.ColorVariationDropDown.Enabled=true;
                end
            end
        end


        function doHideGroundSettings(this)

            this.VisualizeSection.EgoDirection.Enabled=false;
            this.EgoDirection=false;
            notify(this,'HideGroundDataRequest');
        end


        function doHideGroundChanged(this,~,evt)
            notify(this,'HideGroundChanged',evt);
            if~evt.HideGround
                this.ViewGroundData=false;
            end

            if this.ViewGroundData
                this.ColorSection.ColormapDropDown.Enabled=false;
                this.ColorSection.ColormapValDropDown.Enabled=false;
                this.ColorSection.ColorVariationDropDown.Enabled=false;
            end
        end


        function doClusterData(this)

            this.ClusterSettings.ClusterData=this.VisualizeSection.ClusterData.Value;
            this.ColorSection.ColormapDropDown.Enabled=false;
            this.ColorSection.ColormapValDropDown.Enabled=false;
            this.ColorSection.ColorVariationDropDown.Enabled=false;
            notify(this,'ClusteringStatusRequest');
            enableClusterSettings(this.VisualizeSection);
            if this.VisualizeSection.ClusterData.Value
                notify(this,'StartColoringByClusters');
            else
                notify(this,'StopColoringByClusters');
                this.ColorSection.ColormapDropDown.Enabled=true;
                if~strcmp(this.ColorSection.ColormapDropDown.Text,getString(message('lidar:lidarViewer:Color')))
                    this.ColorSection.ColormapValDropDown.Enabled=true;
                    this.ColorSection.ColorVariationDropDown.Enabled=true;
                end

            end
        end


        function doClusterSettings(this)

            notify(this,'ClusterSettingsRequest');
        end


        function doClusterChanged(this,~,evt)
            notify(this,'ClusterDataChanged',evt);
        end


        function startColoringByClusters(this)
            notify(this,'StartColoringByClusters');
        end


        function stopColoringByClusters(this)
            notify(this,'StopColoringByClusters');
        end

        function customVariationRequest(this,evt)
            if evt.DialogState==3

                this.ColorSection.ColormapDropDown.Enabled=true;
                this.ColorSection.ColormapValDropDown.Enabled=true;
                this.VisualizeSection.HideGround.Enabled=true;
                this.VisualizeSection.ClusterData.Enabled=true;

                this.ColorSection.ColorVariationDropDown.Text=this.ColorVariationPrev;
                if strcmp(this.ColorVariationPrev,getString(message('lidar:lidarViewer:Linear')))
                    this.CustomColormapSettings.resetSettings();
                    evt=lidar.internal.lidarViewer.events.ColorChangeEventData(...
                    0,0,1);
                    notify(this,'ColorChangeRequest',evt);
                    lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,...
                    'bringToFront');
                    return;
                end

                lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,...
                'bringToFront')
            elseif evt.DialogState==2
                this.ColorSection.ColormapDropDown.Enabled=true;
                this.ColorSection.ColormapValDropDown.Enabled=true;
                this.VisualizeSection.HideGround.Enabled=true;
                this.VisualizeSection.ClusterData.Enabled=true;

                drawnow();
                lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,...
                'bringToFront')
            end
            notify(this,'CustomColormapRequest',evt)
        end


        function clusterSettingsCloseRequest(this)
            lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,...
            'bringToFront')
        end


        function groundSettingsCloseRequest(this)
            lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,...
            'bringToFront')
        end



        function viewGroundDataRequest(this)

            this.ViewGroundData=true;
            this.ColorSection.ColormapDropDown.Enabled=false;
            this.ColorSection.ColormapValDropDown.Enabled=false;
            this.ColorSection.ColorVariationDropDown.Enabled=false;
            notify(this,'ViewGroundDataRequest');
            if this.VisualizeSection.ClusterData.Value
                this.VisualizeSection.ClusterData.Value=false;
                this.VisualizeSection.ClusterSettingsButton.Enabled=...
                this.VisualizeSection.ClusterData.Value;
            end
        end


        function stopViewGroundDataRequest(this)
            this.ViewGroundData=false;
            notify(this,'StopViewGroundDataRequest');
            this.ColorSection.ColormapDropDown.Enabled=true;
            if~strcmp(this.ColorSection.ColormapDropDown.Text,getString(message('lidar:lidarViewer:Color')))
                this.ColorSection.ColormapValDropDown.Enabled=true;
                this.ColorSection.ColorVariationDropDown.Enabled=true;
            end
        end




        function editModeRequest(this)

            notify(this,'EditModeRequest');
        end




        function measurementModeRequest(this)

            notify(this,'MeasurementModeRequest');
        end




        function defaultLayout(this)

            notify(this,'RequestForDefaultLayout');
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
        function stateInfo=getState(this)


            stateInfo=struct();
            stateInfo.GroundSettings=struct();
            stateInfo.ClusterSettings=struct();


            stateInfo.ColormapPopup=this.ColorSection.ColormapDropDown.Popup;
            stateInfo.ColormapValPopup=this.ColorSection.ColormapValDropDown.Popup;
            stateInfo.ColormapValText=this.ColorSection.ColormapValDropDown.Text;
            stateInfo.ColormapValDropDownEnabled=this.ColorSection.ColormapValDropDown.Enabled;
            stateInfo.CustomColorVariationDropDownEnabled=this.ColorSection.ColorVariationDropDown.Enabled;
            stateInfo.ColormapText=this.ColorSection.ColormapDropDown.Text;
            stateInfo.ColorVariationText=this.ColorSection.ColorVariationDropDown.Text;
            stateInfo.CustomColormapSettings.ColorMapFunction=this.CustomColormapSettings.ColorMapFunction;
            stateInfo.PointSizeVal=this.ColorSection.PointSizeSpinner.Value;
            stateInfo.SaveCameraPopup=this.VisualizeSection.CustomCameraViewButton.Popup;
            stateInfo.BackgroundColor=this.ColorSection.BackgroundColorButton.Icon;
            stateInfo.HideGround=this.VisualizeSection.HideGround.Value;
            stateInfo.HideGroundSettings=this.VisualizeSection.HideGroundSettings.Enabled;
            stateInfo.ClusterData=this.VisualizeSection.ClusterData.Value;
            stateInfo.ViewGroundData=this.ViewGroundData;
            stateInfo.ClusterSettingsButton=this.VisualizeSection.ClusterSettingsButton.Enabled;
            stateInfo.GroundSettings.OrganizedPC=this.GroundSettings.OrganizedPC;
            stateInfo.GroundSettings.ElevationAngleDeltaInternal=this.GroundSettings.ElevationAngleDeltaInternal;
            stateInfo.GroundSettings.InitialElevationAngleInternal=this.GroundSettings.InitialElevationAngleInternal;
            stateInfo.GroundSettings.MaxDistanceInternal=this.GroundSettings.MaxDistanceInternal;
            stateInfo.GroundSettings.MaxAngularDistanceInternal=this.GroundSettings.MaxAngularDistanceInternal;
            stateInfo.GroundSettings.GridResolutionInternal=this.GroundSettings.GridResolutionInternal;
            stateInfo.GroundSettings.ElevationThresholdInternal=this.GroundSettings.ElevationThresholdInternal;
            stateInfo.GroundSettings.SlopeThresholdInternal=this.GroundSettings.SlopeThresholdInternal;
            stateInfo.GroundSettings.MaxWindowRadiusInternal=this.GroundSettings.MaxWindowRadiusInternal;
            stateInfo.GroundSettings.ModeInternal=this.GroundSettings.ModeInternal;
            stateInfo.ClusterSettings.DistanceThresholdInternal=this.ClusterSettings.DistanceThresholdInternal;
            stateInfo.ClusterSettings.AngleThresholdInternal=this.ClusterSettings.AngleThresholdInternal;
            stateInfo.ClusterSettings.MinDistanceInternal=this.ClusterSettings.MinDistanceInternal;
            stateInfo.ClusterSettings.NumClustersInternal=this.ClusterSettings.NumClustersInternal;
            stateInfo.ClusterSettings.ModeInternal=this.ClusterSettings.ModeInternal;
        end


        function setState(this,state,isFileIndependent)



            if isFileIndependent
                this.ColorSection.ColormapDropDown.Popup=state.ColormapPopup;
                this.ColorSection.ColormapValDropDown.Popup=state.ColormapValPopup;
                this.VisualizeSection.CustomCameraViewButton.Popup=state.SaveCameraPopup;
                this.ColorSection.ColormapValDropDown.Enabled=state.ColormapValDropDownEnabled;
                this.ColorSection.ColorVariationDropDown.Enabled=state.CustomColorVariationDropDownEnabled;
            end

            this.ColorSection.ColormapValDropDown.Text=state.ColormapValText;
            this.ColorSection.ColormapDropDown.Text=state.ColormapText;
            this.ColorSection.ColorVariationDropDown.Text=state.ColorVariationText;
            this.CustomColormapSettings.ColorMapFunction=state.CustomColormapSettings.ColorMapFunction;
            this.ColorSection.ColormapValDropDown.Enabled=state.ColormapValDropDownEnabled;
            this.ColorSection.ColorVariationDropDown.Enabled=state.CustomColorVariationDropDownEnabled;
            this.ColorSection.PointSizeSpinner.Value=state.PointSizeVal;
            this.ColorSection.PointSizeSpinner.Description=getString(message('lidar:lidarViewer:PointSizeVal',...
            num2str(state.PointSizeVal)));
            this.ColorSection.BackgroundColorButton.Icon=state.BackgroundColor;

            if isfield(state,'GroundSettings')
                this.GroundSettings.OrganizedPC=state.GroundSettings.OrganizedPC;
                this.GroundSettings.ElevationAngleDeltaInternal=state.GroundSettings.ElevationAngleDeltaInternal;
                this.GroundSettings.InitialElevationAngleInternal=state.GroundSettings.InitialElevationAngleInternal;
                this.GroundSettings.MaxDistanceInternal=state.GroundSettings.MaxDistanceInternal;
                this.GroundSettings.MaxAngularDistanceInternal=state.GroundSettings.MaxAngularDistanceInternal;
                this.GroundSettings.GridResolutionInternal=state.GroundSettings.GridResolutionInternal;
                this.GroundSettings.ElevationThresholdInternal=state.GroundSettings.ElevationThresholdInternal;
                this.GroundSettings.SlopeThresholdInternal=state.GroundSettings.SlopeThresholdInternal;
                this.GroundSettings.MaxWindowRadiusInternal=state.GroundSettings.MaxWindowRadiusInternal;
                this.GroundSettings.ModeInternal=state.GroundSettings.ModeInternal;
            end
            if isfield(state,'ClusterSettings')
                this.ClusterSettings.DistanceThresholdInternal=state.ClusterSettings.DistanceThresholdInternal;
                this.ClusterSettings.AngleThresholdInternal=state.ClusterSettings.AngleThresholdInternal;
                this.ClusterSettings.MinDistanceInternal=state.ClusterSettings.MinDistanceInternal;
                this.ClusterSettings.NumClustersInternal=state.ClusterSettings.NumClustersInternal;
                this.ClusterSettings.ModeInternal=state.ClusterSettings.ModeInternal;
            end
            if isfield(state,'HideGround')
                this.VisualizeSection.HideGround.Value=state.HideGround;
                this.VisualizeSection.HideGroundSettings.Enabled=state.HideGroundSettings;
                if state.ViewGroundData
                    this.ColorSection.ColormapDropDown.Enabled=false;
                    this.ColorSection.ColormapValDropDown.Enabled=false;
                    this.ColorSection.ColorVariationDropDown.Enabled=false;
                end
            end
            if isfield(state,'ClusterData')
                this.VisualizeSection.ClusterData.Value=state.ClusterData;
                this.VisualizeSection.ClusterSettingsButton.Enabled=state.ClusterSettingsButton;
                if state.ClusterData
                    this.ColorSection.ColormapDropDown.Enabled=false;
                    this.ColorSection.ColormapValDropDown.Enabled=false;
                    this.ColorSection.ColorVariationDropDown.Enabled=false;
                end
            end
        end


        function set.BackGroundColor(this,newColor)
            this.BackGroundColor=newColor;
            evt=lidar.internal.lidarViewer.events.BackgroundColorChangeEventData(newColor);
            notify(this,'BackgroundColorChangeRequest',evt);
        end


        function setColorAndColormapValue(this)
            this.ColorSection.ColormapDropDown.Enabled=true;
            if~strcmp(this.ColorSection.ColormapDropDown.Text,getString(message('lidar:lidarViewer:Color')))
                this.ColorSection.ColormapValDropDown.Enabled=true;
                this.ColorSection.ColorVariationDropDown.Enabled=true;
            end
        end


        function resetColorAndColormapValue(this)
            this.ColorSection.ColormapDropDown.Enabled=false;
            this.ColorSection.ColormapValDropDown.Enabled=false;
            this.ColorSection.ColorVariationDropDown.Enabled=false;
        end


        function resetSettingsParameters(this)
            this.GroundSettings.ElevationAngleDeltaInternal=5;
            this.GroundSettings.InitialElevationAngleInternal=30;
            this.GroundSettings.MaxDistanceInternal=0.5;
            this.GroundSettings.MaxAngularDistanceInternal=5;
            this.GroundSettings.GridResolutionInternal=1;
            this.GroundSettings.ElevationThresholdInternal=0.5;
            this.GroundSettings.SlopeThresholdInternal=0.15;
            this.GroundSettings.MaxWindowRadiusInternal=18;
            this.GroundSettings.ModeInternal='segmentGroundFromLidarData';
            this.ClusterSettings.DistanceThresholdInternal=0.5;
            this.ClusterSettings.AngleThresholdInternal=5;
            this.ClusterSettings.MinDistanceInternal=0.5;
            this.ClusterSettings.NumClustersInternal=0.1;
            this.ClusterSettings.ModeInternal='segmentLidarData';
        end


        function val=getViewColorData(this)
            val=this.VisualizeSection.ClusterData.Value;
        end


        function[colormapText,colormapValText]=getColormapAndColormapValText(this)
            colormapText=this.ColorSection.ColormapDropDown.Text;
            colormapValText=this.ColorSection.ColormapValDropDown.Text;
        end


        function TF=isColorPresent(this)
            TF=this.ColorPresent;
        end
    end

    methods
        function set.EgoDirection(this,TF)
            this.VisualizeSection.EgoDirection.Enabled=TF;
        end

        function TF=get.EgoDirection(this)
            TF=this.VisualizeSection.EgoDirection.Enabled;
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
