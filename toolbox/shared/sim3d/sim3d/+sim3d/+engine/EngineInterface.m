classdef EngineInterface<handle
    properties(Access=protected,Hidden=true)
        EnginePid=uint32(0);
        EngineLastError=[];
        ReadyTimeoutEditor_sec=int32(180);
        ReadyTimeout_sec=int32(30);
        ProjectTimeout_sec=60;
        IsRunning=false;
    end


    properties(Constant)
        environmentVariableMatlabPID = 'mw_matlab_pid_for_unreal';
        environmentVariableMatlabRoot = "MATLABROOT";
    end


    methods(Abstract)
        retcode=startProject(self,project)
    end


    methods(Hidden=true)

        function this=EngineInterface()
            this.EnginePid=uint32(feature('getpid'));
        end


        function ready=isReady(self,timeout_sec)
            status=IsSimulation3DInterfaceReady(timeout_sec);
            ready=(status==sim3d.engine.EngineReturnCode.OK)&&...
            ~isempty(self.EngineLastError)&&...
            (self.EngineLastError==sim3d.engine.EngineReturnCode.OK);
        end


        function start(self)
            if ~self.IsRunning
                LogSimulation3DInterfaceTraffic(sim3d.engine.Engine.getDebugLevel() > 0);
                setenv(sim3d.engine.EngineInterface.environmentVariableMatlabPID, num2str(self.EnginePid));
                self.EngineLastError = StartSimulation3DInterface(self.EnginePid);
                self.IsRunning = self.EngineLastError==sim3d.engine.EngineReturnCode.OK;
            end
        end


        function restart(self)
            self.stop();
            self.start();
        end


        function stop(self)
            if self.IsRunning
                self.EngineLastError=ShutdownSimulation3DInterface();
                self.checkReturnCode();

                self.IsRunning=false;
                setenv(sim3d.engine.EngineInterface.environmentVariableMatlabPID);
                self.EngineLastError=sim3d.engine.EngineReturnCode.OK;
                sim3d.engine.Engine.setState(sim3d.engine.EngineCommands.STOP);
                LogSimulation3DInterfaceTraffic(false);
            end
        end


        % 开始仿真（弹出黑色虚幻引擎界面）
        function startSimulation(self, project)
            if ~isempty(project) && ~strcmp(project,sim3d.World.Undefined)
                retcode = self.startProject(project);  % 启动exe
                if retcode == sim3d.engine.EngineReturnCode.Timeout
                    error(message('shared_sim3d:sim3dEngine:StartTimeoutError'));
                elseif retcode == sim3d.engine.EngineReturnCode.OK
                    self.EngineLastError = StartSimulation3DInterface(self.EnginePid);  % built-in
                else
                    error(message('shared_sim3d:sim3dEngine:StartError'));
                end
                timeout=self.ReadyTimeout_sec;
            else
                disp('In the Simulation 3D Scene Configuration block, you set the scene source to ''Unreal Editor''.');
                disp('In Unreal Editor, select ''Play'' to view the scene.');
                self.EngineLastError = StartSimulation3DInterface(self.EnginePid);
                timeout=self.ReadyTimeoutEditor_sec;
            end
            self.checkReturnCode();
            if~self.isReady(timeout)
                error(message('shared_sim3d:sim3dEngine:CommunicationSetupError'));
            end
        end
    end


    methods(Access=protected)

        function checkReturnCode(self)
            switch self.EngineLastError
            case sim3d.engine.EngineReturnCode.OK

            case sim3d.engine.EngineReturnCode.Precondition_Not_Met
                error(message('shared_sim3d:sim3dEngine:UnexpectedProcessTerminationError'));
            otherwise
                errorMessage=message('shared_sim3d:sim3dEngine:InterfaceError');
                error(errorMessage.getString(),self.EngineLastError);
            end
        end
    end
end

