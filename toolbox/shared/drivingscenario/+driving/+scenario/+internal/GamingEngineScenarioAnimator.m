classdef GamingEngineScenarioAnimator < handle
% GamingEngineScenarioViewer ?游戏引擎（比如照片级的）driving-scenario
% 查看器模块的原型，这个在Simulink中的ScenarioReader中使用
    
    properties
        SampleTime = single(1/60);
        % Contains fields
        % {
        % Roads: {
        %   Centers
        %   Width
        %   Lanes
        %   BankAngle}
        % Actors: {NO FIELDS USED}
        % EgoCarId: 
        % ActorProfiles: {ClassID}
        % VehiclePoses: {Position: Yaw: Velocity} Only first
        Scenario = [];
        EgoCarID = 1;
        ClassSpecifications;
        Span = 50;
        Rotation = 0;
    end


    properties (Hidden)
        % Change of factory to use for testing.
        AssetFactory;
    end

    
    % Pre-computed constants
    properties (SetAccess = protected, Hidden)
        CommandWriter = [];
        CommandReader = [];
        StatusRead = [];
        Stopped = true;
        Paused = true;
        
        NumActors = 1;
        ActorClassIDs = [];
        ActorTrajectories = [];
        % 道路信息
        
        % 游戏对象
        MainCamera;
        Roads(1,:) sim3d.road.Road;
        
        % 其他参与者
        ActorsMap;
    end
    
    properties (Hidden)
        SetupReadTimeout   = int32(120);
        RunningReadTimeout = int32(10);
        PausedReadTimeout  = int32(1);
    end
    
    properties (Hidden, Constant)
        InstanceTag = 'GamingEngineScenarioAnimator';
    end
    
    events
        Closed
    end
    
    methods
        
        % 虚幻引擎场景动画师的构造器
        function this = GamingEngineScenarioAnimator(classSpecs, factory)
            if nargin < 1
                classSpecs = driving.internal.scenarioApp.ClassSpecifications;
            end
            if nargin < 2
                factory = driving.scenario.internal.GamingEngineAssetFactory();
            end
            this.ActorsMap = containers.Map('KeyType','double','ValueType','any');
            this.ClassSpecifications = classSpecs;
            this.AssetFactory = factory;
            matlabshared.application.InstanceCache.add(this.InstanceTag, this);
        end
        

        function set.Scenario(this, scenario)
            this.Scenario = scenario;
            this.NumActors = size(scenario.Actors,1); %#ok<MCSUP>
            this.EgoCarID = scenario.EgoCarId; %#ok<MCSUP>
        end

        
        function delete(this)
            stop(this, true);
            matlabshared.application.InstanceCache.remove(this.InstanceTag, this);
        end
        

        function b = isRunning(this)
            b = this.CommandWriter.getState() == 2;
        end
        

        function b = isOpen(this)
            try
                b = ~this.Stopped && isvalid(this.CommandWriter);
            catch me %#ok<NASGU>
                b = false;
            end
        end
        

        function pause(this)
            if ~this.Paused
                writer = this.CommandWriter;
                writer.setState(int32(sim3d.engine.EngineCommands.PAUSE));
                writer.write();
                pause(0.5);

                this.Paused = true;
            end
        end

        
        % 开始进行仿真
        function start(this)
            if this.Paused
                writer = this.CommandWriter;
                % 设置虚幻引擎的运行命令
                writer.setState(int32(sim3d.engine.EngineCommands.RUN));
                writer.write();
                this.CommandReader.setTimeout(this.RunningReadTimeout);
                this.Paused = false;
            end
        end

        
        function stop(this, force)
            if nargin < 2
                force = false;
            end
            if ~force && this.Stopped
                return;
            end
            this.Stopped = true;
            % 清除读写器
            writer = this.CommandWriter;
            reader = this.CommandReader;
            delete(this.MainCamera);
            delete(this.Roads);
            deleteActors(this);
            if ~isempty(writer) && isvalid(writer)
                try
                    writer.setState(int32(sim3d.engine.EngineCommands.STOP));
                    writer.write();
                    pause(1); % pause(sampleTime) is not enough to actually ensure the game is closed.
                catch me %#ok
                    % If the write errors it is bad, proceed to delete,
                    % this can happen when closing the window from the x.
                end
                pause(0.1)
                writer.delete();
            end
            if ~isempty(reader) && isvalid(reader)
                pause(0.1)
                reader.delete();
            end
            pause(0.1)
            notify(this, 'Closed');
            sim3d.engine.Engine.stop();
        end
        
        function animate(this, input, reset)
            % Input
            % struct('NumActors', int, 'Time', dbl, 'Actors',
            % struct('ActorId', int, 'Position', 3x1, 'Velocity', 3x1,
            % 'Roll', 'Pitch', 'Yaw', 'AngularVelocity'))
            writer = this.CommandWriter;
            reader = this.CommandReader;
            if nargin < 3
                reset = false;
            end
            if this.Paused
                % If animate is called while paused, it must be a step,
                % make sure the engine is running.
                writer.setState(int32(sim3d.engine.EngineCommands.RUN));
                writer.write();
                pause(0.1);
                r = reader.read(); %#ok<NASGU>
            end
            
            % send step command
            writer.write();
            reader.read(); % this is slowing things down
            
            actors = this.ActorsMap;
            actorIDs = keys(actors);
            for actorIdx = 1:actors.Count
                %actorID = actorIDs{actorIdx};
                actorID = input.Actors(actorIdx).ActorID;
                actorInfo = actors(actorID);
                % Change translation
                if ~isfield(actorInfo, 'Translation')
                    continue;
                end
                actor = actorInfo.Obj;
                x = input.Actors(actorIdx).Position(1);
                y = -input.Actors(actorIdx).Position(2);
                yaw = -deg2rad(input.Actors(actorIdx).Yaw);
                Translation = actorInfo.Translation;
                Translation(1,1) = x;
                Translation(1,2) = y;
                ARotation = actorInfo.Rotation;
                % For vehicles rotate the wheels as well
                if strcmp(actorInfo.Type, 'Bicyclist')
                    ARotation(1,3) = -yaw;
                    ARotation = this.computePedRotation(ARotation);
                elseif any(strcmp(actorInfo.Type,{'Bicyclist', 'MalePedestrian', 'FemalePedestrian'}))
                    ARotation(1,3) = yaw;
                    ARotation = this.computePedRotation(ARotation);
                else
                    ARotation(1,3) = yaw;
                    %                         Rotation(1,2) = 0; input.Actors(actorIdx).Roll;
                    ARotation(1,1) = -deg2rad(input.Actors(actorIdx).Pitch);
                    ARotation = this.turnWheels(ARotation,input.Actors(actorIdx).Velocity(1));
                end
                if reset
                    actor.write(Translation, ARotation, ones(size(Translation)));
                else
                    actor.step(x, y, yaw);
                end
                actorInfo.Rotation = ARotation;
                actorInfo.Translation = Translation;
                this.ActorsMap(actorIDs{actorIdx}) = actorInfo;
            end
            
            if this.Paused
                % Make sure the engine is put back into pause if it should
                % be paused.
                writer.setState(int32(sim3d.engine.EngineCommands.PAUSE));
                writer.write();
            end
        end
        
        function varargout = setup(this)
            % 关闭其他窗口
            instances = matlabshared.application.InstanceCache.get(this.InstanceTag);
            instances(instances == this) = [];
            for indx = 1:numel(instances)
                stop(instances(indx));
            end
            
            this.setActorClassIDs();
            
            % 设置参与者运行时的轨迹（仅仅初始化位置的时候需要）
            this.updateActorTrajectories();
            
            % 添加路和车道线
            w = this.addRoadsAndLanes();
            
            % 添加智能车和其他参与者
            w = [w; this.addActors()];
            this.setupCommandReaderAndWriter();  % 打开虚幻引擎黑色界面（无内容）

            this.initAndStartGame();  % 在虚幻引擎界面中显示内容（不用运行这句话，等一等前一行代码也可以显示）
            this.initPositionForAllActors();
            if this.Stopped
                sim3d.engine.Engine.start();
                this.Stopped = false;
            end
            pause(0.5);
            writer = this.CommandWriter;
            writer.setState(int32(sim3d.engine.EngineCommands.PAUSE));
            writer.write();
            this.CommandReader.setTimeout(this.RunningReadTimeout);
            pause(0.5);
            if nargout
                varargout = {w};
            end
        end
        
        function b = isWindowOpen(this)
            try
                [r, ~] = ReadSimulation3DCommand(this.CommandReader.Reader);
            catch me %#ok<NASGU>
                r = -1;
            end
            b = r >= 0;
        end
        
        function finishSetup(this)
            reader = this.CommandReader;
            if ~isempty(reader) && isvalid(reader)
                reader.setTimeout(this.PausedReadTimeout);
            end
        end
        
        function deleteActors(this)
            actors = this.ActorsMap;
            if ~isempty(actors)
                for idx = 1:length(actors)
                    actor = actors(idx);
                    % Explicitly delete the actors
                    delete(actor.Obj);
                    
                    % Remove from the map
                    actors.remove(idx);
                end
            end
        end
    end
    
    methods (Static)
        function assetTypes = getAssetTypes(isVehicle)
            % Don't just use sim3d.auto.VehicleTypes because we don't want this
            % to auto-update, we need to update code here and in DSD for
            % new vehicle types.
            if isVehicle
                assetTypes = {'Sedan', 'MuscleCar', 'SportUtilityVehicle', ...
                    'SmallPickupTruck', 'Hatchback', 'BoxTruck', 'Cuboid'};
            else
                assetTypes = {'Bicyclist', 'MalePedestrian', 'FemalePedestrian', 'Barrier', 'Cuboid'};
            end
        end
        
        function dims = getAssetDimensions(type)
            switch type
                case 'Sedan'
                    dims = struct( ...
                        'Length', 4.848, ...
                        'Width',  1.842, ...
                        'Height', 1.517, ...
                        'RearOverhang',  1.119, ...
                        'FrontOverhang', 0.911);
                case 'MuscleCar'
                    dims = struct( ...
                        'Length', 4.948, ...
                        'Width',  2.009, ...
                        'Height', 1.370, ...
                        'RearOverhang',  0.945, ...
                        'FrontOverhang', 0.983);
                case 'SportUtilityVehicle'
                    dims = struct( ...
                        'Length', 4.826, ...
                        'Width',  1.935, ...
                        'Height', 1.774, ...
                        'RearOverhang',  0.939, ...
                        'FrontOverhang', 0.991);
                case 'SmallPickupTruck'
                    dims = struct( ...
                        'Length', 6.142, ...
                        'Width',  2.073, ...
                        'Height', 1.990, ...
                        'RearOverhang',  1.321, ...
                        'FrontOverhang', 1.124);
                case 'Hatchback'
                    dims = struct( ...
                        'Length', 3.862, ...
                        'Width',  1.653, ...
                        'Height', 1.513, ...
                        'RearOverhang',  0.589, ...
                        'FrontOverhang', 0.828);
                case 'BoxTruck'
                    dims = struct(...
                        'Length', 9.000, ...
                        'Width',  3.000, ...
                        'Height', 3.500, ...
                        'RearOverhang',  2.410, ...
                        'FrontOverhang', 1.250);
                case 'Bicyclist'
                    dims = struct(...
                        'Length', 1.630, ...
                        'Width',  0.550, ...
                        'Height', 0.980 + .550); % height of rider will need to be updated
                case 'MalePedestrian'
                    dims = struct(...
                        'Length', 0.590, ...
                        'Width',  0.820, ...
                        'Height', 1.700);
                case 'FemalePedestrian'
                    dims = struct(...
                        'Length', 0.510, ...
                        'Width',  0.730, ...
                        'Height', 1.600);
                case 'ChildPedestrian'
                    dims = struct(...
                        'Length', 0.420, ...
                        'Width',  0.430, ...
                        'Height', 1.100);
                otherwise
                    % Any other objects return an empty structure and they
                    % will not have locked in values.
                    dims = struct;
            end
        end
    end
    
    methods (Access = protected)
        
        function initPositionForAllActors(this)
            actors = this.ActorsMap;
            actorIDs = keys(actors);
            for idx = 1:actors.Count
                actorInfo   = actors(actorIDs{idx});
                if isfield(actorInfo, 'Translation')
                    Translation = actorInfo.Translation;
                    ARotation   = actorInfo.Rotation;
                    Scale       = actorInfo.Scale;
                    actorInfo.Obj.write(Translation,ARotation,Scale);
                else
                    actorInfo.Obj.write();
                end
            end
        end
        
        function initAndStartGame(this)
            % 发送初始化命令
            writer = this.CommandWriter;
            writer.setState(int32(sim3d.engine.EngineCommands.INITIALIZE));
            writer.write();  % 发送
            this.CommandReader.read();
        end
        
        function setupCommandReaderAndWriter(this)
            % 开始工程
            exe_path = sim3d.engine.Env.AutomotiveExe();
            % 不从字符数组转成字符串数据，matlab\toolbox\shared\sim3d\sim3d\+sim3d\World.p的检查会报错：
            % ExecutablePath' 的值无效。它必须满足函数: @(x)isstring(x)||isempty(x)
            if ~isstring(exe_path)
                exe_path = string(exe_path);
            end
            % 区分是否需要像素流转发
            if ispref("Simulation3D", "ExecCmds")
                ExecCmds = getpref("Simulation3D", "ExecCmds");
                if ~isstring(ExecCmds)
                    ExecCmds = string(ExecCmds);
                end
                World = sim3d.World(exe_path, ...
                    "/Game/Maps/EmptyGrass4k4k", ...
                    ExecCmds, ...
                    "CommandLineArgs", ExecCmds);
            else
                World = sim3d.World(exe_path, "/Game/Maps/EmptyGrass4k4k"); % EmptyGrass4k4k or BlackLake
            end
            World.start();  % 打开虚幻引擎（黑色）界面
            % 游戏仿真同步控制
            reader = sim3d.io.CommandReader();
            writer = sim3d.io.CommandWriter();
            reader.setTimeout(this.SetupReadTimeout);
            writer.setSampleTime(this.SampleTime);
            this.CommandReader = reader;
            this.CommandWriter = writer;
        end
        
        function ueRotation = computePedRotation(~,dsdRotation)
            % 3dSimYaw = -(dsdYaw + pi/2)
            ueRotation = dsdRotation;
            ueRotation(1, 3) = dsdRotation(1, 3) - pi / 2;
        end
        
        function Rotation = turnWheels(this,Rotation,Speed)
            % r = r + dr
            if size(Rotation, 1) > 1
                Rotation(2:5,1) = Rotation(2:5,1) - Speed * this.SampleTime / 0.375;
            end
        end
        
        function w = addRoadsAndLanes(this)
            % Set up warnings cell array.
            warnings = matlabshared.application.IndexedWarnings;
            factory = this.AssetFactory;
            roads = this.Scenario.Roads;
            for roadIdx = 1:numel(roads)
                % Setup the lanes and banking angles (only limited lanes
                % supported now)
                roads(roadIdx).Index = roadIdx;
                [this.Roads(roadIdx), roadWarnings] = factory.createRoadAsset('',roads(roadIdx));
                addIndex(warnings, roadWarnings, roadIdx);
            end
            w = getWarningStrings(warnings, 'driving:scenarioApp:GamingEngineRoadError');
        end
        
        function setActorClassIDs(this)
            this.ActorClassIDs = ones(1,this.NumActors);
            actorProfiles = this.Scenario.ActorProfiles;
            for idx=1:this.NumActors
                this.ActorClassIDs(idx) = actorProfiles(idx).ClassID;
            end
        end
        
        function actorType = getActorTypeFromClassID(this,classID)
            classSpecs = this.ClassSpecifications;
            actorType = getProperty(classSpecs, classID, 'AssetType');
        end
               
        function w = addActors(this)
            factory = this.AssetFactory;
            actors = this.Scenario.Actors;
            warnings = matlabshared.application.IndexedWarnings;
            for actorIdx = 1:this.NumActors
                isEgo = isequal(actorIdx,this.EgoCarID);
                if isfield(actors(actorIdx), 'AssetType') && ~isempty(actors(actorIdx).AssetType)
                    actorType = actors(actorIdx).AssetType;
                else
                    actorType = this.getActorTypeFromClassID(this.ActorClassIDs(actorIdx));
                end
                [actor, warnids] = factory.createActorAsset(actorType, actors(actorIdx), isEgo);
                addIndex(warnings, warnids, actors(actorIdx).ActorID);
                
                if isEgo
                        cameraProperties = sim3d.sensors.MainCamera.getMainCameraProperties();
                        cameraProperties.ImageSize = [1, 1];
                        cameraProperties.HorizontalFieldOfView = 1;
                        cameraTransform = sim3d.utils.Transform([-6, 0, 2], deg2rad([0, -15, 0]));
                        this.MainCamera = factory.createCamera(1, actor.Tag, cameraProperties, cameraTransform);
                end
                
                this.ActorsMap(actorIdx) = actor;
            end
            shouldCameraWarn = false;
            if this.NumActors == 0 || isempty(this.EgoCarID)
                if this.Span > 500
                    shouldCameraWarn = true;
                end
                cameraZ = this.Span;
                if cameraZ < 20
                    cameraZ = 20;
                end
                cameraProperties = sim3d.sensors.MainCamera.getMainCameraProperties();
                cameraProperties.ImageSize = [1, 1];
                cameraProperties.HorizontalFieldOfView = 1;
                cameraTransform = sim3d.utils.Transform([1000, 0, cameraZ], [-this.Rotation -90 0]);
                this.MainCamera = factory.createCamera(1, 'Scene Origin', cameraProperties, cameraTransform);
            end
            w = getWarningStrings(warnings);
            if shouldCameraWarn
                w{end + 1} = getString(message('driving:scenarioApp:GamingEngineCameraTooFar'));
            end
            % Actor Spawning in Gaming Engine not implemented
            isSpawn = arrayfun(@(thisActor)any(thisActor.EntryTime>0),actors);
            isDespawn = arrayfun(@(thisActor)any(thisActor.ExitTime<inf),actors);
            if any(isSpawn) || any(isDespawn)
                w{end + 1} = getString(message('driving:scenarioApp:ActorSpawningIn3DDisplay'));
            end
        end
        
        function updateActorTrajectories(this)
            scenario = this.Scenario;
            actors = scenario.Actors;
            vehiclePoses = scenario.VehiclePoses; % this has all actor poses - not just vehicles
            numActors = this.NumActors;
            for actorIdx = 1:numActors
                % Just the first pose should do for initial-position. rest
                % is streamed to the stepImpl function
                actors(actorIdx).TPosition = vehiclePoses(1).ActorPoses(actorIdx).Position .* [1 -1 1];
                actors(actorIdx).TYaw      = single(deg2rad(vehiclePoses(1).ActorPoses(actorIdx).Yaw));
                actors(actorIdx).TVelocity = single(vehiclePoses(1).ActorPoses(actorIdx).Velocity(1));
            end
            this.Scenario.Actors = actors;
        end
    end
end


% [EOF]
