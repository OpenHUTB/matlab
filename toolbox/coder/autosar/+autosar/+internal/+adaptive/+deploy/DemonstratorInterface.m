classdef DemonstratorInterface<matlabshared.internal.LinuxSystemInterface





    properties(Access=public)
        Ssh;
    end

    methods(Access=public)
        function obj=DemonstratorInterface(Ssh)
            obj.Ssh=Ssh;
        end
    end

    methods(Static)
        function uploadArchive(demoInterface,archiveFile,modelName)

            remoteCodeDir=['/tmp/mathworks/',modelName];
            demoInterface.system(sprintf('rm -rf ''%s''',remoteCodeDir));
            demoInterface.system(['mkdir -p ',remoteCodeDir]);


            demoInterface.putFile(archiveFile,remoteCodeDir);
            demoInterface.system(sprintf('cd ''%s'' && unzip ''%s''',remoteCodeDir,archiveFile));
            demoInterface.system(sprintf('rm ''%s''',archiveFile));
        end

        function uploadBuildScript(demointerface,modelName)

            remoteCodeDir=['/tmp/mathworks/',modelName];
            shellscript=fullfile(string(autosarroot),"adaptive","autosarorg_build_model.sh");
            demointerface.putFile(shellscript.char,remoteCodeDir);
        end

        function build(demointerface,demonstratorConfig,modelName)
            remoteCodeDir=['/tmp/mathworks/',modelName];
            buildcommand=sprintf('bash %s/autosarorg_build_model.sh %s %s %s %s',...
            remoteCodeDir,demonstratorConfig.YoctoDir,...
            remoteCodeDir,modelName,demonstratorConfig.Image);
            fprintf("exec: %s\n",buildcommand);
            output=...
            demointerface.system(buildcommand);
            fprintf("%s\n",output);
        end

        function startModel(demointerface,modelName)
            demointerface.system(sprintf('mkdir -p /tmp/%s && cd /tmp/%s && nohup /usr/bin/%s &',...
            modelName,modelName,modelName));
        end

        function stopModel(demointerface,modelName)
            try
                demointerface.system(sprintf('killall -q %s',modelName));
            catch
            end
        end

        function uploadCMakeLists(demointerface,modelName)
            remoteCodeDir=['/tmp/mathworks/',modelName];
            demointerface.putFile('CMakeLists.txt',remoteCodeDir);
        end
        function result=sshValidate(sshClient)
            output=sshClient.execute('echo Success');
            result=strncmp('Success',output,length('Success'));
        end
    end
end


