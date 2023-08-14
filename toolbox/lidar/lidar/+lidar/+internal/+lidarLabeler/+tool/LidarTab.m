classdef LidarTab<driving.internal.groundTruthLabeler.tool.LidarTab




    properties(Access=protected)
LimitsSettings
    end

    events
UsePCFitCuboid
SaveCameraViewEvent

LimitsDataChanged
ChangedView

    end

    methods(Access=public)
        function this=LidarTab(tool)

            this@driving.internal.groundTruthLabeler.tool.LidarTab(tool);

            this.Container=tool;


            addlistener(this.CuboidSection.UsePCFitCuboid,'ValueChanged',@(~,~)this.togglePCFiteCuboid(this.CuboidSection.UsePCFitCuboid.Value));


            this.CameraViewSection.SaveCamViewButton.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)doHomeView(this),varargin{:});
            this.CameraViewSection.SaveCamViewButton.DynamicPopupFcn=@(~,~)getCamSaveViewPopup(this);


            this.CameraViewSection.LimitsSettingsBtn.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)doFullView(this),varargin{:});
            this.CameraViewSection.LimitsSettingsBtn.DynamicPopupFcn=@(~,~)getLimitsDialogPopup(this);

        end

        function enableControls(this)
            enableControls@driving.internal.groundTruthLabeler.tool.LidarTab(this);
            this.ColormapSection.Section.enableAll();
            this.CameraViewSection.enable();
        end

        function disableControls(this)
            disableControls@driving.internal.groundTruthLabeler.tool.LidarTab(this);
            this.CameraViewSection.disable();
        end

        function enableColormapSection(this)
            this.ColormapSection.enable();
        end
    end

    methods(Access=protected)

        function createWidgets(this,name)
            this.createColormapSection();
            this.createCameraViewSection(name);
            this.createGroundSection();
            this.createCuboidSection();
            this.createLineSection();
        end

        function createColormapSection(this)
            this.ColormapSection=lidar.internal.lidarLabeler.tool.sections.LidarColormapSection;
            this.addSectionToTab(this.ColormapSection);
        end

        function createCameraViewSection(this,name)
            this.CameraViewSection=lidar.internal.lidarLabeler.tool.sections.LidarCameraViewSection;
            this.addSectionToTab(this.CameraViewSection);
            this.LimitsSettings=lidar.internal.lidarLabeler.tool.LimitsSettings(this.Container);
        end

        function createCuboidSection(this)
            this.CuboidSection=lidar.internal.lidarLabeler.tool.sections.CuboidSection;
            this.addSectionToTab(this.CuboidSection);
            this.ClusterSettings=lidar.internal.lidarLabeler.tool.ClusterSettings(this.Container);
        end

        function createLineSection(this)
            this.LineSection=driving.internal.groundTruthLabeler.tool.sections.LineSection;
            this.addSectionToTab(this.LineSection);
        end

        function createGroundSection(this)
            this.GroundSection=lidar.internal.lidarLabeler.tool.sections.GroundSection;
            this.addSectionToTab(this.GroundSection);
            this.GroundSettings=lidar.internal.lidarLabeler.tool.GroundSettings(this.Container);
        end

        function togglePCFiteCuboid(this,TF)
            evtData=driving.internal.groundTruthLabeler.tool.CuboidSettingsEventData(TF);
            notify(this,'UsePCFitCuboid',evtData);
        end

        function doHomeView(this)
            doHomeView@driving.internal.groundTruthLabeler.tool.LidarTab(this);
            close(this.LimitsSettings);
        end

        function doFullView(this)
            notify(this,'ChangedView');
            close(this.LimitsSettings);
        end

        function doLimitsSettings(this)
            llt=getParent(this);
            display=llt.DisplayManager.getSelectedDisplay;
            this.LimitsSettings.ToolName=this.getParent.ToolType;
            openLimitsSettings(display,this.LimitsSettings);
        end

        function doLimitsChanged(this,~,evt)
            notify(this,'LimitsDataChanged',evt);
        end

        function doColormap(this)
            this.ColormapSection.ColormapValue.Enabled=true;

            switch this.ColormapSection.Colormap.SelectedIndex
            case 1

                cmap=zeros([256,3]);
                cmap(1:128,1)=1;
                cmap(1:128,2)=linspace(0,1,128);
                cmap(1:128,3)=linspace(0,1,128);
                cmap(128:256,1)=linspace(1,0,129);
                cmap(128:256,2)=linspace(1,0,129);
                cmap(128:256,3)=1;
            case 2

                cmap=parula(256);
            case 3

                cmap=jet(256);
            case 4

                cmap=hot(256);
            case 5

                cmap=spring(256);
            case 6
                cmap=[];
                this.ColormapSection.ColormapValue.Enabled=false;
            otherwise
                assert(false,'Invalid colormap entry')
            end

            switch this.ColormapSection.ColormapValue.SelectedIndex
            case 1

                val='z';
            case 2

                val='radial';
            end

            evtData=driving.internal.groundTruthLabeler.tool.LidarColormapEventData(cmap,val);
            notify(this,'ColormapChanged',evtData);

        end


        function installListeners(this)
            installListeners@driving.internal.groundTruthLabeler.tool.LidarTab(this);
            this.installListenersROILimits();
        end

        function installListenersROILimits(this)
            addlistener(this.LimitsSettings,'LimitsSettingsChanged',@this.doLimitsChanged);
        end
    end




    methods(Access=private)

        function popup=getCamSaveViewPopup(this)

            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();

            if isPopupRefreshed(this.CameraViewSection)


                this.CameraViewSection.RestoreCamView.ItemPushedFcn=...
                @(varargin)protectOnDelete(this,@(varargin)doHomeView(this),varargin{:});
                popup.add(this.CameraViewSection.RestoreCamView);


                for i=1:numel(this.CameraViewSection.SaveCamViewRepo)


                    this.CameraViewSection.SaveCamViewItems{i}.ItemPushedFcn=...
                    @(es,ed)cameraViewSelected(this,i);
                    popup.add(this.CameraViewSection.SaveCamViewItems{i});
                end


                this.CameraViewSection.SaveCamView.ItemPushedFcn=@(es,ed)saveCamView(this);
                popup.add(this.CameraViewSection.SaveCamView);


                this.CameraViewSection.OrganizeCamView.ItemPushedFcn=@(es,ed)organizeCamView(this);

                if isempty(this.CameraViewSection.SaveCamViewRepo)
                    this.CameraViewSection.OrganizeCamView.Enabled=false;
                end
                popup.add(this.CameraViewSection.OrganizeCamView);

                setIsRefreshed(this.CameraViewSection,false);
            else
                popup=this.CameraViewSection.SaveCamViewButton.Popup;
            end
        end


        function saveCamView(this)

            savedNames=this.CameraViewSection.SaveCamViewRepo;
            dlg=lidar.internal.lidarLabeler.tool.SaveCamViewDlg(getParent(this).Tool,savedNames);
            wait(dlg);
            if~dlg.IsCanceled

                evtData=lidar.internal.lidarLabeler.tool.SaveLidarCameraViewEventData(0,1);
                notify(this,'SaveCameraViewEvent',evtData)


                newCamViewName=dlg.getSavedName();
                this.CameraViewSection.appendCameraView(newCamViewName);
            end
        end


        function organizeCamView(this)


            dlg=lidar.internal.lidarLabeler.tool.OrganizeCameraViewDlg(getParent(this).Tool,this.CameraViewSection.SaveCamViewRepo);
            wait(dlg);

            if dlg.getRefreshFlag
                dlg.setRefreshFlag(false);

                savedViewNames=this.CameraViewSection.SaveCamViewRepo;

                userAction=dlg.getUserAction;

                for i=1:numel(userAction)
                    if strcmp(userAction{i}{1},'rename')
                        index=userAction{i}{2}{1};
                        savedViewNames{index}=userAction{i}{2}{2};
                    else
                        index=userAction{i}{2}{1};
                        savedViewNames(index)=[];


                        evtData=lidar.internal.lidarLabeler.tool.SaveLidarCameraViewEventData(index,2);
                        notify(this,'SaveCameraViewEvent',evtData)
                    end
                end

                this.CameraViewSection.SaveCamViewRepo=savedViewNames;

                setIsRefreshed(this.CameraViewSection,true);
                this.CameraViewSection.refreshCamViewSavePopup()
            end
        end


        function cameraViewSelected(this,index)

            evtData=lidar.internal.lidarLabeler.tool.SaveLidarCameraViewEventData(index,0);
            notify(this,'SaveCameraViewEvent',evtData);
            llt=getParent(this);
            display=llt.DisplayManager.getSelectedDisplay;
            setCameraViewLimits(display);
        end


        function popup=getLimitsDialogPopup(this)

            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();

            if isROIPopupRefreshed(this.CameraViewSection)


                this.CameraViewSection.FullView.ItemPushedFcn=...
                @(varargin)protectOnDelete(this,@(varargin)doFullView(this),varargin{:});
                popup.add(this.CameraViewSection.FullView);

                this.CameraViewSection.ROIView.ItemPushedFcn=@(~,~)this.doLimitsSettings;
                popup.add(this.CameraViewSection.ROIView);

                setIsROIPopupRefreshed(this.CameraViewSection,false);
            else
                popup=this.CameraViewSection.LimitsSettingsBtn.Popup;
            end
        end
    end

    methods
        function resetSavedCameraOnNewSession(this)


            this.CameraViewSection.resetSaveCameraView();
        end


        function names=getSavedCameraViewNames(this)

            names=this.CameraViewSection.SaveCamViewRepo;
        end


        function appendSaveCameraViewName(this,params)


            for i=1:numel(params)
                this.CameraViewSection.appendCameraView(params{i}.Name);
            end
        end


        function resetROIViewOnNewSession(this)


            close(this.LimitsSettings);
        end


        function resetGroundSettingsOnNewSession(this)

            this.GroundSection.HideGround.Value=false;
        end

    end
end
