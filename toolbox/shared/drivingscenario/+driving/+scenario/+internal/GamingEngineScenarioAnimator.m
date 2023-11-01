classdef GamingEngineScenarioAnimator < handle
% 对驾驶场景进行照片级仿真的动画师
% 查看器模块的原型，这个在"Simulink中的ScenarioReader"和"驾驶场景设计器的GamingEngineScenarioViewer"中使用
    
    properties
        SampleTime = single(1/60);  % 采样时间
        % 包含的字段：
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
        Scenario = [];  % 需要仿真的驾驶场景
        EgoCarID = 1;
        ClassSpecifications;
        Span = 50;
        Rotation = 0;
    end


    properties (Hidden)
        % 用于测试的工厂变化
        AssetFactory;
    end

    
    % 预先计算好的常量（不可以改变？）
    % 为了动态修改ActorsMap，将protected改为public
    properties (SetAccess = public)  % SetAccess = protected, Hidden
        CommandWriter = [];  % 向虚幻引擎写出命令的写出器
        CommandReader = [];  % 从虚幻引擎读入命令的读取器
        StatusRead = [];
        Stopped = true;
        Paused = true;
        
        NumActors = 1;
        ActorClassIDs = [];
        ActorTrajectories = [];
        % 道路信息
        
        % 游戏对象
        MainCamera;  % 主相机
        Roads(1,:) sim3d.road.Road;
        
        % 参与者集合
        ActorsMap;
    end
    
    properties (Hidden)
        SetupReadTimeout   = int32(120);  % 准备阶段的读取超时限制
        RunningReadTimeout = int32(10);   % 运行时读取的超时限制
        PausedReadTimeout  = int32(1);    % 暂停时的读取超时限制
    end
    
    properties (Hidden, Constant)
        InstanceTag = 'GamingEngineScenarioAnimator';  % 实例标签：游戏引擎场景动画师
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
        

        function set.Scenario(this, scenario)  % function set.Scenario(this, scenario)
            this.Scenario = scenario;  % 驾驶场景
            this.NumActors = size(scenario.Actors,1);  % 参与者的数目
            this.EgoCarID = scenario.EgoCarId;  % 自我车的数目
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
        

        % 制作动画
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
                % 如果动画是在暂停时进行调用，则必须成为一步，以确保引擎正在运行
                writer.setState(int32(sim3d.engine.EngineCommands.RUN));
                writer.write();
                pause(0.1);
                % 读取到当前采样时刻的状态信息
                r = reader.read(); %#ok<NASGU>
            end
            
            % 发送步进命令
            writer.write();
            reader.read(); % this is slowing things down
            
            actors = this.ActorsMap;  % 没有动态变化
            actorIDs = keys(actors);
            for actorIdx = 1 : actors.Count
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
                ARotation = actorInfo.Rotation;  %  Actor Rotation
                % 同时旋转车辆的轮子
                if strcmp(actorInfo.Type, 'Bicyclist')
                    ARotation(1,3) = -yaw;
                    ARotation = this.computePedRotation(ARotation);
                elseif any(strcmp(actorInfo.Type,{'Bicyclist', 'MalePedestrian', 'FemalePedestrian'}))
                    ARotation(1,3) = yaw;
                    ARotation = this.computePedRotation(ARotation);
                else
                    ARotation(1,3) = yaw;  % 旋转矩阵（5x3） 第一行: 俯仰pitch,翻滚roll,偏航yaw
                    %                         Rotation(1,2) = 0; input.Actors(actorIdx).Roll;
                    ARotation(1,1) = -deg2rad(input.Actors(actorIdx).Pitch);  % 一般没有横滚
                    ARotation = this.turnWheels(ARotation, input.Actors(actorIdx).Velocity(1));
                end
                if reset  % 只有第一步才执行重置
                    actor.write(Translation, ARotation, ones(size(Translation)) );  % 参与者各项数据的写入
                else
                    actor.step(x, y, yaw);
                end
                actorInfo.Rotation = ARotation;
                actorInfo.Translation = Translation;
                % 参与者信息写入
                this.ActorsMap(actorIDs{actorIdx}) = actorInfo;
            end
            
            if this.Paused
                % Make sure the engine is put back into pause if it should
                % be paused.
                writer.setState(int32(sim3d.engine.EngineCommands.PAUSE));
                writer.write();
            end
        end
        

        % 初始化虚幻引擎
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

            this.initAndStartGame();  %  在虚幻引擎界面中显示内容（不用运行这句话，等一等前一行代码也可以显示）
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


        % 删除所有参与者
        function deleteActors(this)
            actors = this.ActorsMap;
            if ~isempty(actors)
                actor_keys = keys(actors);
                for idx = 1:length(actor_keys)
                    cur_idx = actor_keys(idx); cur_idx = cur_idx{1};
                    actor = actors(cur_idx);
                    % 明确删除所有参与者
                    delete(actor.Obj);
                    
                    % 从参与者集合中删除
                    actors.remove(cur_idx);
                end
            end
        end
        

%         % 删除所有参与者
%         function deleteActors(this)
%             actors = this.ActorsMap;
%             if ~isempty(actors)
%                 for idx = 1:length(actors)
%                     actor = actors(idx);
%                     % 明确删除所有参与者
%                     delete(actor.Obj);
%                     
%                     % Remove from the map
%                     actors.remove(idx);
%                 end
%             end
%         end

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

        
        % 获得指定参与者类型的维度
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
        
        % 初始化所有参与者的位置
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
        

        % 初始化并启动游戏引擎
        function initAndStartGame(this)
            % 发送初始化命令
            writer = this.CommandWriter;
            writer.setState(int32(sim3d.engine.EngineCommands.INITIALIZE));
            writer.write();  % 设置完状态就发送数据
            this.CommandReader.read();
        end
        

        % 设置读取和写入虚幻场景的命令
        function setupCommandReaderAndWriter(this)
            function updateImpl(World)
                disp('hello')
                World.UserData.Step = World.UserData.Step + 1;  % 每仿真一次，步数就加1
                actorFields = fields(world.Actors);
                actorPresent = strcmp(actorFields, 'Box2');
                if any(actorPresent) && (World.UserData.Step == 500)  % 当仿真到 500 步时就删除参与者
                    actorIndex=(find(actorPresent));
                    actorToDelete = actorFields{actorIndex};
                    World.remove(actorToDelete);
                end
            end

            % 开始工程
            exe_path = sim3d.engine.Env.AutomotiveExe();
            % 不从字符数组转成字符串数据，matlab\toolbox\shared\sim3d\sim3d\+sim3d\World.p的检查会报错：
            % ExecutablePath' 的值无效。它必须满足函数: @(x)isstring(x)||isempty(x)
            if ~isstring(exe_path)
                exe_path = string(exe_path);
            end
            % 区分是否需要像素流转发,以及判断是否是现有场景以及EmptyGrass4k4k场景判断。
            if ispref("Simulation3D", "ExecCmds")
                ExecCmds = getpref("Simulation3D", "ExecCmds");
                if ispref('Simulation3D', 'scene_path')
                    scene_path = getpref('Simulation3D', 'scene_path');
                else
                    scene_path = "/Game/Maps/EmptyGrass4k4k";
                end
                if ~isstring(scene_path)
                    scene_path = string(scene_path);
                end
                
                if ~isstring(ExecCmds)
                    ExecCmds = string(ExecCmds);
                end
                World = sim3d.World(exe_path, ...
                    scene_path, ...
                    ExecCmds, ...
                    "CommandLineArgs", ExecCmds, ...
                    'Update', @updateImpl);  % 'Update', @updateImpl
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

        
        % 计算行人腿的转动
        function ueRotation = computePedRotation(~, dsdRotation)
            % 3dSimYaw = -(dsdYaw + pi/2)
            ueRotation = dsdRotation;
            ueRotation(1, 3) = dsdRotation(1, 3) - pi / 2;
        end

        
        function Rotation = turnWheels(this, Rotation, Speed)  % 根据轮子的选择和速度计算旋转矩阵
            % r = r + dr
            if size(Rotation, 1) > 1
                Rotation(2:5,1) = Rotation(2:5,1) - Speed * this.SampleTime / 0.375;  % 四个轮子的横滚: Speed*this.SampleTime为水平方向移动的距离
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


        % 向场景添加参与者
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

        
        % 更新参与者轨迹
        function updateActorTrajectories(this)
            scenario = this.Scenario;
            actors = scenario.Actors;
            vehiclePoses = scenario.VehiclePoses; % 这有所有参与者的姿态，而不仅仅是车辆
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
