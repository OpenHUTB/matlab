

classdef sshDownload<matlabshared.internal.LinuxSystemInterface

    properties(SetAccess=private)
        RemoteDir='';
        Executable='';
    end

    properties
Ssh
    end

    methods
        function obj=sshDownload(executable,hostname,username,password,remotedir,varargin)
            narginchk(5,6);

            obj.Ssh=matlabshared.internal.ssh2client(hostname,username,password,varargin{1});
            obj.RemoteDir=remotedir;
            exeObject=linkfoundation.util.Executable(fullfile(executable));
            assert(exeObject.exists,...
            DAStudio.message('ERRORHANDLER:utils:FileNotFound',exeObject.FullPathName));
            obj.Executable=exeObject;
        end

        function set.RemoteDir(obj,location)
            try
                obj.system(['ls -al ',location]);
            catch
                try

                    obj.system(['mkdir -p ',location]);
                catch
                    DAStudio.message('ERRORHANDLER:utils:RemoteDirNotFound',location)
                end

            end
            obj.RemoteDir=location;
        end

        function set.Executable(obj,location)
            obj.Executable=location;
        end

        function status=download(obj)
            disp(DAStudio.message('ERRORHANDLER:utils:RemoteKillProcessMsg',obj.Executable.FileName));
            obj.killExecutable();
            obj.putFile(obj.Executable.FullPathName,obj.RemoteDir);

            remoteLocation=[obj.RemoteDir,'/',obj.Executable.FileName];
            status=obj.system(['chmod go+x ',remoteLocation]);
        end

        function status=launch(obj)
            obj.killExecutable();
            disp(DAStudio.message('ERRORHANDLER:utils:RemoteExeLaunchMsg',obj.Executable.FileName));
            remoteLocation=[obj.RemoteDir,'/',obj.Executable.FileName];
            status=obj.system(remoteLocation);
            if(status~=0)
                error(message('ERRORHANDLER:utils:SSHError',msg));
            end
            status=false;
        end

        function killExecutable(obj)
            try
                obj.system(['killall ',obj.Executable.FileName]);
            catch
            end
        end

        function ret=isExecutableRunning(obj)
            cmd=['pidof ',obj.Executable.FileName];
            [~,~,status]=execute(obj.Ssh,cmd,false);
            ret=status==0;
        end

    end
end


