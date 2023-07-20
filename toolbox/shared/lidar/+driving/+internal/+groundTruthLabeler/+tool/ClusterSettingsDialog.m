classdef ClusterSettingsDialog<vision.internal.uitools.CloseDlg




    properties


ModeButton
SegmentLidarLabel
PCSegDistLabel
KMeansLabel


DistanceThresholdSlider
AngleThresholdSlider

DistanceThresholdLabel
AngleThresholdLabel

DistanceThresholdDisplay
AngleThresholdDisplay


MinDistanceSlider
MinDistanceLabel
MinDistanceDisplay


NumClustersSlider
NumClustersLabel
NumClustersDisplay
KMeansNumClustersLabel
KMeansNumClustersText


ViewClustersCheckbox
ViewClustersUnselectedListener
ViewClustersSelectedListener

    end

    properties(Access=private)

        DistanceThresholdMinValue=0
        DistanceThresholdMaxValue=10

        AngleThresholdMinValue=0
        AngleThresholdMaxValue=180

        MinDistanceMinValue=0
        MinDistanceMaxValue=10
        MinDistanceDefaultValue=0.5

        NumClustersMinValue=0
        NumClustersMaxValue=1

LowValue
HighValue
DefaultValue
Limit
    end


    properties(Dependent)
Visible
EnableMode
Mode
    end

    events
ClusterSettingsChanging
ClusterSettingsChanged
StartColoringByClusters
StopColoringByClusters
CheckBoxSelectedAction
CheckBoxUnselectedAction
NumClustersDisplayChanged
DistanceThresholdDisplayChanged
AngleThresholdDisplayChanged
MinDistanceDisplayChanged
    end

    properties(Access=private)
MinDistanceListener
NumClustersListener
AngleThresholdListener
DistanceThresholdListener
    end

    properties(Access=protected)
        ButtonhalfSpace=15;
        ModeInternal='segmentLidarData';

    end


    methods
        function this=ClusterSettingsDialog(tool)

            dlgTitle=vision.getMessage('vision:labeler:LidarClusterDataSettingsOneLine');

            this=this@vision.internal.uitools.CloseDlg(tool,dlgTitle);


            this.DlgSize=[400,210];

            createDialog(this);
            this.Dlg.WindowStyle='modal';

            doLayout(this);

        end

        function update(this,mode,dist,ang,mindist,k)

            this.DistanceThresholdSlider.Value=dist;
            this.AngleThresholdSlider.Value=ang;


            this.MinDistanceSlider.Value=mindist;
            this.NumClustersSlider.Value=k;

            this.Mode=mode;
        end

        function updateSliderDisplay(this,evt)
            if useAppContainer(this)
                this.DistanceThresholdDisplay.Value=num2str(evt.DistanceThreshold,3);
                this.AngleThresholdDisplay.Value=num2str(evt.AngleThreshold,3);
                this.MinDistanceDisplay.Value=num2str(evt.MinDistance,3);
                this.NumClustersDisplay.Value=num2str(evt.NumClusters,3);
            else
                this.DistanceThresholdDisplay.String=num2str(evt.DistanceThreshold,3);
                this.AngleThresholdDisplay.String=num2str(evt.AngleThreshold,3);
                this.MinDistanceDisplay.String=num2str(evt.MinDistance,3);
                this.NumClustersDisplay.String=num2str(evt.NumClusters,3);
            end
        end

        function updateKMeansClusters(this,kMeansNumClusters)
            if~isempty(kMeansNumClusters)&&isvalid(this.Dlg)
                if~useAppContainer
                    this.KMeansNumClustersText.String=num2str(kMeansNumClusters);
                else
                    this.KMeansNumClustersText.Value=num2str(kMeansNumClusters);
                end
            end
        end

    end


    methods(Access=protected)
        function doLayout(this,~,~)

            width=(this.DlgSize(1)/2)-(2.5*this.ButtonHalfSpace);
            height=this.ButtonSize(2);

            subtractForDisplay=20;
            if useAppContainer(this)

                this.ModeButton=uidropdown(this.Dlg,'ValueChangedFcn',@(~,~)modeChangedCallback(this),...
                'Position',[this.ButtonhalfSpace,(5*height)+(5*this.ButtonhalfSpace),1.1*width,height],...
                'Items',{getString(message('vision:labeler:SegmentLidarData')),...
                getString(message('vision:labeler:PCSegDist')),...
                getString(message('vision:labeler:imSegKmeans'))},'FontSize',12,'Value',getString(message('vision:labeler:SegmentLidarData')));

                this.SegmentLidarLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:SegmentLidarDataDesc')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,(3*height)+(4*this.ButtonhalfSpace),this.DlgSize(1)-(2*this.ButtonhalfSpace),2*height]);

                this.PCSegDistLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:PCSegDistDesc')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,(3*height)+(4*this.ButtonhalfSpace),this.DlgSize(1)-(2*this.ButtonhalfSpace),2*height]);


                this.KMeansLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:imSegKmeansDesc')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,(3*height)+(4*this.ButtonhalfSpace),this.DlgSize(1)-(2*this.ButtonhalfSpace),2*height]);

                this.DistanceThresholdSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width-subtractForDisplay,(3*height)+(2*this.ButtonhalfSpace)+5,width-subtractForDisplay,3]);
                this.DistanceThresholdSlider.Tag='distThresholdSlider';
                addlistener(this.DistanceThresholdSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.DistanceThresholdSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));

                this.AngleThresholdSlider=uislider(this.Dlg,'Limits',[0,1],'MinorTicks',[],'Position',[width-subtractForDisplay,height+(2*this.ButtonhalfSpace)+5,width-subtractForDisplay,3],'MajorTicks',[]);
                this.AngleThresholdSlider.Tag='angleThresholdSlider';
                addlistener(this.AngleThresholdSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.AngleThresholdSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));

                this.DistanceThresholdLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:DistanceThreshold')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,(2*height)+(3*this.ButtonhalfSpace),0.75*width,height]);

                this.AngleThresholdLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:AngleThreshold')),...
                'WordWrap','on','FontSize',12,'Position',...
                [this.ButtonhalfSpace,height+(2*this.ButtonhalfSpace),0.75*width,height]);

                this.DistanceThresholdDisplay=uieditfield(this.Dlg,'Position',...
                [(2*width)+(2*this.ButtonhalfSpace)-subtractForDisplay,(2*height)+(3*this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                'Tag','distThresholdEditBox','FontSize',12);
                this.DistanceThresholdDisplay.ValueChangedFcn=@(~,~)triggerDistanceThresholdChangedEvent(this);



                this.AngleThresholdDisplay=uieditfield(this.Dlg,'Position',...
                [(2*width)+(2*this.ButtonhalfSpace)-subtractForDisplay,height+(2*this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                'Tag','angleThresholdEditBox');
                this.AngleThresholdDisplay.ValueChangedFcn=@(~,~)triggerAngleThresholdChangedEvent(this);




                this.MinDistanceSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[width-subtractForDisplay,(height)+(4.5*this.ButtonhalfSpace)+5,width-2*subtractForDisplay,3]);
                this.MinDistanceSlider.Tag='minDistSlider';
                addlistener(this.MinDistanceSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.MinDistanceSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));
                this.NumClustersSlider=uislider(this.Dlg,'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],'Position',[0.35*width,(height)+(4.5*this.ButtonhalfSpace)+5,width-2*subtractForDisplay,3]);
                addlistener(this.NumClustersSlider,'ValueChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.NumClustersSlider,'ValueChanging',@(~,~)settingsChangingCallback(this));

                this.MinDistanceLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:MinDistance')),...
                'WordWrap','on','Position',...
                [2.5*this.ButtonhalfSpace,(2*height)+(3*this.ButtonhalfSpace),0.65*width,height],'FontSize',12);

                this.NumClustersLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:K')),...
                'WordWrap','on','Position',...
                [2*this.ButtonhalfSpace,(2*height)+(3*this.ButtonhalfSpace),0.2*width,height],'FontSize',12);
                this.NumClustersDisplay=uieditfield(this.Dlg,'Position',...
                [(1.2*width)+(0.5*this.ButtonhalfSpace),(2*height)+(3*this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                'FontSize',12,'Tag','kEditBox');
                this.NumClustersDisplay.ValueChangedFcn=@(~,~)triggerNumClustersChangedEvent(this);
                this.NumClustersDisplay.Tooltip=getString(message('vision:labeler:KMeansTooltip'));

                this.KMeansNumClustersLabel=uilabel(this.Dlg,'Text',getString(message('vision:labeler:NumClusters')),...
                'WordWrap','on','Position',...
                [2*this.ButtonhalfSpace,(height)+(1.5*this.ButtonhalfSpace),0.8*width,height],...
                'FontSize',12);

                this.KMeansNumClustersText=uieditfield(this.Dlg,'Position',...
                [(0.75*width)+(2*this.ButtonhalfSpace),(height)+(1.5*this.ButtonhalfSpace),0.33*width,height],...
                'FontSize',12,'FontWeight','Bold','Tag','numClustersEdit');
                this.KMeansNumClustersText.Editable='off';

                this.MinDistanceDisplay=uieditfield(this.Dlg,'Position',...
                [(2*width)+(this.ButtonhalfSpace)-2.5*subtractForDisplay,(2*height)+(3*this.ButtonhalfSpace),(3*subtractForDisplay),height],...
                'FontSize',12,'Tag','minDistEditBox');

                this.MinDistanceDisplay.ValueChangedFcn=@(~,~)triggerMinDistanceChangedEvent(this);



                addlistener(this,'DistanceThresholdDisplayChanged',...
                @(~,~)sliderEditboxModified(this,'distThreshold'));
                addlistener(this,'AngleThresholdDisplayChanged',...
                @(~,~)sliderEditboxModified(this,'angleThreshold'));
                addlistener(this,'MinDistanceDisplayChanged',...
                @(~,~)sliderEditboxModified(this,'minDistance'));
                addlistener(this,'NumClustersDisplayChanged',...
                @(~,~)sliderEditboxModified(this,'kmeansClusters'));


                this.ViewClustersCheckbox=uicheckbox(this.Dlg,'Position',...
                [5*this.ButtonhalfSpace+(10*height),(5*height)+(5*this.ButtonhalfSpace),2*width,height],...
                'FontSize',12,'Text',getString(message('vision:labeler:LidarViewClusters')));
                this.ViewClustersSelectedListener=addlistener(this,'CheckBoxSelectedAction',@(src,evt)viewClustersCheckBoxEnabled(this,evt));
                this.ViewClustersUnselectedListener=addlistener(this,'CheckBoxUnselectedAction',@(src,evt)viewClustersCheckBoxDisabled(this));
                this.ViewClustersCheckbox.ValueChangedFcn=@(~,~)checkboxClickAction(this);
            else

                this.ModeButton=uicontrol('Parent',this.Dlg,...
                'Style','popupmenu',...
                'Callback',@(~,~)modeChangedCallback(this),...
                'Position',[this.ButtonHalfSpace,(5*height)+(5*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                {getString(message('vision:labeler:SegmentLidarData')),...
                getString(message('vision:labeler:PCSegDist')),...
                getString(message('vision:labeler:imSegKmeans'))});

                this.SegmentLidarLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',[this.ButtonHalfSpace,(3*height)+(4*this.ButtonHalfSpace),this.DlgSize(1)-(2*this.ButtonHalfSpace),2*height],...
                'FontUnits','normalized','FontSize',0.3,...
                'String',getString(message('vision:labeler:SegmentLidarDataDesc')));

                this.PCSegDistLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',[this.ButtonHalfSpace,(3*height)+(4*this.ButtonHalfSpace),this.DlgSize(1)-(2*this.ButtonHalfSpace),2*height],...
                'FontUnits','normalized','FontSize',0.3,'Visible','off',...
                'String',getString(message('vision:labeler:PCSegDistDesc')));

                this.KMeansLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'Position',[this.ButtonHalfSpace,(3*height)+(4*this.ButtonHalfSpace),this.DlgSize(1)-(2*this.ButtonHalfSpace),2*height],...
                'FontUnits','normalized','FontSize',0.3,'Visible','off',...
                'String',getString(message('vision:labeler:imSegKmeansDesc')));


                this.DistanceThresholdSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(2*height)+(3*this.ButtonHalfSpace)+5,width-subtractForDisplay,height]);
                this.DistanceThresholdSlider.Tag='distThresholdSlider';
                addlistener(this.DistanceThresholdSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.DistanceThresholdSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));
                this.AngleThresholdSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),height+(2*this.ButtonHalfSpace)+5,width-subtractForDisplay,height]);
                this.AngleThresholdSlider.Tag='angleThresholdSlider';
                addlistener(this.AngleThresholdSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.AngleThresholdSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));

                this.DistanceThresholdLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,(2*height)+(3*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:DistanceThreshold')));

                this.AngleThresholdLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,height+(2*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:AngleThreshold')));

                this.DistanceThresholdDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(2*height)+(3*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','distThresholdEditBox');
                this.DistanceThresholdDisplay.Callback=@(~,~)triggerDistanceThresholdChangedEvent(this);


                this.AngleThresholdDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,height+(2*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','angleThresholdEditBox');
                this.AngleThresholdDisplay.Callback=@(~,~)triggerAngleThresholdChangedEvent(this);


                this.MinDistanceSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(2*height)+(3*this.ButtonHalfSpace)+5,width-subtractForDisplay,height]);
                this.MinDistanceSlider.Tag='minDistSlider';
                addlistener(this.MinDistanceSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.MinDistanceSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));
                this.NumClustersSlider=images.internal.app.utilities.Slider(this.Dlg,[width+(2*this.ButtonHalfSpace),(2*height)+(3*this.ButtonHalfSpace)+5,width-subtractForDisplay,height]);
                addlistener(this.NumClustersSlider,'SliderChanged',@(~,~)settingsChangedCallback(this));
                addlistener(this.NumClustersSlider,'SliderChanging',@(~,~)settingsChangingCallback(this));
                this.MinDistanceLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,(2*height)+(3*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:MinDistance')));

                this.NumClustersLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,(2*height)+(3*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:K')));

                this.NumClustersDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(2*height)+(3*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                "",'Tag','kEditBox');
                this.NumClustersDisplay.Callback=@(~,~)triggerNumClustersChangedEvent(this);
                this.NumClustersDisplay.Tooltip=getString(message('vision:labeler:KMeansTooltip'));

                this.KMeansNumClustersLabel=uicontrol('Parent',this.Dlg,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[this.ButtonHalfSpace,(height)+(1.5*this.ButtonHalfSpace),width,height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:NumClusters')));

                this.KMeansNumClustersText=uicontrol('Parent',this.Dlg,...
                'Style','edit','BackgroundColor',[1,1,1],...
                'HorizontalAlignment','left','ForegroundColor',[1,1,1],...
                'Position',[(width)+(2*this.ButtonHalfSpace),(height)+(1.5*this.ButtonHalfSpace),0.33*width,height],...
                'FontUnits','normalized','FontSize',0.6,'FontWeight','bold','Tag','numClustersEdit');
                this.KMeansNumClustersText.Enable='off';

                this.MinDistanceDisplay=uicontrol('Parent',this.Dlg,...
                'Style','edit',...
                'HorizontalAlignment','left',...
                'Position',[(2*width)+(2*this.ButtonHalfSpace)-subtractForDisplay,(2*height)+(3*this.ButtonHalfSpace),(3*subtractForDisplay),height],...
                'FontUnits','normalized','FontSize',0.6,'String',...
                '','Tag','minDistEditBox');

                this.MinDistanceDisplay.Callback=@(~,~)triggerMinDistanceChangedEvent(this);

                addlistener(this,'DistanceThresholdDisplayChanged',...
                @(~,~)sliderEditboxModified(this,'distThreshold'));
                addlistener(this,'AngleThresholdDisplayChanged',...
                @(~,~)sliderEditboxModified(this,'angleThreshold'));
                addlistener(this,'MinDistanceDisplayChanged',...
                @(~,~)sliderEditboxModified(this,'minDistance'));
                addlistener(this,'NumClustersDisplayChanged',...
                @(~,~)sliderEditboxModified(this,'kmeansClusters'));

                this.ViewClustersCheckbox=uicontrol('Parent',this.Dlg,...
                'Style','checkbox',...
                'Enable','on',...
                'Position',[5*this.ButtonHalfSpace+(10*height),(5*height)+(5*this.ButtonHalfSpace),2*width,height],...
                'Callback',@(~,~)checkboxClickAction(this),...
                'FontUnits','normalized','FontSize',0.6,'String',...
                getString(message('vision:labeler:LidarViewClusters')));


                this.ViewClustersSelectedListener=addlistener(this,'CheckBoxSelectedAction',@(src,evt)viewClustersCheckBoxEnabled(this,evt));
                this.ViewClustersUnselectedListener=addlistener(this,'CheckBoxUnselectedAction',@(src,evt)viewClustersCheckBoxDisabled(this));


            end
        end
        function triggerDistanceThresholdChangedEvent(this)
            notify(this,'DistanceThresholdDisplayChanged');
        end

        function triggerAngleThresholdChangedEvent(this)
            notify(this,'AngleThresholdDisplayChanged');
        end
        function triggerMinDistanceChangedEvent(this)
            notify(this,'MinDistanceDisplayChanged');
        end

        function triggerNumClustersChangedEvent(this)
            notify(this,'NumClustersDisplayChanged');
        end


        function modeChangedCallback(this)
            if useAppContainer(this)
                switch this.ModeButton.Value
                case getString(message('vision:labeler:SegmentLidarData'))
                    this.ModeInternal='segmentLidarData';
                case getString(message('vision:labeler:PCSegDist'))

                    this.ModeInternal='pcsegdist';
                case getString(message('vision:labeler:imSegKmeans'))
                    this.ModeInternal='imsegkmeans';
                end

            else
                switch this.ModeButton.Value
                case 1
                    this.ModeInternal='segmentLidarData';
                case 2
                    this.ModeInternal='pcsegdist';
                case 3
                    this.ModeInternal='imsegkmeans';
                end
            end
            setSliderVisibility(this);
            settingsChangedCallback(this);

        end

        function settingsChangedCallback(this)

            eventData=driving.internal.groundTruthLabeler.tool.LidarClusterEventData(true,...
            this.ModeInternal,this.DistanceThresholdSlider.Value,...
            this.AngleThresholdSlider.Value,...
            this.MinDistanceSlider.Value,...
            this.NumClustersSlider.Value);

            notify(this,'ClusterSettingsChanged',eventData);

        end

        function settingsChangingCallback(this)

            eventData=driving.internal.groundTruthLabeler.tool.LidarClusterEventData(true,...
            this.ModeInternal,this.DistanceThresholdSlider.Value,...
            this.AngleThresholdSlider.Value,...
            this.MinDistanceSlider.Value,...
            this.NumClustersSlider.Value);

            notify(this,'ClusterSettingsChanging',eventData);

        end

        function setSliderVisibility(this)

            switch this.ModeInternal
            case 'segmentLidarData'
                vis1=true;
                vis2=false;
                vis3=false;

            case 'pcsegdist'
                vis1=false;
                vis2=true;
                vis3=false;

            case 'imsegkmeans'
                vis1=false;
                vis2=false;
                vis3=true;

            end


            this.SegmentLidarLabel.Visible=vis1;
            this.DistanceThresholdSlider.Visible=vis1;
            this.AngleThresholdSlider.Visible=vis1;
            this.DistanceThresholdDisplay.Visible=vis1;


            this.DistanceThresholdLabel.Visible=vis1;
            this.AngleThresholdLabel.Visible=vis1;
            this.AngleThresholdDisplay.Visible=vis1;


            this.PCSegDistLabel.Visible=vis2;
            this.MinDistanceSlider.Visible=vis2;
            this.MinDistanceLabel.Visible=vis2;
            this.MinDistanceDisplay.Visible=vis2;


            this.KMeansLabel.Visible=vis3;
            this.NumClustersSlider.Visible=vis3;
            this.NumClustersLabel.Visible=vis3;
            this.NumClustersDisplay.Visible=vis3;
            this.KMeansNumClustersLabel.Visible=vis3;
            this.KMeansNumClustersText.Visible=vis3;
        end

        function viewClustersCheckBoxEnabled(this,evt)
            if evt.Source.ViewClustersCheckbox.Value
                notify(this,'StartColoringByClusters');
            end
        end

        function viewClustersCheckBoxDisabled(this,evt)
            evt.Source.ViewClustersCheckbox.Value=0;
            notify(this,'StopColoringByClusters');
        end

        function checkboxClickAction(this)
            eventData=this.ViewClustersCheckbox.Value;
            if eventData
                notify(this,'CheckBoxSelectedAction')
            else
                notify(this,'CheckBoxUnselectedAction')
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
                case 'segmentLidarData'
                    this.ModeInternal='segmentLidarData';
                    this.ModeButton.Value=getString(message('vision:labeler:SegmentLidarData'));

                case 'pcsegdist'
                    this.ModeInternal='pcsegdist';
                    this.ModeButton.Value=getString(message('vision:labeler:PCSegDist'));

                case 'imsegkmeans'
                    this.ModeInternal='imsegkmeans';
                    this.ModeButton.Value=getString(message('vision:labeler:imSegKmeans'));

                end
            else
                switch mode
                case 'segmentLidarData'
                    this.ModeInternal='segmentLidarData';
                    this.ModeButton.Value=1;

                case 'pcsegdist'
                    this.ModeInternal='pcsegdist';
                    this.ModeButton.Value=2;

                case 'imsegkmeans'
                    this.ModeInternal='imsegkmeans';
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
        function sliderEditboxModified(this,mode)




            switch mode
            case 'distThreshold'
                this.LowValue=this.DistanceThresholdMinValue;
                this.HighValue=this.DistanceThresholdMaxValue;
                this.DefaultValue=this.LowValue;
                index=1;
            case 'angleThreshold'
                this.LowValue=this.AngleThresholdMinValue;
                this.HighValue=this.AngleThresholdMaxValue;
                this.DefaultValue=this.LowValue;
                index=2;
            case 'minDistance'
                this.LowValue=this.MinDistanceMinValue;
                this.HighValue=this.MinDistanceMaxValue;
                this.DefaultValue=this.MinDistanceDefaultValue;
                index=3;
            case 'kmeansClusters'
                this.LowValue=this.NumClustersMinValue;
                this.HighValue=this.NumClustersMaxValue;
                this.DefaultValue=this.LowValue;
                index=4;
            end
            if useAppContainer(this)
                switch mode
                case 'distThreshold'
                    textFieldValue=this.DistanceThresholdDisplay.Value;
                case 'angleThreshold'
                    textFieldValue=this.AngleThresholdDisplay.Value;
                case 'minDistance'
                    textFieldValue=this.MinDistanceDisplay.Value;
                case 'kmeansClusters'
                    textFieldValue=this.NumClustersDisplay.Value;
                end
                textFieldValue=str2double(textFieldValue);
            else
                switch mode
                case 'distThreshold'
                    textFieldValue=str2double(this.DistanceThresholdDisplay.String);
                case 'angleThreshold'
                    textFieldValue=str2double(this.AngleThresholdDisplay.String);
                case 'minDistance'
                    textFieldValue=str2double(this.MinDistanceDisplay.String);
                case 'kmeansClusters'
                    textFieldValue=str2double(this.NumClustersDisplay.String);
                end
            end

            this.Limit='';
            if textFieldValue>this.HighValue
                textFieldValue=this.HighValue;
                this.Limit='higher';
            elseif textFieldValue<=this.LowValue
                textFieldValue=this.DefaultValue;
                this.Limit='lower';
            end

            textFieldValue=(textFieldValue-this.LowValue)/...
            (this.HighValue-this.LowValue);






            isValid=isfinite(textFieldValue)&&~isempty(textFieldValue)...
            &&(textFieldValue>=0)&&(textFieldValue<=1);
            if isValid
                switch index
                case 1
                    this.DistanceThresholdSlider.Value=textFieldValue;
                case 2
                    this.AngleThresholdSlider.Value=textFieldValue;
                case 3
                    this.MinDistanceSlider.Value=textFieldValue;
                case 4
                    this.NumClustersSlider.Value=textFieldValue;
                end
                settingsChangedCallback(this);
                if~isempty(this.Limit)
                    this.setCurrentTextValue(mode);
                end
            else
                this.Limit='invalid';
                this.setCurrentTextValue(mode);
            end
        end

        function setCurrentTextValue(this,mode)
            if useAppContainer(this)
                switch mode
                case 'distThreshold'
                    this.DistanceThresholdDisplay.Value=...
                    this.displayValueInEditBox(this.DistanceThresholdMaxValue,this.DistanceThresholdMinValue,...
                    this.DistanceThresholdSlider.Value);
                case 'angleThreshold'
                    this.AngleThresholdDisplay.Value=...
                    this.displayValueInEditBox(this.AngleThresholdMaxValue,this.AngleThresholdMinValue,...
                    this.AngleThresholdSlider.Value);
                case 'minDistance'
                    this.MinDistanceDisplay.Value=...
                    this.displayValueInEditBox(this.MinDistanceMaxValue,this.MinDistanceDefaultValue,...
                    this.MinDistanceSlider.Value);
                case 'kmeansClusters'
                    this.NumClustersDisplay.Value=...
                    this.displayValueInEditBox(this.NumClustersMaxValue,this.NumClustersMinValue,...
                    this.NumClustersSlider.Value);
                end
            else
                switch mode
                case 'distThreshold'
                    this.DistanceThresholdDisplay.String=...
                    displayValueInEditBox(this,this.DistanceThresholdMaxValue,this.DistanceThresholdMinValue,...
                    this.DistanceThresholdSlider.Value);
                case 'angleThreshold'
                    this.AngleThresholdDisplay.String=...
                    displayValueInEditBox(this,this.AngleThresholdMaxValue,this.AngleThresholdMinValue,...
                    this.AngleThresholdSlider.Value);
                case 'minDistance'
                    this.MinDistanceDisplay.String=...
                    displayValueInEditBox(this,this.MinDistanceMaxValue,this.MinDistanceDefaultValue,...
                    this.MinDistanceSlider.Value);
                case 'kmeansClusters'
                    this.NumClustersDisplay.String=...
                    displayValueInEditBox(this,this.NumClustersMaxValue,this.NumClustersMinValue,...
                    this.NumClustersSlider.Value);
                end
            end
        end

        function displayString=displayValueInEditBox(this,maxValue,minValue,sliderValue)
            limit=this.Limit;
            switch limit
            case 'invalid'
                displayValue=minValue+sliderValue*(maxValue-minValue);
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