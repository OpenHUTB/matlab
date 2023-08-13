classdef EngineGlnxa64<sim3d.engine.EngineInterface

    methods
        function self=EngineGlnxa64()
            self.EngineLastError=sim3d.engine.EngineReturnCode.OK;
            self.EnginePid=uint32(feature('getpid'));
        end
        function delete(self)
            self.stop();
        end
        function retcode=startProject(self,project)
            retcode=sim3d.engine.EngineReturnCode.Error;
            projcommand=strcat(project.FileName," ",project.Arguments);
            [status,~]=system(strcat(projcommand," &"));
            if status==0
                retcode=self.checkRunning(project);
            end
        end
    end
    methods(Access=private,Hidden=true)
        function retcode=checkRunning(self,project)
            retcode=sim3d.engine.EngineReturnCode.Timeout;
            projcommand=strcat(project.FileName," ",project.Arguments);
            command="ps -fww";
            palt=deblank(replace(projcommand,"""",""));
            for i=1:self.ProjectTimeout_sec
                pause(1);
                [status,cmdout]=system(command);
                if status~=0
                    retcode=sim3d.engine.EngineReturnCode.Error;
                    break;
                elseif contains(cmdout,palt)
                    retcode=sim3d.engine.EngineReturnCode.OK;
                    break;
                end
            end
        end
    end
end
