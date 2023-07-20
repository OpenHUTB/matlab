








classdef MeasurementTab<handle

    properties(SetAccess=private,Hidden,Transient)

Tab
    end

    properties(Access=private)

        MeasurementSection lidar.internal.lidarViewer.view.section.MeasurementSection
        ClearSection lidar.internal.lidarViewer.view.section.ClearSection
        CloseSection lidar.internal.lidarViewer.view.section.CloseSection

    end

    properties


ToolName
        value=0
    end

    events
RequestForMeasurementTools
StopLastMeasurementTool
AllToolDeleted
DisableHomeTab
EnableHomeTab
DisableSlider
EnableSlider
UpdateClearSection

CloseMeasurementTab
    end

    methods



        function this=MeasurementTab()

            this.Tab=matlab.ui.internal.toolstrip.Tab(...
            getString(message('lidar:lidarViewer:MeasurementTab')));
            this.Tab.Tag='measurementTab';
            createTab(this);

        end


        function close(this)

        end


        function enable(this)
            this.Tab.enableAll();
        end


        function disable(this)
            this.Tab.disableAll();
        end

        function disableClearSection(this)
            this.ClearSection.ClearButton.Enabled=false;
        end

        function enableClearSection(this)
            clearButton=this.ClearSection.ClearButton;
            clearButton.Enabled=true;
        end


        function reset(this)
            this.MeasurementSection.DistanceButton.Enabled=true;
            this.MeasurementSection.ElevationButton.Enabled=true;
            this.MeasurementSection.PointButton.Enabled=true;
            this.MeasurementSection.AngleButton.Enabled=true;
            this.MeasurementSection.VolumeButton.Enabled=true;
            this.ClearSection.ClearButton.Enabled=false;
            this.CloseSection.CloseButton.Enabled=true;
        end


        function setSection(this,TF)
            this.MeasurementSection.DistanceButton.Enabled=TF;
            this.MeasurementSection.ElevationButton.Enabled=TF;
            this.MeasurementSection.PointButton.Enabled=TF;
            this.MeasurementSection.AngleButton.Enabled=TF;
            this.MeasurementSection.VolumeButton.Enabled=TF;
            this.ClearSection.ClearButton.Enabled=TF;
            this.CloseSection.CloseButton.Enabled=TF;
        end


        function measurementToolCompleted(this,toEnableRemove)


            clearButton=this.ClearSection.ClearButton;
            clearButton.Enabled=toEnableRemove;

            if isempty(this.ToolName)
                return;
            end


            btnIdx=this.MeasurementSection.getIdxFromName(this.ToolName);
            if isempty(btnIdx)
                return;
            end

            this.ToolName='';
            this.setSection(true);
        end
    end



    methods(Access=private)
        function createTab(this)


            tab=this.Tab;

            this.MeasurementSection=lidar.internal.lidarViewer.view.section.MeasurementSection(tab);
            this.ClearSection=lidar.internal.lidarViewer.view.section.ClearSection(tab);
            this.CloseSection=lidar.internal.lidarViewer.view.section.CloseSection(tab);


            this.installMeasurementSectionListeners();


            this.setMeasurementSection(false);
        end
    end



    methods(Access=private)
        function installMeasurementSectionListeners(this)



            this.MeasurementSection.DistanceButton.ValueChangedFcn=...
            @(~,~)this.handleMeasurementTools('Distance Tool');


            this.MeasurementSection.ElevationButton.ValueChangedFcn=...
            @(~,~)this.handleMeasurementTools('Elevation Tool');


            this.MeasurementSection.PointButton.ValueChangedFcn=...
            @(~,~)this.handleMeasurementTools('Point Tool');


            this.MeasurementSection.AngleButton.ValueChangedFcn=...
            @(~,~)this.handleMeasurementTools('Angle Tool');


            this.MeasurementSection.VolumeButton.ValueChangedFcn=...
            @(~,~)this.handleMeasurementTools('Volume Tool');


            this.ClearSection.ClearButton.ButtonPushedFcn=...
            @(~,~)this.removeMeasurementTools();


            this.CloseSection.CloseButton.ButtonPushedFcn=...
            @(~,~)this.closeMeasurementTab();
        end
    end



    methods

        function handleMeasurementTools(this,toolName)
            notify(this,'DisableHomeTab');
            notify(this,'DisableSlider');

            this.value=this.value+1;


            this.ToolName=toolName;

            this.setSection(false);
            this.setToolButton(toolName,true);


            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(toolName,[],false);
            notify(this,'RequestForMeasurementTools',evt);

            notify(this,'EnableHomeTab');
            notify(this,'EnableSlider');

            this.value=this.value-1;
            this.reset();
            this.setToolButton(toolName,false);

            if~this.value
                this.setMeasurementSection(true);
                this.enableClearSection();
            end

            notify(this,'UpdateClearSection');
        end


        function removeMeasurementTools(this)

            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData([],[],true);


            this.ToolName='';

            clearButton=this.ClearSection.ClearButton;
            clearButton.Enabled=false;


            notify(this,'RequestForMeasurementTools',evt);
        end


        function closeMeasurementTab(this)
            notify(this,'CloseMeasurementTab');
        end


        function setMeasurementSection(this,TF)

            this.setSection(TF);
        end


        function resetMeasurementToolSection(this)


            this.reset();
        end


        function setToolButton(this,toolName,TF)
            if strcmp(toolName,'Distance Tool')
                this.MeasurementSection.DistanceButton.Value=TF;
            elseif strcmp(toolName,'Angle Tool')
                this.MeasurementSection.AngleButton.Value=TF;
            elseif strcmp(toolName,'Volume Tool')
                this.MeasurementSection.VolumeButton.Value=TF;
            elseif strcmp(toolName,'Elevation Tool')
                this.MeasurementSection.ElevationButton.Value=TF;
            elseif strcmp(toolName,'Point Tool')
                this.MeasurementSection.PointButton.Value=TF;
            end
        end

    end
end
