classdef SensorSpecification<fusion.internal.scenarioApp.dataModel.Specification

    properties
        ID=1
        SensorEnabled=true
        MountingLocation=[0,0,0]
        MountingAngles=[0,0,0]
PlatformID
        UpdateRate=10
Type
    end


    methods

        function this=SensorSpecification(platformID,varargin)
            this@fusion.internal.scenarioApp.dataModel.Specification(varargin{:});
            if isempty(this.Name)
                this.Name='Sensor';
            end
            this.PlatformID=platformID;

        end


        function sensor=generateSensor(this)
            pvPairs=toPvPairs(this);
            if any(strcmp(this.Type,{'fusionRadar','monostaticRadar'}))
                sensor=fusionRadarSensor(pvPairs{:});
            elseif strcmp(this.Type,'ir')
                sensor=irSensor(pvPairs);
            end
        end


        function code=generateMatlabCode(this)
            preamble=matlab.lang.makeValidName(this.Name)+" = fusionRadarSensor('SensorIndex', "+num2str(this.ID);
            sensorStruct=this.toPvStruct();
            sensorStruct=rmfield(sensorStruct,'SensorIndex');

            radar=fusionRadarSensor('SensorIndex',1);
            fields=fieldnames(sensorStruct);
            for i=1:numel(fields)
                if isequal(sensorStruct.(fields{i}),radar.(fields{i}))
                    sensorStruct=rmfield(sensorStruct,fields{i});
                end
            end
            if isempty(sensorStruct)
                code=preamble+");";
            else
                code=this.fieldsToCode(sensorStruct,preamble+", ...",");");
            end
        end
    end
end
