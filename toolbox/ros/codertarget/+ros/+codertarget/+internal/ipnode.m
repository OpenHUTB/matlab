classdef ipnode < handle
%This class is for internal use only. It may be removed in the future.

%DEVADDRESS Hostname container.
%
% obj = devaddress(hostname, username, password)


% Copyright 2013-2018 The MathWorks, Inc.

    properties (Access = public)
        Hostname
        Port
    end

    methods
        function obj = ipnode(hostname, port)
        % Constructor
            narginchk(1, 2);
            obj.Hostname = hostname;
            if (nargin > 1)
                obj.Port = port;
            end
        end
    end

    methods
        function set.Hostname(obj, value)
            validateattributes(value, {'char'}, {'nonempty', 'row'}, '', 'hostname');
            obj.Hostname = strtrim(value);
        end

        function set.Port(obj, value)
            validateattributes(value, {'numeric'}, ...
                               {'>=',  1, '<=',  65535, 'scalar', 'nonnegative'}, ....
                               '', 'port')
            obj.Port = uint16(value);
        end
    end
end % classdef

%[EOF]
