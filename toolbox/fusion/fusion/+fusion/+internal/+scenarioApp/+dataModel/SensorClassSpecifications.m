classdef SensorClassSpecifications<fusion.internal.scenarioApp.dataModel.ClassSpecifications


    methods
        function this=SensorClassSpecifications()
            this.Name='SensorClassSpecifications';
            if ispref('TrackingScenarioDesigner',this.Name)
                map=getpref('TrackingScenarioDesigner',this.Name);
                if~isa(map,'containers.Map')
                    map=[];
                end
            else
                map=[];
            end
            if isempty(map)
                map=this.getFactoryClassMap;
            end
            processOpenData(this,map);
        end

    end

    methods(Static)
        function map=getFactoryClassMap()


            noScanRadarPV={'ScanMode','No scanning','HasElevation',false};
            rotatorRadarPV={'ScanMode','Mechanical','HasElevation',false,'FieldOfView',[1;10],...
            'ElevationResolution',10/sqrt(12)};
            rasterRadarPV={'ScanMode','Mechanical','HasElevation',true,...
            'MechanicalScanLimits',[-45,45;-10,0],'ElectronicScanLimits',[-45,45;-10,0],...
            'MaxMechanicalScanRate',[75;75]};
            sectorRadarPV={'ScanMode','Mechanical','FieldOfView',[1;10],...
            'MechanicalScanLimits',[-45,45;-10,0],'ElectronicScanLimits',[-45,45;-10,0],...
            'HasElevation',false};

            import fusion.internal.scenarioApp.dataModel.SensorClassSpecifications.getNewSpecification;

            sens1=getNewSpecification(...
            'name','No Scanning',...
            'Category','radar',noScanRadarPV{:});
            sens2=getNewSpecification(...
            'name','Rotator',...
            'Category','radar',rotatorRadarPV{:});
            sens3=getNewSpecification(...
            'name','Sector',...
            'Category','radar',sectorRadarPV{:});
            sens4=getNewSpecification(...
            'name','Raster',...
            'Category','radar',rasterRadarPV{:});
            map=containers.Map(1:4,{sens1;sens2;sens3;sens4});

        end

        function classSpec=getNewSpecification(varargin)

            spec=fusion.internal.scenarioApp.dataModel.RadarSensorSpecification(1);

            allprops=properties(spec);

            classSpec=struct('name',getString(message('fusion:trackingScenarioApp:Component:EditorDefaultNewClassName')),...
            'Category','radar');

            for i=1:numel(allprops)
                classSpec.(allprops{i})=spec.(allprops{i});
            end

            classSpec=rmfield(classSpec,{'MountingLocation','MountingAngles','PlatformID','ID','Name','LookAngle'});

            classSpec.MaxMechanicalScanRate=spec.pMaxMechanicalScanRate;
            classSpec.MechanicalScanLimits=spec.pMechanicalScanLimits;
            classSpec.ElectronicScanLimits=spec.pElectronicScanLimits;





            classSpec=rmfield(classSpec,{'MaxAzimuthScanRate','MaxElevationScanRate'});
            classSpec=rmfield(classSpec,{'MechanicalAzimuthLimits','MechanicalElevationLimits'});
            classSpec=rmfield(classSpec,{'ElectronicAzimuthLimits','ElectronicElevationLimits'});
            classSpec=rmfield(classSpec,{'MaxNumReports'});


            if nargin>0
                if isstruct(varargin{1})
                    fields=fieldnames(varargin{1});
                    for indx=1:numel(fields)
                        classSpec.(fields{indx})=varargin{1}.(fields{indx});
                    end
                else
                    for indx=1:2:numel(varargin)
                        classSpec.(varargin{indx})=varargin{indx+1};
                    end
                end
            end
        end

    end

end