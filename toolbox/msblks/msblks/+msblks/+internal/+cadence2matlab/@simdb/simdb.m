classdef simdb<handle





    properties(Access=public)
simdbResultspath
simdbLocation
simdbHistory

    end

    methods

        function obj=simdb(varargin)

            narginchk(0,3)

            if nargin==0
                warning('Need at least 3 Input arguements for a simdb object');

            elseif nargin>=3
                    obj.simdbResultspath=varargin{1};
                    obj.simdbLocation=varargin{2};
                    obj.simdbHistory=varargin{3};

                end
            end
        end
    end
end

