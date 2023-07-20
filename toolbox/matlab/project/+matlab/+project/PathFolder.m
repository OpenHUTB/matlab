classdef PathFolder<matlab.project.FolderReference
















    methods(Access=public,Hidden=true)
        function obj=PathFolder(varargin)

            obj=obj@matlab.project.FolderReference(varargin{:});

            if(nargin~=0&&numel(varargin{1})==0)
                obj=matlab.project.PathFolder.empty(1,0);
                return;
            end

        end
    end
end


