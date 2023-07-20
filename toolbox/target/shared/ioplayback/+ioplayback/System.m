classdef System<matlab.System



%#codegen
    properties(Nontunable)

        DatasetName=''

        SourceName=''
    end

    properties(Nontunable,Hidden)

        NumberOfDataPoints=0
    end

    properties(Nontunable,Hidden)
        DeviceType=''
        DataFile=''
Reader
Writer
    end

    properties(Access=protected)
Src
    end

    methods

        function obj=System(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end
end

