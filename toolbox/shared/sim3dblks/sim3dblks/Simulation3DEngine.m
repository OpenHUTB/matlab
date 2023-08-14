classdef(StrictDefaults)Simulation3DEngine<matlab.System&...
Simulation3DHandleMap






    methods(Access=protected)
        function icon=getIconImpl(~)
            icon={'3D Scene Configuration'};
        end
    end

    properties(Constant=true,Access=private)
        COMMAND_READ_TIMEOUT=int32(240)
    end

    properties(Constant=true,Access=public)
        MIN_SAMPLE_TIME=0.01
        DEFAULT_SAMPLE_TIME=0.02
    end

    properties(Nontunable)



        ProjectName(1,:)char=sim3d.World.Undefined




        OpenDRIVEName(1,:)char=sim3d.World.Undefined




        SceneDesc(1,:)char=''




        ProjectFormat(1,:)char=getString(message('shared_sim3dblks:sim3dblkConfig:DefaultScenes'))




        SampleTime(1,1)double{mustBeGreaterThanOrEqual(SampleTime,0.01)}=Simulation3DEngine.DEFAULT_SAMPLE_TIME;
    end

    properties











        WeatherConfigParas(1,6)single=[40,90,10,0,0,1]

    end

    properties(Nontunable)



        EnableWindow(1,1)logical=true




        EnableWeather(1,1)logical=false



        EnableRemoteAccess(1,1)logical=false



        EnableOpenDRIVE(1,1)logical=false
    end

    properties(Hidden,Constant)
        ProjectFormatSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkConfig:DefaultScenes',...
        'shared_sim3dblks:sim3dblkConfig:UnrealExecutable',...
        'shared_sim3dblks:sim3dblkConfig:UnrealEditor'});
        WeatherActorName='weatherconfig';
    end

    properties(Access=private)
        Reader=[]
        Writer=[]
        publisher=[];
        StartEventListenerHandle=[]
        PauseEventListenerHandle=[]
        ContinueEventListenerHandle=[]
        StopEventListenerHandle=[]
        EngineTimer=[]
        Project=[]
        State=sim3d.engine.EngineCommands.STOP;
        WeatherConfigWriter=[];
        LastWeatherConfigParas=[40,90,10,0,0,1];
        StreamerPort;
        HttpPort;
        MaxHttpPort=9999;
        MessageToSim3DVDG;
    end

    methods(Access=protected)
        function sts=getSampleTimeImpl(self)
            Simulation3DEngine.getEngineBlocks(gcb);
            if self.SampleTime==-1
                sts=createSampleTime(self,'Type','Inherited');
            else
                sts=createSampleTime(self,'Type','Discrete','SampleTime',self.SampleTime);
            end
        end

        function setupImpl(self)
            if coder.target('MATLAB')
                sim3d.engine.Engine.start();
                world=sim3d.World.getWorld(string(bdroot));
                if~isempty(world)
                    world.delete();
                    sim3d.World.removeWorld(string(bdroot));
                end
                if self.EnableRemoteAccess

                    [~,cmdCheckNodejs]=system("node -v");
                    if contains(cmdCheckNodejs,'node')
                        error(message('shared_sim3dblks:sim3dblkConfig:noNodejs'));
                    end
                    DefHttp=sim3d.engine.Engine.getHttpPort();
                    DefStreamer=sim3d.engine.Engine.getStreamerPort();
                    path=fullfile(matlabroot,"toolbox/shared/sim3dblks/sim3dblks/SignallingWebServer/");
                    flagNodejs=0;

                    if~(exist(strcat(path,'node_modules'),'dir')==7)
                        disp("Installing Node.js dependencies");
                        [~,~]=system(strcat("npm --prefix ",path," install ",path," && exit"));
                        flagNodejs=1;
                    end
                    if flagNodejs==1
                        pause(10);
                        disp("Installation complete!")
                    end

                    while(true)
                        if(DefStreamer==DefHttp)
                            warning(['Http port and streamer port are initialised with same port number values. '...
                            ,'Auto-incrementing the http port']);
                            DefHttp=DefHttp+1;
                        end

                        cmdStreamer=strcat("netstat -ano | grep ",string(DefStreamer));
                        cmdHttp=strcat("netstat -ano | grep ",string(DefHttp));
                        [~,cmdoutStreamer]=system(cmdStreamer);
                        [~,cmdoutHttp]=system(cmdHttp);
                        if(isempty(cmdoutStreamer)&&isempty(cmdoutHttp))
                            self.HttpPort=DefHttp;
                            self.StreamerPort=DefStreamer;
                            break;
                        else
                            if~isempty(cmdoutHttp)
                                DefHttp=DefHttp+1;
                            else
                                DefStreamer=DefStreamer+1;
                            end
                        end
                    end
                    if self.HttpPort>=self.MaxHttpPort
                        disp("No available ports for establishing connection! Please vacate a port.")
                    else
                        [~,out]=system("ipconfig | grep -m1 'IPv4 Address'");
                        ipv4address=split(out,':');
                        ipv4address=ipv4address(2);
                        IPaddress=strtrim(string(ipv4address));
                        fprintf(['To view the simulation on the web on the current or another device on the same network, start a '...
                        ,'web browser and navigate to: '...
                        ,'<a href = "http://%s:%s">http://%s:%s</a> \n'],...
                        IPaddress,string(self.HttpPort),IPaddress,string(self.HttpPort));
                        disp('In the browser window, click on start button, followed by play button icon to visualize the simulation.');
                        cmdLineArgs=strcat("-PixelStreamingIP=localhost -PixelStreamingPort=",string(self.StreamerPort));
                        serverFile=strcat(path,'cirrus.js');

                        serverArgs=strcat("start /b node ",serverFile," --httpPort ",string(self.HttpPort)," --streamerPort ",string(self.StreamerPort));
                        [~,~]=system(serverArgs);
                    end
                end

                self.MessageToSim3DVDG=struct(...
                'ProjectFormat',[],...
                'MatFile',[],...
                'EnableOpenDRIVEFile',[],...
                'OpenDRIVEFile',[]);

                if strcmp(self.ProjectFormat,getString(message('shared_sim3dblks:sim3dblkConfig:DefaultScenes')))
                    switch(self.SceneDesc)
                    case getString(message('shared_sim3dblks:sim3dblkConfig:StraightRoad'))
                        sceneName='/Game/Maps/HwStrght';
                        self.MessageToSim3DVDG.MatFile=fullfile(matlabroot,'toolbox','shared','drivingscenario','PrebuiltScenarios','Simulation3D','StraightRoad.mat');
                    case getString(message('shared_sim3dblks:sim3dblkConfig:CurvedRoad'))
                        sceneName='/Game/Maps/HwCurve';
                        self.MessageToSim3DVDG.MatFile=fullfile(matlabroot,'toolbox','shared','drivingscenario','PrebuiltScenarios','Simulation3D','CurvedRoad.mat');
                    case getString(message('shared_sim3dblks:sim3dblkConfig:ParkingLot'))
                        sceneName='/Game/Maps/SimpleLot';
                    case getString(message('shared_sim3dblks:sim3dblkConfig:DoubleLaneChange'))
                        sceneName='/Game/Maps/DblLnChng';
                        self.MessageToSim3DVDG.MatFile=fullfile(matlabroot,'toolbox','shared','drivingscenario','PrebuiltScenarios','Simulation3D','DoubleLaneChange.mat');
                    case getString(message('shared_sim3dblks:sim3dblkConfig:OpenSurface'))
                        sceneName='/Game/Maps/BlackLake';
                    case getString(message('shared_sim3dblks:sim3dblkConfig:USCityBlock'))
                        self.MessageToSim3DVDG.MatFile=fullfile(matlabroot,'toolbox','shared','drivingscenario','PrebuiltScenarios','Simulation3D','USCityBlock.mat');
                        sceneName='/Game/Maps/USCityBlock';
                    case getString(message('shared_sim3dblks:sim3dblkConfig:USHighway'))
                        sceneName='/Game/Maps/USHighway';
                        self.MessageToSim3DVDG.MatFile=fullfile(matlabroot,'toolbox','shared','drivingscenario','PrebuiltScenarios','Simulation3D','USHighway.mat');
                    case getString(message('shared_sim3dblks:sim3dblkConfig:VirtualMcity'))
                        sceneName='/Game/Maps/VirtualMCity';
                    case getString(message('shared_sim3dblks:sim3dblkConfig:LargeParkingLot'))
                        sceneName='/Game/Maps/LargeParkingLot';
                    case getString(message('shared_sim3dblks:sim3dblkConfig:Airport'))
                        sceneName='/MathWorksAerospaceContent/Maps/Airport';
                    case getString(message('shared_sim3dblks:sim3dblkConfig:Geospatial'))
                        sceneName='/MathWorksGeoSpatial/Maps/GeoSpatialMap';
                    case getString(message('shared_sim3dblks:sim3dblkConfig:EmptyScene'))
                        sceneName='/Game/Maps/EmptyScene';
                    case 'Suburban scene'
                        sceneName='/MathWorksUAVContent/Maps/Suburban';
                    otherwise
                        sceneName='';
                    end
                    if self.EnableRemoteAccess&&self.HttpPort<self.MaxHttpPort
                        self.Project=sim3d.World(string(self.ProjectName),string(sceneName),'CommandLineArgs',cmdLineArgs,'RenderOffScreen',~self.EnableWindow,'Name',string(bdroot));
                    else
                        self.Project=sim3d.World(string(self.ProjectName),string(sceneName),'RenderOffScreen',~self.EnableWindow,'Name',string(bdroot));
                    end

                elseif strcmp(self.ProjectFormat,getString(message('shared_sim3dblks:sim3dblkConfig:UnrealExecutable')))
                    self.MessageToSim3DVDG.EnableOpenDRIVEFile=self.EnableOpenDRIVE;
                    self.MessageToSim3DVDG.OpenDRIVEFile=self.OpenDRIVEName;
                    if self.EnableRemoteAccess&&self.HttpPort<self.MaxHttpPort
                        self.Project=sim3d.World(string(self.ProjectName),string(self.SceneDesc),'CommandLineArgs',cmdLineArgs,'RenderOffScreen',~self.EnableWindow,'Name',string(bdroot));
                    else
                        self.Project=sim3d.World(string(self.ProjectName),string(self.SceneDesc),'RenderOffScreen',~self.EnableWindow,'Name',string(bdroot));
                    end

                elseif strcmp(self.ProjectFormat,getString(message('shared_sim3dblks:sim3dblkConfig:UnrealEditor')))
                    self.MessageToSim3DVDG.EnableOpenDRIVEFile=self.EnableOpenDRIVE;
                    self.MessageToSim3DVDG.OpenDRIVEFile=self.OpenDRIVEName;
                    self.Project=sim3d.World(sim3d.World.Undefined,'Name',string(bdroot));
                    arch=computer('arch');
                    switch arch
                    case 'win64'
                        unrealProc=System.Diagnostics.Process.GetProcessesByName('UE4Editor');
                        status=unrealProc.Length>0;
                    case 'glnxa64'
                        [~,cmdout]=system("ps -fww");
                        status=contains(cmdout,'UE4Editor');
                    otherwise
                        notSupportedPlatformException=MException('sim3D:Engine:setup:PlatformException',...
                        ['3D simulation engine interface is not supported on the ',...
                        computer('arch'),' platform.']);
                        throw(notSupportedPlatformException);
                    end

                    if~status
                        error(message('shared_sim3dblks:sim3dblkConfig:noUnrealEditorOpen'));
                    end
                else
                    self.Project=sim3d.World('','Name',string(bdroot));
                end
                self.MessageToSim3DVDG.ProjectFormat=self.ProjectFormat;

                self.publisher=sim3d.io.Publisher('Sim3DVDG Lanes');
                self.publisher.publish(self.MessageToSim3DVDG);
                modelHandle=get_param(bdroot(gcb),'object');
                self.StartEventListenerHandle=addListener(modelHandle,'StartEvent',@self.onStartEvent);
                self.PauseEventListenerHandle=addListener(modelHandle,'PauseEvent',@self.onPauseEvent);
                self.ContinueEventListenerHandle=addListener(modelHandle,'ContinueEvent',@self.onContinueEvent);
                self.StopEventListenerHandle=addListener(modelHandle,'StopEvent',@self.onStopEvent);
                self.EngineTimer=timer('Period',2,...
                'ExecutionMode','fixedRate',...
                'TimerFcn',@self.onTimerEvent);


                if self.EnableWeather
                    self.WeatherConfigWriter=sim3d.utils.WeatherConfiguration(self.WeatherActorName,self.WeatherConfigParas,false);
                else
                    self.WeatherConfigWriter=[];
                end

                if self.loadflag
                    ModelName='Simulation3DEngine';
                    self.Sim3dSetGetHandle([ModelName,'/StartEventListenerHandle'],self.StartEventListenerHandle);
                    self.Sim3dSetGetHandle([ModelName,'/PauseEventListenerHandle'],self.PauseEventListenerHandle);
                    self.Sim3dSetGetHandle([ModelName,'/ContinueEventListenerHandle'],self.ContinueEventListenerHandle);
                    self.Sim3dSetGetHandle([ModelName,'/StopEventListenerHandle'],self.StopEventListenerHandle);
                    self.Sim3dSetGetHandle([ModelName,'/EngineTimer'],self.EngineTimer);
                    self.Sim3dSetGetHandle([ModelName,'/WeatherConfig'],self.WeatherConfigWriter);
                end
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.ProjectName=s.ProjectName;
            self.OpenDRIVEName=s.OpenDRIVEName;
            self.EnableWindow=s.EnableWindow;
            self.SceneDesc=s.SceneDesc;
            self.ProjectFormat=s.ProjectFormat;
            self.Project=s.Project;
            self.State=s.State;
            self.SampleTime=s.SampleTime;
            self.WeatherConfigParas=s.WeatherConfigParas;
            self.EnableWeather=s.EnableWeather;
            self.EnableRemoteAccess=s.EnableRemoteAccess;
            self.EnableOpenDRIVE=s.EnableOpenDRIVE;
            self.LastWeatherConfigParas=s.LastWeatherConfigParas;

            if self.loadflag

                ModelName='Simulation3DEngine';
                self.Reader=self.Sim3dSetGetHandle([ModelName,'/Reader']);
                self.Writer=self.Sim3dSetGetHandle([ModelName,'/Writer']);
                self.WeatherConfigWriter=self.Sim3dSetGetHandle([ModelName,'/WeatherConfig']);
                self.StartEventListenerHandle=self.Sim3dSetGetHandle([ModelName,'/StartEventListenerHandle']);
                self.PauseEventListenerHandle=self.Sim3dSetGetHandle([ModelName,'/PauseEventListenerHandle']);
                self.ContinueEventListenerHandle=self.Sim3dSetGetHandle([ModelName,'/ContinueEventListenerHandle']);
                self.StopEventListenerHandle=self.Sim3dSetGetHandle([ModelName,'/StopEventListenerHandle']);
                self.EngineTimer=self.Sim3dSetGetHandle([ModelName,'/EngineTimer']);
            else

                self.Reader=s.Reader;
                self.Writer=s.Writer;
                self.WeatherConfigWriter=s.WeatherConfigWriter;
                self.StartEventListenerHandle=s.StartEventListenerHandle;
                self.PauseEventListenerHandle=s.PauseEventListenerHandle;
                self.ContinueEventListenerHandle=s.ContinueEventListenerHandle;
                self.StopEventListenerHandle=s.StopEventListenerHandle;
                self.EngineTimer=s.EngineTimer;
            end


            loadObjectImpl@matlab.System(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@matlab.System(self);

            s.Reader=self.Reader;
            s.Writer=self.Writer;
            s.WeatherConfigWriter=self.WeatherConfigWriter;
            s.StartEventListenerHandle=self.StartEventListenerHandle;
            s.PauseEventListenerHandle=self.PauseEventListenerHandle;
            s.ContinueEventListenerHandle=self.ContinueEventListenerHandle;
            s.StopEventListenerHandle=self.StopEventListenerHandle;
            s.EngineTimer=self.EngineTimer;
            s.OpenDRIVEName=self.OpenDRIVEName;
            s.ProjectName=self.ProjectName;
            s.EnableWindow=self.EnableWindow;
            s.SceneDesc=self.SceneDesc;
            s.ProjectFormat=self.ProjectFormat;
            s.Project=self.Project;
            s.State=self.State;
            s.SampleTime=self.SampleTime;
            s.WeatherConfigParas=self.WeatherConfigParas;
            s.EnableWeather=self.EnableWeather;
            s.EnableRemoteAccess=self.EnableRemoteAccess;
            s.EnableOpenDRIVE=self.EnableOpenDRIVE;
            s.WeatherConfigWriter=self.WeatherConfigWriter;
            s.LastWeatherConfigParas=self.LastWeatherConfigParas;
        end


        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.EngineTimer)
                    stop(self.EngineTimer);
                end
                simulationStatus=get_param(bdroot,'SimulationStatus');
                if strcmp(simulationStatus,'initializing')
                    self.Project.start();
                    self.Reader=sim3d.io.CommandReader();
                    self.Reader.setTimeout(Simulation3DEngine.COMMAND_READ_TIMEOUT);
                    self.Writer=sim3d.io.CommandWriter();
                    self.Writer.setSampleTime(single(self.SampleTime));

                    self.writeCommand();
                    self.Reader.read();
                    self.Writer.setState(int32(sim3d.engine.EngineCommands.RUN));
                    sim3d.engine.Engine.setState(sim3d.engine.EngineCommands.RUN);
                    self.State=sim3d.engine.EngineCommands.RUN;
                    warmUpSteps=sim3d.engine.Engine.getWarmUpSteps();
                    if strcmp(self.ProjectFormat,getString(message('shared_sim3dblks:sim3dblkConfig:UnrealEditor')))
                        warmUpSteps=warmUpSteps+1;
                    end
                    for step=1:warmUpSteps
                        self.Writer.write();
                        self.Reader.read();
                    end

                    if self.loadflag
                        ModelName='Simulation3DEngine';
                        self.Sim3dSetGetHandle([ModelName,'/Writer'],self.Writer);
                        self.Sim3dSetGetHandle([ModelName,'/Reader'],self.Reader);
                    end
                else
                    if~isempty(self.Reader)
                        self.Reader.setTimeout(Simulation3DEngine.COMMAND_READ_TIMEOUT);
                    end
                end
            end
        end

        function[state,sampleTime]=stepImpl(self)
            state=sim3d.engine.EngineCommands.NOP;
            sampleTime=single(-1);
            if coder.target('MATLAB')
                self.writeCommand();
                if~isempty(self.Reader)
                    status=self.Reader.read();
                    state=status.state;
                    sampleTime=status.sampleTime;
                    simulationCommand=self.sim3DEngineStatus2SimulinkCommand(status.state);
                    if~isempty(simulationCommand)
                        set_param(bdroot,'SimulationCommand',simulationCommand),
                    end
                end

                if self.EnableWeather
                    if~isequal(self.LastWeatherConfigParas,self.WeatherConfigParas)
                        self.WeatherConfigWriter.step(self.WeatherConfigParas,true);
                        self.LastWeatherConfigParas=self.WeatherConfigParas;
                    else
                        self.WeatherConfigWriter.step(self.WeatherConfigParas,false);
                    end
                end
            end
        end

        function releaseImpl(self)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            if coder.target('MATLAB')
                if strcmp(simulationStatus,'terminating')||strcmp(simulationStatus,'stopped')
                    if~isempty(self.Writer)

                        pause(0.5);
                        self.Writer.setState(int32(sim3d.engine.EngineCommands.STOP));
                        try
                            self.Writer.write();


                            pause(0.5);
                        catch

                        end
                        self.Writer.delete();
                        self.Writer=[];
                    end
                    if~isempty(self.Reader)
                        self.Reader.delete();
                        self.Reader=[];
                    end

                    if~isempty(self.WeatherConfigWriter)
                        self.WeatherConfigWriter.delete();
                        self.WeatherConfigWriter=[];
                    end

                    if~isempty(self.StartEventListenerHandle)
                        delete(self.StartEventListenerHandle);
                        self.StartEventListenerHandle=[];
                    end
                    if~isempty(self.PauseEventListenerHandle)
                        delete(self.PauseEventListenerHandle);
                        self.PauseEventListenerHandle=[];
                    end
                    if~isempty(self.ContinueEventListenerHandle)
                        delete(self.ContinueEventListenerHandle);
                        self.ContinueEventListenerHandle=[];
                    end
                    if~isempty(self.StopEventListenerHandle)
                        delete(self.StopEventListenerHandle);
                        self.StopEventListenerHandle=[];
                    end
                    if~isempty(self.EngineTimer)
                        stop(self.EngineTimer);
                        delete(self.EngineTimer);
                        self.EngineTimer=[];
                    end
                    if self.State==sim3d.engine.EngineCommands.RUN
                        sim3d.engine.Engine.setState(sim3d.engine.EngineCommands.STOP);
                        pause(self.SampleTime);
                        self.State=sim3d.engine.EngineCommands.STOP;
                    end
                    if~isempty(self.Project)
                        self.Project.delete();
                        self.Project=[];
                    end

                    if self.loadflag
                        ModelName='Simulation3DEngine';
                        self.Sim3dSetGetHandle([ModelName,'/StartEventListenerHandle'],[]);
                        self.Sim3dSetGetHandle([ModelName,'/PauseEventListenerHandle'],[]);
                        self.Sim3dSetGetHandle([ModelName,'/ContinueEventListenerHandle'],[]);
                        self.Sim3dSetGetHandle([ModelName,'/StopEventListenerHandle'],[]);
                        self.Sim3dSetGetHandle([ModelName,'/EngineTimer'],[]);
                        self.Sim3dSetGetHandle([ModelName,'/Writer'],[]);
                        self.Sim3dSetGetHandle([ModelName,'/Reader'],[]);
                        self.Sim3dSetGetHandle([ModelName,'/WeatherConfig'],[]);
                    end
                end
                if self.EnableRemoteAccess

                    cmd=strcat("netstat -ano | grep ",string(self.StreamerPort));
                    [~,cmdout]=system(cmd);
                    if(~isempty(cmdout))
                        processIDs=unique(str2double(regexp(cmdout,'(?<=LISTENING[^0-9]*)[0-9]*','match')));
                        arch=computer('arch');
                        switch arch
                        case 'win64'
                            for pid=1:length(processIDs)
                                cmdToKill=sprintf('taskkill /f /PID %d',processIDs(pid));
                                [~,~]=system(cmdToKill);
                            end
                        case 'glnxa64'
                            for pid=1:length(processIDs)
                                cmdToKill=sprintf('kill -9 %d',processIDs(pid));
                                [~,~]=system(cmdToKill);
                            end
                        end
                    end
                end
            end
        end

        function writeCommand(self)
            if~isempty(self.Writer)
                self.Writer.setState(self.simulinkStatus2Sim3DEngineCommand());
                self.Writer.write();
            end
        end

        function sim3DEngineCommand=simulinkStatus2Sim3DEngineCommand(~)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            switch(simulationStatus)
            case 'stopped'
            case 'terminating'
                sim3DEngineCommand=int32(sim3d.engine.EngineCommands.STOP);
            case 'initializing'
                sim3DEngineCommand=int32(sim3d.engine.EngineCommands.INITIALIZE);
            case 'running'
                sim3DEngineCommand=int32(sim3d.engine.EngineCommands.RUN);
            case 'paused'
                sim3DEngineCommand=int32(sim3d.engine.EngineCommands.PAUSE);
            otherwise

                sim3DEngineCommand=int32(sim3d.engine.EngineCommands.NOP);
            end
        end

        function simulinkCommand=sim3DEngineStatus2SimulinkCommand(~,sim3DEngineStatus)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            switch(sim3DEngineStatus)
            case int32(sim3d.engine.EngineCommands.STOP)
                simulinkCommand='stop';
            case int32(sim3d.engine.EngineCommands.INITIALIZE)
                simulinkCommand='start';
            case int32(sim3d.engine.EngineCommands.RUN)
                switch(simulationStatus)
                case 'stopped'
                    simulinkCommand='start';
                case 'paused'
                    simulinkCommand='continue';
                otherwise
                    simulinkCommand=[];
                end
            case int32(sim3d.engine.EngineCommands.PAUSE)
                simulinkCommand='pause';
            otherwise
                simulinkCommand=[];
            end
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function[sz1,sz2]=getOutputSizeImpl(~)
            sz1=[1,1];
            sz2=[1,1];
        end

        function[fz1,fz2]=isOutputFixedSizeImpl(~)
            fz1=true;
            fz2=true;
        end

        function[dt1,dt2]=getOutputDataTypeImpl(~)
            dt1='int32';
            dt2='single';
        end

        function[cp1,cp2]=isOutputComplexImpl(~)
            cp1=false;
            cp2=false;
        end

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header(...
            'Title','3D Simulation Setup');
        end

        function groups=getPropertyGroupsImpl
            projectSelectionParams=matlab.system.display.Section(...
            'Title','Project Selection',...
            'PropertyList',{'ProjectName','SceneDesc','OpenDRIVEName','EnableOpenDRIVE','ProjectFormat','EnableWeather','WeatherConfigParas','EnableWindow','EnableRemoteAccess'});
            params=matlab.system.display.Section(...
            'Title','',...
            'PropertyList',{'SampleTime'});
            groups=[projectSelectionParams,params];
        end

        function simMode=getSimulateUsingImpl
            simMode='Interpreted execution';
        end
    end

    methods(Hidden)
        function onStartEvent(~,~,~)
        end

        function onPauseEvent(self,src,eventData)%#ok
            if~isempty(self.Writer)
                self.Writer.setState(int32(sim3d.engine.EngineCommands.PAUSE));
                try
                    self.Writer.write();
                catch

                end
            end
            if~isempty(self.Reader)

                self.Reader.setTimeout(int32(0));
            end
            if~isempty(self.EngineTimer)&&strcmp(self.EngineTimer.Running,'off')
                start(self.EngineTimer);
            end
        end

        function onContinueEvent(self,src,eventData)%#ok
            self.Reader.setTimeout(Simulation3DEngine.COMMAND_READ_TIMEOUT);
            stop(self.EngineTimer);
        end

        function onStopEvent(self,~,~)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            if strcmp(simulationStatus,'running')
                if~isempty(self.Writer)
                    self.Writer.setState(int32(sim3d.engine.EngineCommands.PAUSE));
                    try
                        self.Writer.write();


                        pause(0.5);
                    catch

                    end
                end

                self.Reader.setTimeout(int32(0));
                start(self.EngineTimer);
            else
                self.releaseImpl();
            end
        end

        function onTimerEvent(self,src,eventData)%#ok
            if~isempty(self.Reader)
                [status,result]=self.Reader.read(false);
                if result==sim3d.engine.EngineReturnCode.OK

                    simulationCommand=self.sim3DEngineStatus2SimulinkCommand(status.state);
                    if~isempty(simulationCommand)
                        set_param(bdroot,'SimulationCommand',simulationCommand),
                    end
                elseif result==sim3d.engine.EngineReturnCode.Precondition_Not_Met

                    set_param(bdroot,'SimulationCommand','stop'),
                    if strcmp(get_param(bdroot,'FastRestart'),'on')
                        set_param(bdroot,'FastRestart','off');
                    end
                end
            end
        end
    end

    methods(Static,Hidden)
        function sampleTime=getEngineSampleTime(varargin)
            sampleTime=[];
            userSpecifiedSampleTime=varargin{1};
            if nargin>1
                block=varargin{2};
            else
                block=gcb;
            end
            modelWorkspace=get_param(bdroot(block),'ModelWorkspace');
            if~isempty(modelWorkspace)
                if modelWorkspace.hasVariable('SampleTime')
                    if userSpecifiedSampleTime==-1
                        sampleTime=modelWorkspace.getVariable('SampleTime');
                    else
                        sampleTime=userSpecifiedSampleTime;
                    end
                end
            else
            end
            if isempty(sampleTime)
                sim3dEngine=Simulation3DEngine.getEngineBlocks(block);
                if~isempty(sim3dEngine)
                    if length(sim3dEngine)==1
                        if userSpecifiedSampleTime==-1
                            paramStruct=autoblkscheckparams(sim3dEngine{1},{'Ts',[1,1],{'gte',Simulation3DEngine.MIN_SAMPLE_TIME}});
                            sampleTime=paramStruct.Ts;
                        else
                            sampleTime=userSpecifiedSampleTime;
                        end
                    end
                end
            end
        end

        function sim3dEngine=getEngineBlocks(block)
            libraryBlock='sim3dlib/Simulation 3D Scene Configuration';


            sim3dEngine=find_system(bdroot(block),'LookUnderMasks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on','ReferenceBlock',libraryBlock);

            missingBlock=libraryBlock;

            try
                mask=get_param(block,'Parent');
                amode=get_param(mask,'aMode');
                if strcmp(amode,'0')
                    missingBlock='aerolibsim3d/Simulation 3D Scene Configuration';
                elseif strcmp(amode,'4')
                    missingBlock='uavsim3dlib/Simulation 3D Scene Configuration';
                end
            catch

            end
            if~isempty(sim3dEngine)
                sim3dEngineCount=length(sim3dEngine);
                if sim3dEngineCount>1
                    error(message('shared_sim3dblks:sim3dblkConfig:MoreThanOneEngineBlock',missingBlock));
                end
            else
                error(message('shared_sim3dblks:sim3dblkConfig:NoEngineBlock',block,missingBlock));
            end
        end
    end
end
