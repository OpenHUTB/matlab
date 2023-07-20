classdef LimitsSettingsDialog<vision.internal.uitools.CloseDlg




    properties
XMinLimits
XMaxLimits
YMinLimits
YMaxLimits
ZMinLimits
ZMaxLimits
PointDimension

XMinSlider
XMaxSlider
YMinSlider
YMaxSlider
ZMinSlider
ZMaxSlider
PointDimensionSlider

XMinLabel
XMaxLabel
YMinLabel
YMaxLabel
ZMinLabel
ZMaxLabel
PointDimensionLabel

XMinDisplay
XMaxDisplay
YMinDisplay
YMaxDisplay
ZMinDisplay
ZMaxDisplay
PointDimensionDisplay

    end

    properties(Constant)

        PointDimensionMinValue=10
        PointDimensionMaxValue=100
        PointDimensionDefaultValue=10;
    end

    properties

ToolName
LowValue
HighValue
DefaultValue
Limit
    end

    properties(Dependent)
Visible
    end

    events
LimitsSettingsChanging
LimitsSettingsChanged
StartUpdatingByLimits
StopUpdatingByLimits
UpdateLimits
DisplayUpdating

XMinDisplayChanged
XMaxDisplayChanged
YMinDisplayChanged
YMaxDisplayChanged
ZMinDisplayChanged
ZMaxDisplayChanged
PointDimensionDisplayChanged
    end

    properties(Access=private)
XMinLabelPos
XMaxLabelPos
YMinLabelPos
YMaxLabelPos
ZMinLabelPos
ZMaxLabelPos
PointDimensionLabelPos

XMinSliderPos
XMaxSliderPos
YMinSliderPos
YMaxSliderPos
ZMinSliderPos
ZMaxSliderPos
PointDimensionSliderPos

XMinDisplayPos
XMaxDisplayPos
YMinDisplayPos
YMaxDisplayPos
ZMinDisplayPos
ZMaxDisplayPos
PointDimensionDisplayPos

XMinListener
XMaxListener
YMinListener
YMaxListener
ZMinListener
ZMaxListener
PointDimensionListener
    end


    methods
        function this=LimitsSettingsDialog(tool,toolName)

            dlgTitle=vision.getMessage('lidar:labeler:LimitsSettingsOneLine');
            this=this@vision.internal.uitools.CloseDlg(tool,dlgTitle);

            this.DlgSize=[300,300];
            this.ToolName=toolName;
            createDialog(this);

            this.Dlg.WindowStyle='modal';

            doLayout(this);

        end

        function update(this,xminlimits,xmaxlimits,yminlimits,ymaxlimits,...
            zminlimits,zmaxlimits,pointsize)
            if~isWebFigure(this)

                this.XMinSlider.Value=xminlimits;
                this.XMaxSlider.Value=xmaxlimits;
                this.YMinSlider.Value=yminlimits;
                this.YMaxSlider.Value=ymaxlimits;
                this.ZMinSlider.Value=zminlimits;
                this.ZMaxSlider.Value=zmaxlimits;
                this.PointDimensionSlider.Value=pointsize;
            else

                if xminlimits>double(this.XMinSlider.Limits(2))
                    xminlimits=double(this.XMinSlider.Limits(2));
                elseif xminlimits<double(this.XMinSlider.Limits(1))
                    xminlimits=double(this.XMinSlider.Limits(1));
                end
                if xmaxlimits>double(this.XMaxSlider.Limits(2))
                    xmaxlimits=double(this.XMaxSlider.Limits(2));
                elseif xmaxlimits<double(this.XMaxSlider.Limits(1))
                    xmaxlimits=double(this.XMaxSlider.Limits(1));
                end
                if yminlimits>double(this.YMinSlider.Limits(2))
                    yminlimits=double(this.YMinSlider.Limits(2));
                elseif yminlimits<double(this.YMinSlider.Limits(1))
                    yminlimits=double(this.YMinSlider.Limits(1));
                end
                if ymaxlimits>double(this.YMaxSlider.Limits(2))
                    ymaxlimits=double(this.YMaxSlider.Limits(2));
                elseif ymaxlimits<double(this.YMaxSlider.Limits(1))
                    ymaxlimits=double(this.YMaxSlider.Limits(1));
                end
                if zminlimits>double(this.ZMinSlider.Limits(2))
                    zminlimits=double(this.ZMinSlider.Limits(2));
                elseif zminlimits<double(this.ZMinSlider.Limits(1))
                    zminlimits=double(this.ZMinSlider.Limits(1));
                end
                if zmaxlimits>double(this.ZMaxSlider.Limits(2))
                    zmaxlimits=double(this.ZMaxSlider.Limits(2));
                elseif zmaxlimits<double(this.ZMaxSlider.Limits(1))
                    zmaxlimits=double(this.ZMaxSlider.Limits(1));
                end
                this.XMinSlider.Value=double(xminlimits);
                this.XMaxSlider.Value=double(xmaxlimits);
                this.YMinSlider.Value=double(yminlimits);
                this.YMaxSlider.Value=double(ymaxlimits);
                this.ZMinSlider.Value=double(zminlimits);
                this.ZMaxSlider.Value=double(zmaxlimits);
                this.PointDimensionSlider.Value=double(pointsize);
            end
        end

        function updateSliderDisplay(this,evt)
            if~isWebFigure(this)
                this.XMinDisplay.String=num2str(evt.XMinLimits,3);
                this.XMaxDisplay.String=num2str(evt.XMaxLimits,3);
                this.YMinDisplay.String=num2str(evt.YMinLimits,3);
                this.YMaxDisplay.String=num2str(evt.YMaxLimits,3);
                this.ZMinDisplay.String=num2str(evt.ZMinLimits,3);
                this.ZMaxDisplay.String=num2str(evt.ZMaxLimits,3);
                this.PointDimensionDisplay.String=num2str(evt.PointDimension,3);
            else
                this.XMinDisplay.Value=round(double(evt.XMinLimits),04);
                this.XMaxDisplay.Value=round(double(evt.XMaxLimits),04);
                this.YMinDisplay.Value=round(double(evt.YMinLimits),04);
                this.YMaxDisplay.Value=round(double(evt.YMaxLimits),04);
                this.ZMinDisplay.Value=round(double(evt.ZMinLimits),04);
                this.ZMaxDisplay.Value=round(double(evt.ZMaxLimits),04);
                this.PointDimensionDisplay.Value=round(double(evt.PointDimension),04);
            end
        end
    end


    methods(Access=protected)
        function doLayout(this,~,~)
            if~isWebFigure(this)
                calculatePositions(this);

                this.XMinSlider=images.internal.app.utilities.Slider(this.Dlg,this.XMinSliderPos);
                this.XMinSlider.Tag='XMinSlider';
                addlistener(this.XMinSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.XMinSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.XMaxSlider=images.internal.app.utilities.Slider(this.Dlg,this.XMaxSliderPos);
                this.XMaxSlider.Tag='XMaxSlider';
                addlistener(this.XMaxSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.XMaxSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.YMinSlider=images.internal.app.utilities.Slider(this.Dlg,this.YMinSliderPos);
                this.YMinSlider.Tag='YMinSlider';
                addlistener(this.YMinSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.YMinSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.YMaxSlider=images.internal.app.utilities.Slider(this.Dlg,this.YMaxSliderPos);
                this.YMaxSlider.Tag='YMaxSlider';
                addlistener(this.YMaxSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.YMaxSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.ZMinSlider=images.internal.app.utilities.Slider(this.Dlg,this.ZMinSliderPos);
                this.ZMinSlider.Tag='ZMinSlider';
                addlistener(this.ZMinSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.ZMinSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.ZMaxSlider=images.internal.app.utilities.Slider(this.Dlg,this.ZMaxSliderPos);
                this.ZMaxSlider.Tag='ZMaxSlider';
                addlistener(this.ZMaxSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.ZMaxSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.PointDimensionSlider=images.internal.app.utilities.Slider(this.Dlg,this.PointDimensionSliderPos);
                this.PointDimensionSlider.Tag='PointDimensionSlider';

                addlistener(this.PointDimensionSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.PointDimensionSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.XMinLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',this.XMinLabelPos,...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('lidar:labeler:XMinLimits')));

                this.XMaxLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',this.XMaxLabelPos,...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('lidar:labeler:XMaxLimits')));

                this.YMinLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',this.YMinLabelPos,...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('lidar:labeler:YMinLimits')));

                this.YMaxLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',this.YMaxLabelPos,...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('lidar:labeler:YMaxLimits')));

                this.ZMinLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',this.ZMinLabelPos,...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('lidar:labeler:ZMinLimits')));

                this.ZMaxLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',this.ZMaxLabelPos,...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('lidar:labeler:ZMaxLimits')));

                this.PointDimensionLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',this.PointDimensionLabelPos,...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('lidar:labeler:PointDimension')));

                this.XMinDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',this.XMinDisplayPos,...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','XMinEditBox');
                this.XMinDisplay.Callback=@(~,~)triggerXMinLimitsChangedEvent(this);

                this.XMaxDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',this.XMaxDisplayPos,...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','XMaxEditBox');
                this.XMaxDisplay.Callback=@(~,~)triggerXMaxLimitsChangedEvent(this);

                this.YMinDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',this.YMinDisplayPos,...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','YMinEditBox');
                this.YMinDisplay.Callback=@(~,~)triggerYMinLimitsChangedEvent(this);

                this.YMaxDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',this.YMaxDisplayPos,...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','YMaxEditBox');
                this.YMaxDisplay.Callback=@(~,~)triggerYMaxLimitsChangedEvent(this);

                this.ZMinDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',this.ZMinDisplayPos,...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','ZMinEditBox');
                this.ZMinDisplay.Callback=@(~,~)triggerZMinLimitsChangedEvent(this);

                this.ZMaxDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',this.ZMaxDisplayPos,...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','ZMaxEditBox');
                this.ZMaxDisplay.Callback=@(~,~)triggerZMaxLimitsChangedEvent(this);

                this.PointDimensionDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',this.PointDimensionDisplayPos,...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','pointDimensionEditBox');
                this.PointDimensionDisplay.Callback=@(~,~)triggerPointDimensionChangedEvent(this);
            else
                calculatePositions(this);

                this.XMinSlider=uislider(this.Dlg,'Position',this.XMinSliderPos,...
                'ValueChanged',@(~,~)settingsChangedCallback(this),...
                'ValueChanging',@(~,~)settingsChangingCallback(this),...
                'MajorTicks',[],'MinorTicks',[],'MajorTickLabels',{});
                this.XMinSlider.Tag='XMinSlider';
                this.XMaxSlider=uislider(this.Dlg,'Position',this.XMaxSliderPos,...
                'ValueChanged',@(~,~)settingsChangedCallback(this),...
                'ValueChanging',@(~,~)settingsChangingCallback(this),...
                'MajorTicks',[],'MinorTicks',[],'MajorTickLabels',{});
                this.XMaxSlider.Tag='XMaxSlider';
                this.YMinSlider=uislider(this.Dlg,'Position',this.YMinSliderPos,...
                'ValueChanged',@(~,~)settingsChangedCallback(this),...
                'ValueChanging',@(~,~)settingsChangingCallback(this),...
                'MajorTicks',[],'MinorTicks',[],'MajorTickLabels',{});
                this.YMinSlider.Tag='YMinSlider';
                this.YMaxSlider=uislider(this.Dlg,'Position',this.YMaxSliderPos,...
                'ValueChanged',@(~,~)settingsChangedCallback(this),...
                'ValueChanging',@(~,~)settingsChangingCallback(this),...
                'MajorTicks',[],'MinorTicks',[],'MajorTickLabels',{});
                this.YMaxSlider.Tag='YMaxSlider';
                this.ZMinSlider=uislider(this.Dlg,'Position',this.ZMinSliderPos,...
                'ValueChanged',@(~,~)settingsChangedCallback(this),...
                'ValueChanging',@(~,~)settingsChangingCallback(this),...
                'MajorTicks',[],'MinorTicks',[],'MajorTickLabels',{});
                this.ZMinSlider.Tag='ZMinSlider';
                this.ZMaxSlider=uislider(this.Dlg,'Position',this.ZMaxSliderPos,...
                'ValueChanged',@(~,~)settingsChangedCallback(this),...
                'ValueChanging',@(~,~)settingsChangingCallback(this),...
                'MajorTicks',[],'MinorTicks',[],'MajorTickLabels',{});
                this.ZMaxSlider.Tag='ZMaxSlider';
                this.PointDimensionSlider=uislider(this.Dlg,'Position',this.PointDimensionSliderPos,...
                'ValueChanged',@(~,~)settingsChangedCallback(this),...
                'ValueChanging',@(~,~)settingsChangingCallback(this),...
                'MajorTicks',[],'MinorTicks',[],'MajorTickLabels',{},...
                'Limits',[10,100]);
                this.PointDimensionSlider.Tag='PointDimensionSlider';

                this.XMinLabel=uilabel(this.Dlg,...
                'HorizontalAlignment','center',...
                'Position',this.XMinLabelPos,...
                'Text',getString(message('lidar:labeler:XMinLimits')));

                this.XMaxLabel=uilabel(this.Dlg,...
                'HorizontalAlignment','center',...
                'Position',this.XMaxLabelPos,...
                'Text',getString(message('lidar:labeler:XMaxLimits')));

                this.YMinLabel=uilabel(this.Dlg,...
                'HorizontalAlignment','center',...
                'Position',this.YMinLabelPos,...
                'Text',getString(message('lidar:labeler:YMinLimits')));

                this.YMaxLabel=uilabel(this.Dlg,...
                'HorizontalAlignment','center',...
                'Position',this.YMaxLabelPos,...
                'Text',getString(message('lidar:labeler:YMaxLimits')));

                this.ZMinLabel=uilabel(this.Dlg,...
                'HorizontalAlignment','center',...
                'Position',this.ZMinLabelPos,...
                'Text',getString(message('lidar:labeler:ZMinLimits')));

                this.ZMaxLabel=uilabel(this.Dlg,...
                'HorizontalAlignment','center',...
                'Position',this.ZMaxLabelPos,...
                'Text',getString(message('lidar:labeler:ZMaxLimits')));

                this.PointDimensionLabel=uilabel(this.Dlg,...
                'HorizontalAlignment','center',...
                'Position',this.PointDimensionLabelPos,...
                'Text',getString(message('lidar:labeler:PointDimension')));

                this.XMinDisplay=uieditfield(this.Dlg,...
                'numeric',...
                'HorizontalAlignment','center',...
                'Position',this.XMinDisplayPos,...
                'ValueChangedFcn',@(~,~)triggerXMinLimitsChangedEvent(this));
                this.XMinDisplay.Tag='XMinEditBox';

                this.XMaxDisplay=uieditfield(this.Dlg,...
                'numeric',...
                'HorizontalAlignment','center',...
                'Position',this.XMaxDisplayPos,...
                'ValueChangedFcn',@(~,~)triggerXMaxLimitsChangedEvent(this));
                this.XMaxDisplay.Tag='XMaxEditBox';

                this.YMinDisplay=uieditfield(this.Dlg,...
                'numeric',...
                'HorizontalAlignment','center',...
                'Position',this.YMinDisplayPos,...
                'ValueChangedFcn',@(~,~)triggerYMinLimitsChangedEvent(this));
                this.YMinDisplay.Tag='YMinEditBox';

                this.YMaxDisplay=uieditfield(this.Dlg,...
                'numeric',...
                'HorizontalAlignment','center',...
                'Position',this.YMaxDisplayPos,...
                'ValueChangedFcn',@(~,~)triggerYMaxLimitsChangedEvent(this));
                this.YMaxDisplay.Tag='YMaxEditBox';

                this.ZMinDisplay=uieditfield(this.Dlg,...
                'numeric',...
                'HorizontalAlignment','center',...
                'Position',this.ZMinDisplayPos,...
                'ValueChangedFcn',@(~,~)triggerZMinLimitsChangedEvent(this));
                this.ZMinDisplay.Tag='ZMinEditBox';

                this.ZMaxDisplay=uieditfield(this.Dlg,...
                'numeric',...
                'HorizontalAlignment','center',...
                'Position',this.ZMaxDisplayPos,...
                'ValueChangedFcn',@(~,~)triggerZMaxLimitsChangedEvent(this));
                this.ZMaxDisplay.Tag='ZMaxEditBox';

                this.PointDimensionDisplay=uieditfield(this.Dlg,...
                'numeric',...
                'HorizontalAlignment','center',...
                'Position',this.PointDimensionDisplayPos,...
                'ValueChangedFcn',@(~,~)triggerPointDimensionChangedEvent(this));
                this.PointDimensionDisplay.Tag='pointDimensionEditBox';
            end

            addlistener(this,'UpdateLimits',@(src,evt)viewUpdatedDisplay(this));


            function calculatePositions(this)
                if~isWebFigure(this)
                    width=(this.DlgSize(1)/2)-(2.5*this.ButtonHalfSpace);
                    height=this.ButtonSize(2);

                    subtractForDisplay=20;

                    this.XMinLabelPos=[this.ButtonHalfSpace,(7*height)+(7*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.XMaxLabelPos=[this.ButtonHalfSpace,(6*height)+(6*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.YMinLabelPos=[this.ButtonHalfSpace,(5*height)+(5*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.YMaxLabelPos=[this.ButtonHalfSpace,(4*height)+(4*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.ZMinLabelPos=[this.ButtonHalfSpace,(3*height)+(3*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.ZMaxLabelPos=[this.ButtonHalfSpace,(2*height)+(2*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.PointDimensionLabelPos=[this.ButtonHalfSpace,(height)+(this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];

                    this.XMinSliderPos=[width-subtractForDisplay,(8*height)+(7*this.ButtonHalfSpace)+8,width-subtractForDisplay,height];
                    this.XMaxSliderPos=[width-subtractForDisplay,(7*height)+(6*this.ButtonHalfSpace)+8,width-subtractForDisplay,height];
                    this.YMinSliderPos=[width-subtractForDisplay,(6*height)+(5*this.ButtonHalfSpace)+8,width-subtractForDisplay,height];
                    this.YMaxSliderPos=[width-subtractForDisplay,(5*height)+(4*this.ButtonHalfSpace)+8,width-subtractForDisplay,height];
                    this.ZMinSliderPos=[width-subtractForDisplay,(4*height)+(3*this.ButtonHalfSpace)+8,width-subtractForDisplay,height];
                    this.ZMaxSliderPos=[width-subtractForDisplay,(3*height)+(2*this.ButtonHalfSpace)+8,width-subtractForDisplay,height];
                    this.PointDimensionSliderPos=[width-subtractForDisplay,(2*height)+(this.ButtonHalfSpace)+8,width-subtractForDisplay,height];

                    this.XMinDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(8*height)+(7*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.XMaxDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(7*height)+(6*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.YMinDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(6*height)+(5*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.YMaxDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(5*height)+(4*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.ZMinDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(4*height)+(3*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.ZMaxDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(3*height)+(2*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.PointDimensionDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(2*height)+(this.ButtonHalfSpace),(3*subtractForDisplay),height];
                else
                    width=(this.DlgSize(1)/2)-(2.5*this.ButtonHalfSpace);
                    height=this.ButtonSize(2);

                    subtractForDisplay=20;

                    this.XMinLabelPos=[this.ButtonHalfSpace,(7*height)+(7*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.XMaxLabelPos=[this.ButtonHalfSpace,(6*height)+(6*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.YMinLabelPos=[this.ButtonHalfSpace,(5*height)+(5*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.YMaxLabelPos=[this.ButtonHalfSpace,(4*height)+(4*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.ZMinLabelPos=[this.ButtonHalfSpace,(3*height)+(3*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.ZMaxLabelPos=[this.ButtonHalfSpace,(2*height)+(2*this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];
                    this.PointDimensionLabelPos=[this.ButtonHalfSpace,(height)+(this.ButtonHalfSpace),(2*this.ButtonHalfSpace)+subtractForDisplay,2*height];

                    this.XMinSliderPos=[width-subtractForDisplay,(8*height)+(7*this.ButtonHalfSpace)+8,width-subtractForDisplay,3];
                    this.XMaxSliderPos=[width-subtractForDisplay,(7*height)+(6*this.ButtonHalfSpace)+8,width-subtractForDisplay,3];
                    this.YMinSliderPos=[width-subtractForDisplay,(6*height)+(5*this.ButtonHalfSpace)+8,width-subtractForDisplay,3];
                    this.YMaxSliderPos=[width-subtractForDisplay,(5*height)+(4*this.ButtonHalfSpace)+8,width-subtractForDisplay,3];
                    this.ZMinSliderPos=[width-subtractForDisplay,(4*height)+(3*this.ButtonHalfSpace)+8,width-subtractForDisplay,3];
                    this.ZMaxSliderPos=[width-subtractForDisplay,(3*height)+(2*this.ButtonHalfSpace)+8,width-subtractForDisplay,3];
                    this.PointDimensionSliderPos=[width-subtractForDisplay,(2*height)+(this.ButtonHalfSpace)+8,width-subtractForDisplay,3];

                    this.XMinDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(8*height)+(7*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.XMaxDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(7*height)+(6*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.YMinDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(6*height)+(5*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.YMaxDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(5*height)+(4*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.ZMinDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(4*height)+(3*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.ZMaxDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(3*height)+(2*this.ButtonHalfSpace),(3*subtractForDisplay),height];
                    this.PointDimensionDisplayPos=[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(2*height)+(this.ButtonHalfSpace),(3*subtractForDisplay),height];
                end
            end
        end
    end

    methods
        function triggerXMinLimitsChangedEvent(this)
            notify(this,'XMinDisplayChanged');
        end

        function triggerXMaxLimitsChangedEvent(this)
            notify(this,'XMaxDisplayChanged');
        end

        function triggerYMinLimitsChangedEvent(this)
            notify(this,'YMinDisplayChanged');
        end

        function triggerYMaxLimitsChangedEvent(this)
            notify(this,'YMaxDisplayChanged');
        end

        function triggerZMinLimitsChangedEvent(this)
            notify(this,'ZMinDisplayChanged');
        end

        function triggerZMaxLimitsChangedEvent(this)
            notify(this,'ZMaxDisplayChanged');
        end

        function triggerPointDimensionChangedEvent(this)
            notify(this,'PointDimensionDisplayChanged');
        end

        function viewUpdatedDisplay(this)
            notify(this,'startUpdatingByLimits');
        end
    end

    methods
        function settingsChangedCallback(this)
            if~isWebFigure(this)
                eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(true,...
                this.XMinSlider.Value,...
                this.XMaxSlider.Value,...
                this.YMinSlider.Value,...
                this.YMaxSlider.Value,...
                this.ZMinSlider.Value,...
                this.ZMaxSlider.Value,...
                this.PointDimensionSlider.Value);
            else
                eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(true,...
                this.XMinSlider.Value,...
                this.XMaxSlider.Value,...
                this.YMinSlider.Value,...
                this.YMaxSlider.Value,...
                this.ZMinSlider.Value,...
                this.ZMaxSlider.Value,...
                this.PointDimensionSlider.Value);
            end
            notify(this,'LimitsSettingsChanged',eventData);
        end

        function settingsChangingCallback(this)
            if~isWebFigure(this)
                eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(true,...
                this.XMinSlider.Value,...
                this.XMaxSlider.Value,...
                this.YMinSlider.Value,...
                this.YMaxSlider.Value,...
                this.ZMinSlider.Value,...
                this.ZMaxSlider.Value,...
                this.PointDimensionSlider.Value);
            else
                eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(true,...
                this.XMinSlider.Value,...
                this.XMaxSlider.Value,...
                this.YMinSlider.Value,...
                this.YMaxSlider.Value,...
                this.ZMinSlider.Value,...
                this.ZMaxSlider.Value,...
                this.PointDimensionSlider.Value);
            end
            notify(this,'LimitsSettingsChanging',eventData);
        end
    end

    methods
        function set.Visible(this,vis)
            set(this.Dlg,'Visible',vis);
        end

        function vis=get.Visible(this)
            vis=this.Dlg.Visible;
        end

        function tf=isWebFigure(this)
            tf=vision.internal.labeler.jtfeature('UseAppContainer');
        end
    end
end