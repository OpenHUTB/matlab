% 游戏引擎情景查看器
classdef GamingEngineScenarioViewer < handle

    properties(Dependent)
        Visible;  % 驾驶场景设计器的图形界面是否可见
    end


    properties(Hidden, SetAccess=protected)
        Animator;
        Application;
        IsValid
        LastWarnings;
        Offset=[0, 0, 0];
        % 接收实时更新数据的客户端
        client;
        % 是否根据实时数据更新场景
        is_dynamic = 0;
    end


    properties(Access=protected)
        SimulatorSampleChanged;
        SimulatorStateChanged;
        RoadPropertyChanged;
        ActorPropertyChanged;
        NumActorsChanging;
        NumRoadsChanging;
        NewScenario;
        AnimatorClosed;
    end

    events
        WindowClosed;
    end


    methods
        % 构建游戏引擎场景查看器
        function this = GamingEngineScenarioViewer(hApp, varargin)
            this.Application = hApp;        % 驾驶场景设计器应用程序
            % 构建游戏引擎场景动画师
            this.Animator = driving.scenario.internal.GamingEngineScenarioAnimator(varargin{:});

            this.SimulatorStateChanged = addStateChangedListener(hApp.Simulator, @this.onSimulatorStateChanged);
            this.SimulatorSampleChanged = addSampleChangedListener(hApp.Simulator, @this.onSimulatorSampleChanged);
            this.RoadPropertyChanged = event.listener(hApp, 'RoadPropertyChanged', @this.onRoadPropertyChanged);
            this.ActorPropertyChanged = event.listener(hApp, 'ActorPropertyChanged', @this.onActorPropertyChanged);
            this.NumRoadsChanging = event.listener(hApp, 'NumRoadsChanging', @this.onNumRoadsChanging);
            this.NumActorsChanging = event.listener(hApp, 'NumActorsChanging',@this.onNumActorsChanging);

            this.NewScenario = event.listener(hApp,'NewScenario',@this.newScenario);
            % 真正执行构建
            setup(this);
        end


        function delete(this)
            delete(this.Animator);
        end


        function stop(this)
            pause(this.Animator);
        end


        % 开始仿真（无效？）
        function start(this)
            start(this.Animator);
        end


        function vis=get.Visible(this)
            vis = isOpen(this.Animator);
        end


        function set.Visible(this,newVis)
            animator = this.Animator;
            if newVis
                if~isOpen(animator)
                    setup(this);
                end
            elseif isOpen(this)
                stop(animator);
                notify(this,'WindowClosed');
            end
        end
    end


    methods(Hidden)
        % 看动画师是否打开
        function b = isOpen(this)
            b = isOpen(this.Animator);
        end
        

        function b = isWindowOpen(this)
            b = isWindowOpen(this.Animator);
        end


        function onSimulatorStateChanged(this,~,~)
            if~isOpen(this)
                return;
            end
            simulator = this.Application.Simulator;
            animator = this.Animator;
            try
                if isRunning(simulator)
                    start(animator);
                else
                    pause(animator);
                end
            catch me
                if~strcmp(me.identifier,'sim3d:CommandWriter:write:Error') && isRunning(simulator)
                    setup(animator);
                else
                    stop(animator);
                end
            end
        end


        function onSimulatorSampleChanged(this,~,~)
            if this.Visible
                if isPaused(this.Application.Simulator)
                    this.Application.freezeUserInterface();
                end
                update(this);
            end
        end
        

        function update(this)
            animator = this.Animator;
            if ~isOpen(animator)
                setup(animator);
            end
            app = this.Application;
            simulator = app.Simulator;

            try
                animate_input = getAnimateInput(this);
                % 测试动态删除一辆车
                % 测试：drivingScenarioDesigner('LeftTurnScenarioNoSensors.mat')
                if this.is_dynamic == 1  % && getCurrentSample(simulator) == 100  % 获得当前从仿真开始后的采样时间; false &&
                    current_sample = getCurrentSample(simulator);
                    % current_sample = 1;
                    data_dir = 'D:\work\workspace\driving\perception\dynamic\id7\2';
                    radar_det = readmatrix(fullfile(data_dir, 'radarDet.txt'));
                    % 查找当前采样时间的检测结果
                    cur_det = find(radar_det(:, 1) == current_sample);
                    % frameNum, timestamp, id, x(m), y(m), vx(m/s), vy(m/s), rcs
                    obj_list = radar_det(cur_det, :);
                    animate_input.NumActors = numel(cur_det);

                    init_actors = simulator.Designer.Scenario.Actors;
                    temp_actors = init_actors(1);
                    animator_actors = init_actors;  % 虚幻场景中所有参与者的信息

                    % 参与者映射
                    tmp_actors_map =  this.Animator.ActorsMap;
                    cur_actor_map = containers.Map('KeyType','double','ValueType','any');
                    
                    % 参与者配置
                    tmp_profiles = this.Animator.Scenario.ActorProfiles;
                    cur_profiles = tmp_profiles;

                    scenario = this.Application.Simulator.Designer.Scenario;

                    for i = 1 : numel(cur_det)
                        actors(i).ActorID = obj_list(i, 3);
                        x = obj_list(i,4);
                        y = obj_list(i,5);
                        vx = obj_list(i, 6);
                        vy = obj_list(i, 7);
                        actors(i).Position = [x, y, 0];
                        actors(i).Velocity = [vx, vy, 0];
                        actors(i).Roll = 0;
                        actors(i).Pitch = 0;

                        heading = str2double(0);
                        if (heading >= 0. && heading <= 90.) || (heading >= 270. && heading <= 360.)
                            actors(i).Yaw = 90;
                        else
                            actors(i).Yaw = 270;
                        end

                        actors(i).AngularVelocity = [0, 0, 0];

                        % Animator中的参与者构建
                        car = vehicle(scenario, 'ClassID', obj_list(i, 3), ...
                            'Position', [x, y, 0], ...
                            'Velocity', [vx, vy, 0], ...
                            'Roll', actors(i).Yaw, ...
                            'Pitch', 0, ...
                            'Yaw', 0, ...
                            'AngularVelocity', [0, 0, 0]);
%                         temp_actors.ActorID = actors(i).ActorID;
%                         temp_actors.Position = actors(i).Position;
%                         temp_actors.Velocity = actors(i).Velocity;
%                         temp_actors.Yaw = actors(i).Yaw;
%                         temp_actors.Pitch = actors(i).Pitch;
%                         temp_actors.Roll = actors(i).Roll;
%                         animator_actors(i) = temp_actors;  % ?

                        % Animator的Actor Map 信息添加
                        % 5x3:4个轮子，一个车的躯干；
                        % tmp_actors_map(1)  x->(1,1); y-> (1,2)
                        cur_translation = tmp_actors_map(1).Translation;
                        cur_translation(1,1) = x;
                        cur_translation(1,2) = y;
                        cur_actors_map = tmp_actors_map(1);
                        cur_actors_map.Translation = cur_translation;
                        cur_actor_map(actors(i).ActorID) = cur_actors_map;

                        % ActorProfiles信息的添加
                        cur_profiles(i, :) = tmp_profiles(1, :);
                    end
                    animate_input.Actors = actors;
                    this.Application.Simulator.Designer.Scenario.Actors = animator_actors;

                    this.Animator.Scenario.ActorProfiles = cur_profiles;

                    this.Animator.Scenario.VehiclePoses.ActorPoses = actors;
                    
                    this.Animator.ActorsMap = cur_actor_map;

%                     animate_input.NumActors = animate_input.NumActors - 1;
%                     actors = animate_input.Actors;
%                     new_actors = actors(1:end-1);
%                     animate_input.Actors = new_actors;
%                     % 删除this.Animator中的Actor
%                     this.Animator.Scenario.Actors = this.Animator.Scenario.Actors(1:end-1);
%                     this.Animator.Scenario.ActorProfiles = this.Animator.Scenario.ActorProfiles(1:end-1);
%                     this.Animator.Scenario.VehiclePoses.ActorPoses = this.Animator.Scenario.VehiclePoses.ActorPoses(1:end-1);
%                     remove(this.Animator.ActorsMap, 2);
%                     % this.Animator.ActorsMap.Count = this.Animator.ActorsMap.Count-1;  % 只减少数量，会删错
%                     % 无法设置 'drivingScenario' 类的 'Actors' 属性，因为它为只读属性。
%                     this.Application.Simulator.Designer.Scenario.Actors = simulator.Designer.Scenario.Actors(1:end-1);
                end
                animate(this.Animator, animate_input, getCurrentSample(simulator)==1); % 索引超过数组元素的数量。索引不能超过 1。

                this.IsValid=true;
            catch me
                stop(this.Animator,true);
                this.IsValid=false;
                if~any(strcmp(me.identifier,{'sim3d:CommandReader:CommandReader:ReadError',...
                        'sim3d:CommandWriter:write:Error'}))
                    stop(simulator);
                    string=getString(message('driving:scenarioApp:GamingEngineStepError',me.message));
                    app.ScenarioView.errorMessage(string,me.identifier);
                end
            end
        end


        function newScenario(this,~,~)
            this.Visible = false;
        end


        function onRoadPropertyChanged(this,~,ev)
            props={'Centers','Width','BankAngle','Lanes'};
            if isPropChanged(ev.Property,props)
                this.Visible=false;
            end
        end


        function onActorPropertyChanged(this,~,ev)
            props={'AssetType','Length','Width','Height','Position','Roll','Pitch','Yaw','Waypoints','PlotColor'};
            if isPropChanged(ev.Property,props)
                this.Visible=false;
            end
        end

        function onNumRoadsChanging(this,~,~)
            this.Visible=false;
        end


        function onNumActorsChanging(this,~,~)
            this.Visible=false;
        end


        % 获得动画所有的输入参与者
        function input = getAnimateInput(this)
            s = this.Application.Scenario;
            p = this.Application.Simulator;
            poses = actorPoses(s);
            offset = this.Offset;
            actors = s.Actors;
            for indx = 1:numel(poses)
                pos=poses(indx).Position;
                if numel(actors)>=indx&&isa(actors(indx),'driving.scenario.Vehicle')
                    actor=actors(indx);
                    pos=driving.scenario.internal.translateVehiclePosition(...
                        pos,actor.RearOverhang,actor.Length,actor.Roll,actor.Pitch,actor.Yaw);
                end
                poses(indx).Position=pos+offset;
                poses(indx).ActorID=indx;
            end
            input=struct(...
                'NumActors',numel(s.Actors)+numel(s.Barriers),...
                'Time',getCurrentTime(p),...
                'Actors',poses);
        end


        % 启动虚幻引擎界面
        function setup(this)
            animator = this.Animator;

            [animator.Scenario,this.Offset,animator.Span,animator.Rotation] = getAnimatorScenario(this);
            animator.SampleTime = single(this.Application.SampleTime);
            try
                % 弹出虚幻引擎界面
                this.LastWarnings = setup(animator);
            catch ME
                stop(animator,true)
                if strcmp(ME.identifier, 'sim3d:CommandWriter:CommandWriter:SetupError')
                    msg=getString(message('driving:scenarioApp:GamingEngineSetupError'));
                elseif strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
                    msg=sprintf('%s\n', ME.message);
                    for indx=1:min(3,numel(ME.stack))
                        msg=sprintf('%s\n%s (%d)',ME.stack(indx).name,ME.stack(indx).line);
                    end
                else
                    msg=ME.message;
                end
                % 输出异常信息
                disp(msg);

                this.LastWarnings={msg};
                return;
            end
            % TODO：临时加的
            % 等待场景加载完成，不然自定义导出场景会直接关闭
            pause(0.75);

            onSimulatorStateChanged(this);
            if~isempty(animator.Scenario.Actors)
                update(this);
            end
            finishSetup(animator);
        end

        
        function[scenario,offset,span,rotation]=getAnimatorScenario(this)
            [scenario,offset,span,rotation] = get3DScenarioData(this.Application);
        end
    end
end


function b = isPropChanged(changedProps,props)
    if ischar(changedProps)
        changedProps={changedProps};
    end
    b = any(cellfun(@(c)any(strcmp(c,props)),changedProps));
end
