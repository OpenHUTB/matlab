classdef ClusterSettingsDialog<images.internal.app.utilities.CloseDialog




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
NumClustersDisplayChanged
DistanceThresholdDisplayChanged
AngleThresholdDisplayChanged
MinDistanceDisplayChanged
ExternalTrigger
ClusterSettingsCloseRequest
    end

    properties(Access=private)
MinDistanceListener
NumClustersListener
AngleThresholdListener
DistanceThresholdListener
    end

    properties(Access=protected)
        ModeInternal='segmentLidarData';

    end


    methods
        function this=ClusterSettingsDialog(tool)

            monitorPos=get(0,'MonitorPositions');
            location=[monitorPos(1,3)/2,monitorPos(1,4)/2];

            this=this@images.internal.app.utilities.CloseDialog(location,tool);

            this.Size=[400,210];

            create(this);
            this.FigureHandle.WindowStyle='modal';

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
            this.DistanceThresholdDisplay.Value=num2str(evt.DistanceThreshold,3);
            this.AngleThresholdDisplay.Value=num2str(evt.AngleThreshold,3);
            this.MinDistanceDisplay.Value=num2str(evt.MinDistance,3);
            this.NumClustersDisplay.Value=num2str(evt.NumClusters,3);
        end

        function updateKMeansClusters(this,kMeansNumClusters)
            if~isempty(kMeansNumClusters)&&isvalid(this.FigureHandle)
                this.KMeansNumClustersText.Value=num2str(kMeansNumClusters);
            end
        end
    end


    methods(Access=protected)
        function doLayout(this,~,~)

            width=(this.Size(1)/2)-(2.5*15);
            height=this.ButtonSize(2);

            subtractForDisplay=20;

            this.ModeButton=uidropdown(this.FigureHandle,'ValueChangedFcn',...
            @(~,~)modeChangedCallback(this),...
            'Position',[15,(5*height)+(5*15),1.2*width,height],...
            'Items',{getString(message('lidar:lidarViewer:SegmentLidarData')),...
            getString(message('lidar:lidarViewer:PCSegDist')),...
            getString(message('lidar:lidarViewer:imSegKmeans'))},'FontSize',12,'Value',...
            getString(message('lidar:lidarViewer:SegmentLidarData')));


            this.SegmentLidarLabel=uilabel(this.FigureHandle,...
            'Text',getString(message('lidar:lidarViewer:SegmentLidarDataDesc')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,(3*height)+(4*15),this.Size(1)-(2*15),2*height]);


            this.PCSegDistLabel=uilabel(this.FigureHandle,...
            'Text',getString(message('lidar:lidarViewer:PCSegDistDesc')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,(3*height)+(4*15),this.Size(1)-(2*15),2*height]);


            this.KMeansLabel=uilabel(this.FigureHandle,...
            'Text',getString(message('lidar:lidarViewer:imSegKmeansDesc')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,(3*height)+(4*15),this.Size(1)-(2*15),2*height]);


            this.DistanceThresholdSlider=uislider(this.FigureHandle,...
            'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
            'Position',[width-subtractForDisplay,(3*height)+(2*15)+5,...
            width-subtractForDisplay,3]);
            this.DistanceThresholdSlider.Tag='distThresholdSlider';
            addlistener(this.DistanceThresholdSlider,'ValueChanged',...
            @(~,~)settingsChangedCallback(this));
            addlistener(this.DistanceThresholdSlider,'ValueChanging',...
            @(~,~)settingsChangingCallback(this));

            this.AngleThresholdSlider=uislider(this.FigureHandle,...
            'Limits',[0,1],'MinorTicks',[],'Position',...
            [width-subtractForDisplay,height+(2*15)+5,...
            width-subtractForDisplay,3],'MajorTicks',[]);
            this.AngleThresholdSlider.Tag='angleThresholdSlider';
            addlistener(this.AngleThresholdSlider,'ValueChanged',...
            @(~,~)settingsChangedCallback(this));
            addlistener(this.AngleThresholdSlider,'ValueChanging',...
            @(~,~)settingsChangingCallback(this));

            this.DistanceThresholdLabel=uilabel(this.FigureHandle,'Text',getString(message('lidar:lidarViewer:DistanceThreshold')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,(2*height)+(3*15),0.75*width,height]);

            this.AngleThresholdLabel=uilabel(this.FigureHandle,...
            'Text',getString(message('lidar:lidarViewer:AngleThreshold')),...
            'WordWrap','on','FontSize',12,'Position',...
            [15,height+(2*15),0.75*width,height]);

            this.DistanceThresholdDisplay=uieditfield(this.FigureHandle,'Position',...
            [(2*width)+(2*15)-subtractForDisplay,(2*height)+(3*15),...
            (3*subtractForDisplay),height],'Tag','distThresholdEditBox',...
            'FontSize',12);
            this.DistanceThresholdDisplay.ValueChangedFcn=...
            @(~,~)triggerDistanceThresholdChangedEvent(this);

            this.AngleThresholdDisplay=uieditfield(this.FigureHandle,'Position',...
            [(2*width)+(2*15)-subtractForDisplay,height+(2*15),...
            (3*subtractForDisplay),height],'Tag','angleThresholdEditBox');
            this.AngleThresholdDisplay.ValueChangedFcn=...
            @(~,~)triggerAngleThresholdChangedEvent(this);


            this.MinDistanceSlider=uislider(this.FigureHandle,...
            'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
            'Position',[width-subtractForDisplay,(height)+(4.5*15)+5,width-2*subtractForDisplay,3]);
            this.MinDistanceSlider.Tag='minDistSlider';
            addlistener(this.MinDistanceSlider,'ValueChanged',...
            @(~,~)settingsChangedCallback(this));
            addlistener(this.MinDistanceSlider,'ValueChanging',...
            @(~,~)settingsChangingCallback(this));
            this.NumClustersSlider=uislider(this.FigureHandle,...
            'Limits',[0,1],'MajorTicks',[],'MinorTicks',[],...
            'Position',[0.35*width,(height)+(4.5*15)+5,width-2*subtractForDisplay,3]);
            addlistener(this.NumClustersSlider,'ValueChanged',...
            @(~,~)settingsChangedCallback(this));
            addlistener(this.NumClustersSlider,'ValueChanging',...
            @(~,~)settingsChangingCallback(this));

            this.MinDistanceLabel=uilabel(this.FigureHandle,'Text',getString(message('lidar:lidarViewer:MinDistance')),...
            'WordWrap','on','Position',...
            [2.5*15,(2*height)+(3*15),0.65*width,height],...
            'FontSize',12);

            this.NumClustersLabel=uilabel(this.FigureHandle,...
            'Text',getString(message('lidar:lidarViewer:K')),...
            'WordWrap','on','Position',...
            [2*15,(2*height)+(3*15),0.2*width,height],...
            'FontSize',12);
            this.NumClustersDisplay=uieditfield(this.FigureHandle,'Position',...
            [(1.2*width)+(0.5*15),(2*height)+(3*15),(3*subtractForDisplay),height],...
            'FontSize',12,'Tag','kEditBox');
            this.NumClustersDisplay.ValueChangedFcn=...
            @(~,~)triggerNumClustersChangedEvent(this);
            this.NumClustersDisplay.Tooltip=getString(message('lidar:lidarViewer:KMeansTooltip'));

            this.KMeansNumClustersLabel=uilabel(this.FigureHandle,...
            'Text',getString(message('lidar:lidarViewer:NumClusters')),...
            'WordWrap','on','Position',...
            [2*15,(height)+(1.5*15),0.8*width,height],...
            'FontSize',12);

            this.KMeansNumClustersText=uieditfield(this.FigureHandle,'Position',...
            [(0.75*width)+(2*15),(height)+(1.5*15),0.33*width,height],...
            'FontSize',12,'FontWeight','Bold','Tag','numClustersEdit');
            this.KMeansNumClustersText.Editable='off';

            this.MinDistanceDisplay=uieditfield(this.FigureHandle,'Position',...
            [(2*width)+(15)-2.5*subtractForDisplay,(2*height)+(3*15),...
            (3*subtractForDisplay),height],'FontSize',12,'Tag','minDistEditBox');

            this.MinDistanceDisplay.ValueChangedFcn=...
            @(~,~)triggerMinDistanceChangedEvent(this);

            addlistener(this,'DistanceThresholdDisplayChanged',...
            @(~,~)sliderEditboxModified(this,'distThreshold'));
            addlistener(this,'AngleThresholdDisplayChanged',...
            @(~,~)sliderEditboxModified(this,'angleThreshold'));
            addlistener(this,'MinDistanceDisplayChanged',...
            @(~,~)sliderEditboxModified(this,'minDistance'));
            addlistener(this,'NumClustersDisplayChanged',...
            @(~,~)sliderEditboxModified(this,'kmeansClusters'));

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
            switch this.ModeButton.Value
            case getString(message('lidar:lidarViewer:SegmentLidarData'))
                this.ModeInternal='segmentLidarData';
            case getString(message('lidar:lidarViewer:PCSegDist'))
                this.ModeInternal='pcsegdist';
            case getString(message('lidar:lidarViewer:imSegKmeans'))
                this.ModeInternal='imsegkmeans';
            end

            setSliderVisibility(this);
            settingsChangedCallback(this);

        end

        function settingsChangedCallback(this)
            eventData=lidar.internal.lidarViewer.events.LidarClusterEventData(true,...
            this.ModeInternal,this.DistanceThresholdSlider.Value,...
            this.AngleThresholdSlider.Value,...
            this.MinDistanceSlider.Value,...
            this.NumClustersSlider.Value);

            notify(this,'ClusterSettingsChanged',eventData);

        end

        function settingsChangingCallback(this)
            eventData=lidar.internal.lidarViewer.events.LidarClusterEventData(true,...
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
            case 'segmentLidarData'
                this.ModeInternal='segmentLidarData';
                this.ModeButton.Value=getString(message('lidar:lidarViewer:SegmentLidarData'));
            case 'pcsegdist'
                this.ModeInternal='pcsegdist';
                this.ModeButton.Value=getString(message('lidar:lidarViewer:PCSegDist'));
            case 'imsegkmeans'
                this.ModeInternal='imsegkmeans';
                this.ModeButton.Value=getString(message('lidar:lidarViewer:imSegKmeans'));
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
                textFieldValue=this.DistanceThresholdDisplay.Value;
            case 'angleThreshold'
                this.LowValue=this.AngleThresholdMinValue;
                this.HighValue=this.AngleThresholdMaxValue;
                this.DefaultValue=this.LowValue;
                index=2;
                textFieldValue=this.AngleThresholdDisplay.Value;
            case 'minDistance'
                this.LowValue=this.MinDistanceMinValue;
                this.HighValue=this.MinDistanceMaxValue;
                this.DefaultValue=this.MinDistanceDefaultValue;
                index=3;
                textFieldValue=this.MinDistanceDisplay.Value;
            case 'kmeansClusters'
                this.LowValue=this.NumClustersMinValue;
                this.HighValue=this.NumClustersMaxValue;
                this.DefaultValue=this.LowValue;
                index=4;
                textFieldValue=this.NumClustersDisplay.Value;
            end

            textFieldValue=str2double(textFieldValue);

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

    methods(Access=protected)
        function closeClicked(this)
            close(this);
            notify(this,'ClusterSettingsCloseRequest');
        end
    end
end
