classdef GroundSettingsDialog<images.internal.app.utilities.CloseDialog




    properties

        OrganizedPC=false;


ModeButton
SegmentLidarLabel
PCFitPlaneLabel
SegmentGroundSMRFLabel


ElevationAngleDeltaSlider
InitialElevationAngleSlider

ElevationAngleDeltaLabel
InitialElevationAngleLabel

ElevationAngleDeltaDisplay
InitialElevationAngleDisplay


MaxDistanceSlider
MaxAngularDistanceSlider

MaxDistanceLabel
MaxAngularDistanceLabel

MaxAngularDistanceDisplay
MaxDistanceDisplay


GridResolutionSlider
ElevationThresholdSlider
SlopeThresholdSlider
MaxWindowRadiusSlider

GridResolutionLabel
ElevationThresholdLabel
SlopeThresholdLabel
MaxWindowRadiusLabel

GridResolutionDisplay
ElevationThresholdDisplay
SlopeThresholdDisplay
MaxWindowRadiusDisplay


ViewGroundDataCheckbox
ViewGroundDataUnselectedListener
ViewGroundDataSelectedListener
    end

    properties(Dependent)
Visible
EnableMode
Mode
    end

    events
GroundSettingsChanging
GroundSettingsChanged
ViewGroundDataRequest
StopViewGroundDataRequest
ElevationAngleDeltaChanged
InitialElevationAngleChanged
MaxAngularDistanceChanged
MaxDistanceChanged
GridResolutionChanged
ElevationThresholdChanged
SlopeThresholdChanged
MaxWindowRadiusChanged

CheckBoxSelectedAction
CheckBoxUnselectedAction
GroundSettingsCloseRequest
    end

    properties(Access=private)
MaxDistanceListener
MaxAngularDistanceListener
InitialElevationAngleListener
ElevationAngleDeltaListener
GridResolutionListener
ElevationThresholdListener
SlopeThresholdListener
MaxWindowRadiusListener
    end

    properties(Access=private)

        ElevationAngleDeltaMinValue=1;
        ElevationAngleDeltaMaxValue=20;

        InitialElevationAngleMinValue=10;
        InitialElevationAngleMaxValue=35;

        MaxDistanceMinValue=0
        MaxDistanceMaxValue=10;
        MaxDistanceDefaultValue=0.5;

        MaxAngularDistanceMinValue=0;
        MaxAngularDistanceMaxValue=45;
        MaxAngularDistanceDefaultValue=1;

        GridResolutionMinValue=1;
        GridResolutionMaxValue=99;
        GridResolutionDefaultValue=1;

        ElevationThresholdMinValue=0;
        ElevationThresholdMaxValue=10;
        ElevationThresholdDefaultValue=0.5;

        SlopeThresholdMinValue=0;
        SlopeThresholdMaxValue=5;
        SlopeThresholdDefaultValue=0.15;

        MaxWindowRadiusMinValue=1;
        MaxWindowRadiusMaxValue=75;
        MaxWindowRadiusDefaultValue=18;

LowValue
HighValue
DefaultValue
Limit
ToolName
    end

    properties(Access=protected)
        ModeInternal='segmentGroundFromLidarData';
    end


    methods
        function this=GroundSettingsDialog(toolName,TF)
            monitorPos=get(0,'MonitorPositions');
            location=[monitorPos(1,3)/2,monitorPos(1,4)/2];

            this=this@images.internal.app.utilities.CloseDialog(location,toolName);

            this.Size=[400,210];
            this.ToolName=toolName;
            this.OrganizedPC=TF;
            create(this);

            this.FigureHandle.WindowStyle='modal';
            doLayout(this);

        end

        function update(this,mode,elevang,initang,maxdist,maxang)

            this.ElevationAngleDeltaSlider.Value=elevang;
            this.InitialElevationAngleSlider.Value=initang;


            this.MaxDistanceSlider.Value=maxdist;
            this.MaxAngularDistanceSlider.Value=maxang;

            this.Mode=mode;
        end

        function updateWithOrganizedPC(this,mode,elevang,initang,maxdist,...
            maxang,gridres,elevthres,slopethres,maxradius)

            this.ElevationAngleDeltaSlider.Value=elevang;
            this.InitialElevationAngleSlider.Value=initang;


            this.MaxDistanceSlider.Value=maxdist;
            this.MaxAngularDistanceSlider.Value=maxang;


            this.GridResolutionSlider.Value=gridres;
            this.ElevationThresholdSlider.Value=elevthres;
            this.SlopeThresholdSlider.Value=slopethres;
            this.MaxWindowRadiusSlider.Value=maxradius;

            this.Mode=mode;
        end

        function updateSliderDisplay(this,evt)
            this.ElevationAngleDeltaDisplay.Value=num2str(evt.ElevationAngleDelta,3);
            this.InitialElevationAngleDisplay.Value=num2str(evt.InitialElevationAngle,3);
            this.MaxDistanceDisplay.Value=num2str(evt.MaxDistance,3);
            this.MaxAngularDistanceDisplay.Value=num2str(evt.MaxAngularDistance,3);
            if this.OrganizedPC
                this.GridResolutionDisplay.Value=num2str(evt.GridResolution,3);
                this.ElevationThresholdDisplay.Value=num2str(evt.ElevationThreshold,3);
                this.SlopeThresholdDisplay.Value=num2str(evt.SlopeThreshold,3);
                this.MaxWindowRadiusDisplay.Value=num2str(floor(evt.MaxWindowRadius));
            end
        end

        function resetMaxDistanceSliderValue(this,mode)
            switch mode
            case 'maxDistance'
                notify(this,'MaxDistanceChanged');
            case 'maxAngularDistance'
                notify(this,'MaxAngularDistanceChanged');
            end
        end

    end


    methods(Access=private)
        function doLayout(this,~,~)
            width=(this.Size(1)/2)-(2.5*15);
            height=this.ButtonSize(2);

            subtractForDisplay=20;

            if this.OrganizedPC
                popupMenuStrings={getString(message('lidar:lidarViewer:SegmentGroundFromLidarData')),...
                getString(message('lidar:lidarViewer:PCFitPlane')),...
                getString(message('lidar:lidarViewer:SegmentGroundSMRFPlane'))};
            else
                popupMenuStrings={getString(message('lidar:lidarViewer:SegmentGroundFromLidarData')),...
                getString(message('lidar:lidarViewer:PCFitPlane'))};
            end

            this.ModeButton=uidropdown(this.FigureHandle,'Items',popupMenuStrings,...
            'Position',[15,(5*height)+(5*15),width,height]);
            this.ModeButton.ValueChangedFcn=@(~,~)modeChangedCallback(this);

            this.SegmentLidarLabel=uilabel(this.FigureHandle,'Text',...
            getString(message('lidar:lidarViewer:SegmentGroundFromLidarDataDesc')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,(3*height)+(4*15),this.Size(1)-(2*15),2*height]);

            this.PCFitPlaneLabel=uilabel(this.FigureHandle,'Text',...
            getString(message('lidar:lidarViewer:PCFitPlaneDesc')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,(3*height)+(4*15),this.Size(1)-(2*15),2*height]);


            this.ElevationAngleDeltaSlider=uislider(this.FigureHandle,...
            'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
            'Position',[width-subtractForDisplay,(3*height)+(2*15)+5,...
            width-subtractForDisplay,3]);
            this.ElevationAngleDeltaSlider.Tag='elevationSlider';
            addlistener(this.ElevationAngleDeltaSlider,'ValueChanged',...
            @(~,~)settingsChangedCallback(this));
            addlistener(this.ElevationAngleDeltaSlider,'ValueChanging',...
            @(~,~)settingsChangingCallback(this));
            this.InitialElevationAngleSlider=uislider(this.FigureHandle,...
            'Limits',[0,1],'MinorTicks',[],'Position',...
            [width-subtractForDisplay,height+(2*15)+5,...
            width-subtractForDisplay,3],'MajorTicks',[]);
            this.InitialElevationAngleSlider.Tag='initElevationSlider';
            addlistener(this.InitialElevationAngleSlider,'ValueChanged',...
            @(~,~)settingsChangedCallback(this));
            addlistener(this.InitialElevationAngleSlider,'ValueChanging',...
            @(~,~)settingsChangingCallback(this));

            this.ElevationAngleDeltaLabel=uilabel(this.FigureHandle,...
            'Text',getString(message('lidar:lidarViewer:LidarViewerElevationAngleDelta')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,(2*height)+(3*15),0.75*width,height]);

            this.InitialElevationAngleLabel=uilabel(this.FigureHandle,...
            'Text',getString(message('lidar:lidarViewer:LidarViewerInitialElevationAngle')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,height+(2*15),0.75*width,height]);

            this.ElevationAngleDeltaDisplay=uieditfield(this.FigureHandle,'Position',...
            [(2*width)+(2*15)-subtractForDisplay,(2*height)+(3*15),...
            (3*subtractForDisplay),height],'Tag','elevationEditbox',...
            'FontSize',12);
            this.ElevationAngleDeltaDisplay.ValueChangedFcn=...
            @(~,~)triggerElevationAngleEditBoxChangeEvent(this);

            this.InitialElevationAngleDisplay=uieditfield(this.FigureHandle,'Position',...
            [(2*width)+(2*15)-subtractForDisplay,height+(2*15),...
            (3*subtractForDisplay),height],'Tag','initElevationEditBox');

            this.InitialElevationAngleDisplay.ValueChangedFcn=...
            @(~,~)triggerInitialElevationAngleChangeEvent(this);


            this.MaxDistanceSlider=uislider(this.FigureHandle,...
            'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
            'Position',[width,(height)+(4.8*15)+5,width-2*subtractForDisplay,3]);
            this.MaxDistanceSlider.Tag='maxDistanceSlider';
            addlistener(this.MaxDistanceSlider,'ValueChanged',...
            @(~,~)settingsChangedCallback(this));
            addlistener(this.MaxDistanceSlider,'ValueChanging',...
            @(~,~)settingsChangingCallback(this));
            this.MaxAngularDistanceSlider=uislider(this.FigureHandle,...
            'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
            'Position',[width,(height)+(2.2*15)+5,width-2*subtractForDisplay,3]);
            this.MaxAngularDistanceSlider.Tag='maxAngularDistSlider';
            addlistener(this.MaxAngularDistanceSlider,'ValueChanged',...
            @(~,~)settingsChangedCallback(this));
            addlistener(this.MaxAngularDistanceSlider,'ValueChanging',...
            @(~,~)settingsChangingCallback(this));

            this.MaxDistanceLabel=uilabel(this.FigureHandle,'Text',...
            getString(message('lidar:lidarViewer:LidarViewerMaxDistance')),...
            'WordWrap','on','Position',...
            [1.7*15,(2.2*height)+(3*15),0.6*width,height],'FontSize',12);

            this.MaxAngularDistanceLabel=uilabel(this.FigureHandle,'Text',getString(message('lidar:lidarViewer:LidarViewerMaxAngularDistance')),...
            'WordWrap','on','Position',...
            [1.5*15,(1.7*height)+(15),0.75*width,height],'FontSize',12);

            this.MaxDistanceDisplay=uieditfield(this.FigureHandle,'Position',...
            [(2*width)+(15)-2*subtractForDisplay,(2.1*height)+(3*15),...
            (3*subtractForDisplay),height],'FontSize',12,...
            'Tag','maxDistEditBox');
            this.MaxDistanceDisplay.ValueChangedFcn=...
            @(~,~)triggerMaxDistanceChangedEvent(this);

            this.MaxAngularDistanceDisplay=uieditfield(this.FigureHandle,'Position',...
            [(2*width)+(15)-2*subtractForDisplay,(1.9*height)+(15),...
            (3*subtractForDisplay),height],'FontSize',12,...
            'Tag','maxAngularDistEditBox');
            this.MaxAngularDistanceDisplay.ValueChangedFcn=...
            @(~,~)triggerMaxAngularDistanceChangedEvent(this);

            if this.OrganizedPC

                this.SegmentGroundSMRFLabel=uilabel(this.FigureHandle,...
                'Text',getString(message('lidar:lidarViewer:SegmentGroundSMRFDesc')),...
                'WordWrap','on','FontSize',12,'Position',...
                [15,((5*height)+(3*15)-5),this.Size(1)-(2*15),2*height]);

                this.GridResolutionSlider=uislider(this.FigureHandle,...
                'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
                'Position',[width,((4*height)+(3*15)+2),...
                width-2*subtractForDisplay,3]);
                this.GridResolutionSlider.Tag='gridResolutionSlider';
                addlistener(this.GridResolutionSlider,'ValueChanged',...
                @(~,~)settingsChangedCallback(this));
                addlistener(this.GridResolutionSlider,'ValueChanging',...
                @(~,~)settingsChangingCallback(this));
                this.ElevationThresholdSlider=uislider(this.FigureHandle,...
                'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
                'Position',[width,(5*height),width-2*subtractForDisplay,3]);
                this.ElevationThresholdSlider.Tag='elevationThresholdSlider';
                addlistener(this.ElevationThresholdSlider,'ValueChanged',...
                @(~,~)settingsChangedCallback(this));
                addlistener(this.ElevationThresholdSlider,'ValueChanging',...
                @(~,~)settingsChangingCallback(this));
                this.SlopeThresholdSlider=uislider(this.FigureHandle,...
                'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
                'Position',[width,(3*height)+10,width-2*subtractForDisplay,3]);
                this.SlopeThresholdSlider.Tag='slopeThresholdSlider';
                addlistener(this.SlopeThresholdSlider,'ValueChanged',...
                @(~,~)settingsChangedCallback(this));
                addlistener(this.SlopeThresholdSlider,'ValueChanging',...
                @(~,~)settingsChangingCallback(this));
                this.MaxWindowRadiusSlider=uislider(this.FigureHandle,...
                'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
                'Position',[width,(2*height)+5,width-2*subtractForDisplay,3]);
                this.MaxWindowRadiusSlider.Tag='maxWindowRadiusSlider';
                addlistener(this.MaxWindowRadiusSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.MaxWindowRadiusSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));

                this.GridResolutionLabel=uilabel(this.FigureHandle,...
                'Text',getString(message('lidar:lidarViewer:GridResolution')),...
                'WordWrap','on','FontSize',12,'Position',...
                [(height+15),(6*height),0.75*width,height]);

                this.ElevationThresholdLabel=uilabel(this.FigureHandle,...
                'Text',getString(message('lidar:lidarViewer:ElevationThreshold')),...
                'WordWrap','on','FontSize',12,'Position',...
                [(height+15),(6*15)+2,0.75*width,height]);

                this.SlopeThresholdLabel=uilabel(this.FigureHandle,...
                'Text',getString(message('lidar:lidarViewer:SlopeThreshold')),...
                'WordWrap','on','FontSize',12,'Position',...
                [(height+15),(3*height)+2,0.75*width,height]);

                this.MaxWindowRadiusLabel=uilabel(this.FigureHandle,...
                'Text',getString(message('lidar:lidarViewer:LidarViewerMaximumWindowRadius')),...
                'WordWrap','on','FontSize',12,'Position',...
                [(height+15),(2*15)+5,0.75*width,height]);

                this.GridResolutionDisplay=uieditfield(this.FigureHandle,'Position',...
                [(2*width)+(15)-subtractForDisplay,(6*height),...
                (3*subtractForDisplay),height],...
                'Tag','gridResEditBox','FontSize',12);
                this.GridResolutionDisplay.ValueChangedFcn=@(~,~)triggerGridResolutionChangedEvent(this);

                this.ElevationThresholdDisplay=uieditfield(this.FigureHandle,'Position',...
                [(2*width)+(15)-subtractForDisplay,(6*15)+2,(3*subtractForDisplay),height],...
                'Tag','eleThreEditBox','FontSize',12);
                this.ElevationThresholdDisplay.ValueChangedFcn=...
                @(~,~)triggerElevationThresholdChangedEvent(this);

                this.SlopeThresholdDisplay=uieditfield(this.FigureHandle,'Position',...
                [(2*width)+(15)-subtractForDisplay,(3*height)+3,...
                (3*subtractForDisplay),height],...
                'Tag','slopeThreEditBox','FontSize',12);
                this.SlopeThresholdDisplay.ValueChangedFcn=...
                @(~,~)triggerSlopeThresholdChangedEvent(this);

                this.MaxWindowRadiusDisplay=uieditfield(this.FigureHandle,'Position',...
                [(2*width)+(15)-subtractForDisplay,(height)+(15),(3*subtractForDisplay),height],...
                'Tag','maxRadiusEditBox','FontSize',12);
                this.MaxWindowRadiusDisplay.ValueChangedFcn=@(~,~)triggerMaxWindowRadiusChangedEvent(this);
            end

            this.ViewGroundDataCheckbox=uicheckbox(this.FigureHandle,'Position',...
            [5*15+(10*height),(5*height)+(5*15),2*width,height],...
            'FontSize',12,'Text',getString(message('lidar:lidarViewer:LidarGroundData')));
            this.ViewGroundDataCheckbox.Tag='GroundDataCheckBox';
            this.ViewGroundDataSelectedListener=addlistener(this,'CheckBoxSelectedAction',@(src,evt)viewGroundDataCheckBoxEnabled(this,evt));
            this.ViewGroundDataUnselectedListener=addlistener(this,'CheckBoxUnselectedAction',@(src,evt)viewGroundDataCheckBoxDisabled(this));
            this.ViewGroundDataCheckbox.ValueChangedFcn=...
            @(~,~)checkboxClickAction(this);


            addlistener(this,'ElevationAngleDeltaChanged',...
            @(~,~)sliderEditboxChanged(this,'elevationDeltaAngle'));
            addlistener(this,'InitialElevationAngleChanged',...
            @(~,~)sliderEditboxChanged(this,'initialElevationAngle'));
            addlistener(this,'MaxAngularDistanceChanged',...
            @(~,~)sliderEditboxChanged(this,'maxAngularDistance'));
            addlistener(this,'MaxDistanceChanged',...
            @(~,~)sliderEditboxChanged(this,'maxDistance'));
            addlistener(this,'GridResolutionChanged',...
            @(~,~)sliderEditboxChanged(this,'gridResolution'));
            addlistener(this,'ElevationThresholdChanged',...
            @(~,~)sliderEditboxChanged(this,'elevationThreshold'));
            addlistener(this,'SlopeThresholdChanged',...
            @(~,~)sliderEditboxChanged(this,'slopeThreshold'));
            addlistener(this,'MaxWindowRadiusChanged',...
            @(~,~)sliderEditboxChanged(this,'maxWindowRadius'));

            function triggerMaxDistanceChangedEvent(this)
                notify(this,'MaxDistanceChanged')
            end

            function triggerMaxAngularDistanceChangedEvent(this)
                notify(this,'MaxAngularDistanceChanged');
            end

            function triggerInitialElevationAngleChangeEvent(this)
                notify(this,'InitialElevationAngleChanged');
            end

            function triggerElevationAngleEditBoxChangeEvent(this)
                notify(this,'ElevationAngleDeltaChanged')
            end

            function triggerGridResolutionChangedEvent(this)
                notify(this,'GridResolutionChanged')
            end
            function triggerElevationThresholdChangedEvent(this)
                notify(this,'ElevationThresholdChanged')
            end

            function triggerSlopeThresholdChangedEvent(this)
                notify(this,'SlopeThresholdChanged')
            end

            function triggerMaxWindowRadiusChangedEvent(this)
                notify(this,'MaxWindowRadiusChanged')
            end
        end


        function modeChangedCallback(this)
            switch this.ModeButton.Value
            case getString(message('lidar:lidarViewer:SegmentGroundFromLidarData'))
                this.ModeInternal='segmentGroundFromLidarData';
            case getString(message('lidar:lidarViewer:PCFitPlane'))
                this.ModeInternal='pcfitplane';
            otherwise
                this.ModeInternal='segmentGroundSMRF';
            end

            setSliderVisibility(this);
            settingsChangedCallback(this);
        end

        function settingsChangedCallback(this)


            if this.OrganizedPC
                eventData=lidar.internal.lidarViewer.events.LidarViewerHideGroundEventData(true,...
                this.ModeInternal,this.ElevationAngleDeltaSlider.Value,...
                this.InitialElevationAngleSlider.Value,...
                this.MaxDistanceSlider.Value,...
                [0,0,1],...
                this.MaxAngularDistanceSlider.Value,...
                this.GridResolutionSlider.Value,...
                this.ElevationThresholdSlider.Value,...
                this.SlopeThresholdSlider.Value,...
                this.MaxWindowRadiusSlider.Value);
            else
                eventData=lidar.internal.lidarViewer.events.LidarViewerHideGroundEventData(true,...
                this.ModeInternal,this.ElevationAngleDeltaSlider.Value,...
                this.InitialElevationAngleSlider.Value,...
                this.MaxDistanceSlider.Value,...
                [0,0,1],...
                this.MaxAngularDistanceSlider.Value);
            end

            notify(this,'GroundSettingsChanged',eventData);

        end

        function settingsChangingCallback(this)


            if this.OrganizedPC
                eventData=lidar.internal.lidarViewer.events.LidarViewerHideGroundEventData(true,...
                this.ModeInternal,this.ElevationAngleDeltaSlider.Value,...
                this.InitialElevationAngleSlider.Value,...
                this.MaxDistanceSlider.Value,...
                [0,0,1],...
                this.MaxAngularDistanceSlider.Value,...
                this.GridResolutionSlider.Value,...
                this.ElevationThresholdSlider.Value,...
                this.SlopeThresholdSlider.Value,...
                this.MaxWindowRadiusSlider.Value);
            else
                eventData=lidar.internal.lidarViewer.events.LidarViewerHideGroundEventData(true,...
                this.ModeInternal,this.ElevationAngleDeltaSlider.Value,...
                this.InitialElevationAngleSlider.Value,...
                this.MaxDistanceSlider.Value,...
                [0,0,1],...
                this.MaxAngularDistanceSlider.Value);
            end

            notify(this,'GroundSettingsChanging',eventData);

        end

        function setSliderVisibility(this)

            switch this.ModeInternal
            case 'segmentGroundFromLidarData'
                vis1=true;
                vis2=false;
                vis3=false;
            case 'pcfitplane'
                vis1=false;
                vis2=true;
                vis3=false;
            otherwise
                vis1=false;
                vis2=false;
                vis3=true;
            end


            this.SegmentLidarLabel.Visible=vis1;
            this.ElevationAngleDeltaSlider.Visible=vis1;
            this.InitialElevationAngleSlider.Visible=vis1;

            this.ElevationAngleDeltaLabel.Visible=vis1;
            this.InitialElevationAngleLabel.Visible=vis1;

            this.ElevationAngleDeltaDisplay.Visible=vis1;
            this.InitialElevationAngleDisplay.Visible=vis1;


            this.PCFitPlaneLabel.Visible=vis2;
            this.MaxDistanceSlider.Visible=vis2;
            this.MaxAngularDistanceSlider.Visible=vis2;

            this.MaxDistanceLabel.Visible=vis2;
            this.MaxAngularDistanceLabel.Visible=vis2;

            this.MaxDistanceDisplay.Visible=vis2;
            this.MaxAngularDistanceDisplay.Visible=vis2;


            if this.OrganizedPC
                this.SegmentGroundSMRFLabel.Visible=vis3;
                this.GridResolutionSlider.Visible=vis3;
                this.ElevationThresholdSlider.Visible=vis3;
                this.SlopeThresholdSlider.Visible=vis3;
                this.MaxWindowRadiusSlider.Visible=vis3;

                this.GridResolutionLabel.Visible=vis3;
                this.ElevationThresholdLabel.Visible=vis3;
                this.SlopeThresholdLabel.Visible=vis3;
                this.MaxWindowRadiusLabel.Visible=vis3;

                this.GridResolutionDisplay.Visible=vis3;
                this.ElevationThresholdDisplay.Visible=vis3;
                this.SlopeThresholdDisplay.Visible=vis3;
                this.MaxWindowRadiusDisplay.Visible=vis3;
            end

        end

        function viewGroundDataCheckBoxEnabled(this,evt)
            if evt.Source.ViewGroundDataCheckbox.Value
                notify(this,'ViewGroundDataRequest');
            end
        end

        function viewGroundDataCheckBoxDisabled(this,evt)
            evt.Source.ViewGroundDataCheckbox.Value=0;
            notify(this,'StopViewGroundDataRequest');
        end

        function checkboxClickAction(this)
            eventData=this.ViewGroundDataCheckbox.Value;
            if eventData
                notify(this,'CheckBoxSelectedAction')
            else
                notify(this,'CheckBoxUnselectedAction')
            end
        end

    end




    methods
        function set.Visible(this,vis)
            set(this.FigureHandle,'Visible',vis);
        end

        function vis=get.Visible(this)
            vis=this.FigureHandle.Visible;
        end

        function set.EnableMode(this,en)
            set(this.ModeButton,'Enable',en);
        end

        function en=get.EnableMode(this)
            en=this.ModeButton.Enable;
        end

        function set.Mode(this,mode)
            switch mode
            case 'segmentGroundFromLidarData'
                this.ModeInternal='segmentGroundFromLidarData';
                this.ModeButton.Value=getString(message('lidar:lidarViewer:SegmentGroundFromLidarData'));
            case 'pcfitplane'
                this.ModeInternal='pcfitplane';
                this.ModeButton.Value=getString(message('lidar:lidarViewer:PCFitPlane'));
            otherwise
                this.ModeInternal='segmentGroundSMRF';
                this.ModeButton.Value=getString(message('lidar:lidarViewer:SegmentGroundSMRFPlane'));
            end
            setSliderVisibility(this);
        end

        function mode=get.Mode(this)
            mode=this.ModeButton.Enable;
        end
    end

    methods

        function sliderEditboxChanged(this,mode)






            switch mode
            case 'elevationDeltaAngle'
                this.LowValue=this.ElevationAngleDeltaMinValue;
                this.HighValue=this.ElevationAngleDeltaMaxValue;
                this.DefaultValue=this.LowValue;
                index=1;
                textFieldValue=this.ElevationAngleDeltaDisplay.Value;
            case 'initialElevationAngle'
                this.LowValue=this.InitialElevationAngleMinValue;
                this.HighValue=this.InitialElevationAngleMaxValue;
                this.DefaultValue=this.LowValue;
                index=2;
                textFieldValue=this.InitialElevationAngleDisplay.Value;
            case 'maxAngularDistance'
                this.LowValue=this.MaxAngularDistanceMinValue;
                this.HighValue=this.MaxAngularDistanceMaxValue;
                this.DefaultValue=this.MaxAngularDistanceDefaultValue;
                index=3;
                textFieldValue=this.MaxAngularDistanceDisplay.Value;
            case 'maxDistance'
                this.LowValue=this.MaxDistanceMinValue;
                this.HighValue=this.MaxDistanceMaxValue;
                this.DefaultValue=this.MaxDistanceDefaultValue;
                index=4;
                textFieldValue=this.MaxDistanceDisplay.Value;
            case 'gridResolution'
                this.LowValue=this.GridResolutionMinValue;
                this.HighValue=this.GridResolutionMaxValue;
                this.DefaultValue=this.GridResolutionDefaultValue;
                index=5;
                textFieldValue=this.GridResolutionDisplay.Value;
            case 'elevationThreshold'
                this.LowValue=this.ElevationThresholdMinValue;
                this.HighValue=this.ElevationThresholdMaxValue;
                this.DefaultValue=this.ElevationThresholdDefaultValue;
                index=6;
                textFieldValue=this.ElevationThresholdDisplay.Value;
            case 'slopeThreshold'
                this.LowValue=this.SlopeThresholdMinValue;
                this.HighValue=this.SlopeThresholdMaxValue;
                this.DefaultValue=this.SlopeThresholdDefaultValue;
                index=7;
                textFieldValue=this.SlopeThresholdDisplay.Value;
            otherwise
                this.LowValue=this.MaxWindowRadiusMinValue;
                this.HighValue=this.MaxWindowRadiusMaxValue;
                this.DefaultValue=this.MaxWindowRadiusDefaultValue;
                index=8;
                textFieldValue=this.MaxWindowRadiusDisplay.Value;
            end

            textFieldValue=str2double(textFieldValue);

            this.Limit='';
            if textFieldValue>this.HighValue
                this.Limit='higher';
                textFieldValue=this.HighValue;
            elseif textFieldValue<=this.LowValue
                this.Limit='lower';
                textFieldValue=this.LowValue;

            end

            textFieldValue=(textFieldValue-this.LowValue)/...
            (this.HighValue-this.LowValue);

            isValid=isfinite(textFieldValue)&&~isempty(textFieldValue)...
            &&(textFieldValue>=0)&&(textFieldValue<=1);










            if isValid
                switch index
                case 1
                    this.ElevationAngleDeltaSlider.Value=textFieldValue;
                case 2
                    this.InitialElevationAngleSlider.Value=textFieldValue;
                case 3
                    this.MaxAngularDistanceSlider.Value=textFieldValue;
                case 4
                    this.MaxDistanceSlider.Value=textFieldValue;
                case 5
                    this.GridResolutionSlider.Value=textFieldValue;
                case 6
                    this.ElevationThresholdSlider.Value=textFieldValue;
                case 7
                    this.SlopeThresholdSlider.Value=textFieldValue;
                otherwise
                    this.MaxWindowRadiusSlider.Value=textFieldValue;
                end
                settingsChangedCallback(this);
                if~isempty(this.Limit)
                    this.setCurrentValueText(mode);
                end
            else
                this.Limit='invalid';
                this.setCurrentValueText(mode);
            end
        end

        function setCurrentValueText(this,mode)
            switch mode
            case 'elevationDeltaAngle'
                this.ElevationAngleDeltaDisplay.Value=...
                displayValueInEditBox(this,this.ElevationAngleDeltaMaxValue,this.ElevationAngleDeltaMinValue,...
                this.ElevationAngleDeltaSlider.Value);
            case 'initialElevationAngle'
                this.InitialElevationAngleDisplay.Value=...
                displayValueInEditBox(this,this.InitialElevationAngleMaxValue,this.InitialElevationAngleMinValue,...
                this.InitialElevationAngleSlider.Value);
            case 'maxAngularDistance'
                this.MaxAngularDistanceDisplay.Value=...
                displayValueInEditBox(this,this.MaxAngularDistanceMaxValue,this.MaxAngularDistanceMinValue,...
                this.MaxAngularDistanceSlider.Value);
            case 'maxDistance'
                this.MaxDistanceDisplay.Value=...
                displayValueInEditBox(this,this.MaxDistanceMaxValue,this.MaxDistanceMinValue,...
                this.MaxDistanceSlider.Value);
            case 'gridResolution'
                this.GridResolutionDisplay.Value=...
                displayValueInEditBox(this,this.GridResolutionMaxValue,this.GridResolutionMinValue,...
                this.GridResolutionSlider.Value);
            case 'elevationThreshold'
                this.ElevationThresholdDisplay.Value=...
                displayValueInEditBox(this,this.ElevationThresholdMaxValue,this.ElevationThresholdMinValue,...
                this.ElevationThresholdSlider.Value);
            case 'slopeThreshold'
                this.SlopeThresholdDisplay.Value=...
                displayValueInEditBox(this,this.SlopeThresholdMaxValue,this.SlopeThresholdMinValue,...
                this.SlopeThresholdSlider.Value);
            otherwise
                this.MaxWindowRadiusDisplay.Value=...
                displayValueInEditBox(this,this.MaxWindowRadiusMaxValue,this.MaxWindowRadiusMinValue,...
                this.MaxWindowRadiusSlider.Value);
            end
        end

        function displayString=displayValueInEditBox(this,maxValue,minValue,sliderValue)
            limit=this.Limit;
            switch limit
            case 'invalid'
                displayValue=round(minValue+sliderValue*(maxValue-minValue),2);
                displayString=num2str(displayValue);
            case 'higher'


                displayValue=maxValue;
                displayString=num2str(displayValue);
            case 'lower'


                displayValue=minValue;
                displayString=num2str(displayValue);
            end
        end
    end

    methods(Access=protected)
        function closeClicked(this)
            close(this);
            notify(this,'GroundSettingsCloseRequest');
        end
    end
end
