classdef GroundSettingsDialog<vision.internal.uitools.CloseDlg




    properties


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
    end

    properties(Dependent)
Visible
EnableMode
Mode
    end

    events
GroundSettingsChanging
GroundSettingsChanged

ElevationAngleDeltaChanged
InitialElevationAngleChanged
MaxAngularDistanceChanged
MaxDistanceChanged
GridResolutionChanged
ElevationThresholdChanged
SlopeThresholdChanged
MaxWindowRadiusChanged
    end

    properties(Access=private)
Size
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
        ButtonhalfSpace=15;
        ModeInternal='segmentGroundFromLidarData';

    end


    methods

        function this=GroundSettingsDialog(tool,toolName)

            dlgTitle=vision.getMessage('vision:labeler:LidarHideGroundOneLine');

            this=this@vision.internal.uitools.CloseDlg(tool,dlgTitle);

            this.DlgSize=[400,210];
            this.ToolName=toolName;
            createDialog(this);

            this.Dlg.WindowStyle='modal';
            doLayout(this);

        end

        function update(this,mode,elevang,initang,maxdist,maxang)

            this.ElevationAngleDeltaSlider.Value=elevang;
            this.InitialElevationAngleSlider.Value=initang;


            this.MaxDistanceSlider.Value=maxdist;
            this.MaxAngularDistanceSlider.Value=maxang;

            this.Mode=mode;
        end

        function updateWithLTlicense(this,mode,elevang,initang,maxdist,maxang,gridres,...
            elevthres,slopethres,maxradius)

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

            isLTLicensePresent=checkForLidarLicense();
            if useAppContainer(this)
                this.ElevationAngleDeltaDisplay.Value=num2str(evt.ElevationAngleDelta,3);
                this.InitialElevationAngleDisplay.Value=num2str(evt.InitialElevationAngle,3);
                this.MaxDistanceDisplay.Value=num2str(evt.MaxDistance,3);
                this.MaxAngularDistanceDisplay.Value=num2str(evt.MaxAngularDistance,3);
                if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                    this.GridResolutionDisplay.Value=num2str(evt.GridResolution,3);
                    this.ElevationThresholdDisplay.Value=num2str(evt.ElevationThreshold,3);
                    this.SlopeThresholdDisplay.Value=num2str(evt.SlopeThreshold,3);
                    this.MaxWindowRadiusDisplay.Value=num2str(floor(evt.MaxWindowRadius));
                end
            else
                this.ElevationAngleDeltaDisplay.String=num2str(evt.ElevationAngleDelta,3);
                this.InitialElevationAngleDisplay.String=num2str(evt.InitialElevationAngle,3);
                this.MaxDistanceDisplay.String=num2str(evt.MaxDistance,3);
                this.MaxAngularDistanceDisplay.String=num2str(evt.MaxAngularDistance,3);
                if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                    this.GridResolutionDisplay.String=num2str(evt.GridResolution,3);
                    this.ElevationThresholdDisplay.String=num2str(evt.ElevationThreshold,3);
                    this.SlopeThresholdDisplay.String=num2str(evt.SlopeThreshold,3);
                    this.MaxWindowRadiusDisplay.String=num2str(floor(evt.MaxWindowRadius));
                end
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

        function resetGridResolutionSliderValue(this,mode)
            switch mode
            case 'gridResolution'
                notify(this,'GridResolutionChanged');
            case 'elevationThreshold'
                notify(this,'ElevationThresholdChanged');
            case 'slopeThreshold'
                notify(this,'SlopeThresholdChanged');
            case 'maxWindowRadius'
                notify(this,'MaxWindowRadiusChanged');
            end
        end

    end


    methods(Access=private)
        function doLayout(this,~,~)
            this.Size=[400,210];
            width=(this.Size(1)/2)-(2.5*this.ButtonHalfSpace);
            height=this.ButtonSize(2);

            subtractForDisplay=20;

            isLTLicensePresent=checkForLidarLicense();
            if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                popupMenuStrings={getString(message('vision:labeler:SegmentGroundFromLidarData')),...
                getString(message('vision:labeler:PCFitPlane')),...
                getString(message('vision:labeler:SegmentGroundSMRFPlane'))};
            else
                popupMenuStrings={getString(message('vision:labeler:SegmentGroundFromLidarData')),...
                getString(message('vision:labeler:PCFitPlane'))};
            end

            if useAppContainer(this)
                this.ModeButton=uidropdown(this.Dlg,'Items',popupMenuStrings,...
                'Position',[this.ButtonhalfSpace,(5*height)+(5*this.ButtonhalfSpace),width,height]);
                this.ModeButton.ValueChangedFcn=@(~,~)modeChangedCallback(this);

                this.SegmentLidarLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:SegmentGroundFromLidarDataDesc')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,(3*height)+(4*this.ButtonhalfSpace),this.Size(1)-(2*this.ButtonhalfSpace),2*height]);

                this.PCFitPlaneLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:PCFitPlaneDesc')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,(3*height)+(4*this.ButtonhalfSpace),this.Size(1)-(2*this.ButtonhalfSpace),2*height]);


                this.ElevationAngleDeltaSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width-subtractForDisplay,(3*height)+(2*this.ButtonhalfSpace)+5,width-subtractForDisplay,3]);
                this.ElevationAngleDeltaSlider.Tag='elevationSlider';
                addlistener(this.ElevationAngleDeltaSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.ElevationAngleDeltaSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));
                this.InitialElevationAngleSlider=uislider(this.Dlg,'Limits',[0,1],'MinorTicks',[],'Position',[width-subtractForDisplay,height+(2*this.ButtonhalfSpace)+5,width-subtractForDisplay,3],'MajorTicks',[]);
                this.InitialElevationAngleSlider.Tag='initElevationSlider';
                addlistener(this.InitialElevationAngleSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.InitialElevationAngleSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));

                this.ElevationAngleDeltaLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:ElevationAngleDelta')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,(2*height)+(3*this.ButtonhalfSpace),0.75*width,height]);

                this.InitialElevationAngleLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:InitialElevationAngle')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,height+(2*this.ButtonhalfSpace),0.75*width,height]);

                this.ElevationAngleDeltaDisplay=uieditfield(this.Dlg,'Position',...
                [(2*width)+(2*this.ButtonhalfSpace)-subtractForDisplay,(2*height)+(3*this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                'Tag','elevationEditbox','FontSize',12);
                this.ElevationAngleDeltaDisplay.ValueChangedFcn=...
                @(~,~)triggerElevationAngleEditBoxChangeEvent(this);

                this.InitialElevationAngleDisplay=uieditfield(this.Dlg,'Position',...
                [(2*width)+(2*this.ButtonhalfSpace)-subtractForDisplay,height+(2*this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                'Tag','initElevationEditBox');
                this.InitialElevationAngleDisplay.ValueChangedFcn=...
                @(~,~)triggerInitialElevationAngleChangeEvent(this);



                this.MaxDistanceSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width,(height)+(4.8*this.ButtonhalfSpace)+5,width-2*subtractForDisplay,3]);
                this.MaxDistanceSlider.Tag='maxDistanceSlider';
                addlistener(this.MaxDistanceSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.MaxDistanceSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));
                this.MaxAngularDistanceSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width,(height)+(2.2*this.ButtonhalfSpace)+5,width-2*subtractForDisplay,3]);
                this.MaxAngularDistanceSlider.Tag='maxAngularDistSlider';
                addlistener(this.MaxAngularDistanceSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.MaxAngularDistanceSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));

                this.MaxDistanceLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:MaxDistance')),...
                'WordWrap','on','Position',...
                [1.7*this.ButtonhalfSpace,(2.2*height)+(3*this.ButtonhalfSpace),0.6*width,height],'FontSize',12);

                this.MaxAngularDistanceLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:MaxAngularDistance')),...
                'WordWrap','on','Position',...
                [1.5*this.ButtonhalfSpace,(1.7*height)+(this.ButtonhalfSpace),0.75*width,height],'FontSize',12);

                this.MaxDistanceDisplay=uieditfield(this.Dlg,'Position',...
                [(2*width)+(this.ButtonhalfSpace)-2*subtractForDisplay,(2.1*height)+(3*this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                'FontSize',12,'Tag','maxDistEditBox');
                this.MaxDistanceDisplay.ValueChangedFcn=@(~,~)triggerMaxDistanceChangedEvent(this);


                this.MaxAngularDistanceDisplay=uieditfield(this.Dlg,'Position',...
                [(2*width)+(this.ButtonhalfSpace)-2*subtractForDisplay,(1.9*height)+(this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                'FontSize',12,'Tag','maxAngularDistEditBox');
                this.MaxAngularDistanceDisplay.ValueChangedFcn=@(~,~)triggerMaxAngularDistanceChangedEvent(this);

                if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent

                    this.SegmentGroundSMRFLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:SegmentGroundSMRFDesc')),...
                    'WordWrap','on','FontSize',12,'Position',...
                    [this.ButtonhalfSpace,((5*height)+(3*this.ButtonhalfSpace)-5),this.Size(1)-(2*this.ButtonhalfSpace),2*height]);

                    this.GridResolutionSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width,((4*height)+(3*this.ButtonhalfSpace)+2),width-2*subtractForDisplay,3]);
                    this.GridResolutionSlider.Tag='gridResolutionSlider';
                    addlistener(this.GridResolutionSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                    addlistener(this.GridResolutionSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));
                    this.ElevationThresholdSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width,(5*height),width-2*subtractForDisplay,3]);
                    this.ElevationThresholdSlider.Tag='elevationThresholdSlider';
                    addlistener(this.ElevationThresholdSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                    addlistener(this.ElevationThresholdSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));
                    this.SlopeThresholdSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width,(3*height)+10,width-2*subtractForDisplay,3]);
                    this.SlopeThresholdSlider.Tag='slopeThresholdSlider';
                    addlistener(this.SlopeThresholdSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                    addlistener(this.SlopeThresholdSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));
                    this.MaxWindowRadiusSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width,(2*height)+5,width-2*subtractForDisplay,3]);
                    this.MaxWindowRadiusSlider.Tag='maxWindowRadiusSlider';
                    addlistener(this.MaxWindowRadiusSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                    addlistener(this.MaxWindowRadiusSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));

                    this.GridResolutionLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:GridResolution')),...
                    'WordWrap','on','FontSize',12,'Position',...
                    [(height+this.ButtonhalfSpace),(6*height),0.75*width,height]);

                    this.ElevationThresholdLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:ElevationThreshold')),...
                    'WordWrap','on','FontSize',12,'Position',...
                    [(height+this.ButtonhalfSpace),(6*this.ButtonhalfSpace)+2,0.75*width,height]);

                    this.SlopeThresholdLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:SlopeThreshold')),...
                    'WordWrap','on','FontSize',12,'Position',...
                    [(height+this.ButtonhalfSpace),(3*height)+2,0.75*width,height]);

                    this.MaxWindowRadiusLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:MaxWindowRadius')),...
                    'WordWrap','on','FontSize',12,'Position',...
                    [(height+this.ButtonhalfSpace),(2*this.ButtonhalfSpace)+5,0.75*width,height]);

                    this.GridResolutionDisplay=uieditfield(this.Dlg,'Position',...
                    [(2*width)+(this.ButtonhalfSpace)-subtractForDisplay,(6*height),(3*subtractForDisplay),height],...
                    'Tag','gridResEditBox','FontSize',12);
                    this.GridResolutionDisplay.ValueChangedFcn=@(~,~)triggerGridResolutionChangedEvent(this);

                    this.ElevationThresholdDisplay=uieditfield(this.Dlg,'Position',...
                    [(2*width)+(this.ButtonhalfSpace)-subtractForDisplay,(6*this.ButtonhalfSpace)+2,(3*subtractForDisplay),height],...
                    'Tag','eleThreEditBox','FontSize',12);
                    this.ElevationThresholdDisplay.ValueChangedFcn=@(~,~)triggerElevationThresholdChangedEvent(this);

                    this.SlopeThresholdDisplay=uieditfield(this.Dlg,'Position',...
                    [(2*width)+(this.ButtonhalfSpace)-subtractForDisplay,(3*height)+3,(3*subtractForDisplay),height],...
                    'Tag','slopeThreEditBox','FontSize',12);
                    this.SlopeThresholdDisplay.ValueChangedFcn=@(~,~)triggerSlopeThresholdChangedEvent(this);

                    this.MaxWindowRadiusDisplay=uieditfield(this.Dlg,'Position',...
                    [(2*width)+(this.ButtonhalfSpace)-subtractForDisplay,(height)+(this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                    'Tag','maxRadiusEditBox','FontSize',12);
                    this.MaxWindowRadiusDisplay.ValueChangedFcn=@(~,~)triggerMaxWindowRadiusChangedEvent(this);
                end
            else

                this.ModeButton=uicontrol('Parent',this.Dlg,...
                'Style','popupmenu',...
                'Callback',@(~,~)modeChangedCallback(this),...
                'Position',[this.ButtonHalfSpace,(5*height)+(5*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,...
                'String',popupMenuStrings);

                this.SegmentLidarLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',[this.ButtonHalfSpace,(3*height)+(4*this.ButtonHalfSpace),this.DlgSize(1)-(2*this.ButtonHalfSpace),2*height],...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('vision:labeler:SegmentGroundFromLidarDataDesc')));

                this.PCFitPlaneLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',[this.ButtonHalfSpace,(3*height)+(4*this.ButtonHalfSpace),this.DlgSize(1)-(2*this.ButtonHalfSpace),2*height],...
                'FontUnits','normalized','FontSize',0.3,'Visible','off',...
                'String',getString(message('vision:labeler:PCFitPlaneDesc')));


                this.ElevationAngleDeltaSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(2*height)+(3*this.ButtonHalfSpace)+5,width-subtractForDisplay,height]);
                this.ElevationAngleDeltaSlider.Tag='elevationSlider';
                addlistener(this.ElevationAngleDeltaSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.ElevationAngleDeltaSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));
                this.InitialElevationAngleSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),height+(2*this.ButtonHalfSpace)+5,width-subtractForDisplay,height]);
                this.InitialElevationAngleSlider.Tag='initElevationSlider';
                addlistener(this.InitialElevationAngleSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.InitialElevationAngleSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.ElevationAngleDeltaLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,(2*height)+(3*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:ElevationAngleDelta')));

                this.InitialElevationAngleLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,height+(2*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:InitialElevationAngle')));

                this.ElevationAngleDeltaDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(2*height)+(3*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','elevationEditbox');

                this.ElevationAngleDeltaDisplay.Callback=...
                @(~,~)triggerElevationAngleEditBoxChangeEvent(this);

                this.InitialElevationAngleDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,height+(2*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','initElevationEditBox');
                this.InitialElevationAngleDisplay.Callback=...
                @(~,~)triggerInitialElevationAngleChangeEvent(this);


                this.MaxDistanceSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(2*height)+(3*this.ButtonHalfSpace)+5,width-subtractForDisplay,height]);
                this.MaxDistanceSlider.Tag='maxDistanceSlider';
                addlistener(this.MaxDistanceSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.MaxDistanceSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));
                this.MaxAngularDistanceSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),height+(2*this.ButtonHalfSpace)+5,width-subtractForDisplay,height]);
                this.MaxAngularDistanceSlider.Tag='maxAngularDistSlider';
                addlistener(this.MaxAngularDistanceSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.MaxAngularDistanceSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.MaxDistanceLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,(2*height)+(3*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:MaxDistance')));

                this.MaxAngularDistanceLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,height+(2*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:MaxAngularDistance')));

                this.MaxDistanceDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(2*height)+(3*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','maxDistEditBox');
                this.MaxDistanceDisplay.Callback=@(~,~)triggerMaxDistanceChangedEvent(this);

                this.MaxAngularDistanceDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,height+(2*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','maxAngularEditBox');
                this.MaxAngularDistanceDisplay.Callback=@(~,~)triggerMaxAngularDistanceChangedEvent(this);

                if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent

                    this.SegmentGroundSMRFLabel=uicontrol('Parent',this.Dlg,...
                    'Style','text',...
                    'HorizontalAlignment','left',...
                    'Position',[this.ButtonHalfSpace,(3*height)+(4*this.ButtonHalfSpace),this.DlgSize(1)-(2*this.ButtonHalfSpace),2*height],...
                    'FontUnits','normalized','FontSize',0.3,'Visible','off',...
                    'String',getString(message('vision:labeler:SegmentGroundSMRFDesc')));

                    this.GridResolutionSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(5*height)+(this.ButtonHalfSpace),width-subtractForDisplay,height]);
                    this.GridResolutionSlider.Tag='gridResolutionSlider';
                    addlistener(this.GridResolutionSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                    addlistener(this.GridResolutionSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));
                    this.ElevationThresholdSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(6*this.ButtonHalfSpace)+2,width-subtractForDisplay,height]);
                    this.ElevationThresholdSlider.Tag='elevationThresholdSlider';
                    addlistener(this.ElevationThresholdSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                    addlistener(this.ElevationThresholdSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));
                    this.SlopeThresholdSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(height)+(3*this.ButtonHalfSpace)+2,width-subtractForDisplay,height]);
                    this.SlopeThresholdSlider.Tag='slopeThresholdSlider';
                    addlistener(this.SlopeThresholdSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                    addlistener(this.SlopeThresholdSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));
                    this.MaxWindowRadiusSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(2*height)+2,width-subtractForDisplay,height]);
                    this.MaxWindowRadiusSlider.Tag='maxWindowRadiusSlider';
                    addlistener(this.MaxWindowRadiusSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                    addlistener(this.MaxWindowRadiusSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                    this.GridResolutionLabel=uicontrol('Parent',this.Dlg,...
                    'Style','text',...
                    'HorizontalAlignment','right',...
                    'Position',[(this.ButtonHalfSpace),((height)+(6*this.ButtonHalfSpace)+2),width,height],...
                    'FontUnits','normalized','FontSize',0.6,'String',...
                    getString(message('vision:labeler:GridResolution')));

                    this.ElevationThresholdLabel=uicontrol('Parent',this.Dlg,...
                    'Style','text',...
                    'HorizontalAlignment','right',...
                    'Position',[this.ButtonHalfSpace,((2*height)+(3*this.ButtonHalfSpace)+2),width,height],...
                    'FontUnits','normalized','FontSize',0.6,'String',...
                    getString(message('vision:labeler:ElevationThreshold')));

                    this.SlopeThresholdLabel=uicontrol('Parent',this.Dlg,...
                    'Style','text',...
                    'HorizontalAlignment','right',...
                    'Position',[this.ButtonHalfSpace,(3*height)+2,width,height],...
                    'FontUnits','normalized','FontSize',0.6,'String',...
                    getString(message('vision:labeler:SlopeThreshold')));

                    this.MaxWindowRadiusLabel=uicontrol('Parent',this.Dlg,...
                    'Style','text',...
                    'HorizontalAlignment','right',...
                    'Position',[this.ButtonHalfSpace,((height)+(this.ButtonHalfSpace)+2),width,height],...
                    'FontUnits','normalized','FontSize',0.6,'String',...
                    getString(message('vision:labeler:MaxWindowRadius')));

                    this.GridResolutionDisplay=uicontrol('Parent',this.Dlg,...
                    'Style','edit',...
                    'HorizontalAlignment','left',...
                    'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(5*height)+(this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                    'FontUnits','normalized','FontSize',0.6,'String',...
                    '','Tag','gridResEditBox');
                    this.GridResolutionDisplay.Callback=@(~,~)triggerGridResolutionChangedEvent(this);

                    this.ElevationThresholdDisplay=uicontrol('Parent',this.Dlg,...
                    'Style','edit',...
                    'HorizontalAlignment','left',...
                    'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(6*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                    'FontUnits','normalized','FontSize',0.6,'String',...
                    '','Tag','eleThreEditBox');
                    this.ElevationThresholdDisplay.Callback=@(~,~)triggerElevationThresholdChangedEvent(this);

                    this.SlopeThresholdDisplay=uicontrol('Parent',this.Dlg,...
                    'Style','edit',...
                    'HorizontalAlignment','left',...
                    'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(height)+(3*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                    'FontUnits','normalized','FontSize',0.6,'String',...
                    '','Tag','slopeThreEditBox');
                    this.SlopeThresholdDisplay.Callback=@(~,~)triggerSlopeThresholdChangedEvent(this);

                    this.MaxWindowRadiusDisplay=uicontrol('Parent',this.Dlg,...
                    'Style','edit',...
                    'HorizontalAlignment','left',...
                    'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(2*height),(3*subtractForDisplay),height],...
                    'FontUnits','normalized','FontSize',0.6,'String',...
                    '','Tag','maxRadiusEditBox');
                    this.MaxWindowRadiusDisplay.Callback=@(~,~)triggerMaxWindowRadiusChangedEvent(this);
                end

            end

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
            if useAppContainer(this)
                switch this.ModeButton.Value
                case getString(message('vision:labeler:SegmentGroundFromLidarData'))
                    this.ModeInternal='segmentGroundFromLidarData';
                case getString(message('vision:labeler:PCFitPlane'))
                    this.ModeInternal='pcfitplane';
                otherwise
                    this.ModeInternal='segmentGroundSMRF';
                end
            else
                switch this.ModeButton.Value
                case 1
                    this.ModeInternal='segmentGroundFromLidarData';
                case 2
                    this.ModeInternal='pcfitplane';
                otherwise
                    this.ModeInternal='segmentGroundSMRF';
                end
            end

            setSliderVisibility(this);
            settingsChangedCallback(this);
        end

        function settingsChangedCallback(this)


            isLTLicensePresent=checkForLidarLicense();
            if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                eventData=driving.internal.groundTruthLabeler.tool.LidarHideGroundEventData(true,...
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
                eventData=driving.internal.groundTruthLabeler.tool.LidarHideGroundEventData(true,...
                this.ModeInternal,this.ElevationAngleDeltaSlider.Value,...
                this.InitialElevationAngleSlider.Value,...
                this.MaxDistanceSlider.Value,...
                [0,0,1],...
                this.MaxAngularDistanceSlider.Value);
            end

            notify(this,'GroundSettingsChanged',eventData);

        end

        function settingsChangingCallback(this)


            isLTLicensePresent=checkForLidarLicense();
            if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                eventData=driving.internal.groundTruthLabeler.tool.LidarHideGroundEventData(true,...
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
                eventData=driving.internal.groundTruthLabeler.tool.LidarHideGroundEventData(true,...
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


            isLTLicensePresent=checkForLidarLicense();
            if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
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

    end

    methods

        function set.Visible(this,vis)
            set(this.Dlg,'Visible',vis);
        end

        function vis=get.Visible(this)
            vis=this.Dlg.Visible;
        end

        function set.EnableMode(this,en)
            set(this.ModeButton,'Enable',en);
        end

        function en=get.EnableMode(this)
            en=this.ModeButton.Enable;
        end

        function set.Mode(this,mode)
            if useAppContainer(this)
                switch mode
                case 'segmentGroundFromLidarData'
                    this.ModeInternal='segmentGroundFromLidarData';
                    this.ModeButton.Value=getString(message('vision:labeler:SegmentGroundFromLidarData'));
                case 'pcfitplane'
                    this.ModeInternal='pcfitplane';
                    this.ModeButton.Value=getString(message('vision:labeler:PCFitPlane'));
                otherwise
                    this.ModeInternal='segmentGroundSMRF';
                    this.ModeButton.Value=getString(message('vision:labeler:SegmentGroundSMRFPlane'));
                end
            else
                switch mode
                case 'segmentGroundFromLidarData'
                    this.ModeInternal='segmentGroundFromLidarData';
                    this.ModeButton.Value=1;
                case 'pcfitplane'
                    this.ModeInternal='pcfitplane';
                    this.ModeButton.Value=2;
                otherwise
                    this.ModeInternal='segmentGroundSMRF';
                    this.ModeButton.Value=3;
                end
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
            case 'initialElevationAngle'
                this.LowValue=this.InitialElevationAngleMinValue;
                this.HighValue=this.InitialElevationAngleMaxValue;
                this.DefaultValue=this.LowValue;
                index=2;
            case 'maxAngularDistance'
                this.LowValue=this.MaxAngularDistanceMinValue;
                this.HighValue=this.MaxAngularDistanceMaxValue;
                this.DefaultValue=this.MaxAngularDistanceDefaultValue;
                index=3;
            case 'maxDistance'
                this.LowValue=this.MaxDistanceMinValue;
                this.HighValue=this.MaxDistanceMaxValue;
                this.DefaultValue=this.MaxDistanceDefaultValue;
                index=4;
            case 'gridResolution'
                this.LowValue=this.GridResolutionMinValue;
                this.HighValue=this.GridResolutionMaxValue;
                this.DefaultValue=this.GridResolutionDefaultValue;
                index=5;
            case 'elevationThreshold'
                this.LowValue=this.ElevationThresholdMinValue;
                this.HighValue=this.ElevationThresholdMaxValue;
                this.DefaultValue=this.ElevationThresholdDefaultValue;
                index=6;
            case 'slopeThreshold'
                this.LowValue=this.SlopeThresholdMinValue;
                this.HighValue=this.SlopeThresholdMaxValue;
                this.DefaultValue=this.SlopeThresholdDefaultValue;
                index=7;
            otherwise
                this.LowValue=this.MaxWindowRadiusMinValue;
                this.HighValue=this.MaxWindowRadiusMaxValue;
                this.DefaultValue=this.MaxWindowRadiusDefaultValue;
                index=8;
            end
            if useAppContainer(this)
                switch mode
                case 'elevationDeltaAngle'
                    textFieldValue=this.ElevationAngleDeltaDisplay.Value;
                case 'initialElevationAngle'
                    textFieldValue=this.InitialElevationAngleDisplay.Value;
                case 'maxAngularDistance'
                    textFieldValue=this.MaxAngularDistanceDisplay.Value;
                case 'maxDistance'
                    textFieldValue=this.MaxDistanceDisplay.Value;
                case 'gridResolution'
                    textFieldValue=this.GridResolutionDisplay.Value;
                case 'elevationThreshold'
                    textFieldValue=this.ElevationThresholdDisplay.Value;
                case 'slopeThreshold'
                    textFieldValue=this.SlopeThresholdDisplay.Value;
                otherwise
                    textFieldValue=this.MaxWindowRadiusDisplay.Value;
                end
                textFieldValue=str2double(textFieldValue);
            else
                switch mode
                case 'elevationDeltaAngle'
                    textFieldValue=str2double(this.ElevationAngleDeltaDisplay.String);
                case 'initialElevationAngle'
                    textFieldValue=str2double(this.InitialElevationAngleDisplay.String);
                case 'maxAngularDistance'
                    textFieldValue=str2double(this.MaxAngularDistanceDisplay.String);
                case 'maxDistance'
                    textFieldValue=str2double(this.MaxDistanceDisplay.String);
                case 'gridResolution'
                    textFieldValue=str2double(this.GridResolutionDisplay.String);
                case 'elevationThreshold'
                    textFieldValue=str2double(this.ElevationThresholdDisplay.String);
                case 'slopeThreshold'
                    textFieldValue=str2double(this.SlopeThresholdDisplay.String);
                otherwise
                    textFieldValue=str2double(this.MaxWindowRadiusDisplay.String);
                end
            end
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
            if useAppContainer(this)
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
            else
                switch mode
                case 'elevationDeltaAngle'
                    this.ElevationAngleDeltaDisplay.String=...
                    displayValueInEditBox(this,this.ElevationAngleDeltaMaxValue,this.ElevationAngleDeltaMinValue,...
                    this.ElevationAngleDeltaSlider.Value);
                case 'initialElevationAngle'
                    this.InitialElevationAngleDisplay.String=...
                    displayValueInEditBox(this,this.InitialElevationAngleMaxValue,this.InitialElevationAngleMinValue,...
                    this.InitialElevationAngleSlider.Value);
                case 'maxAngularDistance'
                    this.MaxAngularDistanceDisplay.String=...
                    displayValueInEditBox(this,this.MaxAngularDistanceMaxValue,this.MaxAngularDistanceMinValue,...
                    this.MaxAngularDistanceSlider.Value);
                case 'maxDistance'
                    this.MaxDistanceDisplay.String=...
                    displayValueInEditBox(this,this.MaxDistanceMaxValue,this.MaxDistanceMinValue,...
                    this.MaxDistanceSlider.Value);
                case 'gridResolution'
                    this.GridResolutionDisplay.String=...
                    displayValueInEditBox(this,this.GridResolutionMaxValue,this.GridResolutionMinValue,...
                    this.GridResolutionSlider.Value);
                case 'elevationThreshold'
                    this.ElevationThresholdDisplay.String=...
                    displayValueInEditBox(this,this.ElevationThresholdMaxValue,this.ElevationThresholdMinValue,...
                    this.ElevationThresholdSlider.Value);
                case 'slopeThreshold'
                    this.SlopeThresholdDisplay.String=...
                    displayValueInEditBox(this,this.SlopeThresholdMaxValue,this.SlopeThresholdMinValue,...
                    this.SlopeThresholdSlider.Value);
                otherwise
                    this.MaxWindowRadiusDisplay.String=...
                    displayValueInEditBox(this,this.MaxWindowRadiusMaxValue,this.MaxWindowRadiusMinValue,...
                    this.MaxWindowRadiusSlider.Value);
                end
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

end

function tf=useAppContainer(~)
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end
function tf=checkForLidarLicense()
    [tf,~]=license('checkout','Lidar_Toolbox');
end