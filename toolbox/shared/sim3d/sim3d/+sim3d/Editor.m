classdef Editor








    properties(SetAccess='private',GetAccess='public')
        Uproject string{mustBeNonempty}=fullfile(matlabroot,...
        "toolbox","shared","sim3d","sim3d","internal","sim3dtemplates",...
        "AutoVrtlEnv","AutoVrtlEnv.uproject");
    end

    methods
        function self=Editor(uproject)



            self.Uproject=uproject;
        end

        function[status,result]=open(self)




            sim3d.engine.Engine.restart();
            command=sprintf("start ""UE4"" /b ""%s""",self.Uproject);
            [status,result]=system(command);
        end
    end
    methods(Static)
        function enableExternalMode()





            sim3d.engine.Engine.restart();
            platform=computer('arch');

            if strcmp(platform,'win64')

                System.Environment.SetEnvironmentVariable(...
                sim3d.engine.EngineInterface.environmentVariableMatlabRoot,...
                matlabroot,System.EnvironmentVariableTarget.User);
                System.Environment.SetEnvironmentVariable(...
                sim3d.engine.EngineInterface.environmentVariableMatlabPID,...
                num2str(uint32(feature('getpid'))),...
                System.EnvironmentVariableTarget.User);
                path=char(System.Environment.GetEnvironmentVariable('PATH',...
                System.EnvironmentVariableTarget.User));
                path=[path,';',fullfile(matlabroot,'bin','win64')];
                System.Environment.SetEnvironmentVariable('PATH',...
                path,System.EnvironmentVariableTarget.User);
            else

                system('gnome-terminal & disown');
            end
        end
    end
end
