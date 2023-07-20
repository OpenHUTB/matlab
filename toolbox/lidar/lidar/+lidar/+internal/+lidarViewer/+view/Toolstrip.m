








classdef Toolstrip<handle

    properties

TabGroup


        Home lidar.internal.lidarViewer.view.HomeTab


        Edit lidar.internal.lidarViewer.view.EditTab


        Measurement lidar.internal.lidarViewer.view.MeasurementTab
    end

    properties(Dependent,SetAccess=private)
Tabs
    end

    properties(Access=private)



TSState



CachedCMapValPopup


EgoValue
    end

    methods



        function this=Toolstrip()

            this.TabGroup=matlab.ui.internal.toolstrip.TabGroup();
            this.TabGroup.Tag='lidarViewerTabs';

            wireUpHomeTab(this);
            wireUpEditTab(this);
        end


        function close(this)

            this.disableAll();
            this.Edit.close();
            this.Measurement.close();
        end


        function disableAll(this)

            disable(this.Home);
            disable(this.Edit);

        end


        function setToolstrip(this,TF,inEditMode)

            if inEditMode
                TS=this.Edit;
            else
                TS=this.Home;
            end

            if TF
                enable(TS);
            else
                disable(TS);
            end
        end
    end




    methods
        function tool=get.Tabs(this)
            tool=this.TabGroup;
        end


        function setEditTabOptions(this,isDataEdited)

            this.Edit.setEditTabOptions(isDataEdited);
        end


        function setToolTabOptions(this,isDataEdited)

            this.Measurement.setToolTabOptions(isDataEdited);
        end


        function updateColorOptions(this,colorOptions)



            setColormapValPopUp(this.Home,colorOptions)

            setColormapValText(this.Home,...
            getString(message('lidar:lidarViewer:ColormapValueZ')));
            this.Home.BackGroundColor=[0,0,40/255];
            setBackGroundColor(this.Home);
        end


        function updateCustomCameraPopup(this,savedViews)

            this.Home.setCustomCameraPopUp(savedViews);
        end


        function resetTSAfterEditMode(this)








            this.Home.setDefaultVisualizationSection();


            this.Home.setColormapValPopUp();
        end


        function resetTSAfterMeasurementMode(this)








            this.Home.setDefaultVisualizationSection();


            this.Home.setColormapValPopUp();
        end



        function setDefaultCMapValText(this,inEditMode)


            if inEditMode
                setColormapValText(this.Edit,...
                getString(message('lidar:lidarViewer:ColormapValueZ')));
            else
                setColormapValText(this.Home,...
                getString(message('lidar:lidarViewer:ColormapValueZ')));
            end
        end


        function setDefaultCMapText(this,inEditMode)


            if inEditMode
                setColormapText(this.Edit,...
                getString(message('lidar:lidarViewer:ColormapRedWhiteBlue')));
            else
                setColormapText(this.Home,...
                getString(message('lidar:lidarViewer:ColormapRedWhiteBlue')));
            end
        end


        function changeToEditTab(this)



            homeVisualizseState=this.Home.getState();


            this.CachedCMapValPopup=homeVisualizseState.ColormapValPopup;


            remove(this.TabGroup,this.Home.Tab);



            add(this.TabGroup,this.Edit.Tab);
            this.TabGroup.SelectedTab=this.Edit.Tab;


            this.Edit.setState(homeVisualizseState);


            this.Edit.BackGroundColor=this.Home.BackGroundColor;


            if this.Home.isColorPresent()
                addColorInColormap(this,true,true);
            end
        end


        function changeToMeasurementTab(this)



            remove(this.TabGroup,this.Home.Tab);


            wireUpMeasurementTab(this);
            this.TabGroup.SelectedTab=this.Measurement.Tab;
            this.Measurement.reset();
        end


        function changeToHomeTab(this,fromTab)



            editVisualizseState=this.Edit.getState();


            if strcmp(fromTab,'Measurement')
                remove(this.TabGroup,this.Measurement.Tab);
            elseif strcmp(fromTab,'Edit')
                remove(this.TabGroup,this.Edit.Tab);
            end

            add(this.TabGroup,this.Home.Tab);
            this.TabGroup.SelectedTab=this.Home.Tab;


            this.Home.setState(editVisualizseState,false);
            this.Home.disableGroundAndClusterSettings();


            this.Home.setColorAndColormapValue();

        end


        function disableAlgorithmAndFinalizeSection(this)


            this.Edit.disableAlgorithmAndFinalizeSection();
        end


        function addColorInColormap(this,inEditMode,colorPresent)

            if colorPresent
                if inEditMode
                    addColorInColormap(this.Edit);
                else
                    addColorInColormap(this.Home);
                end
            else
                if inEditMode
                    this.Edit.setColormapPopUp();
                else
                    this.Home.setColormapPopUp();
                end
            end
        end
    end




    events


RequestForNewSession
RequestToImportSignals
ColorChangeRequest
BackgroundColorChangeRequest
PointSizeChangeRequest
PlanarViewChangeRequest
EditModeRequest
MeasurementModeRequest
RequestForDefaultLayout
RequestForCustomCameraOperation
RequestToExportSignals
RequestToGenerateScript
CameraViewChangeRequest
DefaultViewChangeRequest
ExternalTrigger
HideGroundChanged
ClusterSettingsRequest
ClusterDataChanged
StartColoringByClusters
StopColoringByClusters
ViewGroundDataRequest
StopViewGroundDataRequest
ClusteringStatusRequest
HideGroundDataRequest
CustomColormapRequest
RequestForMeasurementTools
CloseMeasurementTab
    end




    events


RequestToExitEditMode
RequestToEditSignals
RequestToRevertEdits
RequestToUpdateEdits
RequestToEditDataWithCustomFunction
    end

    events

RequestToMeasurementTools
StopLastMeasurementTool
UpdateClearSection
DisableSlider
EnableSlider


    end




    methods(Access=private)
        function wireUpHomeTab(this)
            this.Home=lidar.internal.lidarViewer.view.HomeTab();
            add(this.TabGroup,this.Home.Tab);
            this.TabGroup.SelectedTab=this.Home.Tab;


            addlistener(this.Home,'RequestForNewSession',@(~,~)notify(this,'RequestForNewSession'));
            addlistener(this.Home,'RequestToImportSignals',@(~,evt)notify(this,'RequestToImportSignals',evt));
            addlistener(this.Home,'ColorChangeRequest',@(~,evt)notify(this,'ColorChangeRequest',evt));
            addlistener(this.Home,'BackgroundColorChangeRequest',@(~,evt)notify(this,'BackgroundColorChangeRequest',evt));
            addlistener(this.Home,'PlanarViewChangeRequest',@(~,evt)notify(this,'PlanarViewChangeRequest',evt));
            addlistener(this.Home,'RequestForCustomCameraOperation',@(~,evt)notify(this,'RequestForCustomCameraOperation',evt));
            addlistener(this.Home,'PointSizeChangeRequest',@(~,evt)notify(this,'PointSizeChangeRequest',evt));
            addlistener(this.Home,'RequestToExportSignals',@(~,~)notify(this,'RequestToExportSignals'));
            addlistener(this.Home,'EditModeRequest',@(~,~)notify(this,'EditModeRequest'));
            addlistener(this.Home,'MeasurementModeRequest',@(~,~)notify(this,'MeasurementModeRequest'));
            addlistener(this.Home,'RequestForDefaultLayout',@(~,~)notify(this,'RequestForDefaultLayout'));
            addlistener(this.Home,'CameraViewChangeRequest',@(~,evt)notify(this,'CameraViewChangeRequest',evt));
            addlistener(this.Home,'DefaultViewChangeRequest',@(~,~)notify(this,'DefaultViewChangeRequest'));
            addlistener(this.Home,'HideGroundChanged',@(src,evt)notify(this,'HideGroundChanged',evt));
            addlistener(this.Home,'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));
            addlistener(this.Home,'ClusterSettingsRequest',@(~,~)notify(this,'ClusterSettingsRequest'));
            addlistener(this.Home,'ClusterDataChanged',@(~,evt)notify(this,'ClusterDataChanged',evt));
            addlistener(this.Home,'StartColoringByClusters',@(~,~)notify(this,'StartColoringByClusters'));
            addlistener(this.Home,'StopColoringByClusters',@(~,~)notify(this,'StopColoringByClusters'));
            addlistener(this.Home,'ViewGroundDataRequest',@(~,~)notify(this,'ViewGroundDataRequest'));
            addlistener(this.Home,'StopViewGroundDataRequest',@(~,~)notify(this,'StopViewGroundDataRequest'));
            addlistener(this.Home,'ClusteringStatusRequest',@(~,~)notify(this,'ClusteringStatusRequest'));
            addlistener(this.Home,'HideGroundDataRequest',@(~,~)notify(this,'HideGroundDataRequest'));
            addlistener(this.Home,'CustomColormapRequest',@(~,evt)notify(this,'CustomColormapRequest',evt));
        end


        function wireUpEditTab(this)
            this.Edit=lidar.internal.lidarViewer.view.EditTab();


            addlistener(this.Edit,'RequestToEditSignals',@(~,evt)requestToEditSignal(this,evt));
            addlistener(this.Edit,'RequestToEditDataWithCustomFunction',@(~,evt)notify(this,'RequestToEditDataWithCustomFunction',evt));
            addlistener(this.Edit,'RequestToExitEditMode',@(~,evt)exitEditMode(this,evt));
            addlistener(this.Edit,'RequestToUpdateEdits',@(~,evt)notify(this,'RequestToUpdateEdits',evt));
            addlistener(this.Edit,'ColorChangeRequest',@(~,evt)notify(this,'ColorChangeRequest',evt));
            addlistener(this.Edit,'BackgroundColorChangeRequest',@(~,evt)notify(this,'BackgroundColorChangeRequest',evt));
            addlistener(this.Edit,'PlanarViewChangeRequest',@(~,evt)notify(this,'PlanarViewChangeRequest',evt));
            addlistener(this.Edit,'PointSizeChangeRequest',@(~,evt)notify(this,'PointSizeChangeRequest',evt));
            addlistener(this.Edit,'DefaultViewChangeRequest',@(~,~)notify(this,'DefaultViewChangeRequest'));
            addlistener(this.Edit,'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));
            addlistener(this.Edit,'CustomColormapRequest',@(~,evt)notify(this,'CustomColormapRequest',evt));

        end


        function wireUpMeasurementTab(this)
            this.Measurement=lidar.internal.lidarViewer.view.MeasurementTab();

            add(this.TabGroup,this.Measurement.Tab);


            addlistener(this.Measurement,'RequestForMeasurementTools',@(~,evt)notify(this,'RequestForMeasurementTools',evt));
            addlistener(this.Measurement,'DisableHomeTab',@(~,~)enablingHomeTab(this,false));
            addlistener(this.Measurement,'EnableHomeTab',@(~,~)enablingHomeTab(this,true));
            addlistener(this.Measurement,'UpdateClearSection',@(~,~)notify(this,'UpdateClearSection'));
            addlistener(this.Measurement,'DisableSlider',@(~,~)notify(this,'DisableSlider'));
            addlistener(this.Measurement,'EnableSlider',@(~,~)notify(this,'EnableSlider'));
            addlistener(this.Measurement,'CloseMeasurementTab',@(~,~)notify(this,'CloseMeasurementTab'));
        end
    end

    methods


        function enablingHomeTab(this,value)
            if value
                this.Home.enable();
                if this.Home.ViewGroundData||this.Home.ClusterSettings.ClusterData
                    this.Home.resetColorAndColormapValue();
                else
                    this.Home.setColorAndColormapValue();
                end

                this.Home.EgoDirection=this.EgoValue;
            else
                this.EgoValue=this.Home.EgoDirection;
                this.Home.disable();
            end
        end
    end




    methods(Access=private)

        function requestToEditSignal(this,evt)

            notify(this,'RequestToEditSignals',evt)
        end


        function exitEditMode(this,evt)


            notify(this,'RequestToExitEditMode',evt);

            if~evt.ToSave


                this.Home.setCachedCmapValPopup(this.CachedCMapValPopup);
                this.CachedCMapValPopup=[];
            end
            resetSettingsParameters(this.Home);
        end
    end




    methods
        function saveTSState(this,dataId)


            if numel(this.TSState)<dataId

                dataId=1+numel(this.TSState);
            end
            this.TSState{dataId}=this.Home.getState();
        end


        function toggleTSState(this,dataId)

            if isempty(this.TSState)||isempty(this.TSState(dataId))
                return;
            end
            tsState=this.TSState{dataId};
            this.Home.setState(tsState,true);
        end


        function deleteTSState(this,dataId)

            if numel(this.TSState)<dataId

                return;
            end
            this.TSState(dataId)=[];
        end
    end
end
