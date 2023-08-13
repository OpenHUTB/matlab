classdef ClassSpecifications<handle
    properties(SetAccess=protected,Hidden)
Map
    end

    methods
        function this=ClassSpecifications(map)
            if nargin<1
                if ispref('DrivingScenarioDesigner','ClassSpecifications')
                    map=getpref('DrivingScenarioDesigner','ClassSpecifications');
                    if~isa(map,'containers.Map')
                        map=[];
                    end
                else
                    map=[];
                end
            end
            if isempty(map)
                map=this.getFactoryClassMap;
            end
            processOpenData(this,map);
        end

        function clear(this)
            map=this.Map;
            ids=keys(map);
            for indx=1:numel(ids)
                remove(map,ids{indx});
            end
        end

        function spec=getSpecification(this,id)
            map=this.Map;
            if~isKey(map,id)
                map(id)=this.getNewSpecification(...
                'name',getString(message('driving:scenarioApp:UserDefinedText')),...
                'isVehicle',false,...
                'isMovable',true);
            end
            spec=map(id);
            spec.id=id;
        end

        function ids=getAllIds(this)
            ids=keys(this.Map);
            ids=[ids{:}];
        end

        function setSpecification(this,id,spec)
            map=this.Map;
            map(id)=spec;
        end

        function changeID(this,oldID,newID)
            map=this.Map;
            if isKey(map,oldID)
                spec=map(oldID);
                remove(map,oldID);
                map(newID)=spec;%#ok<*NASGU>
            end
        end

        function setProperty(this,id,name,value)
            spec=getSpecification(this,id);
            spec.(name)=value;
            setSpecification(this,id,spec);
        end

        function value=getProperty(this,id,name)
            spec=getSpecification(this,id);
            value=spec.(name);
        end

        function saveAsPreference(this)
            setpref('DrivingScenarioDesigner','ClassSpecifications',this.Map);
        end
    end

    methods(Static)
        function map=getFactoryClassMap()
            elev=[-90,90];
            azim=[-180,180];
            pattern=[10,10;10,10];
            map=containers.Map(1,driving.internal.scenarioApp.ClassSpecifications.getNewSpecification(...
            'name',getString(message('driving:scenarioApp:CarText')),...
            'AssetType','Sedan',...
            'Mesh',driving.scenario.carMesh));
            map(2)=driving.internal.scenarioApp.ClassSpecifications.getNewSpecification(...
            'name',getString(message('driving:scenarioApp:TruckText')),...
            'Length',8.2,...
            'Width',2.5,...
            'Height',3.5,...
            'AssetType','BoxTruck',...
            'Mesh',driving.scenario.truckMesh);
            map(3)=driving.internal.scenarioApp.ClassSpecifications.getNewSpecification(...
            'name',getString(message('driving:scenarioApp:BicycleText')),...
            'isVehicle',false,...
            'Length',1.7,...
            'Width',0.45,...
            'Height',1.7,...
            'Speed',5,...
            'AssetType','Bicyclist',...
            'Mesh',driving.scenario.bicycleMesh);
            map(4)=driving.internal.scenarioApp.ClassSpecifications.getNewSpecification(...
            'name',getString(message('driving:scenarioApp:PedestrianText')),...
            'isVehicle',false,...
            'Length',0.24,...
            'Width',0.45,...
            'Height',1.7,...
            'Speed',1.5,...
            'AssetType','MalePedestrian',...
            'Mesh',driving.scenario.pedestrianMesh,...
            'RCSPattern',[-8,-8;-8,-8]);
            [jerseyBarrierWidth,jerseyBarrierHeight]=driving.scenario.BarrierSegment.getJerseyBarrierDimensions;
            map(5)=driving.internal.scenarioApp.ClassSpecifications.getNewSpecification(...
            'name',getString(message('driving:scenarioApp:JerseyBarrierText')),...
            'isVehicle',false,...
            'isMovable',false,...
            'Length',5,...
            'Width',jerseyBarrierWidth,...
            'Height',jerseyBarrierHeight,...
            'Speed',0,...
            'AssetType','Barrier',...
            'BarrierType','Jersey Barrier',...
            'Mesh',driving.scenario.jerseyBarrierMesh,...
            'PlotColor',[0.65,0.65,0.65]);
            [guardrailWidth,guardrailHeight]=driving.scenario.BarrierSegment.getGuardrailDimensions;
            map(6)=driving.internal.scenarioApp.ClassSpecifications.getNewSpecification(...
            'name',getString(message('driving:scenarioApp:GuardrailBarrierText')),...
            'isVehicle',false,...
            'isMovable',false,...
            'Length',5,...
            'Width',guardrailWidth,...
            'Height',guardrailHeight,...
            'Speed',0,...
            'AssetType','Cuboid',...
            'BarrierType','Guardrail',...
            'Mesh',driving.scenario.guardrailMesh,...
            'PlotColor',[0.55,0.55,0.55]);
        end

        function spec=getNewSpecification(varargin)
            elev=[-90,90];
            azim=[-180,180];
            pattern=[10,10;10,10];
            spec=struct(...
            'isVehicle',true,...
            'isMovable',true,...
            'Length',4.7,...
            'Width',1.8,...
            'Height',1.4,...
            'Speed',driving.scenario.Path.DefaultSpeed,...
            'AssetType','Cuboid',...
            'BarrierType','None',...
            'RCSElevationAngles',elev,...
            'RCSAzimuthAngles',azim,...
            'RCSPattern',pattern,...
            'PlotColor',[],...
            'Mesh',[]);

            if nargin>0
                if isstruct(varargin{1})
                    fields=fieldnames(varargin{1});
                    for indx=1:numel(fields)



                        if strcmp(fields{indx},'name')||isfield(spec,fields{indx})
                            spec.(fields{indx})=varargin{1}.(fields{indx});
                        end
                    end
                    if~any(strcmp(spec.AssetType,driving.scenario.internal.GamingEngineScenarioAnimator.getAssetTypes(spec.isVehicle)))
                        spec.AssetType='Cuboid';
                    end
                else
                    for indx=1:2:numel(varargin)
                        spec.(varargin{indx})=varargin{indx+1};
                    end
                end
            end
        end
    end

    methods(Hidden)
        function data=getSaveData(this)
            data=this.Map;
        end

        function processOpenData(this,data)
            ids=keys(data);
            ids=[ids{:}];

            defaults=this.getFactoryClassMap;


            for id=ids
                loadSpec=data(id);

                if isfield(loadSpec,'Mesh')&&isempty(loadSpec.Mesh)
                    loadSpec=rmfield(loadSpec,'Mesh');
                end
                if defaults.isKey(id)
                    defaultSpec=defaults(id);





                    if partialMatch(defaultSpec,loadSpec)
                        fieldsToComplete=setdiff(fieldnames(defaultSpec),fieldnames(loadSpec));
                        for jndx=1:numel(fieldsToComplete)
                            f=fieldsToComplete{jndx};
                            loadSpec.(f)=defaultSpec.(f);
                        end
                    end
                end
                data(id)=this.getNewSpecification(loadSpec);
            end



            if isKey(data,5)
                if~partialMatch(data(5),defaults(5),true)
                    firstGap=find(diff([ids,inf])>1,1,'first');
                    data(ids(firstGap)+1)=defaults(5);
                    ids=sort([ids,firstGap+1]);
                end
            else
                data(5)=defaults(5);
            end
            if isKey(data,6)
                if~partialMatch(data(6),defaults(6),true)
                    firstGap=find(diff([ids,inf])>1,1,'first');
                    data(ids(firstGap)+1)=defaults(6);
                    ids=sort([ids,firstGap+1]);
                end
            else
                data(6)=defaults(6);
            end


















            this.Map=data;
        end
    end
end

function b=partialMatch(default,load,excludeName)


    b=false;
    fields=fieldnames(load);
    if nargin>2&&excludeName
        f=setdiff(fields,'name');
    end
    for indx=1:numel(fields)
        f=fields{indx};
        if isfield(default,f)&&isfield(load,f)
            if isa(default.(f),'extendedObjectMesh')&&isa(load.(f),'extendedObjectMesh')
                dMesh=default.(f);
                lMesh=load.(f);
                if~isequal(dMesh.Vertices,lMesh.Vertices)||~isequal(dMesh.Faces,lMesh.Faces)
                    return;
                end
            elseif~isequal(default.(f),load.(f))
                return;
            end
        end
    end
    b=true;
end


