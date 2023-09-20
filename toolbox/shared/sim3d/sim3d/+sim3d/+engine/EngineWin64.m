% Win64平台的虚幻引擎类
classdef EngineWin64<sim3d.engine.EngineInterface

    methods

        function self=EngineWin64()
            self.EngineLastError = sim3d.engine.EngineReturnCode.OK;  % 构建完虚幻引擎类将其状态设置为成功
            setenv(sim3d.engine.EngineInterface.environmentVariableMatlabRoot, matlabroot);
        end


        function delete(self)
            self.stop();
        end


        % 启动虚幻引擎工程
        function retcode = startProject(self, command)
            retcode = sim3d.engine.EngineReturnCode.Error;
            % 配置运行虚幻引擎exe时的信息，包括启动的参数
            game = sim3d.engine.EngineWin64.makeProcess(command.FileName, command.Arguments);
            status = game.Start();  % 使用 .NET 的 System.Diagnostics.Process 对象启动虚幻引擎的exe

            if status == 1
                retcode = self.checkRunning(game);
            end
        end
    end


    methods(Access=private,Hidden=true)

        % 检查进程process是否在运行
        function retcode = checkRunning(self, process)
            retcode = sim3d.engine.EngineReturnCode.Timeout;
            for i = 1 : self.ProjectTimeout_sec
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

        % 设置程序启动的参数信息
        function process = makeProcess(FileName, Arguments)
            % .NET 文档：https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process?view=net-7.0
            process = System.Diagnostics.Process(); % https://ww2.mathworks.cn/help/releases/R2022b/matlab/matlab_external/an-assembly-is-a-library-of-net-classes.html
            process.StartInfo.FileName = FileName;    % 虚幻引擎可执行文件的文件名
            process.StartInfo.Arguments = Arguments;  % 获取启动应用程序时要使用的命令行参数的集合。添加到列表中的字符串不需要预先转义。
            process.StartInfo.UseShellExecute = false;  % 指定是否使用操作系统 shell 启动进程。如果UseShellExecute设置为false，则新进程将继承调用进程的标准输入、标准输出和标准错误流
            % EnvironmentVariables：获取文件的搜索路径、临时文件的目录、应用程序特定的选项和其他类似信息。
            process.StartInfo.EnvironmentVariables.Remove("PATH");
            process.StartInfo.EnvironmentVariables.Add("PATH",...
                fullfile(matlabroot,"bin","win64") + ";" + getenv("PATH") ...
            );
        end
    end
end

