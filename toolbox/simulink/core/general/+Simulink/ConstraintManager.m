










classdef ConstraintManager<handle

    methods(Static)
        function open(varargin)

            narginchk(0,1);


            if nargin==0
                constraint_manager('Create');
            else
                constraint_manager('Create',varargin{1});
            end
        end
    end
end

