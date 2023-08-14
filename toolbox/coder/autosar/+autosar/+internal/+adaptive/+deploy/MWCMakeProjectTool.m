classdef MWCMakeProjectTool<coder.make.ProjectTool




    properties
BuildInfo
    end

    methods(Access=public)
        function obj=MWCMakeProjectTool(~)
            obj@coder.make.ProjectTool('AUTOSAR Adaptive Linux Executable');
        end

        function[ret,context]=initialize(~,~,context,varargin)


            ret=true;
            context.val=true;
        end

        function[ret,context]=createProject(~,buildInfo,context,varargin)
            narginchk(6,inf);
            validateattributes(buildInfo,{'RTW.BuildInfo'},{'nonempty'});
            ret=buildInfo.ModelName;
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


