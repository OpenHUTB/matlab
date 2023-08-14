classdef SensorPropertySheet<driving.internal.scenarioApp.PropertySheet
    properties
        ShowDetectionParameters=false;
        ShowAccuracyNoise=false;
    end

    properties(Hidden)
hShowDetectionParameters
hShowAccuracyNoise

hDetectionParameters

hDetectionProbabilityLabel
hDetectionProbability

hLimitDetections
hMaxNumDetections

hAccuracyNoise

hHasNoise

hDetectionCoordinatesLabel
hDetectionCoordinates

hMaxRangeLabel
hMaxRange

DetectionLayout
AccuracyNoiseLayout
    end

    methods
        function this=SensorPropertySheet(dlg)
            this@driving.internal.scenarioApp.PropertySheet(dlg);
        end

        function update(this)
            sensor=getSpecification(this);
            if isempty(sensor)
                enable='off';
                string={''};
                index=1;
            else
                enable=getEnable(this);
                string=getDetectionCoordinatesLabels(this);
                index=find(strcmp(sensor.DetectionCoordinates,getDetectionCoordinatesTag(this)));
            end
            set(this.hDetectionCoordinates,'String',string,...
            'Enable',enable,...
            'Value',index);
            set([this.hShowAccuracyNoise,this.hShowDetectionParameters],'Enable',enable);
        end

        function topInset=getTopInset(~)
            topInset=-5;
        end

        function rightInset=getRightInset(~)
            rightInset=-3;
        end

        function leftInset=getLeftInset(~)
            leftInset=-3;
        end
    end

    methods(Access=protected)
        function tags=getDetectionCoordinatesTag(~)
            tags={'Ego Cartesian','Sensor Cartesian'};
        end
        function labels=getDetectionCoordinatesLabels(~)
            labels={getString(message('driving:scenarioApp:EgoCartesian')),...
            getString(message('driving:scenarioApp:SensorCartesian'))};
        end

        function limitDetectionsCallback(this,hcbo,~)
            if hcbo.Value
                newValue='Property';
            else
                newValue='Auto';
            end
            setProperty(this,'MaxNumDetectionsSource',newValue);
        end

        function detectionCoordinatesCallback(this,hItem,~)
            coordinates={'Ego Cartesian','Sensor Cartesian','Sensor spherical'};
            setProperty(this,'DetectionCoordinates',coordinates{hItem.Value});
        end

        function updateMaxNumWidgets(this,sensor,type,enable)

            if isempty(sensor)
                enable='off';
            end
            if isempty(sensor)||strcmp(sensor.(['MaxNum',type,'Source']),'Auto')
                limitValue=false;
                maxEnable='off';
                maxString='';
            else
                limitValue=true;
                maxEnable=enable;
                maxString=sensor.(['MaxNum',type]);
            end
            set(this.(['hLimit',type]),'Value',limitValue,'Enable',enable);
            set(this.(['hMaxNum',type]),'String',maxString,'Enable',maxEnable);
        end
    end
end


