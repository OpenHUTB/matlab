classdef CallSite<coder.Location














































    properties(SetAccess={?coder.ScreenerInfo})
        CalleeName(1,:)char='';
        File(1,1)coder.File;
    end

    methods(Access={?coder.ScreenerInfo})
        function obj=CallSite(calleeName,file,varargin)


            obj@coder.Location(varargin{:});
            if nargin==0
                return;
            end
            if nargin~=2
                narginchk(8,8);
            end
            obj.CalleeName=calleeName;
            obj.File=file;
        end
    end
end
