classdef PathFolder<slproject.FolderReference



















    methods(Access=public,Hidden=true)
        function obj=PathFolder(varargin)

            obj=obj@slproject.FolderReference(varargin{:});

            if(nargin~=0&&numel(varargin{1})==0)
                obj=slproject.PathFolder.empty(1,0);
                return;
            end

        end
    end
end


