classdef EngineWin64<sim3d.engine.EngineInterface

    methods

        function self=EngineWin64()
            self.EngineLastError=sim3d.engine.EngineReturnCode.OK;
            setenv(sim3d.engine.EngineInterface.environmentVariableMatlabRoot,matlabroot);
        end


        function delete(self)
            self.stop();
        end


        function retcode=startProject(self,command)
            retcode=sim3d.engine.EngineReturnCode.Error;
            game=sim3d.engine.EngineWin64.makeProcess(command.FileName,command.Arguments);
            status=game.Start();

            if status==1
                retcode=self.checkRunning(game);
            end
        end
    end


    methods(Access=private,Hidden=true)

        function retcode=checkRunning(self,process)
            retcode=sim3d.engine.EngineReturnCode.Timeout;
            for i=1:self.ProjectTimeout_sec
                pause(1);
                if process.HasExited~=0
                    if process.ExitCode==-1073741515
                        retcode=sim3d.engine.EngineReturnCode.EntryPointNotFound;
                    else
                        retcode=sim3d.engine.EngineReturnCode.Error;
                    end
                    break;
                elseif process.Responding==1
                    retcode=sim3d.engine.EngineReturnCode.OK;
                    break;
                end
            end
        end
    end


    methods(Static=true)

        function process=makeProcess(FileName,Arguments)
            process=System.Diagnostics.Process();
            process.StartInfo.FileName=FileName;
            process.StartInfo.Arguments=Arguments;
            process.StartInfo.UseShellExecute=false;
            process.StartInfo.EnvironmentVariables.Remove("PATH");
            process.StartInfo.EnvironmentVariables.Add("PATH",...
            fullfile(matlabroot,"bin","win64")+";"+getenv("PATH"));
        end
    end
end

