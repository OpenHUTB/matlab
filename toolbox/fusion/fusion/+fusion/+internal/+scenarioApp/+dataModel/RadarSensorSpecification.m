classdef RadarSensorSpecification<fusion.internal.scenarioApp.dataModel.SensorSpecification


    properties


        DetectionProbability=0.9
        FalseAlarmRate=1e-6
        FieldOfView=[1,5]
        MaxUnambiguousRange=100000
        MaxUnambiguousRadialSpeed=200

        ScanMode='No scanning'

        HasElevation=false
        HasRangeRate=false
        HasRangeAmbiguities=false
        HasRangeRateAmbiguities=false
        HasNoise=true
        HasFalseAlarms=true
        HasOcclusion=true
        HasINS=true

        ReferenceRange=100000
        ReferenceRCS=0
        MaxNumDetections=inf
        DetectionCoordinates='Scenario'

        AzimuthResolution=1
        AzimuthBias=0.1
        ElevationResolution=1
        ElevationBias=0.1
        RangeResolution=100
        RangeBias=0.05
        RangeRateResolution=10
        RangeRateBias=0.05

        CenterFrequency=300000000
LookAngle
    end

    properties

        RangeLimits=[0,100000]
        RangeRateLimits=[-200,200]
        TargetReportFormat='Clustered detections'
    end


    properties(Dependent)
MaxMechanicalScanRate
MechanicalScanLimits
ElectronicScanLimits
    end


    properties(Dependent)
MaxNumReports
MaxAzimuthScanRate
MaxElevationScanRate
MechanicalAzimuthLimits
MechanicalElevationLimits
ElectronicAzimuthLimits
ElectronicElevationLimits
    end

    properties(SetAccess=protected,Hidden)
        pMaxMechanicalScanRate=[75;75]
        pMechanicalScanLimits=[0,360;-10,0]
        pElectronicScanLimits=[-45,45;-45,45]
    end


    methods
        function this=RadarSensorSpecification(varargin)
            this@fusion.internal.scenarioApp.dataModel.SensorSpecification(varargin{:});
            this.Type='fusionRadar';
            resetLookAngle(this);
        end

        function updateRadarSpecification(this)






            if strcmp(this.Type,'monostaticRadar')
                this.RangeLimits=[0,1e7];
                this.RangeRateLimits=[-1e7,1e7];
                this.TargetReportFormat='Detections';
            end
        end

        function value=get.ElectronicScanLimits(this)
            if~this.HasElevation
                value=this.pElectronicScanLimits(1,:);
            else
                value=this.pElectronicScanLimits;
            end
        end

        function set.ElectronicScanLimits(this,value)
            if~this.HasElevation
                this.pElectronicScanLimits(1,:)=value(1,:);
            else
                this.pElectronicScanLimits=value;
            end
            resetLookAngle(this);
        end

        function value=get.ElectronicAzimuthLimits(this)
            value=this.pElectronicScanLimits(1,:);
        end

        function set.ElectronicAzimuthLimits(this,value)
            this.pElectronicScanLimits(1,:)=value;
        end

        function value=get.ElectronicElevationLimits(this)
            value=this.pElectronicScanLimits(2,:);
        end

        function set.ElectronicElevationLimits(this,value)
            this.pElectronicScanLimits(2,:)=value;
        end

        function value=get.MechanicalAzimuthLimits(this)
            value=this.pMechanicalScanLimits(1,:);
        end

        function set.MechanicalAzimuthLimits(this,value)
            this.pMechanicalScanLimits(1,:)=value;
        end

        function value=get.MechanicalElevationLimits(this)
            value=this.pMechanicalScanLimits(2,:);
        end

        function set.MechanicalElevationLimits(this,value)
            this.pMechanicalScanLimits(2,:)=value;
        end

        function set.HasElevation(this,value)
            this.HasElevation=value;
            resetLookAngle(this);
        end

        function value=get.MechanicalScanLimits(this)
            if~this.HasElevation
                value=this.pMechanicalScanLimits(1,:);
            else
                value=this.pMechanicalScanLimits;
            end
        end

        function set.MechanicalScanLimits(this,value)
            if~this.HasElevation
                this.pMechanicalScanLimits(1,:)=value(1,:);
            else
                this.pMechanicalScanLimits=value;
            end
            resetLookAngle(this);
        end

        function set.ScanMode(this,value)
            this.ScanMode=value;
            resetLookAngle(this);
        end

        function value=get.MaxMechanicalScanRate(this)
            if~this.HasElevation
                value=this.pMaxMechanicalScanRate(1);
            else
                value=this.pMaxMechanicalScanRate;
            end
        end

        function set.MaxMechanicalScanRate(this,value)
            if~this.HasElevation
                this.pMaxMechanicalScanRate(1)=value(1);
            else
                this.pMaxMechanicalScanRate=value;
            end
        end

        function value=get.MaxAzimuthScanRate(this)
            value=this.pMaxMechanicalScanRate(1);
        end

        function set.MaxAzimuthScanRate(this,value)
            this.pMaxMechanicalScanRate(1)=value;
        end

        function value=get.MaxElevationScanRate(this)
            value=this.pMaxMechanicalScanRate(2);
        end

        function set.MaxElevationScanRate(this,value)
            this.pMaxMechanicalScanRate(2)=value;
        end

        function value=get.MaxNumReports(this)
            value=this.MaxNumDetections;
        end

        function set.MaxNumReports(this,value)
            this.MaxNumDetections=value;
        end
    end

    methods
        function resetLookAngle(this)
            switch this.ScanMode
            case 'No scanning'
                la=[0;0];
            case 'Mechanical'
                la=this.pMechanicalScanLimits(:,1);
                if this.FieldOfView(2)>abs(diff(this.pMechanicalScanLimits(2,:)))
                    la(2)=mean(this.pMechanicalScanLimits(2,:));
                end
            case 'Electronic'
                la=this.pElectronicScanLimits(:,1);
            case 'Mechanical and electronic'
                la=this.pMechanicalScanLimits(:,1)+...
                this.pElectronicScanLimits(:,1);
            end

            if~this.HasElevation
                this.LookAngle=[la(1);0];
            else
                this.LookAngle=la;
            end
        end
    end

    methods

        function importMonostaticRadarSensor(this,sensor,warningHandler)%#ok<INUSD>
            this.UpdateRate=sensor.UpdateRate;
            this.MountingLocation=sensor.MountingLocation;
            this.MountingAngles=sensor.MountingAngles([3,2,1]);
            this.DetectionProbability=sensor.DetectionProbability;
            this.FalseAlarmRate=sensor.FalseAlarmRate;
            this.FieldOfView=sensor.FieldOfView;
            this.ScanMode=sensor.ScanMode;
            this.HasElevation=sensor.HasElevation;
            this.HasRangeRate=sensor.HasRangeRate;
            this.HasRangeAmbiguities=sensor.HasRangeAmbiguities;
            this.HasNoise=sensor.HasNoise;
            this.HasFalseAlarms=sensor.HasFalseAlarms;
            this.HasOcclusion=sensor.HasOcclusion;
            this.ReferenceRange=sensor.ReferenceRange;
            this.ReferenceRCS=sensor.ReferenceRCS;
            this.AzimuthResolution=sensor.AzimuthResolution;
            this.AzimuthBias=sensor.AzimuthBiasFraction;
            this.RangeResolution=sensor.RangeResolution;
            this.RangeBias=sensor.RangeBiasFraction;
            this.CenterFrequency=sensor.CenterFrequency;

            if any(strcmp(sensor.ScanMode,{'Electronic','Mechanical and electronic'}))
                this.ElectronicScanLimits=sensor.ElectronicScanLimits;
            end

            if any(strcmp(sensor.ScanMode,{'Mechanical','Mechanical and electronic'}))
                this.MechanicalScanLimits=sensor.MechanicalScanLimits;
                this.MaxMechanicalScanRate=sensor.MaxMechanicalScanRate;
            end

            this.MaxUnambiguousRange=sensor.MaxUnambiguousRange;


            if sensor.HasRangeRate
                this.HasRangeRateAmbiguities=sensor.HasRangeRateAmbiguities;
                this.RangeRateResolution=sensor.RangeRateResolution;
                this.RangeRateBias=sensor.RangeRateBiasFraction;
            end

            if sensor.HasRangeRate&&(sensor.HasRangeRateAmbiguities||...
                sensor.HasFalseAlarms)
                this.MaxUnambiguousRadialSpeed=sensor.MaxUnambiguousRadialSpeed;
            end

            if sensor.HasElevation
                this.ElevationResolution=sensor.ElevationResolution;
                this.ElevationBias=sensor.ElevationBiasFraction;
            end


            if strcmp(sensor.MaxNumDetectionsSource,'Property')
                this.MaxNumDetections=sensor.MaxNumDetections;
            else
                this.MaxNumDetections=Inf;
            end

            resetLookAngle(this);
        end

        function importFusionRadarSensor(this,sensor,warningHandler)%#ok<INUSD>
            this.UpdateRate=sensor.UpdateRate;
            this.MountingLocation=sensor.MountingLocation;
            this.MountingAngles=sensor.MountingAngles([3,2,1]);
            this.DetectionProbability=sensor.DetectionProbability;
            this.FalseAlarmRate=sensor.FalseAlarmRate;
            this.FieldOfView=reshape(sensor.FieldOfView,1,2);
            this.ScanMode=sensor.ScanMode;
            this.HasElevation=sensor.HasElevation;
            this.HasRangeRate=sensor.HasRangeRate;
            this.HasRangeAmbiguities=sensor.HasRangeAmbiguities;
            this.HasNoise=sensor.HasNoise;
            this.HasFalseAlarms=sensor.HasFalseAlarms;
            this.HasOcclusion=sensor.HasOcclusion;
            this.ReferenceRange=sensor.ReferenceRange;
            this.ReferenceRCS=sensor.ReferenceRCS;
            this.AzimuthResolution=sensor.AzimuthResolution;
            this.AzimuthBias=sensor.AzimuthBiasFraction;
            this.RangeResolution=sensor.RangeResolution;
            this.RangeBias=sensor.RangeBiasFraction;
            this.RangeLimits=sensor.RangeLimits;
            this.CenterFrequency=sensor.CenterFrequency;
            this.TargetReportFormat=sensor.TargetReportFormat;

            if any(strcmp(sensor.ScanMode,{'Electronic','Mechanical and electronic'}))
                if sensor.HasElevation
                    this.ElectronicElevationLimits=sensor.ElectronicElevationLimits;
                end
                this.ElectronicAzimuthLimits=sensor.ElectronicAzimuthLimits;
            end

            if any(strcmp(sensor.ScanMode,{'Mechanical','Mechanical and electronic'}))
                if sensor.HasElevation
                    this.MechanicalElevationLimits=sensor.MechanicalElevationLimits;
                    this.MaxElevationScanRate=sensor.MaxElevationScanRate;
                end
                this.MechanicalAzimuthLimits=sensor.MechanicalAzimuthLimits;
                this.MaxAzimuthScanRate=sensor.MaxAzimuthScanRate;
            end

            this.MaxUnambiguousRange=sensor.MaxUnambiguousRange;


            if sensor.HasRangeRate
                this.HasRangeRateAmbiguities=sensor.HasRangeRateAmbiguities;
                this.RangeRateResolution=sensor.RangeRateResolution;
                this.RangeRateBias=sensor.RangeRateBiasFraction;
                this.RangeRateLimits=sensor.RangeRateLimits;
            end

            if sensor.HasRangeRate&&(sensor.HasRangeRateAmbiguities||...
                sensor.HasFalseAlarms)
                this.MaxUnambiguousRadialSpeed=sensor.MaxUnambiguousRadialSpeed;
            end

            if sensor.HasElevation
                this.ElevationResolution=sensor.ElevationResolution;
                this.ElevationBias=sensor.ElevationBiasFraction;
            end


            if strcmp(sensor.MaxNumReportsSource,'Property')
                this.MaxNumDetections=sensor.MaxNumReports;
            else
                this.MaxNumDetections=Inf;
            end

            resetLookAngle(this);
        end

        function pvPairs=toPvPairs(this)

            pvPairs={'SensorIndex',this.ID,...
            'UpdateRate',this.UpdateRate,...
            'MountingLocation',this.MountingLocation,...
            'MountingAngles',this.MountingAngles([3,2,1]),...
            'DetectionProbability',this.DetectionProbability,...
            'FalseAlarmRate',this.FalseAlarmRate,...
            'FieldOfView',reshape(this.FieldOfView,1,2),...
            'ScanMode',this.ScanMode,...
            'HasElevation',this.HasElevation,...
            'HasRangeRate',this.HasRangeRate,...
            'HasRangeAmbiguities',this.HasRangeAmbiguities,...
            'HasNoise',this.HasNoise,...
            'HasINS',this.HasINS,...
            'HasFalseAlarms',this.HasFalseAlarms,...
            'HasOcclusion',this.HasOcclusion,...
            'ReferenceRange',this.ReferenceRange,...
            'ReferenceRCS',this.ReferenceRCS,...
            'DetectionCoordinates',this.DetectionCoordinates,...
            'AzimuthResolution',this.AzimuthResolution,...
            'AzimuthBiasFraction',this.AzimuthBias,...
            'RangeResolution',this.RangeResolution,...
            'RangeBiasFraction',this.RangeBias,...
            'RangeLimits',this.RangeLimits,...
            'CenterFrequency',this.CenterFrequency,...
            'TargetReportFormat',this.TargetReportFormat
            };


            if any(strcmp(this.ScanMode,{'Electronic','Mechanical and electronic'}))
                pvPairs=[pvPairs,{'ElectronicAzimuthLimits',this.ElectronicAzimuthLimits}];
                if this.HasElevation
                    pvPairs=[pvPairs,{'ElectronicElevationLimits',this.ElectronicElevationLimits}];
                end
            end
            if any(strcmp(this.ScanMode,{'Mechanical','Mechanical and electronic'}))
                pvPairs=[pvPairs,{'MaxAzimuthScanRate',this.MaxAzimuthScanRate,...
                'MechanicalAzimuthLimits',this.MechanicalAzimuthLimits}];
                if this.HasElevation
                    pvPairs=[pvPairs,{'MaxElevationScanRate',this.MaxElevationScanRate}];
                    pvPairs=[pvPairs,{'MechanicalElevationLimits',this.MechanicalElevationLimits}];
                end
            end


            if this.HasRangeAmbiguities
                pvPairs=[pvPairs,{'MaxUnambiguousRange',this.MaxUnambiguousRange}];
            end

            if this.HasRangeRate
                pvPairs=[pvPairs,{'HasRangeRateAmbiguities',this.HasRangeRateAmbiguities,...
                'RangeRateResolution',this.RangeRateResolution,...
                'RangeRateBiasFraction',this.RangeRateBias,...
                'RangeRateLimits',this.RangeRateLimits}];
            end

            if this.HasRangeRate&&(this.HasRangeRateAmbiguities||...
                this.HasFalseAlarms)
                pvPairs=[pvPairs,{'MaxUnambiguousRadialSpeed',this.MaxUnambiguousRadialSpeed}];
            end

            if this.HasElevation
                pvPairs=[pvPairs,{'ElevationResolution',this.ElevationResolution,...
                'ElevationBiasFraction',this.ElevationBias}];
            end


            if isfinite(this.MaxNumReports)
                pvPairs=[pvPairs,{'MaxNumReportsSource','Property','MaxNumReports',this.MaxNumReports}];
            end

        end

    end

end