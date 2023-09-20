% 对象创建和定义虚拟现实世界，并使用 Unreal Engine®运行协同仿真。
classdef World < handle

    properties(Constant = true, Hidden = true)
        Undefined(1, :)string = "<none>"
        MaxActorLimit = 10000;  % 仿真世界中最优有一万个参与者
    end


    properties(Constant = true, Access = private, Hidden = true)
        Worlds = containers.Map();
    end


    properties (Access = public, Hidden = true)
        ExecutablePath      % 指向可执行文件的路径
        Map(1, 1) string
        ExecCmds(1, :)string = "r.DefaultFeature.MotionBlur 0"
        RenderOffScreenFlag(1, :)string = ""
        CommandLineArgs(1, :)string = ""
        SampleTime = 1 / 60
        CommandReader = []
        CommandWriter = []
        SetupImpl = []
        UpdateImpl = []
        OutputImpl = []
        ReleaseImpl = []
        Root(1, 1)sim3d.internal.RootObject;
        StepTimer;
        RateLimiter = [0, 0];
    end


    % 可以从实例变量中访问到的属性
    properties (Access = public)
        Name        % 世界的名称，指定为字符串。
        Actors = struct();      % 世界中的所有参与者的结构体，其字段为参与者的名字。
        % world.UserData.Step = 0;
        % 将用户数据结构初始化为零。在更新函数中，将使用此结构从世界中删除参与者之前插入延迟。
        % % 用户指定的在仿真运行时可能需要的数据，指定为结构。
        % 需要定制的 Update, Output, Setup 和 Release 函数来使用 UserData 存储数据。UserData 确保所有这些功能都可以访问相同的数据。
        UserData
        Viewports = struct();
    end


    properties ( Access = protected )
        NewActorBuffer = [  ];
        Textures( 1, 1 )sim3d.internal.Textures;
        State = sim3d.engine.EngineCommands.NOP;
        CommandReadTimeout( 1, 1 )int32 = 120
    end

    methods

        % 场景世界的构造函数
        function self = World(varargin)
            parser = inputParser;  % 函数的输入解析器

            % 将一个可选输入添加到输入解析器模式中。将参数命名为 ExecutablePath，并为其赋予默认值 13。
            % 格式：(名字, 默认值, 验证函数)
            parser.addOptional("ExecutablePath", sim3d.engine.Env.AutomotiveExe(), @(x)isstring(x) || isempty(x) );
            parser.addOptional("Map", "/Game/Maps/EmptyScene", @isstring);
            % addParameter 在输入解析器模式中添加可选的 名-值对 参数
            parser.addParameter("ExecCmds", "", @isstring);        % 可执行命令的全部字符串？（可选）
            % addOptional 将可选的位置参数(直接输入到这个位置，该参数没有名称）添加到输入解析器模式中
            parser.addOptional("CommandLineArgs", "", @isstring);  % 提供命令行参数
            parser.addParameter("OverrideExecCmds", false, @islogical);
            parser.addParameter("RenderOffScreen", false, @islogical);  % 在后台运行仿真的选项，指定为 0(false) 或 1(true)。
            parser.addParameter("Setup", []);
            parser.addParameter("Output", []);  % 通过在每个仿真步骤执行 @outputFcn 来修改协同仿真。此自定义函数可用于将有关指定 sim3d.Actor 对象的数据发送到虚幻引擎。.
            parser.addParameter("Update", []);  % 自定义更新函数，用于从虚幻引擎读取有关指定参与者的数据，指定为用户定义函数的句柄。
            parser.addParameter("Release", []);
            parser.addParameter("Name", sim3d.World.generateWorldName(), @isstring);

            parser.parse(varargin{:});  % 对输入varargin进行解析

            self.Name = parser.Results.Name;
            self.ExecutablePath = parser.Results.ExecutablePath;
            self.Map = parser.Results.Map;
            self.CommandLineArgs = parser.Results.CommandLineArgs;
            self.SetupImpl = parser.Results.Setup;
            self.UpdateImpl = parser.Results.Update;
            self.OutputImpl = parser.Results.Output;
            self.ReleaseImpl = parser.Results.Release;
            self.Root = sim3d.internal.RootObject();
            self.Root.ParentWorld = self;

            if (self.Map == "/Game/Maps/EmptyScene")
                sim3d.World.validateLicense();
            end

            if parser.Results.OverrideExecCmds
                self.ExecCmds = parser.Results.ExecCmds;
            else
                self.ExecCmds = [self.ExecCmds, parser.Results.ExecCmds];
            end

            if parser.Results.RenderOffScreen
                self.RenderOffScreenFlag = "-RenderOffScreen";
            end
            self.Textures.reset();

            % 添加默认的像素流转发
            % self.ExecCmds = [self.ExecCmds, " -AudioMixer -PixelStreamingIP=localhost -PixelStreamingPort=8888"];

            sim3d.World.addWorld(self.Name, self);
        end


        function delete(self)
            if (~isempty(self.StepTimer))
                self.endSim();
            end
            self.Root.generateUniqueActorID( 1 );
            sim3d.World.removeWorld( self.Name );
        end


        function actor = add(self, actor, parent)
            if nargin == 2
                parent = self.Root;
            elseif nargin > 3 || nargin < 2
                error( message( "shared_sim3d:sim3dWorld:WrongNumOfArgsInAdd" ) );
            end

            actor.Parent = parent;
            actor.ParentWorld = self;
            self.add2ActorBuffer(actor.getTag());
        end

        
        function run(self, sampleTime, simulationTime)
            % R36
            % self sim3d.World
            % sampleTime(1, 1) single{ mustBePositive } = 1 / 50.0;
            arguments
                self sim3d.World
                sampleTime(1, 1) single{ mustBePositive } = 1/50.0;
                simulationTime(1, 1) single{ mustBePositive } = inf;
            end

            if ~isinf( simulationTime )
                cleanup = onCleanup(@self.endSim);
            end
            this.setup( sampleTime );
            if length( fieldnames( self.Actors ) ) > sim3d.World.MaxActorLimit
                error( message( "shared_sim3d:sim3dWorld:MaxActorLimitExceeded", sim3d.World.MaxActorLimit ) );
            elseif length( fieldnames( self.Actors ) ) > 1200
                self.updateTimeout();
            end
            self.start();
            self.reset();
            if isinf(simulationTime)
                self.StepTimer = timer('Period', sampleTime, 'ExecutionMode', 'fixedRate', 'TimerFcn', @self.onTimerEvent );
                self.StepTimer.start();
            else
                currentTime = 0;
                stepIndex = 0;
                try
                    while (currentTime < simulationTime)
                        self.step();
                        stepIndex = stepIndex + 1;
                        currentTime = stepIndex * sampleTime;
                    end
                catch
                end
            end
        end


        function remove(self, object)
            if nargin == 1
                self.Root.remove();
            elseif nargin == 2
                tag = '';
                if isa(object, 'sim3d.AbstractActor')
                    tag = object.getTag(  );
                elseif isa( object, 'char' )
                    tag = object;
                end
                if isfield( self.Actors, tag )
                    if ~isequal( self, self.Actors.( tag ).ParentWorld )
                        error( message( "shared_sim3d:sim3dWorld:DelActorInDiffWorld", tag ) );
                    end
                    self.Actors.( tag ).remove( false );
                end
            end
        end

        
        % 函数创建一个带有单个字段 Main 的视口，其中包含一个 sim3d.sensors.MainCamera 对象。
        function viewport = createViewport(self)
            cameraProperties = sim3d.sensors.MainCamera.getMainCameraProperties();
            cameraTransform = sim3d.utils.Transform( [  - 6, 0, 2 ], [ 0, 0, 0 ] );
            viewport = sim3d.sensors.MainCamera( 1, 'Scene Origin', cameraProperties, cameraTransform );
            self.add( viewport );
            self.Viewports.Main = viewport;
        end
        
    end


    methods (Access = public, Hidden = true)
        function setup(self, sampleTime)
            % R36
            % self sim3d.World
            % sampleTime(1, 1)single{ mustBePositive }
            arguments
                self sim3d.World
                sampleTime(1,1) single{mustBePositive}
            end
            
            status = sim3d.engine.Engine.getState(  );
            if status == sim3d.engine.EngineCommands.RUN || status == sim3d.engine.EngineCommands.INITIALIZE
                error( message( "shared_sim3d:sim3dWorld:SimulationSessionSingleton" ) );
            end
            self.Root.setupTree(  );
        
            self.SampleTime = sampleTime;
            self.CommandReader = sim3d.io.CommandReader(  );
            self.CommandReader.setTimeout( self.CommandReadTimeout );
            self.CommandWriter = sim3d.io.CommandWriter(  );
            self.CommandWriter.setSampleTime( self.SampleTime );
        
            if ~isempty( self.SetupImpl )
                self.SetupImpl( self );
            end
            self.emptyActorBuffer();
        end

        % 打开虚幻引擎（黑色）界面
        function start(self)
            status = sim3d.engine.Engine.getState();
            if status == sim3d.engine.EngineCommands.RUN
                error(message("shared_sim3d:sim3dWorld:SimulationSessionSingleton"));
            end
            sim3d.engine.Engine.startSimulation(self.asCommand());
        end


        function reset( self )
            status = sim3d.engine.Engine.getState();
            if status == sim3d.engine.EngineCommands.RUN || status == sim3d.engine.EngineCommands.INITIALIZE
                error( message( "shared_sim3d:sim3dWorld:SimulationSessionSingleton" ) );
            end
        
            self.CommandWriter.setState( int32( sim3d.engine.EngineCommands.INITIALIZE ) );
            self.CommandWriter.write();
            self.CommandReader.read(  );
            sim3d.engine.Engine.setState( sim3d.engine.EngineCommands.RUN );
            self.State = sim3d.engine.EngineCommands.RUN;
        end


        function updateNewActorsInWorld(self)
            for n = 1:length( self.NewActorBuffer )
                newactor = self.Actors.( self.NewActorBuffer{ n } );
                newactor.setup();
                newactor.reset();
            end
            self.emptyActorBuffer();
        end


        function step( self )
        
            if ~isempty( self.OutputImpl )
                self.OutputImpl( self );
            end
            self.updateNewActorsInWorld();
            self.Root.output();
            self.updateNewActorsInWorld();
            self.CommandWriter.setState( int32( sim3d.engine.EngineCommands.RUN ) );
            self.CommandWriter.write();
            self.CommandReader.read();
            self.Root.update();
        
            if ~isempty(self.UpdateImpl)
                self.UpdateImpl(self)
            end
        end

        function stop(self)
            self.CommandWriter.setState( int32( sim3d.engine.EngineCommands.STOP ) );
            self.CommandWriter.write();
            if self.State == sim3d.engine.EngineCommands.RUN
                sim3d.engine.Engine.setState( sim3d.engine.EngineCommands.STOP);
                self.State = sim3d.engine.EngineCommands.STOP;
            end
        end


        function release(self)
            if ~isempty(self.ReleaseImpl)
                self.ReleaseImpl(self);
            end
            if ~isempty(self.CommandWriter)
                self.CommandWriter.delete();
            end
            if ~isempty(self.CommandReader)
                self.CommandReader.delete();
            end
            self.Root.delete();
            sim3d.engine.Engine.stop();
        end

        
        % 设置exe执行时的启动参数
        function command = asCommand(self)
            if strcmp(self.ExecutablePath, sim3d.World.Undefined) || isempty(self.ExecutablePath)
                command = sim3d.World.Undefined;
                return
            end
        
            command.FileName = self.ExecutablePath;  % 虚幻引擎exe的路径

            command.Arguments = "";

            if (~strcmp(self.Map, ""))  % 存在地图，比如：比如：/Game/Maps/EmptyGrass4k4k
                command.Arguments = command.Arguments.append(...
                    strcat(self.Map, " ") ...
                 );
            end

            % self.ExecCmds = "r.DefaultFeature.MotionBlur 0"    ""
            command.Arguments = command.Arguments.append(  ...
                strcat("-nosound", " " ),  ...
                strcat("-ExecCmds=", """", strjoin(self.ExecCmds, ";"), """", " ") ...
                    );

            if (~strcmp(self.CommandLineArgs, ""))
                command.Arguments = command.Arguments.append(...
                    strcat(self.CommandLineArgs, " ") ...
                );
            end
            if (~strcmp( self.RenderOffScreenFlag, "" ) )
                command.Arguments = command.Arguments.append(  ...
                    strcat(self.RenderOffScreenFlag, " " ) ...
                );
            end
            command.Arguments = command.Arguments.append(  ...
                strcat( "-pakdir=", """", fullfile(userpath, "sim3d_project", string(sprintf( 'R%s', version( '-release' ) ) ), "WindowsNoEditor", "AutoVrtlEnv", "Content", "Paks" ), """" ) ...
                );
            % 添加像素流转发参数
            command.Arguments = command.Arguments.append(" -AudioMixer -PixelStreamingIP=localhost -PixelStreamingPort=8888");
        end


        function add2ActorBuffer( self, actorName )
            self.NewActorBuffer{ end  + 1 } = actorName;
        end
        
        function emptyActorBuffer(self)
            self.NewActorBuffer = [];
        end
        
        
        function cleanupTextures(self)
            self.Textures.reset();
        end
        
        function textureName = addTexture( self, varargin )
            textureName = self.Textures.add( varargin{ : } );
        end
        
        function removeTexture( self, textureName )
            self.Textures.remove( textureName );
        end
        
        function addActorToTexture( self, texture, actorName )
            self.Textures.addActor( texture, actorName );
        end
        
        function addTextureToActor( self, actor, texture )
            self.Textures.addTexture( texture, actor );
        end
        
        function removeActorFromTexture( self, texture, actorName )
            self.Textures.removeActor( texture, actorName );
        end
        
        function textureData = getTextureData( self, textureName )
            textureData = self.Textures.getTextureData( textureName );
        end
        
        function textureStruct = exportTexture( self )
            textureStruct = self.Textures.exportAsStruct(  );
        end
        
        function textureMap = importTexture( self, textureStruct )
            textureMap = self.Textures.importFromStruct( textureStruct );
        end
        
        function atMock = IsMockWorld( self )
            atMock = isa( self, 'MockWorld' );
        end

        function updateTimeout(self)
            self.CommandReadTimeout = length( fieldnames( self.Actors ) ) * 0.1;
        end

        function onTimerEvent( self, src, eventData )%#ok
            try
                self.step(  );
            catch
                self.endSim(  );
            end
        end

        function endSim( self )
        
            if ~isempty( self.StepTimer )
                self.StepTimer.stop(  );
                self.StepTimer.delete(  );
                self.StepTimer = [  ];
            end
            self.stop(  );
            self.release(  );
            self.Root.generateUniqueActorID( 1 );
        end

        function keepRate( self, Rate )
        
            self.RateLimiter( 2 ) = self.RateLimiter( 2 ) + 1;
            ExpectedTime = self.RateLimiter( 1 ) + self.RateLimiter( 2 ) / Rate;
            CurrentTime = now * 86400;
            Delay = ( ExpectedTime - CurrentTime );
            if abs( Delay ) > 10 / Rate
                Delay = 0.5 / Rate;
                self.RateLimiter = [ now * 86400, 0 ];
            end
            if Delay > 0
                pause( Delay );
            else
                drawnow;
            end
        end

    end


    methods ( Static = true, Access = public, Hidden = false )
        function world = getWorld( worldName )
    
            world = [  ];
            map = sim3d.World.Worlds;
            if ( map.isKey( worldName ) )
                world = map( worldName );
            end
        end
        function worldName = generateWorldName(  )
    
            map = sim3d.World.Worlds;
            worldName = sprintf( "World%d", map.Count );
        end
    end


    methods ( Static = true, Access = public, Hidden = true )

        function validateLicense
            licenseCheckedOut = builtin( 'license', 'checkout', 'virtual_reality_toolbox' );
            licenseExists = builtin( 'license', 'test', 'virtual_reality_toolbox' );
            if licenseCheckedOut ~= 1 || licenseExists ~= 1
                error( message( 'shared_sim3dblks:sim3dsharederrAutoIcon:invalidSL3DLicense' ) );
            end
        end


        function addWorld( worldName, world )
    
            map = sim3d.World.Worlds;
            if ( ~map.isKey( worldName ) )
                map( worldName ) = world;%#ok
            else
                error( message( "shared_sim3d:sim3dWorld:WorldNameDuplicated", worldName ) );
            end
        end


        function removeWorld( worldName )
    
            map = sim3d.World.Worlds;
            if ~isempty( map ) && ( map.isKey( worldName ) )
                map.remove( worldName );
            end
        end


        function world = buildWorldFromModel( modelName )
    
            world = sim3d.World.getWorld( modelName );
            if ~isempty( world )
                if ~isvalid( world )
    
                    sim3d.World.removeWorld( modelName );
                    world = sim3d.World( 'Name', modelName );
                end
            else
    
                world = sim3d.World( 'Name', modelName );
            end
            libraryBlock = 'sim3dlib/Simulation 3D Actor';
            blockList = find_system( modelName, 'LookUnderMasks', 'on',  ...
                'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
                'FollowLinks', 'on', 'ReferenceBlock', libraryBlock );
    
            for i = 1:length( blockList )
                blockOp = get_param( blockList{ i }, 'Operation' );
                if ( strcmp( blockOp, 'Create at setup' ) )
                    sim3d.World.createBlockActors( blockList{ i }, world );
                end
            end
            world.Root.generateUniqueActorID( 1 );
        end


        function actor = createBlockActors( block, world )
            maskObj = get_param( block, 'MaskObject' );
            actorPrm = maskObj.getParameter( 'ActorName' );
            actorName = actorPrm.Value;
            parentPrm = maskObj.getParameter( 'ParentName' );
            parentName = parentPrm.Value;
            translationPrm = maskObj.getParameter( 'Translation' );
            translation = eval( translationPrm.Value );
            rotationPrm = maskObj.getParameter( 'Rotation' );
            rotation = eval( rotationPrm.Value );
            scalePrm = maskObj.getParameter( 'Scale' );
            scale = eval( scalePrm.Value );
            if isfield( world.Actors, actorName )
    
                return ;
            end
            actor = sim3d.Actor( 'ActorName', actorName,  ...
                'Translation', translation,  ...
                'Rotation', rotation,  ...
                'Scale', scale,  ...
                'Mobility', sim3d.utils.MobilityTypes.Movable );
            world.add( actor );
            if ~( strcmp( 'Scene Origin', parentName ) )
                actor.setParentIdentifier( parentName );
            end
            SrcPrm = maskObj.getParameter( 'SourceFile' );
            SrcFile = SrcPrm.Value;
            InitPrm = maskObj.getParameter( 'InitScriptText' );
            InitScript = InitPrm.Value;
            if ~isempty( SrcFile )
                try
                    [ ~, name, ext ] = fileparts( strtrim( SrcFile ) );
                    if strcmpi( ext, '.m' )
                        feval( name, actor, world );
                    else
                        actor.load( SrcFile );
                    end
                catch e
                    error( e.message );
                end
            end
            if ~isempty( InitScript )
                try
                    World = world;
                    Actor = actor;
                    eval( InitScript );
                catch e
                    error( e.message );
                end
            end
        end

    end

end
