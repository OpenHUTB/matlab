classdef LimitsSettings<handle




    properties
Dialog
ToolGroup
ToolName
Container
    end

    properties(Dependent)
LimitsData
XMinLimits
XMaxLimits
YMinLimits
YMaxLimits
ZMinLimits
ZMaxLimits
PointDimension
    end

    events
ROIViewPressed
LimitsSettingsChanged
XMinDisplayChanged
XMaxDisplayChanged
YMinDisplayChanged
YMaxDisplayChanged
ZMinDisplayChanged
ZMaxDisplayChanged
PointDimensionDisplayChanged
    end

    properties

        LimitsDataInternal=false;

XMinInternal
XMaxInternal
YMinInternal
YMaxInternal
ZMinInternal
ZMaxInternal
        PointDimensionInternal=10;

XMinRange
XMaxRange
YMinRange
YMaxRange
ZMinRange
ZMaxRange
        PointDimensionRange=[10,100];

DialogListener

    end


    methods

        function this=LimitsSettings(tool)
            this.Container=tool.Tool;
        end

        function open(this,pointCloud)
            xmin=round(double(pointCloud.XLimits(1)),04);
            xmax=round(double(pointCloud.XLimits(2)),04);
            ymin=round(double(pointCloud.YLimits(1)),04);
            ymax=round(double(pointCloud.YLimits(2)),04);
            zmin=round(double(pointCloud.ZLimits(1)),04);
            zmax=round(double(pointCloud.ZLimits(2)),04);

            if xmin>=0||xmax<0
                this.XMinRange=[xmin,round((xmin+xmax)/2,04)];
                this.XMaxRange=[round((xmin+xmax)/2+0.1,04),xmax];
            else
                this.XMinRange=[xmin,0];
                this.XMaxRange=[0.1,xmax];
            end

            if ymin>=0||ymax<0
                this.YMinRange=[ymin,round((ymin+ymax)/2,04)];
                this.YMaxRange=[round((ymin+ymax)/2+0.1,04),ymax];

            else
                this.YMinRange=[ymin,0];
                this.YMaxRange=[0.1,ymax];
            end

            if zmin>=0||zmax<0
                this.ZMinRange=[zmin,round((zmin+zmax)/2,04)];
                this.ZMaxRange=[round((zmin+zmax)/2+0.1,04),zmax];
            else
                this.ZMinRange=[zmin,0];
                this.ZMaxRange=[0.1,zmax];
            end
            if isempty(this.Dialog)||~isvalid(this.Dialog)||~isvalid(this.Dialog.Dlg)
                this.Dialog=lidar.internal.lidarLabeler.tool.LimitsSettingsDialog(this.Container,this.ToolName);
                update(this.Dialog,this.XMinLimits,this.XMaxLimits,this.YMinLimits,this.YMaxLimits,...
                this.ZMinLimits,this.ZMaxLimits,...
                this.PointDimension);
                wireUpListeners(this);
                updateSliderDisplay(this);
                this.Dialog.Visible='on';

            else
                figure(this.Dialog.Dlg);
            end
        end

        function sliderEditboxModified(this,mode)

            switch mode
            case 'XMinLimits'
                if~useAppContainer(this)
                    textFieldValue=str2double(this.Dialog.XMinDisplay.String);
                else
                    textFieldValue=this.Dialog.XMinDisplay.Value;
                end
                this.Dialog.LowValue=this.XMinRange(1);
                this.Dialog.HighValue=this.XMinRange(2);
                this.Dialog.DefaultValue=this.Dialog.LowValue;
                index=1;
            case 'XMaxLimits'
                if~useAppContainer(this)
                    textFieldValue=str2double(this.Dialog.XMaxDisplay.String);
                else
                    textFieldValue=this.Dialog.XMaxDisplay.Value;
                end
                this.Dialog.LowValue=this.XMaxRange(1);
                this.Dialog.HighValue=this.XMaxRange(2);
                this.Dialog.DefaultValue=this.Dialog.LowValue;
                index=2;
            case 'YMinLimits'
                if~useAppContainer(this)
                    textFieldValue=str2double(this.Dialog.YMinDisplay.String);
                else
                    textFieldValue=this.Dialog.YMinDisplay.Value;
                end
                this.Dialog.LowValue=this.YMinRange(1);
                this.Dialog.HighValue=this.YMinRange(2);
                this.Dialog.DefaultValue=this.Dialog.LowValue;
                index=3;
            case 'YMaxLimits'
                if~useAppContainer(this)
                    textFieldValue=str2double(this.Dialog.YMaxDisplay.String);
                else
                    textFieldValue=this.Dialog.YMaxDisplay.Value;
                end
                this.Dialog.LowValue=this.YMaxRange(1);
                this.Dialog.HighValue=this.YMaxRange(2);
                this.Dialog.DefaultValue=this.Dialog.LowValue;
                index=4;
            case 'ZMinLimits'
                if~useAppContainer(this)
                    textFieldValue=str2double(this.Dialog.ZMinDisplay.String);
                else
                    textFieldValue=this.Dialog.ZMinDisplay.Value;
                end
                this.Dialog.LowValue=this.ZMinRange(1);
                this.Dialog.HighValue=this.ZMinRange(2);
                this.Dialog.DefaultValue=this.Dialog.LowValue;
                index=5;
            case 'ZMaxLimits'
                if~useAppContainer(this)
                    textFieldValue=str2double(this.Dialog.ZMaxDisplay.String);
                else
                    textFieldValue=this.Dialog.ZMaxDisplay.Value;
                end
                this.Dialog.LowValue=this.ZMaxRange(1);
                this.Dialog.HighValue=this.ZMaxRange(2);
                this.Dialog.DefaultValue=this.Dialog.LowValue;
                index=6;
            case 'PointDimensionLimits'
                if~useAppContainer(this)
                    textFieldValue=str2double(this.Dialog.PointDimensionDisplay.String);
                else
                    textFieldValue=this.Dialog.PointDimensionDisplay.Value;
                end
                this.Dialog.LowValue=this.Dialog.PointDimensionMinValue;
                this.Dialog.HighValue=this.Dialog.PointDimensionMaxValue;
                this.Dialog.DefaultValue=this.Dialog.PointDimensionDefaultValue;
                index=7;
            end

            this.Dialog.Limit='';
            if textFieldValue>this.Dialog.HighValue
                textFieldValue=this.Dialog.HighValue;
                this.Dialog.Limit='higher';
            elseif textFieldValue<=this.Dialog.LowValue
                textFieldValue=this.Dialog.DefaultValue;
                this.Dialog.Limit='lower';
            end

            if~useAppContainer(this)
                textFieldValue=(textFieldValue-this.Dialog.LowValue)/...
                (this.Dialog.HighValue-this.Dialog.LowValue);
            end
            if~useAppContainer(this)
                isValid=isfinite(textFieldValue)&&~isempty(textFieldValue)...
                &&(textFieldValue>=0)&&(textFieldValue<=1);
            else
                isValid=isfinite(textFieldValue)&&~isempty(textFieldValue);
            end

            if isValid
                switch index
                case 1
                    this.Dialog.XMinSlider.Value=textFieldValue;
                    settingsChangedCallback(this.Dialog);
                case 2
                    this.Dialog.XMaxSlider.Value=textFieldValue;
                    settingsChangedCallback(this.Dialog);
                case 3
                    this.Dialog.YMinSlider.Value=textFieldValue;
                    settingsChangedCallback(this.Dialog);
                case 4
                    this.Dialog.YMaxSlider.Value=textFieldValue;
                    settingsChangedCallback(this.Dialog);
                case 5
                    this.Dialog.ZMinSlider.Value=textFieldValue;
                    settingsChangedCallback(this.Dialog);
                case 6
                    this.Dialog.ZMaxSlider.Value=textFieldValue;
                    settingsChangedCallback(this.Dialog);
                case 7
                    this.Dialog.PointDimensionSlider.Value=textFieldValue;
                    settingsChangedCallback(this.Dialog);
                end

                if~isempty(this.Dialog.Limit)
                    this.setCurrentTextValue(mode);
                end
            else
                this.Dialog.Limit='invalid';
                this.setCurrentTextValue(mode);
            end
        end

        function setCurrentTextValue(this,mode)
            if~useAppContainer(this)
                switch mode
                case 'XMinLimits'
                    this.Dialog.XMinDisplay.String=...
                    this.displayValueInEditBox(this.XMinRange(1),this.XMinRange(2),...
                    this.Dialog.XMinSlider.Value);
                case 'XMaxLimits'
                    this.Dialog.XMaxDisplay.String=...
                    this.displayValueInEditBox(this.XMaxRange(1),this.XMaxRange(2),...
                    this.Dialog.XMaxSlider.Value);
                case 'YMinLimits'
                    this.Dialog.YMinDisplay.String=...
                    this.displayValueInEditBox(this.YMinRange(1),this.YMinRange(2),...
                    this.Dialog.YMinSlider.Value);
                case 'YMaxLimits'
                    this.Dialog.YMaxDisplay.String=...
                    this.displayValueInEditBox(this.YMaxRange(1),this.YMaxRange(2),...
                    this.Dialog.YMaxSlider.Value);
                case 'ZMinLimits'
                    this.Dialog.ZMinDisplay.String=...
                    this.displayValueInEditBox(this.ZMinRange(1),this.ZMinRange(2),...
                    this.Dialog.ZMinSlider.Value);
                case 'ZMaxLimits'
                    this.Dialog.ZMaxDisplay.String=...
                    this.displayValueInEditBox(this.ZMaxRange(1),this.ZMaxRange(2),...
                    this.Dialog.ZMaxSlider.Value);
                case 'PointDimensionLimits'
                    this.Dialog.PointDimensionDisplay.String=...
                    this.displayValueInEditBox(this.Dialog.PointDimensionMinValue,this.Dialog.PointDimensionMaxValue,...
                    this.Dialog.PointDimensionSlider.Value);
                end
            else
                switch mode
                case 'XMinLimits'
                    this.Dialog.XMinDisplay.Value=...
                    this.displayValueInEditBox(this.XMinRange(1),this.XMinRange(2),...
                    this.Dialog.XMinSlider.Value);
                case 'XMaxLimits'
                    this.Dialog.XMaxDisplay.Value=...
                    this.displayValueInEditBox(this.XMaxRange(1),this.XMaxRange(2),...
                    this.Dialog.XMaxSlider.Value);
                case 'YMinLimits'
                    this.Dialog.YMinDisplay.Value=...
                    this.displayValueInEditBox(this.YMinRange(1),this.YMinRange(2),...
                    this.Dialog.YMinSlider.Value);
                case 'YMaxLimits'
                    this.Dialog.YMaxDisplay.Value=...
                    this.displayValueInEditBox(this.YMaxRange(1),this.YMaxRange(2),...
                    this.Dialog.YMaxSlider.Value);
                case 'ZMinLimits'
                    this.Dialog.ZMinDisplay.Value=...
                    this.displayValueInEditBox(this.ZMinRange(1),this.ZMinRange(2),...
                    this.Dialog.ZMinSlider.Value);
                case 'ZMaxLimits'
                    this.Dialog.ZMaxDisplay.Value=...
                    this.displayValueInEditBox(this.ZMaxRange(1),this.ZMaxRange(2),...
                    this.Dialog.ZMaxSlider.Value);
                case 'PointDimensionLimits'
                    this.Dialog.PointDimensionDisplay.Value=...
                    this.displayValueInEditBox(this.Dialog.PointDimensionMinValue,this.Dialog.PointDimensionMaxValue,...
                    this.Dialog.PointDimensionSlider.Value);
                end
            end
        end

        function displayString=displayValueInEditBox(this,minValue,maxValue,sliderValue)
            limit=this.Dialog.Limit;
            switch limit
            case 'invalid'
                displayValue=round(minValue+sliderValue*(maxValue-minValue),04);
                if~useAppContainer(this)
                    displayString=num2str(displayValue);
                else
                    displayString=displayValue;
                end
            case 'higher'


                displayValue=round(maxValue,04);
                if~useAppContainer(this)
                    displayString=num2str(displayValue);
                else
                    displayString=displayValue;
                end
            case 'lower'


                displayValue=round(minValue,04);
                if~useAppContainer(this)
                    displayString=num2str(displayValue);
                else
                    displayString=displayValue;
                end
            end
        end

        function close(this)
            try %#ok<TRYNC>
                this.DialogListener={};
                this.XMinInternal=[];
                this.XMaxInternal=[];
                this.YMinInternal=[];
                this.YMaxInternal=[];
                this.ZMinInternal=[];
                this.ZMaxInternal=[];
                this.PointDimensionInternal=10;

                this.XMinRange=[];
                this.XMaxRange=[];
                this.YMinRange=[];
                this.YMaxRange=[];
                this.ZMinRange=[];
                this.ZMaxRange=[];
                delete(this.Dialog);
                this.Dialog=[];
            end
        end

        function delete(this)
            close(this);
            delete(this);
        end

    end

    methods(Access=protected)

        function settingsChangedCallback(this,evt)

            this.XMinLimits=evt.XMinLimits;
            this.XMaxLimits=evt.XMaxLimits;
            this.YMinLimits=evt.YMinLimits;
            this.YMaxLimits=evt.YMaxLimits;
            this.ZMinLimits=evt.ZMinLimits;
            this.ZMaxLimits=evt.ZMaxLimits;
            this.PointDimension=evt.PointDimension;
            this.LimitsDataInternal=evt.LimitsData;

            updateSliderDisplay(this);
            packageEventData(this);

        end

        function settingsChangingCallback(this,evt)

            this.XMinLimits=evt.XMinLimits;
            this.XMaxLimits=evt.XMaxLimits;
            this.YMinLimits=evt.YMinLimits;
            this.YMaxLimits=evt.YMaxLimits;
            this.ZMinLimits=evt.ZMinLimits;
            this.ZMaxLimits=evt.ZMaxLimits;
            this.PointDimension=evt.PointDimension;

            updateSliderDisplay(this);
        end

        function updateSliderDisplay(this)
            if~useAppContainer(this)
                eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(...
                this.LimitsDataInternal,...
                this.XMinInternal,...
                this.XMaxInternal,...
                this.YMinInternal,...
                this.YMaxInternal,...
                this.ZMinInternal,...
                this.ZMaxInternal,...
                this.PointDimensionInternal);
            else
                eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(...
                this.LimitsDataInternal,...
                this.Dialog.XMinSlider.Value,...
                this.Dialog.XMaxSlider.Value,...
                this.Dialog.YMinSlider.Value,...
                this.Dialog.YMaxSlider.Value,...
                this.Dialog.ZMinSlider.Value,...
                this.Dialog.ZMaxSlider.Value,...
                this.Dialog.PointDimensionSlider.Value);
            end

            try %#ok<TRYNC>
                updateSliderDisplay(this.Dialog,eventData);
            end
        end

        function startUpdatingByLimits(this)
            notify(this,'StartUpdatingByLimits');
        end

        function stopUpdatingByLimits(this)
            notify(this,'StopUpdatingByLimits');
        end

        function packageEventData(this)
            eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(...
            this.LimitsDataInternal,...
            this.XMinInternal,...
            this.XMaxInternal,...
            this.YMinInternal,...
            this.YMaxInternal,...
            this.ZMinInternal,...
            this.ZMaxInternal,...
            this.PointDimensionInternal);

            notify(this,'LimitsSettingsChanged',eventData);
        end

        function wireUpListeners(this)

            this.DialogListener{1}=event.listener(this.Dialog,'LimitsSettingsChanged',@(src,evt)settingsChangedCallback(this,evt));
            this.DialogListener{2}=event.listener(this.Dialog,'LimitsSettingsChanging',@(src,evt)settingsChangingCallback(this,evt));
            this.DialogListener{3}=event.listener(this.Dialog,'XMinDisplayChanged',@(~,~)sliderEditboxModified(this,'XMinLimits'));
            this.DialogListener{4}=event.listener(this.Dialog,'XMaxDisplayChanged',@(~,~)sliderEditboxModified(this,'XMaxLimits'));
            this.DialogListener{5}=event.listener(this.Dialog,'YMinDisplayChanged',@(~,~)sliderEditboxModified(this,'YMinLimits'));
            this.DialogListener{6}=event.listener(this.Dialog,'YMaxDisplayChanged',@(~,~)sliderEditboxModified(this,'YMaxLimits'));
            this.DialogListener{7}=event.listener(this.Dialog,'ZMinDisplayChanged',@(~,~)sliderEditboxModified(this,'ZMinLimits'));
            this.DialogListener{8}=event.listener(this.Dialog,'ZMaxDisplayChanged',@(~,~)sliderEditboxModified(this,'ZMaxLimits'));
            this.DialogListener{9}=event.listener(this.Dialog,'PointDimensionDisplayChanged',@(~,~)sliderEditboxModified(this,'PointDimensionLimits'));
        end

    end

    methods
        function set.LimitsDataInternal(this,TF)

            this.LimitsDataInternal=TF;

            if~TF
                close(this)
            end

            packageEventData(this);
        end

        function TF=get.LimitsData(this)
            TF=this.LimitsDataInternal;
        end

        function set.XMinLimits(this,percent)
            if~useAppContainer(this)
                this.XMinInternal=this.XMinRange(1)+...
                percent*(this.XMinRange(2)-this.XMinRange(1));
            else
                this.XMinInternal=this.Dialog.XMinSlider.Value;
            end
        end

        function limits=get.XMinLimits(this)
            if isempty(this.XMinInternal)
                this.XMinInternal=this.XMinRange(1);
            end
            if~useAppContainer(this)
                limits=(this.XMinInternal-this.XMinRange(1))/...
                (this.XMinRange(2)-this.XMinRange(1));
            else
                if this.XMinInternal>this.XMinRange(2)
                    this.XMinInternal=this.XMinRange(2);
                end
                if this.XMinInternal<this.XMinRange(1)
                    this.XMinInternal=this.XMinRange(1);
                end
                limits=this.XMinInternal;
                this.Dialog.XMinSlider.Limits=[double(this.XMinRange(1)),double(this.XMinRange(2))];
            end
        end

        function set.XMaxLimits(this,percent)
            if~useAppContainer(this)
                this.XMaxInternal=this.XMaxRange(1)+...
                percent*(this.XMaxRange(2)-this.XMaxRange(1));
            else
                this.XMaxInternal=this.Dialog.XMaxSlider.Value;
            end
        end

        function limits=get.XMaxLimits(this)
            if isempty(this.XMaxInternal)
                this.XMaxInternal=this.XMaxRange(2);
            end
            if~useAppContainer(this)
                limits=(this.XMaxInternal-this.XMaxRange(1))/...
                (this.XMaxRange(2)-this.XMaxRange(1));
            else
                if this.XMaxInternal>this.XMaxRange(2)
                    this.XMaxInternal=this.XMaxRange(2);
                end
                if this.XMaxInternal<this.XMaxRange(1)
                    this.XMaxInternal=this.XMaxRange(1);
                end
                limits=this.XMaxInternal;
                this.Dialog.XMaxSlider.Limits=[double(this.XMaxRange(1)),double(this.XMaxRange(2))];
            end
        end

        function set.YMinLimits(this,percent)
            if~useAppContainer(this)
                this.YMinInternal=this.YMinRange(1)+...
                percent*(this.YMinRange(2)-this.YMinRange(1));
            else
                this.YMinInternal=this.Dialog.YMinSlider.Value;
            end
        end

        function limits=get.YMinLimits(this)
            if isempty(this.YMinInternal)
                this.YMinInternal=this.YMinRange(1);
            end
            if~useAppContainer(this)
                limits=(this.YMinInternal-this.YMinRange(1))/...
                (this.YMinRange(2)-this.YMinRange(1));
            else
                if this.YMinInternal>this.YMinRange(2)
                    this.YMinInternal=this.YMinRange(2);
                end
                if this.YMinInternal<this.YMinRange(1)
                    this.YMinInternal=this.YMinRange(1);
                end
                limits=this.YMinInternal;
                this.Dialog.YMinSlider.Limits=[double(this.YMinRange(1)),double(this.YMinRange(2))];
            end
        end

        function set.YMaxLimits(this,percent)
            if~useAppContainer(this)
                this.YMaxInternal=this.YMaxRange(1)+...
                percent*(this.YMaxRange(2)-this.YMaxRange(1));
            else
                this.YMaxInternal=this.Dialog.YMaxSlider.Value;
            end
        end

        function limits=get.YMaxLimits(this)
            if isempty(this.YMaxInternal)
                this.YMaxInternal=this.YMaxRange(2);
            end
            if~useAppContainer(this)
                limits=(this.YMaxInternal-this.YMaxRange(1))/...
                (this.YMaxRange(2)-this.YMaxRange(1));
            else
                if this.YMaxInternal>this.YMaxRange(2)
                    this.YMaxInternal=this.YMaxRange(2);
                end
                if this.YMaxInternal<this.YMaxRange(1)
                    this.YMaxInternal=this.YMaxRange(1);
                end
                limits=this.YMaxInternal;
                this.Dialog.YMaxSlider.Limits=[double(this.YMaxRange(1)),double(this.YMaxRange(2))];
            end
        end

        function set.ZMinLimits(this,percent)
            if~useAppContainer(this)
                this.ZMinInternal=this.ZMinRange(1)+...
                percent*(this.ZMinRange(2)-this.ZMinRange(1));
            else
                this.ZMinInternal=this.Dialog.ZMinSlider.Value;
            end
        end

        function limits=get.ZMinLimits(this)
            if isempty(this.ZMinInternal)
                this.ZMinInternal=this.ZMinRange(1);
            end
            if~useAppContainer(this)
                limits=(this.ZMinInternal-this.ZMinRange(1))/...
                (this.ZMinRange(2)-this.ZMinRange(1));
            else
                if this.ZMinInternal>this.ZMinRange(2)
                    this.ZMinInternal=this.ZMinRange(2);
                end
                if this.ZMinInternal<this.ZMinRange(1)
                    this.ZMinInternal=this.ZMinRange(1);
                end
                limits=this.ZMinInternal;
                this.Dialog.ZMinSlider.Limits=[double(this.ZMinRange(1)),double(this.ZMinRange(2))];
            end
        end

        function set.ZMaxLimits(this,percent)
            if~useAppContainer(this)
                this.ZMaxInternal=this.ZMaxRange(1)+...
                percent*(this.ZMaxRange(2)-this.ZMaxRange(1));
            else
                this.ZMaxInternal=this.Dialog.ZMaxSlider.Value;
            end
        end

        function limits=get.ZMaxLimits(this)
            if isempty(this.ZMaxInternal)
                this.ZMaxInternal=this.ZMaxRange(2);
            end
            if~useAppContainer(this)
                limits=(this.ZMaxInternal-this.ZMaxRange(1))/...
                (this.ZMaxRange(2)-this.ZMaxRange(1));
            else
                if this.ZMaxInternal>this.ZMaxRange(2)
                    this.ZMaxInternal=this.ZMaxRange(2);
                end
                if this.ZMaxInternal<this.ZMaxRange(1)
                    this.ZMaxInternal=this.ZMaxRange(1);
                end
                limits=this.ZMaxInternal;
                this.Dialog.ZMaxSlider.Limits=[double(this.ZMaxRange(1)),double(this.ZMaxRange(2))];
            end
        end

        function set.PointDimension(this,percent)
            if~useAppContainer(this)
                this.PointDimensionInternal=this.PointDimensionRange(1)+...
                percent*(this.PointDimensionRange(2)-this.PointDimensionRange(1));
            else
                this.PointDimensionInternal=this.Dialog.PointDimensionSlider.Value;
            end
        end

        function limits=get.PointDimension(this)
            if~useAppContainer(this)
                limits=(this.PointDimensionInternal-this.PointDimensionRange(1))/...
                (this.PointDimensionRange(2)-this.PointDimensionRange(1));
            else
                limits=this.PointDimensionInternal;
            end
        end
    end
end

function tf=useAppContainer(~)
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end