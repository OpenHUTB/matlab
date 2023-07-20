classdef Env




    properties(Constant=true,Access=private)
        archPathMap=containers.Map({'win64','glnxa64','maci64'},{...
        fullfile("UE4","WindowsNoEditor","VehicleSimulation.exe"),...
        fullfile("UE4","LinuxNoEditor","AutoVrtlEnv.sh"),...
        []});
    end

    methods(Hidden)


        function self=Env()
        end
    end

    methods(Static)
        function path=ProjectRoot()
            path=fullfile(matlabroot,"toolbox","shared","sim3d_projects");
        end

        function path=AutomotiveRoot()
            path=fullfile(sim3d.engine.Env.ProjectRoot(),"automotive_project");
        end

        function path=AutomotiveExe()
            if ispref("Simulation3D","UnrealPath")
                path=getpref("Simulation3D","UnrealPath");
                return
            end

            archPath=sim3d.engine.Env.archPathMap(computer('arch'));
            if isempty(archPath)
                notSupportedPlatformException=MException('sim3D:Engine:setup:PlatformException',...
                ['3D simulation engine interface is not supported on the ',...
                computer('arch'),' platform.']);
                throw(notSupportedPlatformException);
            end
            path=fullfile(sim3d.engine.Env.AutomotiveRoot(),archPath);
        end
    end
end
