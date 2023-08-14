classdef DemonstratorProjectTool<coder.make.ProjectTool





    properties
BuildInfo
FileWriter
    end

    methods(Access=public)
        function obj=DemonstratorProjectTool(~)
            obj@coder.make.ProjectTool('AUTOSAR Demonstrator CMake');
        end

        function setFileWriter(h,fileWriter)
            h.FileWriter=fileWriter;
        end

        function[ret,context]=initialize(h,~,context,varargin)
            ret=true;
            context.val=true;
            if isempty(h.FileWriter)
                h.FileWriter=autosar.internal.adaptive.deploy.FileWriter('CMakeLists.txt');
            end
        end

        function[ret,context]=createProject(h,buildInfo,context,varargin)
            narginchk(6,inf);
            toolchain=varargin{1};
            type=varargin{2};
            comp=varargin{3};
            validateattributes(buildInfo,{'RTW.BuildInfo'},{'nonempty'});
            validateattributes(context,{'struct'},{'nonempty'});
            validateattributes(toolchain,{'coder.make.ToolchainInfo'},{'nonempty'});
            validateattributes(type,{'coder.make.enum.BuildOutput'},{'nonempty'});
            validateattributes(comp,{'struct'},{'nonempty'});

            ret=buildInfo.ModelName;

            appName=string(buildInfo.ModelName);

            assert(~isempty(buildInfo.Src.Files));
            cppSources=autosar.internal.adaptive.deploy.normalizeFilenamesForCMake(buildInfo.getSourceFiles(true,true));

            otherFiles=autosar.internal.adaptive.deploy.normalizeFilenamesForCMake(buildInfo.getNonBuildFiles(true,true));
            arxmlFiles=otherFiles(otherFiles.endsWith(".arxml"));

            includedirs=autosar.internal.adaptive.deploy.normalizeFilenamesForCMake(buildInfo.getIncludePaths(true));

            autosar.internal.adaptive.deploy.write_cmake(h.FileWriter,appName,...
            appName,'Release',cppSources,arxmlFiles,includedirs,...
            '');
        end

        function[ret,context]=buildProject(~,~,context,varargin)
            ret='Success';
        end

        function[ret,context]=downloadProject(~,~,context,varargin)
            ret=true;
        end

        function[ret,context]=runProject(~,~,context,varargin)
            ret=true;
        end

        function[ret,context]=onError(~,~,context,varargin)
            ret=true;
        end

        function[ret,context]=terminate(~,~,context,varargin)
            ret=true;
        end
    end
end


