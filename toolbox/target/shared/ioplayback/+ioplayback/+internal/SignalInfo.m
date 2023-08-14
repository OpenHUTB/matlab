classdef SignalInfo<handle


%#codegen
    properties
        Name=''
        Dimensions=[1,1]
        DataType=''
        IsComplex=''
    end
    methods
        function obj=SignalInfo(varargin)
            coder.allowpcode('plain');

            obj.pvParse(varargin{:});
        end
        function setProperties(obj,varargin)
            pvParse(obj,varargin{:});
        end
    end
    methods(Access=protected)
        function pvParse(obj,varargin)
            if nargin>1
                if~isempty(varargin)
                    if rem(length(varargin),2)
                        matlab.system.internal.error('ioplayback:general:invalidPVPairs');
                    end


                    for ii=1:2:numel(varargin)
                        obj.(varargin{ii})=varargin{ii+1};
                    end
                end
            end
        end
    end
end
