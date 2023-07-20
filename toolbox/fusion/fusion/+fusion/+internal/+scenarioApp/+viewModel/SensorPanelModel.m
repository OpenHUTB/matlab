classdef SensorPanelModel<handle



    properties
        Enabled logical=true
        ShowSensorMounting=false
        ShowDetectionParameters=false
        ShowAdvancedParameters=false
        ShowAccuracyAndNoiseSettings=false
        ShowScanningFOVParameters=false
    end

    events
PanelEnableChanged
    end

    methods
        function set.Enabled(this,newValue)
            oldValue=this.Enabled;
            this.Enabled=newValue;
            if oldValue~=newValue
                notify(this,'PanelEnableChanged');
            end
        end

        function enablePanel(this)
            this.Enabled=true;
        end

        function disablePanel(this)
            this.Enabled=false;
        end

        function onSensorAdded(this)



            if all(~[this.ShowSensorMounting,this.ShowDetectionParameters...
                ,this.ShowAdvancedParameters,this.ShowAccuracyAndNoiseSettings...
                ,this.ShowScanningFOVParameters])
                this.ShowSensorMounting=true;
                this.ShowScanningFOVParameters=true;
            end
        end
    end
end

